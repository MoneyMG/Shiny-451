FROM --platform=linux/amd64 rocker/shiny-verse:latest #probably going to have to change the platform but I also dont know what it means atm
RUN apt-get update && apt-get install -y git


RUN git clone https://github.com/MoneyMG/Shiny-451.git /srv/shiny-server/shiny-451
RUN Rscript /srv/shiny-server/shiny-451/requirements.R

# Make the Shiny app available at port 3838
EXPOSE 3838

# Run the app
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/shiny-stocks/', host = '0.0.0.0', port = 3838)"]

