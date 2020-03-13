library(shiny)
library(dygraphs)
library(datasets)

lungDeaths <- cbind(mdeaths, fdeaths)

ui <- fluidPage(
  
  titlePanel("Predicted Deaths from Lung Disease (UK)"),
  
  wellPanel(
    dygraphOutput("dygraph")
  )
)


server <- function(input, output) {
  
  output$dygraph <- renderDygraph({
    dygraph(lungDeaths)
  })
  
}


# Run the app ---- 
shinyApp(ui = ui, server = server) 
