# Load packages ----------------------------------------------------------------

library(shiny)
library(tidyverse)
library(ggthemes)
library(scales)
library(countrycode)
library(bslib)
library(ggplot2)
library(dplyr)
library(maps)
library(plotly)
library(usdata)
library(mapproj)
library(leaflet)

# Load and prep data -----------------------------------------------------------

#reading in the datasets
public_schools <- read_csv("https://data-nces.opendata.arcgis.com/api/download/v1/items/6a4fa1b0434e4688b5d60c2e5c1dcaaa/csv?layers=0")

neighborhood_poverty <- read_csv("https://data-nces.opendata.arcgis.com/api/download/v1/items/10bd90462ec14a53bab1827bc8f533c9/csv?layers=1")

#joining data
schools_poverty <- public_schools %>%
  left_join(neighborhood_poverty, by = "NCESSCH")

#adding ratio of free lunch column and removing values <0
schools_poverty <- schools_poverty %>%
  group_by(STABR) %>%
  mutate(
    "state" = abbr2state(STABR)
  ) %>%
  filter(TOTAL > 0) %>%
  filter(TOTFRL >= 0) %>%
  mutate(
    "Ratio_of_Free_Lunches" = (TOTFRL)/TOTAL
  ) %>%
  filter(Ratio_of_Free_Lunches <= 1) 

#adding our variables
s_p_names <- schools_poverty %>%
  group_by(state) %>%
  summarise(
    "reduced/free_lunches" = mean(TOTFRL, na.rm = TRUE),
    "Income_Poverty_Ratio" = mean(IPR_EST, na.rm = TRUE),
    "Student_Teacher_Ratio" = mean(STUTERATIO, na.rm = TRUE),
    "Black_Student_Ratio" = mean(BL/TOTAL, na.rm = TRUE),
    "Male_To_Female_Ratio" = mean((TOTMENROL+1)/(TOTFENROL+1), na.rm = TRUE),
    "Ratio_of_Free_Lunches" = mean(((TOTFRL+1)/(TOTAL+1)), na.rm = TRUE)
  )

#making the state names lowercase for mapping
mean_data <- s_p_names
mean_data$state <- tolower(mean_data$state)

#removing Alaska and Hawaii and renaming variables
schools_48 <- schools_poverty %>%
  filter(STABR != "AK" & STABR != "HI") %>%
  mutate(
    "Income_Poverty_Ratio" = IPR_EST,
    "Student_Teacher_Ratio" = STUTERATIO, 
    "Black_Student_Ratio" = BL/TOTAL,
    "Male_To_Female_Ratio" = (TOTMENROL+1)/(TOTFENROL+1),
    "Ratio_of_Free_Lunches" = (TOTFRL+1)/(TOTAL+1)
  ) %>% select(Income_Poverty_Ratio, Student_Teacher_Ratio, Black_Student_Ratio, Male_To_Female_Ratio, Ratio_of_Free_Lunches, LAT, LON)

#removing outliers for the scatterplot
scatterplot_data <- schools_48 %>%
  filter(Student_Teacher_Ratio > 2.785) %>%
  filter(Student_Teacher_Ratio < 26.265) 

# Set up the choices for the drop-down menus
var_choice <- names(s_p_names)
var_choice <- var_choice[-c(1:2)]

state_choices <- unique(s_p_names$state)
state_choices <- state_choices[!state_choices %in% c("Alaska", "Hawaii", NA)]

# Define the pages -----------------------------------------------------------

home_page <- fluidPage(
  titlePanel("Inequality and Welfare in Public Schools"),
  "Created by: Audrey and Molly", 
  card(card_header("About Our Project"), "Welcome to our project regarding inequality and welfare in public schools in the United States. We are investigating if there are correlations between state/location, school neighborhood poverty estimate, free lunch programs, teacher to student ratio, ratio of black students, and male to female ratio."),
  card("Select different inequality/welfare variables to investigate how they are correlated within U.S. public schools:"),
  
  selectInput(inputId = "scatterplot_variable_one",
              label = "X-axis:",
              choices = var_choice),
  selectInput(inputId = "scatterplot_variable_two",
              label = "Y-axis:",
              choices = var_choice),
  plotOutput("scatterplot")
)

full_page <- fluidPage(
  
  titlePanel("Inequality and Welfare in Public Schools in the United States"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "selected_variable",
                  label = "Select a Variable:",
                  choices = var_choice)
    ),

    mainPanel(
      plotlyOutput("mean_plot"),
      plotOutput("full_plot")
    )
  )
)

state_page <- fluidPage(
  
  titlePanel("Individual States Income Poverty Estimates"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("selected_state", 
                  label = "Select a State:", 
                  choices = state_choices)
    ),
    
    mainPanel(
      plotOutput("state_plot")
    )
  )
)


leaflet_page <- fluidPage(

  titlePanel("Interactive Mapping of Inequality and Welfare in Public Schools"),
  
  sidebarLayout(
    sidebarPanel(
      "Zoom in to certain areas on the map to explore trends. Blue represents lower values, and green represents higher values"
    ),

    mainPanel(
      leafletOutput("leaflet_plot"),
      leafletOutput("leaflet_lunch")
    )
  )
)
  
# Define UI for application -----------------------------------------------------------

