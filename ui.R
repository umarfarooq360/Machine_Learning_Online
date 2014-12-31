
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

shinyUI(
 fluidPage(
    
  # Application title
  titlePanel("Machine Learning Application"),
    
  hr(),
  
  # Show a plot of the generated distribution
  sidebarPanel(
    h2("Model Parameters"),
    fileInput('file1', h5('Choose Data File (CSV)'),
              accept=c('text/csv', 
                       'text/comma-separated-values,text/plain', 
                       '.csv')),
    tags$hr(),
    
    splitLayout( div(checkboxInput('header', 'Header', TRUE),
    radioButtons('sep', 'Separator',
                 c(Comma=',',
                   Semicolon=';',
                   Tab='\t'),
                 ',')),
    radioButtons('quote', 'Quote',
                 c(None='',
                   'Double Quote'='"',
                   'Single Quote'="'"),
                 '"')),
  
    
    hr(),
    
  
    h3("Variables Selection"),
    uiOutput(outputId = "features"),
    textOutput(outputId = "test_checkbox"),
    textOutput(outputId = "feature_error"),
    uiOutput(outputId = "ann_parameters")
    
    
    
    
    
 
),
mainPanel(
  #Panel only displayed after file is read
  conditionalPanel (condition = "output.ann_parameters !== null" , div( h4("Preview Of Read Data: "), helpText("Showing 10 Columns only"), 
    
    #This is the preview of read file                                                                    
    tableOutput(outputId = "contents")
  
 ,hr() ,h4("ANN Plot"),plotOutput("ann_plot"),hr(),

  h4("ANN Overview"), uiOutput("ann_printstats"),hr(),h4("ANN Output") ,tableOutput(outputId = "ann_result")   )   )
  )
) )

