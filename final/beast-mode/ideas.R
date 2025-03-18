#         ui <- page_navbar(
#           theme = bs_theme(version = 5, bootswatch = "minty"),
#           tabPanel("Introduction", p("An app for analyzing Starwars data."),
#           tabPanel("Data", gt: gt_output("dataTable")),
#           navbarMenu("More Analyses", 
#               tabPanel("Height Analysis", plotOutput ("heightplot")),
#               tabPanel("Mass Analysis", plotOutput ("massPlot"))
#         )
