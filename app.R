library(shiny)
library(ReturnForge)
library(dplyr)
library(ggplot2)
library(zoo)
library(PerformanceAnalytics)

ui <- fluidPage(

    # Application title
    titlePanel("Stock Summary"),

    
    sidebarLayout(
        sidebarPanel(
            textInput('ticker', 'Enter stock ticker', value = 'SPY'),
            dateRangeInput('daterange', 'Date Range',
                      start = Sys.Date() - 365, end = Sys.Date())
        ),
        mainPanel(
           plotOutput("ddPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$ddPlot <- renderPlot({
        
        ticker = input$ticker
        dates = input$daterange
        
        rets <- tidyquant::tq_get(
          x = ticker,
          get = 'stock.prices',
          from = dates[1],
          to = dates[2]
        ) %>% 
          dplyr::mutate(ret = (adjusted /dplyr::lag(adjusted) - 1)) %>% 
          tidyr::drop_na() %>% 
          tidyr::pivot_wider(id_cols = date, names_from = symbol, values_from = ret)
        
        dat <- zoo::zoo(rets[,-1], order.by = rets$date)
        
        plt <- PerformanceAnalytics::chart.Drawdown(dat, engine = 'ggplot2')
        
        return(plt)
        
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
