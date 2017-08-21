
library(leaflet)
library(maptools)
library(maps)
library(shiny)
library(data.table)

##load the static data
shape <- read.csv('/Users/sarahcha/Documents/W205/final_project/google_transit/shapes.txt')
stop <- read.csv('/Users/sarahcha/Documents/W205/final_project/google_transit/stops.txt')

## load the real-time data
getRealData <- function(path) {
  file <- read.csv('/Users/sarahcha/Documents/W205/final_project/batch_data/trip_update.csv')
}

##pulling out latitude and longitude coordinates for stops
stop$stop_lon <- as.numeric(stop$stop_lon)
lons = stop$stop_lon
stop$stop_lat <- as.numeric(stop$stop_lat)
lats = stop$stop_lat
stop_id = stop$stop_id

ids <- unique(shape$shape_id)
shape_orig <- shape
#length(ids)

####processing updates
stop_coord = data.frame(stop= stop$stop_id, lons = stop$stop_lon,lats = stop$stop_lat )
#stop_coord = stop_coord[complete.cases(stop_coord), ]
shinyServer(function(input, output, session) {
  
  ###creating a spatial object to map subway lines
  for(i in 1:10){
    shapes <- shape_orig[shape_orig$shape_id == ids[i],]
    shape_map <- list(x = shapes$shape_pt_lon, y = shapes$shape_pt_lat)
    shape_temp <- map2SpatialLines(shape_map, IDs = ids[i])
    #shape_lines <- spRbind(shape_lines, shape_temp)
  }
  
  # Region select input box
  part_choices <- reactive({
    as.list(c(1L, 2L, 3L, 4L), names = c('Lower Manhattan', "Midtown", "Upper Manhattan", "Bronx"))
  })
  
  observe({
    updateSelectInput(session, "region", choices=part_choices())
  })
  
  vehicleLocations <- reactive({
    input$refresh
    interval <- max(as.numeric(input$interval), 30)
    ##invalidate this reactive after interval has passed
    invalidateLater(interval * 1000, session)
    getRealData()
  })
  
  lastUpdateTime <- reactive({
    vehicleLocations() # Trigger this reactive when vehicles locations are updated
    Sys.time()
  })
  
  # Number of seconds since last update
  output$timeSinceLastUpdate <- renderUI({
    # Trigger this every 5 seconds
    invalidateLater(5000, session)
    p(
      class = "text-muted",
      "Data refreshed ",
      round(difftime(Sys.time(), lastUpdateTime(), units="secs")),
      " seconds ago."
    )
  })
  
  routeVehicleLocations <- reactive({
    updates <- vehicleLocations()
  
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
  find_region <- function(longitude_coord){
    coordinate <- as.numeric(longitude_coord)
    if(coordinate < -73.98 ){
      region = 1
    }
    if((coordinate < -73.9465) & (coordinate >= -73.98)){
      region = 2
    }
    if ((coordinate < -73.7949) & (coordinate >= -73.9465)){
      region = 3
    }
    if ((coordinate >=-73.7949)){
      region = 4
    }
    return (region)
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
  lons <- list(-74.0086, -73.9840, -73.9465, -73.7949)
  updates_df["lat_coord"] <- apply(updates_df[1], 1, find_lat)
  updates_df["lon_coord"] <- apply(updates_df[1], 1, find_lon)
  updates_df["region"] <-apply(updates_df["lon_coord"], 1, find_region)
  
  real_time_data_table =data.table(updates)
  real_time_data_table_adj = real_time_data_table[, list(train_queue = sum (arrival_delay > 0 , departure_delay > 0 ), length (arrival_delay[arrival_delay != 0])+ length (departure_delay[departure_delay != 0]), freq = .N), by = c("stop_id")]
  
  real_updates = cbind(updates_df, real_time_data_table_adj)
  
  real_updates$lat_coord <- as.numeric(real_updates$lat_coord)
  real_updates$lon_coord <- as.numeric(real_updates$lon_coord)
  real_updates$train_queue <- as.numeric(real_updates$train_queue)
  real_updates$radius <- real_updates$train_queue * 2
  real_updates$color <- apply(real_updates[6], 1, color_fun)
  
  return (real_updates)
  })
  
  ##Station table
  output$stationMetrics <- renderUI({
    r <- routeVehicleLocations()
    region_filter <- input$region
    r_filter <- head(r[order(r$train_queue, decreasing =F),], n = 5)
    r_filter <- r_filter[r_filter$region == region_filter, ]
    
    tags$table(class = "table",
               tags$thead(tags$tr(
                 tags$th("Stop"),
                 tags$th("Average Delay"),
                 tags$th("Average Turnstile Swipes")
               )),
               tags$tbody(
                 tags$tr(
                   tags$td(r_filter$unique_stop[1]),
                   tags$td(r_filter$train_queue[1]),
                   tags$td("NULL")
                 )))
                 
  })
  ##render the map
  output$subwaymap <- renderLeaflet({
    r2 <- routeVehicleLocations()
    
    find_area <- as.numeric(input$region)
    lats <- list(40.7163, 40.7549, 40.8116, 40.7282)
    lons <- list(-74.0086, -73.9840, -73.9465, -73.7949)

    lng = lons[[find_area]]
    lat = lats[[find_area]]
    
    map <- leaflet() %>% 
      addProviderTiles("CartoDB.DarkMatter") %>%  
      addPolylines(data = shape_temp, color = 'blue') %>%
      addCircleMarkers(data = r2, lat = ~lat_coord, lng = ~lon_coord, radius = ~radius, color = ~color) %>%
      #addCircles(data = stop_coord, lat = ~lats, lng = ~lons, color = 'blue')
      setView(map, lng = lng, lat = lat, zoom = 13)
    #map
  })
  
  
  
  
})        
