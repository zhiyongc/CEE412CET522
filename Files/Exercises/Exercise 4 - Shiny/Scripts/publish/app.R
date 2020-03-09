library(shiny)
# install.packages("shinyjs")
library(shinyjs)
# install.packages("DBI")
library(DBI)
# install.packages("odbc")
library(odbc)

# build connnection
conn <- DBI::dbConnect(odbc::odbc(),
                       Driver   = "FreeTDS",
                       Server   = "128.95.29.72",
                       Database = "CEE412_CET522_W20",
                       UID      = "CEE412_Admin",
                       PWD      = "star*lab1",
                       Port     = 1433)


# save data to database
saveDataToDatabase <- function(data) {
  print(data)
  table_columns <- dbListFields(conn, "E4_Survey")
  colnames(data) <- as.character(table_columns)
  dbWriteTable(conn, "E4_Survey", data, append = TRUE, overwrite = FALSE, row.names = FALSE)
}


# UI
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
    # state using shinyjs based on Javascript
    shinyjs::useShinyjs(),
    
    column(6,
           wellPanel(
             titlePanel("A Survey Demo"),
             div(id = "form",
                 textInput("name", labelMandatory("Name"), ""),
                 textInput("favourite_pkg", labelMandatory("Favourite R package")),
                 checkboxInput("used_shiny", "I've built a Shiny app in R before", FALSE),
                 sliderInput("r_num_years", "Number of years using R", 0, 10, 2, ticks = FALSE),
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
  
  
  # define the header
  fieldsAll <- c("name", "favourite_pkg", "used_shiny", "r_num_years", "os_type")
  
  # get the system time
  timestamp <- function() format(Sys.time(), "%Y-%m-%d %H:%M:%OS")
  
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
