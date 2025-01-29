library(shiny)
library(dplyr)
library(stringr)
library(tidyquant)
library(ggplot2)
library(zoo)
library(PerformanceAnalytics)
library(corrplot)

ui <- fluidPage(

    # Application title
    titlePanel("Stock Summary"),

    
    sidebarLayout(
        sidebarPanel(
            textInput('ticker', 'Enter Comma Deliniated Tickers', value = "CCOM.TO, CMDY, BCI, GSG, DCMT"),
            dateRangeInput('daterange', 'Date Range',
                      start = Sys.Date() - 365, end = Sys.Date()),
            textInput('klusters', 'Enter Number of Klusters', value = 3),
            textInput('seed', 'Input seed', value = 123)
        ),
        mainPanel(
           plotOutput("ddPlot"),
           plotOutput("klusterPlot"),
           plotOutput('corrPlot')
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$ddPlot <- renderPlot({
        
        tickers <- stringr::str_split(stringr::str_replace_all(input$ticker, ' ', ''), ',')[[1]]
        dates <-  input$daterange
        
        rets <- tidyquant::tq_get(
          x = tickers,
          get = 'stock.prices',
          from = dates[1],
          to = dates[2]
        ) %>% 
          dplyr::group_by(symbol) %>% 
          dplyr::mutate(ret = (adjusted /dplyr::lag(adjusted) - 1)) %>% 
          tidyr::drop_na() %>% 
          tidyr::pivot_wider(id_cols = date, names_from = symbol, values_from = ret)
        
        dat <- zoo::zoo(rets[,-1], order.by = rets$date)
        
        plt <- PerformanceAnalytics::charts.PerformanceSummary(dat, main="Performance Summary",legend.loc = "topleft")
        
        return(plt)
        
    })
    
   output$klusterPlot <- renderPlot({
      
      tickers <- stringr::str_split(stringr::str_replace_all(input$ticker, ' ', ''), ',')[[1]]
      dates <-  input$daterange
      kluster <- as.numeric(input$klusters)
      seed <- as.numeric(input$seed)
      
      dat <- tidyquant::tq_get(
        x = tickers,
        get = 'stock.prices',
        from = dates[1],
        to = dates[2]
      ) %>% 
        dplyr::group_by(symbol) %>% 
        dplyr::summarize(
          avg_return = mean(adjusted / lag(adjusted) - 1, na.rm = TRUE),
          volatility = sd(adjusted / lag(adjusted) - 1, na.rm = TRUE),
          sharpe_ratio = avg_return / volatility
        )
      
      dat_scaled <- dat %>% 
        dplyr::select(avg_return, volatility, sharpe_ratio) %>% 
        scale()
      
      set.seed(seed)
      
      res <- stats::kmeans(dat_scaled, centers = kluster)
      
      dat <- dat %>% 
        dplyr::mutate(cluster = as.factor(res$cluster))
      
      plt <- ggplot(dat, aes(x = avg_return, y = volatility, color = cluster)) +
        geom_point(size = 3) +
        geom_text(aes(label = symbol), vjust = -0.5, hjust = 0.5) +
        scale_x_continuous(labels = scales::percent_format(accuracy = 0.01)) +
        scale_y_continuous(labels = scales::percent_format(accuracy = 0.01)) +
        labs(
          title = "Scaled K-Means Clustering",
          x = "Average Return",
          y = "Volatility",
          color = "Cluster"
        ) +
        theme_minimal()
      
      return(plt)
      
      })
      
      output$corrPlot <- renderPlot({
        
        tickers <- stringr::str_split(stringr::str_replace_all(input$ticker, ' ', ''), ',')[[1]]
        dates <-  input$daterange
        
        rets <- tidyquant::tq_get(
          x = tickers,
          get = 'stock.prices',
          from = dates[1],
          to = dates[2]
        ) %>% 
          dplyr::group_by(symbol) %>% 
          dplyr::mutate(ret = (adjusted /dplyr::lag(adjusted) - 1)) %>% 
          tidyr::drop_na() %>% 
          tidyr::pivot_wider(id_cols = date, names_from = symbol, values_from = ret) %>% 
          dplyr::select(-date)
        
        corrs <- stats::cor(rets, method = 'kendall')
        
        plt <- corrplot::corrplot(
          corr = corrs,
          method = 'number',
          order = 'AOE',
          type = 'lower'
        )
      
        return(plt)
        
      })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
