#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Electric Vehicle Charging Stations in the United States, 2020"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            radioButtons("radio", "Map view:",
                         choiceNames = list(
                             "charging stations / 100k residents",
                             "total charging stations"
                         ),
                           choiceValues = list(
                               "stations_per_100k",
                               "total_stations"))
    
            

        ),

        # Show a plot of the generated distribution
        mainPanel(
            leafletOutput("state_map")
            # leafletOutput("state_stations_per_100k"),
            # leafletOutput("state_stations")
            #leafletOutput("ev_marker_map")
            #plotOutput("distPlot")
        )
    )
))
