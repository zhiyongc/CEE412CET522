library(shiny)
library(shinyjs)
library(DBI)
library(odbc)
library(leaflet)
library(leaflet.extras)



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
# Car2GoData$timestamp <- as.character(as.POSIXct(Car2GoData$timestamp, origin="1970-01-01", format="%d/%m/%Y %H:%M:%S"))




# UI
ui <- fluidPage(
  
  # App title ----
  titlePanel("Hello Shiny!"),
  fluidRow(
    # state using shinyjs based on Javascript
    shinyjs::useShinyjs(),
    fluidRow(
      column(4, 
             wellPanel(
               leafletOutput("myMap1")
             )
      ),
      column(4, 
             wellPanel(
               leafletOutput("myMap2")
             )
      ),
      column(4, 
             wellPanel(
               leafletOutput("myMap3")
             )
      )
    ),
    fluidRow(
      column(4, 
             wellPanel(
               leafletOutput("myMap4")
             )
      ),
      column(4, 
             wellPanel(
               leafletOutput("myMap5")
             )
      ),
      column(4, 
             wellPanel(
               leafletOutput("myMap6")
             )
      )
    )
  )
)


# Server
server <- function(input, output) {

  # initialize the tableData as the query result that stored in initial_surveyData
  rv <- reactiveValues(Car2Go = queryData)
  
  # output associated with the leafletOutput in the UI script
  output$myMap1 <- renderLeaflet({
    
    leaflet() %>%
      addTiles() %>%  # Add default OpenStreetMap map tiles
      addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
  })
  
  # output associated with the leafletOutput in the UI script
  output$myMap2 <- renderLeaflet({
    
    leaflet() %>%
      addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
      addMarkers(data = rv$Car2Go, lng = ~olon, lat = ~olat, popup = paste("Vehicle ID:", rv$Car2Go$id, "<br>", "Address:", rv$Car2Go$oaddress))
  })
  
  # output associated with the leafletOutput in the UI script
  output$myMap3 <- renderLeaflet({
    
    leaflet() %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addHeatmap(data = rv$Car2Go, lng = ~olon, lat = ~olat, blur = 20, max = 0.5, radius = 15)
  })
  
  

  
  # output associated with the leafletOutput in the UI script
  output$myMap4 <- renderLeaflet({
    
    leaflet() %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = rv$Car2Go, lng = ~olon, lat = ~olat, clusterOptions = markerClusterOptions())
  })
  
  
  # output associated with the leafletOutput in the UI script
  output$myMap5 <- renderLeaflet({
    
    map <- leaflet() %>%
      # Base groups
      addTiles(group = "OSM (default)") %>%
      addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      # Overlay groups
      addCircles(data = rv$Car2Go, lng = ~olon, lat = ~olat, radius = rv$Car2Go$ofuel * 2, group = "Vehicle Fuel") %>%
      addMarkers(data = rv$Car2Go, lng = ~olon, lat = ~olat, clusterOptions = markerClusterOptions(), group = "Heatmap") %>%
      # Layers control
      addLayersControl(
        baseGroups = c("OSM (default)", "Toner"),
        overlayGroups = c("Vehicle Fuel", "Heatmap"),
        options = layersControlOptions(collapsed = FALSE)
      )
    
    map 
  })
  
  # output associated with the leafletOutput in the UI script
  output$myMap6 <- renderLeaflet({
    
    leaflet() %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = rv$Car2Go, lng = ~olon, lat = ~olat, popup = paste("Vehicle ID:", rv$Car2Go$id, "<br>", "Address:", rv$Car2Go$oaddress))
  })
  
  observeEvent(input$myMap6_marker_click, { 
    p <- input$myMap6_marker_click
    print(p)
    
  })
  
}


# Run the app ---- 
shinyApp(ui = ui, server = server) 
