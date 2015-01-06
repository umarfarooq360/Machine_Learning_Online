
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny);

library(neuralnet);

#library();

train_data  <<- NULL;

shinyServer(function(input, output) {
   
  
  
  
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
  
  
  #This loads up check and radio boxes for the feature selection
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
    if (is.null(input$features_checkbox )) return ("");
      
    for( fts in input$features_checkbox ){
      if(fts == input$prediction_radio){return ("Error: Feature can be dependent variable")}
    }
    return (NULL);
    
    
  })
  
  
  output$ann_parameters <- renderUI({
    
    if(is.null(input$prediction_radio)) {return(NULL)}
    
    return(div(br(),hr(),h4("Neural Network Parameters") ,
        
        #Numeric input for Hidden layers       
        numericInput("hiddenlayers",label= h5("Hidden Layers"), value=3), 
        
        #Numeric input for threshold
        numericInput("threshold",label= h5("Stop Threshold"), value= 0.01),helpText("Numeric value specifying the threshold for the
        partial derivatives of the errorfunction as stopping criteria."),
    
        #Slider Input for stepmax
        sliderInput("stepmax" , label = h5("Maximum Steps (10^x)"), min= 3, max = 7 ,value=5) ,
        helpText("The maximum steps for the training of the neural network."),
        checkboxInput("linear_out" , label="Scale Output", value=F ), helpText("Should the 
                                                   logistic function be applied to ANN output"),
        br(),h4("Testing Parameters"), 
        checkboxInput("sample_from_train",label="Sample From Training Data" , value=TRUE),
        
        uiOutput("testing_parameters"),
        actionButton("runIt", label= "Run ANN")
    
    
    ))
    
    
  })
  
  
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
  
  output$ann_result <-renderTable({
    
  if(input$runIt == 0){
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
          testSet = train_data[ -trainIndex ,  ];
          trainSet = train_data[ trainIndex , ];
      }else if(!input$sample_from_train){
        trainSet = train_data ;
        testSet =  read.csv(input$testfile$datapath, header=input$header, sep=input$sep, 
                            quote=input$quote)
        
      }
      
      
      incProgress(0.2, detail ="Creating ANN");
      
      
      #Create the ANN
      #return(paste(input$prediction_radio," ~ ", featureString) );
      
      NNet <<-  neuralnet( paste(input$prediction_radio," ~ ", featureString)  , trainSet, 
              hidden = input$hiddenlayers,stepmax = 10^(input$stepmax) ,linear.output=!input$linear_out,lifesign="minimal",threshold = input$threshold);
      
      
      
      #return(paste(input$features_checkbox[1:length(input$features_checkbox) ], collapse=" , ")  )
      
      
      incProgress(0.5, detail ="Testing on provided Data")
      
      
      testSet_Features = subset(testSet,select=input$features_checkbox  );
      #return(testSet_Features);
      NNresults = compute(NNet , testSet_Features );
      final_results = (round(NNresults$net.result , 3 ));  
      #colnames(final_results) <- paste("Predicted ",input$prediction_radio) ;
      
      testSet[paste("Predicted ",input$prediction_radio)] <- final_results;
      
      #will cause the plot to be built after ANN is created
      output$ann_plot <- renderPlot({
        return(plot(NNet));
      })
      
      #results in printing of stats
            
      output$ann_printstats <- renderUI({
        return( div(paste("Error: ", round (NNet$result.matrix [1] ,4)) 
                  , br() ,"Needed Steps: " 
                      ,NNet$result.matrix [3])   );
        
      })
      
      return(testSet)
    
    })
    
    
      
    }
  })
  
  #---------------------------------
  #           SVM Server Methods
  #--------------------------------
  
  
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
  
  
  
  
  
  
  
  
  
})
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  


