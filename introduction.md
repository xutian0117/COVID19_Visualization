
### Purpose of this App

This shiny app displays the updated COVID-19 statistics by each country. It is also used for  Tian Xu (916407454)'s STA141B final project in Winter 2021 at UC Davis. The COVID-19 pandemic is an ongoing pandemic. The severity of the new cases on a country could damage the local economic status. Therefore, it is interesting to create an app to keep track on the updated metrics for COVID 19 for each country. 


### App’s instruction

The data is obtained through API call to [https://covid19api.com”](https://covid19api.com). The data format is in JSON. Then, I convert it to data frame. I also use regular expression to extract the date information, then put it in data type format in R. There are three tab panels in this app. The panel descriptions are given below. 

#### First Panel: Covid Data

In this page, all the COVID data used to construct the second panel can be browsered in here. The data is sorted by the total number of confirmed cases in descending order. 

#### Second Panel: Global Confirmed Case

An interactive tree map is created by plotly to display the total number of deaths in each country. The area of the rectangle gets larger if the total number of confirmed cases getting larger. The proportion of the confirmed cases among the total number of confirmed cases in the world is displayed. 

#### Third Panel: Time Series

This page shows the interactive time series plot to compare the metric across a group of selected countries. The countries of interests are Brazil, Canada, China, Italy, Russian, United Kingdom and United States. Those are the countries which have the high number of confirmed cases. There are three metrics can be selected from the drop down menu on the side panel. They are the total number of confirmed cases, total number of deaths and total number of active cases. If the cursor moves to the line, it can show the exact case counts on a certain date and certain country. Besides, we can also focus on certain time period by clicking and dragging to highlight any time period. 



