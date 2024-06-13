#
# This white is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)

fluidPage(
  # Application title
  titlePanel("Water Clarity Criteria Evaluator"),
  
  # Sidebar layout with input and output definitions
  sidebarLayout(
    sidebarPanel(
      # Input: Upload file
      verbatimTextOutput("paragraph_text"),
      fileInput("file1", "Choose CSV File (Optional)",
                accept = c(
                  "text/csv",
                  "text/comma-separated-values,text/plain",
                  ".csv")
      ),
      numericInput("kd_target", "KD Target (1/m):", value = 0.89),
      numericInput("user_annual_prob", "User-defined annual probability of exceeding KD target:", value = 0.2),
      checkboxInput("checkbox", "Calculate annual exceedance probability from datafile", value = FALSE),
      textOutput("text"),
      sliderInput("allow_exceed", "Allowable No. of Annual Exceedances", min = 0, max = 2, value = 0, step = 1),
      sliderInput("year_basis", "Out of How Many Years", min = 3, max = 5, value = 5, step = 1),
      # Add a button to execute calculations
      actionButton("calculate", "Calculate")
    ),
    
    # Show a table of the uploaded data and calculation results
    mainPanel(
      # Add user instructions at the top of the main panel
      h4("Purpose:"),
      p("The purpose of this tool is to assist water quality managers in setting water
           clarity targets for the protection of submerged aquatic vegetation (SAV). 
           The targets are expressed as a maximum magnitude of the median seasonal light
           attentuation (KD) and an allowable frequency of exceedance. The user enters the
           KD target magnitude, annual probability of exceedance at a site, and an allowable annual
           exceedance frequency. Optionally, the user can upload site data and let the tool
           calculate the annual probability of exceedance. The tool calculates the
           probability that the site would fail the target in a 3-5 year assessment period.
           If the failure probability is too high for a healthy SAV site, or too low
           for an unhealthy SAV site, users can adjust the target magnitude or allowable
           exceedance frequency to obtain a more reasonable regulatory target."),
      h4("Instructions:"),
      p("1. Optionally, upload a CSV file containing your data."),
      p("2. Adjust the KD Target and other parameters as needed."),
      p("3. If you want to calcuate the annual exceedance probability from the
              file data, be sure to click the checkbox."),
      p("3. Click the 'Calculate' button to perform the calculations."),
      p("The results will be displayed in the table and text outputs below."),
      
      tableOutput("contents"),
      htmlOutput("exceed_percent_output"),
      htmlOutput("probability_of_success"),
      p(""),
      htmlOutput("probability_output")
    )
  )
)
