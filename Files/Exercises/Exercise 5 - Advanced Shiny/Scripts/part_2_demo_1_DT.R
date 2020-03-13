library(shiny)
library(DBI)
library(odbc)
# Install.packages('DT')
library(DT)

if (Sys.info()['sysname'] == "Windows") {
  conn <- DBI::dbConnect(odbc::odbc(),
                         Driver = "SQL Server",
                         Server = "128.95.29.72",
                         Database = "CEE412_CET522_W20",
                         UID      = "CEE412CET522",
                         PWD      = "Winter2020",
                         Port     = 1433)
} else {
  conn <- DBI::dbConnect(odbc::odbc(),
                         Driver = "SQLServer",
                         Server = "128.95.29.72",
                         Database = "CEE412_CET522_W20",
                         UID      = "CEE412CET522",
                         PWD      = "Winter2020",
                         Port     = 1433)
}

# Select all data from E4_Servery
query <- "SELECT TOP 80 * FROM [E5_Car2GoData]"
queryData <- dbGetQuery(conn, query)

# UI
ui <- fluidPage(
  
  # App title ----
  titlePanel("Hello Shiny!"),
  # Create a new Row in the UI for selectInputs
  fluidRow(
    column(3,
           selectInput("VID", "Vechile ID:", c("All", unique(as.character(queryData$id))))
    ),
    column(3,
           selectInput("Distance","Distance Larger Than:", c("All", 1, 2, 3, 4, 5))
    )
  ),
  
  DT::dataTableOutput("table1")
)


# Server
server <- function(input, output) {
  
  # initialize the tableData as the query result that stored in initial_surveyData
  rv <- reactiveValues(Car2GoData = queryData)
  
  # Filter data based on selections
  output$table1 <- DT::renderDataTable(DT::datatable({
    data1 <- rv$Car2GoData
    if (input$VID != "All") {
      data1 <- data1[data1$id == input$VID,]
    }
    if (input$Distance != "All") {
      data1 <- data1[data1$distance >= input$Distance,]
    }
    data1
  }))

  
}


# Run the app ---- 
shinyApp(ui = ui, server = server) 

