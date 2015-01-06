
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
    tabPanel(title="Artificial Neural Network",
  sidebarPanel(
                    
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
    textOutput(outputId = "feature_error"),
    uiOutput(outputId = "ann_parameters")
    
      
  

  
   
  ,width =5
   
   ),
mainPanel(
  #Panel only displayed after file is read
  conditionalPanel (condition = "output.ann_parameters !== null" , div( h4("Preview Of Read Data: "), helpText("Showing 10 Columns only"), 
    
    #This is the preview of read file                                                                    
    tableOutput(outputId = "contents")
  
 ,hr() ,h4("ANN Plot"),plotOutput("ann_plot"),hr(),

  h4("ANN Overview"), uiOutput("ann_printstats"),hr(),h4("ANN Output") ,tableOutput(outputId = "ann_result")   )   )
  , width=7)


) 

  #The next next panel for SVM starts here
  ,tabPanel(title="Support Vector Machine", sidebarPanel(
    h3("Model Parameters"),
    #File input Code
    fileInput('file_svm', h5('Choose Data File (CSV)'),
              accept=c('text/csv', 
                       'text/comma-separated-values,text/plain', 
                       '.csv')),
    tags$hr(),
    #
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
                              '"'))
    ,uiOutput(outputId = "svm_features"),
    textOutput(outputId = "svm_test_checkbox"),
    textOutput(outputId = "svm_feature_error"),
    uiOutput(outputId = "svm_parameters")
    
    
    
    
    ), #SVM sidebar panel end 
    mainPanel(
      #Panel only displayed after file is read
      conditionalPanel (condition = "output.svm_parameters !== null" , div( h4("Preview Of Read Data: "), helpText("Showing 10 Columns only"), 
        #This is the preview of read file                                                                    
        tableOutput(outputId = "svm_contents")        
                                                                            
      )  )  #conditional panel end
      )#SVM Main Panel end
          
          
          
          
          ), #SVM Tab panel ends here

    id=c("ANN" , "SVM"), type="tabs" ,position="above" )  #The code for all tabs (tabsetPanel) ends here
  ) #fluidPage ends here
)  #the app ends here

