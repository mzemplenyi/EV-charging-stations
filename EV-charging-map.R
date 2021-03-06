################################
# Michele Zemplenyi
# GIS using R
# EV charging stations analysis
################################

# helpful web resource 
# https://www.jessesadler.com/post/gis-with-r-intro/

library(sp) # Note: sp objects cannot be plotted with ggplot2 (unless forced into a compatible form)
# note: https://www.naturalearthdata.com/ is an open-source repository of maps
library(dplyr)
library(rgdal)

library(leaflet)
file_path <- ("~/GitHub/EV-charging-stations/station_elec_equipments_mv/station_elec_equipments_mvPoint.shp")
df <- readOGR(dsn = file_path)
dim(df)
names(df)

df <- df@data %>% rename(state = st_prv_cod)
levels(df$state)
names(df)
# sample rows to make maps faster to load
#df <- df[sample(nrow(df), size = 500),]

#leaflet() %>% 
#  addTiles %>% 
#  addMarkers(data=df)

# Get total chargers by state
ev_state <- df %>% group_by(state) %>%  summarise(total = n())
View(ev_state)

pop_data <- read.csv("~/GitHub/EV-charging-stations/EV-charging-stations/data/state-pop-2019.csv")
head(pop_data)
tail(pop_data)
colnames(pop_data) <- c("state", "pop_2019")
# remove periods at the start of certain state names
pop_data$state <- gsub("[.]", "", pop_data$state)
# remove commas from population figures
pop_data$pop_2019 <- gsub(",", "", pop_data$pop_2019)
pop_data$pop_2019 <- as.numeric(as.character(pop_data$pop_2019))
str(pop_data)

## Make choropleths of states
library("geojsonio")
# transfrom .json file into a spatial polygons data frame
states <-   geojson_read( 
    x = "https://raw.githubusercontent.com/PublicaMundi/MappingAPI/master/data/geojson/us-states.json"
    , what = "sp"
  )
class(states)
names(states)
head(states@data)
nrow(states@data)

# leaflet(states) %>% 
#   setView(-96, 37.8, 4) %>% 
#   addTiles() %>% 
#   addPolygons()

## this states files has state names written out -- I need to map them 
# to state abbreviations to match the ev stations file (df)
levels(df$state)
states$name

states$abbrev <- c("AL", "AK", "AZ", "AR","CA", "CO", "CT",
                   "DE", "DC", "FL", "GA", "HI", "ID", "IL", "IN", "IA",
                   "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS",
                   "MO", "MT", "NE", "NV", "NH", "NJ", "NM","NY",
                   "NC", "ND", "OH", "OK", "OR", "PA", "RI",
                   "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA",
                   "WV", "WI", "WY", "PR")

## now I can join states to ev_states 
head(left_join(states@data, ev_state, by = c("abbrev"="state"))) # looks good
states@data <- left_join(states@data, ev_state, by = c("abbrev"="state"))
summary(states$total)

# join state populations to the state file 
# first check that state names match
which(pop_data$state %in% states@data$name )
which(!pop_data$state %in% states@data$name)
states@data <- left_join(states@data, pop_data, by = c("name" = "state"))
str(states@data)

states@data <- states@data %>% mutate(stations_per_cap =  round(total / pop_2019,6))
states@data <- states@data %>% mutate(stations_per_100k = round(100000 * total / pop_2019,2))
head(states@data)
saveRDS(states, file = "C:/Users/Michele/Documents/GitHub/EV-charging-stations/EV-charging-stations/data/ev_charging_by_state.Rds")

pal <- colorNumeric(palette="Blues", domain = states$total)
qpal <- colorQuantile("Reds", states$total, n=10)

labels <- sprintf(
  "<strong>%s</strong><br/>%g electric stations",
  states$name, states$total
) %>% lapply(htmltools::HTML)

m <- leaflet(states) %>%
  setView(-96, 37.8, 4) %>%
  addTiles() %>% 
  addPolygons(
  fillColor= ~qpal(total),
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
  direction = "auto")); m



#####################################
# map with shading normalized by population density
###################################

head(states@data)
states@data <- states@data %>% mutate(stations_per_popdens = total / density)
names(states)

pal <- colorNumeric(palette="Greens", domain = states$stations_per_popdens)
#qpal <- colorQuantile("Blues", states$stations_per_popdens, n=10)

labels <- sprintf(
  "<strong>%s</strong><br/>%g electric stations / pop dens",
  states$name, states$stations_per_popdens
) %>% lapply(htmltools::HTML)

m <- leaflet(states) %>%
  setView(-96, 37.8, 4) %>%
  addTiles() %>% 
  addPolygons(
    fillColor= ~pal(stations_per_popdens),
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
      direction = "auto")); m
