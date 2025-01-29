p <- c("PerformanceAnalytics","ggplot2","tidyverse") 
new.packages <- p[!(p %in% installed.packages()[, "Package"])]
if (length(new.packages)) {
  install.packages(new.packages, dependencies = TRUE)
}
