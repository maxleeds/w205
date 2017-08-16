#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(leaflet)
library(maptools)
library(maps)
library(shiny)
library(data.table)

shape <- read.csv('/Users/sarahcha/Documents/W205/final_project/google_transit/shapes.txt')
stop <- read.csv('/Users/sarahcha/Documents/W205/final_project/google_transit/stops.txt')


shinyServer(function(input, output) {
    
    ##pulling out latitude and longitude coordinates for stops
    stop$stop_lon <- as.numeric(stop$stop_lon)
    lons = stop$stop_lon
    stop$stop_lat <- as.numeric(stop$stop_lat)
    lats = stop$stop_lat
    stop_id = stop$stop_id
    stop_coord = data.frame(stop= stop$stop_id, lons = stop$stop_lon,lats = stop$stop_lat )
    stop_coord = stop_coord[complete.cases(stop_coord), ]
    
    shape$shape_id
    ids <- unique(shape$shape_id)
    shape_orig <- shape
    #length(ids)

    ###creating a spatial object to map subway lines
    for(i in 1:10){
      shape <- shape_orig[shape_orig$shape_id == ids[i],]
      shape_map <- list(x = shape$shape_pt_lon, y = shape$shape_pt_lat)
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
    
    head(real_time_data_table_adj)
    real_updates = cbind(updates_df, real_time_data_table_adj)
    real_updates$lat_coord <- as.numeric(real_updates$lat_coord)
    real_updates$lon_coord <- as.numeric(real_updates$lon_coord)
    real_updates$train_queue <- as.numeric(real_updates$train_queue)
    real_updates$radius <- real_updates$train_queue * 2
    real_updates$color <- apply(real_updates[5], 1, color_fun)

    
    output$map <- renderLeaflet({
    leaflet() %>% 
      addTiles() %>%
      addPolylines(data = shape_temp, color = 'blue') %>%
      addCircleMarkers(data = real_updates, lat = ~lat_coord, lng = ~lon_coord, radius = ~radius, color = ~color) 
      #addCircles(data = stop_coord, lat = ~lats, lng = ~lons, color = 'blue')
    })  

})
