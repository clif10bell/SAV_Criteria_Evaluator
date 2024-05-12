#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)

# Define server logic
function(input, output) {
  output$paragraph_text <- renderText({
    "The *.csv file should have two columns: Year and KD. The KD is the
    median annual light attenuation value for the site in units of 1/m."
  })
  
  # Function to read CSV file and return dataframe
  getDataFrame <- reactive({
    req(input$file1) # Make sure file is uploaded
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    df <- read.csv(inFile$datapath)
    return(df)
  })
  
  # Calculate exceedance percentage or return error message
  exceed_percent <- eventReactive(input$calculate, {
    if (input$checkbox == TRUE) {
      if (is.null(input$file1)) {
        return("Error: Please upload a file to calculate the exceedance percentage from the data.")
      } else {
        df <- getDataFrame()
        kd_target <- input$kd_target
        allow_exceed <- input$allow_exceed
        exceed_count <- sum(df[,2] > kd_target)
        exceed_percent <- (exceed_count / nrow(df)) * 100
        return(exceed_percent)
      }
    } else {
      exceed_percent <- input$user_annual_prob * 100
      return(exceed_percent)
    }
  })
  
  # Show sorted dataframe and calculate exceedance percentage
  output$contents <- renderTable({
    df <- getDataFrame()
    if (!is.null(df)) {
      df <- df[order(df[,2]), ] # Sort dataframe by second column
      kd_target <- input$kd_target
    }
    return(df)
  })
  
  # Display the exceedance percentage or error message
  output$exceed_percent_output <- renderText({
    exceed_percent_value <- exceed_percent()
    if (is.character(exceed_percent_value)) {
      return(exceed_percent_value)
    } else {
      paste("<strong>Annual probability of exceeding KD Target:</strong>", round(exceed_percent_value, 1), "%")
    }
  })
  
  probability <- function(p, k, z) {
    ## Calculate the assessment period at least k + 1 exceedances
    prob <- 1 - pbinom(k, z, p)
    return(prob)
  }
  
  # Calculate and display non-attainment probability or empty string if error
  output$probability_output <- renderText({
    exceed_percent_value <- exceed_percent()
    if (is.character(exceed_percent_value)) {
      return("")
    } else {
      prob <- probability(exceed_percent_value/100, input$allow_exceed, input$year_basis)
      paste("<strong>Probability of exceeding the target more than the allowable frequency
            over the multi-year assessment period:</strong>", round(prob*100, 1), "%")
    }
  })
}
