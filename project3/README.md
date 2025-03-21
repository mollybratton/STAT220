Portfolio Project 3 Writeup
================
Molly Bratton and Audrey Moyer

- [About Our Code](#about-our-code)
- [Wrangle the Data](#wrangle-the-data)
- [Create Bar Chart](#create-bar-chart)
- [Create Time Series Plot](#create-time-series-plot)

``` r
knitr::opts_chunk$set(warning = FALSE, message = FALSE, echo = TRUE)
library(tidyverse)
library(ggplot2)
library(dplyr)
library(maps)
library(mapproj)
library(patchwork)
library(purrr)
library(scales)
```

## About Our Code

The goal of our project is to create a bar chart and a time series plot
using data from the National Centers for Environmental Information at
the National Oceanic and Atmospheric Administration. This data is
available across 44 csv files that are seperated by year. To combine all
of these datasets into one final dataset, we used a function that takes
in a path (e.g. “data/1980.csv”), and reads in that csv file, and
accounts for the fact that the “Begin Date” and “End Date” columns are a
part of the date class, and “CPI-Adjusted Cost”, “Unadjusted Cost”, and
“Deaths” are numeric. The read_disaster_data function also uses stringr
to remove the date from the parentheses. Then, we use the list.files()
function to list all of the CSV files in the data folder that end in
csv, and then use map() to go through each file in the data folder and
read the files in. We then add all of these files to one dataset using
list_rbind(), and we use write_csv() to create a final csv file with all
of the data from each year.

Now that we have the final csv file, we can read that file in using
read_csv(), and save that in the variable final_weather_data. After
that, we want to add a column that just has the year for each event, as
we want to graph the bar and time series plots using year on the x-axis.
We can then plot the bar chart, but we also add another column for the
total cost per year by grouping by year, and then mutating with
sum(`CPI-Adjusted Cost`) to get a final total cost for the combined
(adjusted) cost for each year.

## Wrangle the Data

``` r
read_disaster_data <- function(path){
  #takes a file path and correctly reads in the corresponding data
  year_data <- read_csv(path, skip = 2, col_types = cols(
    Name = col_character(),
    Disaster = readr::col_factor(),
    `Begin Date` = col_date(format = "%Y%m%d"),
    `End Date` = col_date(format = "%Y%m%d"),
    `CPI-Adjusted Cost` = col_number(),
    `Unadjusted Cost` = col_number(),
    Deaths = col_number()
  ))
  year_data$Name = str_replace(year_data$Name, " \\s*\\([^\\)]+\\)", "")
  year_data
}


# List all of the CSV files in the data folder
paths <- list.files("data", pattern = "[.]csv$", full.names = TRUE)

#Go through each file in the data folder and read the files in
new_files <- purrr::map(paths, read_disaster_data)

#Add all data to one dataset
weather_data <- purrr::list_rbind(new_files)
```

``` r
# Save the new full dataset in a separate file
write_csv(weather_data, file = "final_weather_combined_data.csv")
```

## Create Bar Chart

``` r
# Read in the full dataset from the other file
final_weather_data <- read_csv("final_weather_combined_data.csv")

#mutating to add a year column
final_weather_data <- weather_data %>%
  mutate(
    year = year(`End Date`)
  )
```

``` r
final_weather_data %>%
  ggplot() +
  geom_bar(aes(x = year, fill = Disaster)) +
  scale_color_viridis_d(option = "D", aesthetics = "fill") +
  theme_minimal() +
  labs(x = "Year", y = "Number of Events", title = "United States Billion Dollar Disaster Events, 1980-2024")
```

![](proj3_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

## Create Time Series Plot

``` r
# Add the CPI adjusted cost together for each year
final_weather_data <- final_weather_data %>%
  group_by(year) %>%
  mutate(
    total_cost = sum(`CPI-Adjusted Cost`)
  )
```

``` r
labels_y <- c("$0", "$100", "$200", "$300", "$400")

#time-series line plot
final_weather_data %>%
  ggplot() +
  geom_line(aes(x = `End Date`, y = total_cost)) +
  scale_y_continuous(labels = labels_y) +
  labs(x = "Year", y = "Cost in Billions", title = "United States Billion Dollar Disaster Cost Per Year, 1980-2024") +
  theme_minimal()
```

![](proj3_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->
