
library(leaflet)
library(maptools)
library(maps)
library(shiny)
library(data.table)

##load the static data
shape <- read.csv('/Users/sarahcha/Documents/W205/final_project/google_transit/shapes.txt')
stop <- read.csv('/Users/sarahcha/Documents/W205/final_project/google_transit/stops.txt')

## load the real-time data
## getRealData <- function(path) {
##
## }


shinyServer(function(input, output, session) {
  
  # Region select input box
  part_choices <- reactive({
    as.list(c(1L, 2L, 3L, 4L), names = c('Lower Manhattan', "Midtown", "Upper Manhattan", "Bronx"))
  })
  
  observe({
    updateSelectInput(session, "region", choices=part_choices())
  })
  
  ##pulling out latitude and longitude coordinates for stops
  stop$stop_lon <- as.numeric(stop$stop_lon)
  lons = stop$stop_lon
  stop$stop_lat <- as.numeric(stop$stop_lat)
  lats = stop$stop_lat
  stop_id = stop$stop_id
  
  ids <- unique(shape$shape_id)
  shape_orig <- shape
  #length(ids)
  
  ###creating a spatial object to map subway lines
  for(i in 1:10){
    shapes <- shape_orig[shape_orig$shape_id == ids[i],]
    shape_map <- list(x = shapes$shape_pt_lon, y = shapes$shape_pt_lat)
    shape_temp <- map2SpatialLines(shape_map, IDs = ids[i])
    #shape_lines <- spRbind(shape_lines, shape_temp)
  }
  
  ####processing updates
  stop_coord = data.frame(stop= stop$stop_id, lons = stop$stop_lon,lats = stop$stop_lat )
  #stop_coord = stop_coord[complete.cases(stop_coord), ]
  
  updates <- read.csv('/Users/sarahcha/Documents/W205/final_project/batch_data/trip_update.csv')
  unique_stop_ids <- unique(updates$stop_id)
  updates$arrival_delay <- as.numeric(updates$arrival_delay)
  updates$departure_delay <- as.numeric(updates$departure_delay)
  
  ##create a dataframe that will have stop id, coordinates + updates
  updates_df = data.frame(unique_stop = unique_stop_ids, lat_coord = seq(0,0,length.out=length(unique_stop_ids)), lon_coord = seq(0,0,length.out=length(unique_stop_ids)) )
  
  ##functions to map coordinates to each of the stops
  find_lat <- function(unique_stop){
    lat = stop_coord[stop_coord$stop == unique_stop, 3]
    return (lat)
  }
  find_lon <- function(unique_stop){
    lon = stop_coord[stop_coord$stop == unique_stop, 2]
    return (lon)
  }
  
  color_fun <- function(train_queue){
    if (train_queue == 0) {
      color = 'blue'
    }
    else {
      color = 'yellow'
    }
    return (color)
  }
  
  updates_df["lat_coord"] <- apply(updates_df[1], 1, find_lat)
  updates_df["lon_coord"] <- apply(updates_df[1], 1, find_lon)
  
  real_time_data_table =data.table(updates)
  real_time_data_table_adj = real_time_data_table[, list(train_queue = sum (arrival_delay > 0 , departure_delay > 0 ), length (arrival_delay[arrival_delay != 0])+ length (departure_delay[departure_delay != 0]), freq = .N), by = c("stop_id")]
  
  real_updates = cbind(updates_df, real_time_data_table_adj)
  real_updates$lat_coord <- as.numeric(real_updates$lat_coord)
  real_updates$lon_coord <- as.numeric(real_updates$lon_coord)
  real_updates$train_queue <- as.numeric(real_updates$train_queue)
  real_updates$radius <- real_updates$train_queue * 2
  real_updates$color <- apply(real_updates[5], 1, color_fun)
  
  ##render the map
  output$subwaymap <- renderLeaflet({
    find_area <- as.numeric(input$region)
    lats <- list(40.7163, 40.7549, 40.8116, 40.7282)
    lons <- list(-74.0086, -73.9840, -73.9465, -73.7949)

    lng = lons[[find_area]]
    lat = lats[[find_area]]
    
    map <- leaflet() %>% 
      addProviderTiles("CartoDB.DarkMatter") %>%  
      addPolylines(data = shape_temp, color = 'blue') %>%
      addCircleMarkers(data = real_updates, lat = ~lat_coord, lng = ~lon_coord, radius = ~radius, color = ~color) %>%
      #addCircles(data = stop_coord, lat = ~lats, lng = ~lons, color = 'blue')
      setView(map, lng = lng, lat = lat, zoom = 14)
    #map
  })
  
  
  
  
})        
