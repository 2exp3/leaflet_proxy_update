box::use(
  leaflet[...],
  htmlwidgets[onRender, JS],
  magrittr[`%>%`],
)

#' @export
create_map <- function(map_data) {
  renderLeaflet({
    leaflet(
      data = map_data,
      options = leafletOptions(
        preferCanvas = TRUE,
        zoomControl = FALSE,
        minZoom = 0.5,
        attributionControl = TRUE
      )
    ) %>%
      setView(lng = 10, lat = 25, zoom = 1) %>%
      addProviderTiles(
        providers$CartoDB.VoyagerNoLabels,
        options = providerTileOptions(
          updateWhenZooming = FALSE,
          updateWhenIdle = FALSE
        )
      ) %>%
      addPolygons(
        layerId = ~ISO3c,
        color = "black",
        fillColor = "#e2e2e2",
        dashArray = "3",
        weight = 1,
        smoothFactor = 1,
        fillOpacity = 1,
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          dashArray = "",
          fillOpacity = 0.9,
          bringToFront = FALSE
        )
      ) %>%
      onRender(
        JS(
          "function(el, x) {
          var map = this; map._initialCenter = map.getCenter();
          map._initialZoom = map.getZoom();
          }"
        )
      )
  })
}

#' @export
slow_update_polygon_colors <- function(map_id, map_data, new_color) {
  leafletProxy(map_id, data = map_data) %>%
    addPolygons(
      layerId = ~ISO3c,
      color = "black",
      fillColor = new_color,
      dashArray = "3",
      weight = 1,
      smoothFactor = 1,
      fillOpacity = 1,
      highlightOptions = highlightOptions(
        color = "white",
        weight = 2,
        dashArray = "",
        fillOpacity = 0.9,
        bringToFront = FALSE
      )
    )
}

#' @export
fast_update_polygon_colors <- function(map_id, map_data, new_color) {
  leafletProxy(map_id, data = map_data) %>%
    set_shape_fill_color(
      layer_id = ~ISO3c,
      fill_color = new_color
    )
}

set_shape_fill_color <- function(map, layer_id, fill_color = NULL, options = NULL) {
  data <- getMapData(map)
  options <- c(
    list(layerId = layer_id),
    options,
    filterNULL(list(fillColor = fill_color))
  )

  options <- evalFormula(options, data = data)
  options <- do.call(data.frame, c(options, list(stringsAsFactors = FALSE)))

  layer_id <- options[[1]]
  style <- options[-1]

  invokeMethod(map, data, "setFill", "shape", layer_id, style)
}
