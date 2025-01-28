#### TEMPLATE FILE NOT VALID DO NOT USE UNTIL ACTUAL #####


FROM --platform=linux/amd64 rocker/shiny-verse:latest
RUN apt-get update && apt-get install -y git


RUN git clone https://github.com/risktoollib/shiny-stocks.git /srv/shiny-server/shiny-stocks
RUN Rscript /srv/shiny-server/shiny-stocks/requirements.R

# Make the Shiny app available at port 3838
EXPOSE 3838

# Run the app
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/shiny-stocks/', host = '0.0.0.0', port = 3838)"]