ui <- page_fluid(
  theme = bs_theme(version = 5, bootswatch = "minty"),
  navset_pill( 
    nav_panel("Our Project", home_page),
    nav_panel("Inequality and Welfare Maps", full_page), 
    nav_panel("Interactive Maps", leaflet_page), 
    nav_panel("Income Poverty Ratio per State", state_page), 
    nav_menu( 
      "Our Data", 
      "From the Department of Education:", 
      nav_item( 
        a("Our Poverty Data", href = "https://catalog.data.gov/dataset/school-neighborhood-poverty-estimates-2020-21", target = "_blank") 
      ), 
      nav_item( 
        a("Our School Data", href = "https://catalog.data.gov/dataset/public-school-characteristics-2022-23-451db", target = "_blank") 
      ), 
    ), 
  ), 
  id = "tab" 
)


# Define server logic for application -----------------------------------------------------------

server <- function(input, output) {
  
  states <- map_data("state")
  
  output$scatterplot <- renderPlot({
    ggplot(scatterplot_data, aes_string(x = input$scatterplot_variable_one, y = input$scatterplot_variable_two)) +
      geom_point(alpha = 0.5) +
      geom_smooth(method = "lm", se = FALSE) +
      labs(title = str_c("Scatterplot of Correlation Between ", input$scatterplot_variable_one, " And ", input$scatterplot_variable_two))
  })
    
  # State averages map
  output$mean_plot <- renderPlotly({
    mean_plotly <- mean_data %>%
      ggplot() + 
      geom_map(
        aes_string(map_id = "state", fill = input$selected_variable), map = states) +
      scale_color_viridis_c(aesthetics = "fill") +
      expand_limits(x = states$long, y = states$lat) +
      coord_map() +
      theme_map() +
      labs(title = str_c("State Averages for ", input$selected_variable)) +
      theme(legend.position = "bottom")
    ggplotly(mean_plotly)
  })

# Map with all U.S. schools  
  output$full_plot <- renderPlot({
    ggplot(states, aes(x=long, y=lat, group=group)) +  
      geom_polygon(color="black", fill="white") + 
      coord_fixed() +
      theme_map() +
      geom_point(data = schools_48, aes_string(x = "LON", y = "LAT", group = "FALSE", colour = input$selected_variable), alpha = 0.5, shape = ".") +
      expand_limits(x = states$long, y = states$lat) +
      scale_color_viridis_c() +
      theme(legend.position = "bottom") +
      labs(title = "Income Poverty Ratio for Public Schools in U.S.", color = input$selected_variable)
  })
  
# Single state map of IPR  
  output$state_plot <- renderPlot({
    
    state_schools <- schools_poverty %>%
      filter(state == input$selected_state)
    
    state_map_data <- map_data("county", region = input$selected_state)
    
    ggplot(state_map_data, aes(x=long, y=lat, group=group)) +  
      geom_polygon(color="black", fill="white") + 
      coord_fixed() +
      theme_map() +
      geom_point(data = state_schools, aes(x = LON, y = LAT, group = FALSE, color = IPR_EST), alpha = 0.5) +
      scale_color_viridis_c() +
      labs(title = str_c("Average IPR for Public Schools in ", input$selected_state), color = "Income Poverty Ratio") +
      theme(legend.position = "bottom")
  })
  
  # Leaflet Map
  output$leaflet_plot <- renderLeaflet({
    
    title <- 
    "<style>
      .custom-title {
        color: #34495e;
        text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.2);
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
        background-color: rgba(204, 224, 255, 0.9);
        padding: 6px;
        border-radius: 4px;
        transition: background-color 0.3s, box-shadow 0.3s;
    }
    .custom-title:hover {
        background-color: rgba(204, 224, 255, 0.7);
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
    }
    </style>
    <h1>
      Student Teacher Ratio
    </h1>"
    
    leaflet_data <- schools_poverty %>%
      filter(STUTERATIO > 2.785) %>%
      filter(STUTERATIO < 26.265) 
    
    colors_student_ratio <- colorNumeric(
      palette = c("#3b528b", "#5ec962"),
      domain = range(leaflet_data$STUTERATIO, na.rm = TRUE)
    )
    
    leaflet(data = leaflet_data) %>%
      addTiles() %>%
      setView(lng = -98, lat = 40, zoom = 4) %>%
      addCircles(radius = 1, popup = paste("School: ", leaflet_data$SCH_NAME, ", Student to Teacher Ratio: ", leaflet_data$STUTERATIO), color = ~colors_student_ratio(schools_poverty$STUTERATIO)) %>%
      addControl(html = title, position = "topright", className = "custom-title")
    
  })
  
  output$leaflet_lunch <- renderLeaflet({
    title <- 
      "<style>
      .custom-title {
        color: #34495e;
        text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.2);
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
        background-color: rgba(204, 224, 255, 0.9);
        padding: 6px;
        border-radius: 4px;
        transition: background-color 0.3s, box-shadow 0.3s;
    }
    .custom-title:hover {
        background-color: rgba(204, 224, 255, 0.7);
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
    }
    </style>
    <h1>
      Free/Reduced Lunch Ratio
    </h1>"
    
    colors_student_ratio <- colorNumeric(
      palette = c("#3b528b", "#5ec962"),
      domain = range(schools_poverty$Ratio_of_Free_Lunches, na.rm = TRUE)
    )
    
    leaflet(data = schools_poverty) %>%
      addTiles() %>%
      setView(lng = -98, lat = 40, zoom = 4) %>%
      addCircles(radius = 1, popup = paste("School: ", schools_poverty$SCH_NAME, ", Free/Reduced Lunch Ratio: ", schools_poverty$Ratio_of_Free_Lunches), color = ~colors_student_ratio(schools_poverty$Ratio_of_Free_Lunches)) %>%
      addControl(html = title, position = "topright", className = "custom-title")
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
