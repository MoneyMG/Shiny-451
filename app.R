library(shiny)
library(ReturnForge)
library(dplyr)
library(ggplot2)
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
        
        dat <- ReturnForge::genrets(ticker, dates[1], output = 'zoo')
        
        plt <- PerformanceAnalytics::chart.Drawdown(dat, engine = 'ggplot2')
        
        return(plt)
        
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
