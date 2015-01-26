
# This is the server logic for a Shiny web application.
# This is the backend for a Machine Learning Application that supports 
# Artificial Neural Network, and Support Vector Machine
# 
# http://www.rstudio.com/shiny/
# Author: Omar Farooq
# Date: 1/25/2015
#

library(shiny);

library(neuralnet);

library(e1071);

train_data  <<- NULL;

shinyServer(function(input, output) {
   
  #----------------------------------------------
  #This function renders the table showing 10 columns of the read data
  #----------------------------------------------
  
  output$contents <- renderTable({
    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    
    inFile <- input$file1
    
    if (is.null(inFile))
      return( NULL)
    
    
    
    train_data <<- read.csv(inFile$datapath, header=input$header, sep=input$sep, 
             quote=input$quote)
    
    features_list = train_data[1,]; 
    
    return(train_data[1:10,]);
  })
  
  #----------------------------------------------
  # This loads up check and radio boxes for the feature selection
  #----------------------------------------------
  
  output$features <- renderUI({
    
    inFile <- input$file1
    if (is.null(inFile))
    {return(NULL)}
    
        
    #store the data as a table
    train_data <<- read.csv(inFile$datapath, header=input$header, sep=input$sep, 
                           quote=input$quote)
    
    #return the check and radio boxes based on headers
     return (
       div(h3("Variables Selection"),splitLayout(
       (checkboxGroupInput("features_checkbox", label=h5("Features"),
                          choices = colnames(train_data))       
       
       ) , (radioButtons("prediction_radio", label=h5("Dependent Variable"),
                                           choices = colnames(train_data))       
       ) )
       
       
      )  );
    
    
  })
  
  #This is just for testing
  output$test_checkbox <- renderText({
    
    if(!is.null(train_data) ) {return(NULL)}
    
  })
  
  #This will give an error when feature is dependent variable
  output$feature_error <- renderText({
    if((length(input$features_checkbox )==0)&&(!is.null(input$sample_from_train)) ){return("Please select atleast one feature")}
    if (is.null(input$features_checkbox ) ) return ("");
      
    for( fts in input$features_checkbox ){
      if(fts == input$prediction_radio){return ("Error: Feature can be dependent variable")}
    }
    
    return (NULL);
    
    
  })
  
  
  #----------------------------------------------
  # This renders parameters for the ANN model 
  #----------------------------------------------
  
  output$ann_parameters <- renderUI({
    
    if(is.null(input$prediction_radio)) {return(NULL)}
    
    else if(input$modeltype ==1) {  #Return ann parameters
    return(div(br(),hr(),h4("Neural Network Parameters") ,
        
        #Numeric input for Hidden layers       
        numericInput("hiddenlayers",label= h5("Hidden Layers"), value=3), 
        
        #Numeric input for threshold
        numericInput("threshold",label= h5("Stop Threshold"), value= 0.01),helpText("Numeric value specifying the threshold for the
        partial derivatives of the error function as stopping criteria."),
    
        #Slider Input for stepmax
        sliderInput("stepmax" , label = h5("Maximum Steps (10^x)"), min= 3, max = 7 ,value=5) ,
        helpText("The maximum steps for the training of the neural network."),
        checkboxInput("linear_out" , label="Scale Output", value=F ), helpText("Should the 
                                                   logistic function be applied to ANN output"),
        
        #The options to choose testing data from
        hr(),h4("Testing Parameters"), 
        checkboxInput("sample_from_train",label="Sample From Training Data" , value=FALSE),
        
        #Running button
        uiOutput("testing_parameters"),
        actionButton("runIt", label= "Run ANN")
    
    
    ))
  }else if(input$modeltype ==2 ){  #Otherwise return SVM Parameters
    return(div(br(),hr(),h4("Support Vector Machine Parameters") ,
               
               #Numeric input for Hidden layers       
               radioButtons("kernel",label= h5("Kernel Type"), choices=list("Linear"="linear","Polynomial"= "polynomial","Radial Basis"="radial","Sigmoid"= "sigmoid")), 
               
               #The cost parameter of SVM
               numericInput("costparam",label= h5("Cost Parameter"), value= 1),helpText("Numeric value specifying the cost of constraint violation"),
               
               
               
               #Numeric input for stopping threshold
               numericInput("threshold",label= h5("Stop Threshold"), value= 0.001),helpText("Numeric value specifying the tolerance of termination"),
               
              #Should the variables be scaled           
               checkboxInput("scale_variables" , label=h5("Scale Variables"), value=F ), helpText("Should the variables be scaled"),
              
              checkboxInput("scale_output" , label="Scale Output", value=F ), helpText("Should the 
                                                   logistic function be applied to the output"),
              
              
              #The options to choose testing data from
               hr(),h4("Testing Parameters"), 
               checkboxInput("sample_from_train",label="Sample From Training Data" , value=FALSE),
               
              #Running button
               uiOutput("testing_parameters"),
               actionButton("runIt", label= "Run SVM")
               
               
    ))
    
  }
    
  })
  
  
  #----------------------------------------------
  # This load the testing parameters. E.g. sampling from data or specifying a file
  #----------------------------------------------
  
  output$testing_parameters <- renderUI({
    if(input$sample_from_train == TRUE){
      return (sliderInput("percent_train" , label= "Percentage Training Data" , min =0.0, max =1.0, value=0.5) )
    }else if((!input$sample_from_train) == TRUE){
      return(
        fileInput('testfile', h5('Test Data File (CSV)'),
                  accept=c('text/csv', 
                           'text/comma-separated-values,text/plain', 
                           '.csv'))
        )
      
    }
    
    return (NULL);
    
  })
  
  
  #----------------------------------------------
  #This function renders the output table with predicted values
  #----------------------------------------------
  
  output$ann_result <-renderTable({
    if(is.null(input$runIt) ){return(NULL)}
    
  if( (input$runIt == 0)  ){
      return(NULL)
    }
  if(input$runIt >0 ){
      withProgress(message="Processing!", value=0.1, {
      #return("trainSet");
      
      #Read the file AGAIN lol
      train_data <- read.csv(input$file1$datapath, header=input$header, sep=input$sep, 
                              quote=input$quote)
      
      #make a string of features sperated by + signs
      featureString = paste(input$features_checkbox[1:length(input$features_checkbox) ], collapse=" + ");
      index = 1:nrow(train_data);
      
      #UPdate progress
      incProgress(0.2, detail ="Parsing the data");
      
      
      #find index of stuff used for training
      if(input$sample_from_train){
          trainIndex = sample(index, trunc(length(index)* input$percent_train ));
          testSet <<- train_data[ -trainIndex ,  ];
          trainSet <<- train_data[ trainIndex , ];
      }else if(!input$sample_from_train){
        trainSet = train_data ;
        testSet <<-  read.csv(input$testfile$datapath, header=input$header, sep=input$sep, 
                            quote=input$quote)
        
      }
      
      
      incProgress(0.2, detail ="Creating the specified model");
      
      
     
      if(input$modeltype ==1){
      
      NNet <<-  neuralnet( paste(input$prediction_radio," ~ ", featureString)  , trainSet, 
              hidden = input$hiddenlayers,stepmax = 10^(input$stepmax) ,linear.output=!input$linear_out,lifesign="minimal",threshold = input$threshold);
      }else if(input$modeltype ==2){
        print( paste(input$prediction_radio," ~ ", featureString));
        print(input$kernel );
        SVM_Model <<-  svm( x=trainSet[input$features_checkbox] ,y= trainSet[input$prediction_radio] , 
                            kernel = input$kernel  ,cost= input$costparam, tolerance = input$threshold, scale=input$scale_variables);
        
        #SVM_Model <<-  svm( paste(input$prediction_radio," ~ ", featureString)  , data=trainSet, 
        #                    kernel = input$kernel  ,cost= input$costparam, tolerance = input$threshold, scale=input$scale_variables);
        
        
      }
      
      
      #return(paste(input$features_checkbox[1:length(input$features_checkbox) ], collapse=" , ")  )
      
      #update progress
      incProgress(0.5, detail ="Testing on provided Data")
      
      #get features
      testSet_Features = subset(testSet,select=input$features_checkbox  );
      
      #Test the model on the provided data
      if(input$modeltype ==1){
        
        NNresults = compute(NNet , testSet_Features );
        final_results = (round(NNresults$net.result , 5 ));   
        
        }else if(input$modeltype ==2){
        
          SVM_Pred = predict(SVM_Model ,testSet_Features );
          final_results = round(SVM_Pred  , 5);
          
      }
      
          
      testSet[paste("Predicted ",input$prediction_radio)] <<- final_results;
            
      if(input$modeltype ==1){
          #will cause the plot to be built after ANN is created
          output$ann_plot <- renderPlot({
            return(plot(NNet));
          })
          
          #results in printing of stats
          output$ann_printstats <- renderUI({
          return( div(paste("Error: ", round (NNet$result.matrix [1] ,4)) 
                      , br() ,"Needed Steps: " 
                          ,NNet$result.matrix [3],br(),br(),downloadButton('ann_downloadData', 'Download Output')  ) );
            
             })
      }else if(input$modeltype ==2){
        #will cause the plot to be built after ANN is created
        output$ann_plot <- renderPlot({
          return(plot(x=SVM_Model ,data= testSet_Features ,formula= "Survived ~ Age"));
        })
        
        #results in printing of stats
        output$ann_printstats <- renderUI({
          return( div(downloadButton('ann_downloadData', 'Download Output'),  ) )
        })
        
      }
       
      return(testSet)
    
    })
    
    
      
    }
  })
  
  
  output$ann_downloadData <- downloadHandler(
    filename = function(){ paste( 'output_',floor(runif(1,1000,9999) ) , '.csv', sep='')},
    content = function(file){
      write.csv( testSet , file  )
    }
  )
  ##########################################################
  #---------------------------------
  #           SVM Server Methods
  #--------------------------------
  ########################################################
  
  #This renders a table showing a preview of read data
  output$svm_contents <- renderTable({
    
    # input$file_svm will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    
    inFile <- input$file_svm
    
    if (is.null(inFile))
      return( NULL)
    
        
    train_data <<- read.csv(inFile$datapath, header=input$header, sep=input$sep, 
                            quote=input$quote)
    
    features_list = train_data[1,]; 
    
    return(train_data[1:10,]);
  })

  
  
#----------------------------------------------
# This loads up check and radio boxes for the feature selection
#----------------------------------------------

output$svm_features <- renderUI({
  
  inFile <- input$file_svm
  if (is.null(inFile))
  {return(NULL)}
  
  
  #store the data as a table
  train_data <<- read.csv(inFile$datapath, header=input$header, sep=input$sep, 
                          quote=input$quote)
  
  #return the check and radio boxes based on headers
  return (
    div(h3("Variables Selection"),splitLayout(
      (checkboxGroupInput("features_checkbox", label=h5("Features"),
                          choices = colnames(train_data))       
       
      ) , (radioButtons("prediction_radio", label=h5("Dependent Variable"),
                        choices = colnames(train_data))       
      ) )
      
      
    )  );
})


#----------------------------------------------
# This loads up check and radio boxes for the feature selection
#----------------------------------------------

output$svm_features <- renderUI({
  
  inFile <- input$file_svm
  if (is.null(inFile))
  {return(NULL)}
  
  
  #store the data as a table
  train_data <<- read.csv(inFile$datapath, header=input$header, sep=input$sep, 
                          quote=input$quote)
  
  #return the check and radio boxes based on headers
  return (
    div(h3("Variables Selection"),splitLayout(
      (checkboxGroupInput("features_checkbox", label=h5("Features"),
                          choices = colnames(train_data))       
       
      ) , (radioButtons("prediction_radio", label=h5("Dependent Variable"),
                        choices = colnames(train_data))       
      ) )
      
      
    )  );
  
  
})
  
  
  
  
})  #End of shiny server
  
  
  
  
  
  
  


