library(leaflet)
library(maptools)
library(maps)
library(shiny)
library(data.table)

##load the static data
shape <- read.csv('/data/sarah/w205/Sarah/google_transit/shapes.txt')
stop <- read.csv('/data/sarah/w205/Sarah/google_transit/stops.txt')

## load the real-time data
getRealData <- function(path) {
  real_time_file <- read.csv('/data/tim/w205/Parse/Output/update.csv', header = FALSE, stringsAsFactors = FALSE, na.strings = "\\N")
}

##pulling out latitude and longitude coordinates for stops
stop$stop_lon <- as.numeric(stop$stop_lon)
lons = stop$stop_lon
stop$stop_lat <- as.numeric(stop$stop_lat)
lats = stop$stop_lat
stop_id = stop$stop_id

ids <- unique(shape$shape_id)
shape_orig <- shape

stop_coord = data.frame(stop= stop$stop_id, name= stop$stop_name,lons = stop$stop_lon,lats = stop$stop_lat )
#stop_coord = stop_coord[complete.cases(stop_coord), ]


####processing updates
shinyServer(function(input, output, session) {
  
  ###creating a spatial object to map subway lines
  for(i in 1:length(ids)){
    shapes <- shape_orig[shape_orig$shape_id == ids[i],]
    shape_map <- list(x = shapes$shape_pt_lon, y = shapes$shape_pt_lat)
    shape_temp <- map2SpatialLines(shape_map, IDs = ids[i])
    #shape_lines <- spRbind(shape_lines, shape_temp)
  }
  
  # Region select input box
  part_choices <- reactive({
    as.list(c("Lower Manhattan" = 1L, "Midtown" = 2L, "Upper Manhattan" =3L, "Bronx" = 4L))
    #as.list(c(1L, 2L, 3L, 4L), names = )
  })
  
  observe({
    updateSelectInput(session, "region", choices=part_choices() )
  })
  
  vehicleLocations <- reactive({
    input$refresh
    interval <- max(as.numeric(input$interval), 30)
    ##invalidate after interval has passed
    invalidateLater(interval * 1000, session)
    getRealData()
  })
  
  lastUpdateTime <- reactive({
    vehicleLocations() # Trigger this reactive when updates come through
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
    ##add column headers
    names(updates) <- c("stop_id", "stop_name", "lat", "lon", "arrival_delay", "departure_delay", "vacant", "turnstile")
    
    ##format turnstile data to remove NAs and negative data
    updates[updates=="NA"] <- lapply(updates[updates=="NA"],as.numeric)
    updates[is.na(updates)] <- 1
    updates$turnstile <- as.numeric(updates$turnstile)
    
    unique_stop_ids <- unique(updates$stop_id)
    updates$arrival_delay <- as.numeric(updates$arrival_delay)
    updates$departure_delay <- as.numeric(updates$departure_delay)
    updates$turnstile <- as.numeric(updates$turnstile)
    updates$arrival_delay[updates$arrival_delay < 0] <- 0
    updates$departure_delay[updates$departure_delay < 0] <- 0
    
    ##functions to map coordinates to each of the stops
    find_lat <- function(unique_stop){
      lat = stop_coord[stop_coord$stop == unique_stop, 4]
      return (lat)
    }
    find_lon <- function(unique_stop){
      lon = stop_coord[stop_coord$stop == unique_stop, 3]
      return (lon)
    }
    ### function to aggregate delays by delays
    find_delays <- function(stop){
      stop_filter <- updates[updates$stop_id == stop, ]
      delays <- sum(stop_filter$departure_delay[stop_filter$departure_delay > 0])
      return(delays)
    }
    ### function to pull turnstile data by stop
    find_turnstile <- function(stop){
      stop_filter <- updates[updates$stop_id == stop, ]
      turnstile <- mean(as.numeric(stop_filter$turnstile))
      return (turnstile)
    }
    ##function to find stop name
    find_name <- function(stop){
      line <- head(stop_coord[stop_coord$stop == stop, ], 1)
      name <- line$name
      return(name)
    }
    
    find_region <- function(longitude_coord){
      coordinate <- as.numeric(longitude_coord)
      #lons <- list(-74.0086, -73.9840, -73.9465, -73.8899)
      if(coordinate < -74.0086 ){
        region = 1
      }
      if((coordinate < -73.975) & (coordinate >= -74.0086)){
        region = 2
      }
      if ((coordinate < -73.90) & (coordinate >= -73.975)){
        region = 3
      }
      if ((coordinate >=-73.90)){
        region = 4
      }
      return (region)
    }
    
    color_fun <- function(train_queue){
      if (train_queue <= 0) {
        color = 'black'
      }
      else {
        color = 'yellow'
      }
      return (color)
    }
    
    turn_color <- function(turnstile){
      if (as.numeric(turnstile) > 1000000) {
        t_color = 'red'
      }
      else {
        t_color = 'green'
      }
      return (t_color)
    }
    
    ##create a dataframe with the latest updates
    updates_df = data.frame(unique_stop = unique_stop_ids, lat_coord = seq(0,0,length.out=length(unique_stop_ids)), lon_coord = seq(0,0,length.out=length(unique_stop_ids)) )
    
    #lons <- list(-74.0086, -73.9840, -73.9465, -73.8899)
    updates_df["stop_name"] <- apply(updates_df[1], 1, find_name)
    updates_df["lat_coord"] <- apply(updates_df[1], 1, find_lat)
    updates_df["lon_coord"] <- apply(updates_df[1], 1, find_lon)
    updates_df["region"] <-apply(updates_df["lon_coord"], 1, find_region)
    updates_df["delays"] <- apply(updates_df[1], 1, find_delays)
    updates_df["turnstile"] <- apply(updates_df[1], 1, find_turnstile)
    updates_df$radius <- updates_df$delays/500
    updates_df$color <- apply(updates_df["delays"], 1, color_fun)
    updates_df$t_color <- apply(updates_df["turnstile"], 1, turn_color)
    
    return (updates_df)
  })
  
  ##Station table
  output$stationMetrics <- renderUI({
    r <- routeVehicleLocations()
    region_filter <- input$region
    r_filter <- r[r$delays > 0, ] #filter for stations with delays 
    #r_filter <- r_filter[r_filter$turnstiles > 1, ] #filter for actual turnstile data
    r_filter <- r_filter[order(r_filter$delays, decreasing =T),] #sort by highest delays 
    r_filter <- head(r_filter[r_filter$region == region_filter, ], 5) #then by region 
    
    tags$table(class = "table",
               tags$thead(tags$tr(
                 tags$th("Stop"),
                 tags$th("Stop Name"),
                 tags$th("Average Delay (in mins)"),
                 tags$th("Turnstile Volume (visitors per hour)")
               )),
               tags$tbody(
                 tags$tr(
                   tags$td(r_filter$unique_stop[1]),
                   tags$td(r_filter$stop_name[1]),
                   tags$td(as.integer(r_filter$delays[1]/60/10)),
                   tags$td(ifelse(as.integer(r_filter$turnstile[1]/35/24) > 1,as.integer(r_filter$turnstile[1]/35/24),"NA" )) #to get visitors per hour from 5 week data
                 ),
                 tags$tr(
                   tags$td(r_filter$unique_stop[2]),
                   tags$td(r_filter$stop_name[2]),
                   tags$td(as.integer(r_filter$delays[2]/60/10)),
                   tags$td(ifelse(as.integer(r_filter$turnstile[2]/35/24) > 1,as.integer(r_filter$turnstile[2]/35/24),"NA" ))
                 ),
                 tags$tr(
                   tags$td(r_filter$unique_stop[3]),
                   tags$td(r_filter$stop_name[3]),
                   tags$td(as.integer(r_filter$delays[3]/60/10)),
                   tags$td(ifelse(as.integer(r_filter$turnstile[3]/35/24) > 1,as.integer(r_filter$turnstile[3]/35/24),"NA" ))
                 ),
                 tags$tr(
                   tags$td(r_filter$unique_stop[4]),
                   tags$td(r_filter$stop_name[4]),
                   tags$td(as.integer(r_filter$delays[4]/60)),
                   tags$td(ifelse(as.integer(r_filter$turnstile[4]/35/24) > 1,as.integer(r_filter$turnstile[4]/35/24),"NA" ))
                 ),
                 tags$tr(
                   tags$td(r_filter$unique_stop[5]),
                   tags$td(r_filter$stop_name[5]),
                   tags$td(as.integer(r_filter$delays[5]/60/10)),
                   tags$td(ifelse(as.integer(r_filter$turnstile[5]/35/24) > 1,as.integer(r_filter$turnstile[5]/35/24),"NA" ))
                 )
               ))
    
  })
  
  ##create a custom Legend with color code for map
  addLegendCustom <- function(map, colors, labels, sizes, opacity = 0.5){
    colorAdditions <- paste0(colors, "; width:", sizes, "px; height:", sizes, "px")
    labelAdditions <- paste0("<div style='display: inline-block;height: ",sizes, "px;margin-top: 4px;line-height: ", sizes, "px;'>", labels, "</div>")
    
    return(addLegend(map, colors = colorAdditions, labels = labelAdditions, opacity = opacity))
  }
  
  ##render the map
  output$subwaymap <- renderLeaflet({
    r2 <- routeVehicleLocations()
    
    find_area <- as.numeric(input$region)
    lats <- list(40.7163, 40.7549, 40.8116, 40.8566)
    lons <- list(-74.0086, -73.9840, -73.9465, -73.8899)
    
    lng = lons[[find_area]]
    lat = lats[[find_area]]
    
    map <- leaflet() %>% 
      addProviderTiles("CartoDB.DarkMatter") %>%  
      addPolylines(data = shape_temp, color = 'blue') %>%
      addCircleMarkers(data = r2, lat = ~lat_coord, lng = ~lon_coord, radius = ~radius, color = ~color) %>%
      addCircleMarkers(data = r2, lat = ~lat_coord, lng = ~lon_coord, radius = 2, color = ~t_color) %>%
      setView(map, lng = lng, lat = lat, zoom = 13)
    addLegendCustom(map, colors = c("red", "green", "yellow"), labels = c("high traffic subway stop", "low traffic subway stop", "delays"), sizes = c(10, 10, 20))
    #map
  })
  
  
  
  
})   
