library(shiny)
library(RODBC)

# build connnection
conn <-odbcConnect("CEE412_CET522", "CEE412_Admin", "star*lab1")
# conn <-odbcConnect("CEE412_CET522", "Your Username", "Your Password")

# query 
surveyQuery <- "SELECT * FROM [E4_Survey]"

# select the Survey data based on query
surveyData <- sqlQuery(conn, surveyQuery)

# check the data type
typeof(surveyData$name)

# format the timestamp column into the format "%d/%m/%Y %H:%M:%S"
surveyData$timestamp <- as.character(as.POSIXct(surveyData$timestamp, origin="1970-01-01", format="%d/%m/%Y %H:%M:%S"))


# UI
ui <- fluidPage(
  
  # App title ----
  titlePanel("Hello Shiny!"),
  
  fluidRow(
    column(12, 
      wellPanel(
        tableOutput('table')
      )
    )
  )
)


# Server
server <- function(input, output) {
  
  output$table <- renderTable(surveyData)
  
}


# Run the app ---- 
shinyApp(ui = ui, server = server) 
