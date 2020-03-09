library(shiny)

ui <- fluidPage(
  tags$img(height = 100,
           width = 100,
           src = "R.png"),
  titlePanel("Hello Shiny!")
)

server <- function(input, output) {}

shinyApp(ui = ui, server = server)

