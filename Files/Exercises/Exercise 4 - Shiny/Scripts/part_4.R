library(RODBC)
library(leaflet)
library(leaflet.extras)
library(shiny)
library(shinyjs)

# build connnection
# conn <-odbcConnect("Database_E6(write the name of the database that you gave it while setting up the DSN)", "Your name", "your password")
conn <-odbcConnect("CEE412_CET522", "CEE412_Admin", "star*lab1")


# list of tables
sqlTables(conn, tableType="TABLE")

# select all the Car2Go data
data = sqlQuery(conn, "SELECT * FROM [E4_Car2GoData]")

# check the data type
typeof(data$olon)

# select the top 500 rows as the sample to be visualized
sampleData <- data[c(1:500),]


# save data to database
saveDataToDatabase <- function(data) {

  ColumnsOfTable       <- sqlColumns(conn, "E4_Survey")
  varTypes             <- as.character(ColumnsOfTable$TYPE_NAME) 
  names(varTypes)      <- as.character(ColumnsOfTable$COLUMN_NAME) 
  colnames(data) <- as.character(ColumnsOfTable$COLUMN_NAME)
  
  sqlSave(conn, data, "E4_Survey", fast=TRUE, append=TRUE,  rownames=FALSE, varTypes=varTypes )
}


# UI




fieldsMandatory <- c("name", "favourite_pkg")

labelMandatory <- function(label) {
  tagList(
    label,
    span("*", class = "mandatory_star")
  )
}



# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Hello Shiny!"),
  
  
  fluidRow(
    
    column(12,wellPanel(
      leafletOutput("mymap")
    ))
    
  ),
  
  fluidRow(
    # state using shinyjs based on Javascript
    shinyjs::useShinyjs(),
    
    column(4,
           wellPanel(
             titlePanel("A Survey Demo"),
             div(id = "form",
                 textInput("name", labelMandatory("Name"), ""),
                 textInput("favourite_pkg", labelMandatory("Favourite R package")),
                 checkboxInput("used_shiny", "I've built a Shiny app in R before", FALSE),
                 sliderInput("r_num_years", "Number of years using R", 0, 25, 2, ticks = FALSE),
                 selectInput("os_type", "Operating system used most frequently",
                             c("",  "Windows", "Mac", "Linux")),
                 actionButton("submit", "Submit", class = "btn-primary")
             ),
             shinyjs::hidden(
               # create an hidden div
               div(
                 id = "thankyou_msg",
                 h3("Thanks, your response was submitted successfully!"),
                 actionLink("submit_another", "Submit another response")
               )
             )  
           )
    )
  )
)


# Server
server <- function(input, output) {
  
  # get data from the sampleData dataframe
  data <- reactive({
    x <- sampleData
  })
  
  
  # define the header
  fieldsAll <- c("name", "favourite_pkg", "used_shiny", "r_num_years", "os_type")
  
  # get the system time
  timestamp <- function() format(Sys.time(), "%Y-%m-%d %H:%M:%OS")
  
  # output associated with the leafletOutput in the UI script
  output$mymap <- renderLeaflet({
    
    # get the data
    df <- data()
    
    # definition of the leaflet map 
    m <- leaflet(data = df) %>%
      addTiles() %>%
      # setView(lng=-73.935242, lat=40.730610 , zoom=10)
      addMarkers(lng = ~olon, lat = ~olat, popup = paste("Vehicle ID", df$id, "<br>", "Address:", df$oaddress))%>%
      addHeatmap(lng = ~olon, lat = ~olat, blur = 20, max = 0.5, radius = 15)
    # return the map
    m
  })
  
  # gather form data into a format  
  formData <- reactive({
    data <- sapply(fieldsAll, function(x) input[[x]])
    data <- c(data, timestamp = timestamp())
    data <- t(data)
    data <- as.data.frame(data)
  })
  
  # action to take when submit button is pressed
  observeEvent(input$submit, {
    saveDataToDatabase(formData())
    shinyjs::reset("form")
    shinyjs::hide("form")
    shinyjs::show("thankyou_msg")
  })
  
  # action to take when submit_another button is pressed
  observeEvent(input$submit_another, {
    shinyjs::show("form")
    shinyjs::hide("thankyou_msg")
  })    
}


# Run the app ---- 
shinyApp(ui = ui, server = server) 
