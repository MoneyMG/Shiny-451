p <- c("ReturnForge","PerformanceAnalytics","ggplot2","tidyverse") #Return forge probably isn't going to work because it isn't on Cran
new.packages <- p[!(p %in% installed.packages()[, "Package"])]
if (length(new.packages)) {
  install.packages(new.packages, dependencies = TRUE)
}