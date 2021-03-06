#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(rgdal)
library(dplyr)

# Define server logic required to draw a histogram
shinyServer(function(input, output){
    
    # Note: Any render*() function is a reactive context
    # Accessing reactive values outside of reactive context results in an error
    # Other ways to create a reactive context are to use reactive({}) or observe({...})
    # https://www.youtube.com/watch?v=cqOUpnF-Lco
    
    
    # Read in individual EV charging station data

    states_file_path <- ("ev_charging_by_state.Rds")
    states <- readRDS(states_file_path)
    
    # radioInput <- reactive({
    #     switch(input$radio,
    #            "stations_per_100k" = stations_per_100k,
    #            "total_stations" = total_stations)
    # })
    
    
    output$state_map <- renderLeaflet({
        if(input$radio == "stations_per_100k"){
            shading_var <- states$stations_per_100k
            pal <- colorNumeric(palette="Purples", domain = shading_var)
            labels <- sprintf(
                "<strong>%s</strong><br/>%g electric stations / 100k residents",
                states$name, shading_var) %>% lapply(htmltools::HTML)
        }
        if(input$radio == "total_stations"){
            shading_var <- states$total
            pal <- colorNumeric(palette="Greens", domain = shading_var)
            labels <- sprintf(
                "<strong>%s</strong><br/>%g electric stations",
                states$name, shading_var) %>% lapply(htmltools::HTML)
        }
        
        # default map code
        m1 <- leaflet(states) %>%
            setView(-96, 37.8, 3) %>%
            addTiles() %>% 
            addPolygons(
                fillColor= ~pal(shading_var),
                weight = 2,
                opacity = 1,
                color= "white",
                dashArray = "3",
                fillOpacity=0.7,
                highlight = highlightOptions(
                    weight = 5,
                    color = "#666",
                    dashArray= "",
                    fillOpacity = 0.7,
                    bringToFront=TRUE),
                label = labels,
                labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")) %>% 
            addLegend("bottomright", pal = pal, values = ~shading_var,
                      title = ""); m1
        
    })

    


    
    # file_path <- ("~/GitHub/EV-charging-stations/station_elec_equipments_mv/station_elec_equipments_mvPoint.shp")
    # df <- readOGR(dsn = file_path)
    # df <- df@data %>% rename(state = st_prv_cod)
    # # sample rows to make maps faster to load
    # df <- df[sample(nrow(df), size = 200),]
    # 
    # output$ev_marker_map <- renderLeaflet({
    #     leaflet() %>%
    #         addTiles %>%
    #         addMarkers(data = df)

    })

