library(shiny)
library(jsonlite)
library(httr)
library(rvest)
library(DT)
library(dplyr)
library(tidyverse)
library(plotly)
library(ggplot2)
library("RCurl") 
library("png") 

# obtain Coronavirus Data from API

# get overall countries summary

r <- RETRY("GET", "https://api.covid19api.com/summary", pause_min = 1, times = 20)
json <- content(r, as = "text", encoding = "UTF-8")
summary_dataset <- fromJSON(json)

# get detail statistics from certain countries of interest

base_link = "https://api.covid19api.com/total/country/"

get_json = function(country){
  r <- RETRY("GET", paste0(base_link, country), 
             pause_min = 1, times = 20)
  json <- content(r, as = "text", encoding = "UTF-8")
  return(fromJSON(json))
}

country_list <-  c("china", "united-states", "canada", "united-kingdom", "brazil", "italy", "russia")
country_abbreviation <- c("CN", "US", "CA", "UK", "BR", "IT", "RU")
json_list <- lapply(country_list, get_json)
covid_dataset <- do.call("rbind", json_list)
covid_dataset$Country_Code <- rep(country_abbreviation, sapply(json_list, nrow))
covid_dataset$Country <- as.factor(covid_dataset$Country)
covid_dataset$Country_Code <- as.factor(covid_dataset$Country_Code)
covid_dataset$Record_Date <- str_extract(covid_dataset$Date, "(\\d{4}-\\d{2}-\\d{2})")
covid_dataset$Record_Date <- as.Date(covid_dataset$Record_Date, tryFormats = c("%Y-%m-%d", "%Y/%m/%d"))
covid_dataset <- covid_dataset[,c("Country","Confirmed","Deaths","Recovered","Active","Country_Code","Record_Date")]

# UI

ui <- fluidPage(
  title = "COVID-19 pandemic",
  tabsetPanel(
    # TabPanel_1
    tabPanel(
      title = "COVID19",
      plotOutput("coronavirus_img", width = "800px"),
      includeMarkdown("introduction.md")
    ),
    # TabPanel_2
    tabPanel(
      title = "Covid Data",
      DT::dataTableOutput("covid_data_to_display")
    ),
    # TabPanel_3
    tabPanel(
      title = "Global Confirmed Case",
      mainPanel(plotlyOutput("covid_treemap", height = "600px", width = "600px"))
    ),
    # TabPanel_4
    tabPanel(
      title = "Time Series",
      sidebarPanel(
        selectInput(inputId = "feature_to_show", 
                                  label = "Metric:",
                                  choices = c("Confirmed", "Deaths", "Active"),
                                  selected = "Confirmed")
      ),
      mainPanel(
        plotlyOutput("timeSeriesPlot")
      )
    )
  )    
)

# Server

server <- function(input, output, session) {
  
  # TabPanel_2
  output$covid_data_to_display <- DT::renderDataTable({
    countries_df <- summary_dataset$Countries[,c("Country", "TotalConfirmed", "NewConfirmed", "NewDeaths", "TotalDeaths", "NewRecovered", "TotalRecovered")]
    names(countries_df) <- c("Country", "Total Confirmed", "New Confirmed", "New Deaths", "Total Deaths", "New Recovered", "Total Recovered")
    countries_df2 <- countries_df[order(countries_df[,"Total Confirmed"], decreasing = TRUE),]
    row.names(countries_df2) <- NULL
    return(countries_df2)
  })
  
  # TabPanel_3
  output$coronavirus_img <- renderPlot({
    x <- "https://ewscripps.brightspotcdn.com/dims4/default/ff2ea6e/2147483647/strip/true/crop/1280x720+0+0/resize/1280x720!/quality/90/?url=http%3A%2F%2Fewscripps-brightspot.s3.amazonaws.com%2F9b%2F1c%2Fd6365aa54b5687a3cb1386a180db%2Fupdate-coronavirus-colorado-live-blog-covid19.png"
    img <- readPNG(getURLContent(x))
    plot(1:10,
         ty = "n",
         axes = FALSE,
         ann = FALSE)
    rasterImage(img, 0, 0, 10, 10)
  })
  
  # plotly
  conf_df <- summary_dataset$Countries %>% arrange(-TotalConfirmed)
  conf_df$parents = "Total confirmed cases in each country along with the corresponding percentages"
  output$covid_treemap <- renderPlotly({
    plot_ly(data = conf_df,
            type= "treemap",
            values = ~TotalConfirmed,
            labels= ~ Country,
            parents=  ~parents,
            domain = list(column=0),
            name = "Total confirmed cases in each country along with the corresponding percentages",
            textinfo="label+value+percent parent")
  })

  # TabPanel_4

  output$timeSeriesPlot <- renderPlotly({
    if (!is.null(input$feature_to_show)){
      dataset_for_ts = covid_dataset[,c("Country", "Record_Date", input$feature_to_show)]
      names(dataset_for_ts)[3] <- "value"
      return(print(
        ggplotly(
          ggplot(dataset_for_ts,
                 aes(x = Record_Date, 
                     y = value, col = Country)) + 
            geom_line() + 
            xlab("Time") + 
            ylab("counts") +
            ggtitle(paste("Number of", input$feature_to_show, "cases."))
        ) %>% layout(height = 800, width = 800)
      ))
     }
  })
  
}

shinyApp(server = server, ui = ui)

