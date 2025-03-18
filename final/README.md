# final

This is your repo for the final project. You have full control over the files and organization!

## Shiny app:
https://mollybratton.shinyapps.io/Final-Project/

## Technical overview:
Our project investigates trends in equity and welfare in public schools in the continental United States. We started by joining our two datasets on school ID, as they both had school ID as a variable. Once we had our joined dataset (schools_poverty), we added a column for the proportion of students at each school who were eligible for reduced price or free lunch (number of students eligible divided by the total number of students). Some of the schools had a negative ratio, or a ratio greater than 1, so we removed these schools from our final dataset as we were unsure how a school would have negative students, or how a school would have more students eligible for reduced price or free lunch than the total number of students. We also removed all the schools with 0 students from our dataset, because these would not add to the data analysis that we wanted to conduct. We made a second dataset (s_p_names) were we grouped the data by state and then calculated the average number of students eligible for reduced or free price lunches, the average income to poverty ratio, the average student to teacher ratio, and the average black student ratio, the average male to female student ratio, and the average proportion of students eligible for reduced price or free lunch out of the total number of students for each state. The last thing we did to clean our dataset was to remove outliers. The student-to-teacher ratio variable ranged from -1 to 1860. It doesn’t make sense to have -1 students (but we dealt with this issue already by filtering out schools that had a total number of students less than or equal to 0), and it also doesn’t make much sense to have 1 teacher for 1860 students. We used the 1.5 IQR method to get rid of our outliers, and found that values less than 2.785 and greater than 26.265 were outliers. Once we removed these, it was much easier to see our data on a scatterplot. By removing these data points, we found that we had several states with missing data (), but we decided to leave these states without data, as we thought that they might have inputed it incorrectly, as it does not make sense to have less than 0 students total, or less than 0 students eligible for free lunches.

Once we had our final dataset, we created a shiny app. We defined the ui and server, and created multiple pages in the app. The home page consists of a scatterplot where the user can choose which variables they want to compare, and the graph outputs a scatterplot of the two variables with a line of best fit. The inequality and welfare maps page consists of 2 maps of the continental US, and the user can choose which variable to color by. The output map is colored by which variable is chosen, with one map being the state averages and the other showing each individual school as a point. The interactive map page has a leaflet map that the user can zoom into and click on points to investigate individual schools. Finally, the income to poverty ratio per state page allows the user to choose a state, and outputs a map of the state chosen with a point for each school, colored by income poverty ratio. 

## How to navigate our repo:
The README in our repo contains a link to our published shiny app, as well as this writeup, and our self-evaluation according to the rubric. Our data is included as .csv files in our repo, but we decided to read them into our project using links instead, to make reproducing our code easier. Our Final.Rmd file contains the initial exploratory data analysis and mutations that we did on the data. The Final.html file includes these scatterplots and maps as a knitted output file. Our shiny app code is in the folder beast-mode. 


## Rubric:

# Successful

All boxes should be checked

- [X] Acquire data from at least 2 sources
- [X] Consider the who, what, when, why, and how of your datasets
- [X] Work with a type of data that was not accessible to you as a Stat120, 230, or 250 student (text, spatial, network, date, etc)
- [X] Demonstrate proficiency with joining data
- [X] Demonstrate proficiency with tidying data
- [X] Demonstrate proficiency using non-numeric data types (text, spatial, date time, factor)
- [X] Create high-quality, customized graphics using R or ggplot
- [X] Graphs contain interactive components (plotly, leaflet, etc) 
- [X] Product is published online as an rpubs or shinyapps website and is pitched towards a public audience
- [X] Product meets high submission quality standards:
  - [X] No grammatical mistakes, spelling mistakes, or typos
  - [X] All graphs are readable with appropriate labels and titles
  - [X] Rendered document does not contain any unnecessary content (package loading messages, warnings, etc.)
  - [X] Graphs have been customized and are appropriate and readable with the theme of the document
- [X] All group members have a commit history on github
- [X] Code is well-document and clean
- [X] Project repo is organized 
- [X] README contains a link to your published project, a technical summary of what you did, and a self-evaluation using this rubric


# Excellent

## Must be checked

- [X] Meets very high submission quality standards: Final product is polished, professional, and customized


## Two of three must be checked

- [ ] Acquire data using one of the advanced techniques discussed in class (scraping, API, database, iterating over files in a folder, etc.)
- [X] Significant portion of the project uses non-numeric data types (e.g. maps that use lat/long location; text analysis; etc) **OR** Project relied on a significant amount of joining or combining data
- [X] Product is an interactive shiny app
