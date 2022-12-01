box::use(
  shiny[
    bootstrapPage, moduleServer, NS, fixedRow, column,
    observeEvent, renderUI, uiOutput, tags, reactiveValues
  ],
  leaflet[leafletOutput],
  sf[st_read],
)

box::use(
  logic/map,
  logic/utils,
)

map_data <- st_read(dsn = "app/static/data/map_data.shp", quiet = TRUE)

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    fixedRow(
      column(
        6,
        tags$h1("Slow re-rendering"),
        utils$color_selector(ns("slow_change_colors")),
        leafletOutput(ns("slow_map")),
        uiOutput(ns("slow_time"))
      ),
      column(
        6,
        tags$h1("Fast re-rendering"),
        utils$color_selector(ns("fast_change_colors")),
        leafletOutput(ns("fast_map")),
        uiOutput(ns("fast_time"))
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$slow_map <- map$create_map(map_data)
    output$fast_map <- map$create_map(map_data)
    runtimes <- reactiveValues(slow = NA, fast = NA)

    observeEvent(input$slow_change_colors, {
      t1 <- Sys.time()
      map$slow_update_polygon_colors("slow_map", map_data, input$slow_change_colors)
      t2 <- Sys.time()
      runtimes$slow <- round((t2 - t1) * 1000, 3)
    }, ignoreInit = TRUE)
    output$slow_time <- renderUI(tags$h2(paste("Execution time:", runtimes$slow, "msec")))

    observeEvent(input$fast_change_colors, {
      t1 <- Sys.time()
      map$fast_update_polygon_colors("fast_map", map_data, input$fast_change_colors)
      t2 <- Sys.time()
      runtimes$fast <- round((t2 - t1) * 1000, 3)
    }, ignoreInit = TRUE)
    output$fast_time <- renderUI(tags$h2(paste("Execution time:", runtimes$fast, "msec")))
  })
}
