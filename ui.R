
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
  
  tabsetPanel( 
    tabPanel(title="Machine Learning Application",
  sidebarPanel(
                    
               h3("Choose Model Type"), selectInput("modeltype",label='Select Model from the options',choices=
                                list("Artificial Neural Network"=1, "Support Vector Machine"=2 )) ,hr(),
               h3("Model Parameters"),
    fileInput('file1', h5('Choose Training Data File (CSV)'),
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
    
  
    
    uiOutput(outputId = "features"),
    textOutput(outputId = "test_checkbox"),
    div(textOutput(outputId = "feature_error"), style="color:red;font-weight:200"),
    uiOutput(outputId = "ann_parameters")
    
      
  

  
   
  ,width =5
   
   ),
mainPanel(
  #Panel only displayed after file is read
  conditionalPanel (condition = "output.ann_parameters !== null" , div( h4("Preview Of Read Data: "), helpText("Showing 10 Columns only"), 
    
    #This is the preview of read file                                                                    
    tableOutput(outputId = "contents")
  
 ,hr() ,h4("Model Plot"),plotOutput("ann_plot"),hr(),

  h4("Model Overview"), uiOutput("ann_printstats"),hr(),h4("Model Output") ,tableOutput(outputId = "ann_result")   )   )
  , width=7)  #main Panel ends here
   

   )  #TabPanel ends here
  ,id=c("MLAPP" ), type="tabs" ,position="above" )  #The code for all tabs (tabsetPanel) ends here
  ) #fluidPage ends here
)  #the app ends here

