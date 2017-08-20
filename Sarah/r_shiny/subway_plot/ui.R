#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shinydashboard)
library(leaflet)

header <- dashboardHeader(
  title = "NYC Subway Station Traffic Tracker"
)

body <- dashboardBody(
  fluidRow(
    column(width = 9,
           box(width = NULL, solidHeader = TRUE,
               leafletOutput("subwaymap", height = 500)
           ),
           box(width = NULL,
               uiOutput("stationMetrics")
           )
    ),
    column(width = 3,
           box(width = NULL, status = "warning",
               selectInput("region", label= "Region", choices = "1", selected = "1"),
               p(
                 class = "text-muted",
                 paste("Note: please only select one region."
                 )
               )
           ),
           box(width = NULL, status = "warning",
               selectInput("interval", "Refresh interval",
                           choices = c(
                             "30 seconds" = 30,
                             "1 minute" = 60,
                             "2 minutes" = 120,
                             "5 minutes" = 300,
                             "10 minutes" = 600
                           ),
                           selected = "60"
               ),
               uiOutput("timeSinceLastUpdate"),
               actionButton("refresh", "Refresh now"),
               p(class = "text-muted",
                 br(),
                 "Source data updates every 30 seconds."
               )
           )
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)


