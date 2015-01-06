ML_Kit
======

Online Machine Learning library, coded in R interfaced with HTML/CSS/JavaScript using Shiny. Supports Artificial Neural Network for now. SVM, Naive Bayes, Principal Component Analysis support coming soon. 

####Demo

Check out the deployed web app at:

https://umarfarooq360.shinyapps.io/ML_Kit/

###Deployment and Usage
__Preview__

![Machine Learning App Preview](https://raw.githubusercontent.com/umarfarooq360/ML_Kit/master/app_preview.png)

__Usage__


1. Upload the training file. CSV and XLS formats are accepted.
2. Select the dependent variable and the features.
3. Select training parameters.
4. Upload or select testing data. The app accepts seperate testing data as well as support for using a sample of the training data for testing.
5. Press the run button(once only). It'll take a little bit of time depending on the size of the data and then show the results.

####Modifying the Code
Clone the repository. Assuming you have R installed, install the shiny package by running

````
install.packages("shiny")
````
Load the library by running

````
library(shiny)
```
I would recommend using [RStudio](http://www.rstudio.com/) for Shiny apps.
The app works with just two files ui.R and server.R.
Check out the Shiny Documentation for more details.

http://shiny.rstudio.com/
