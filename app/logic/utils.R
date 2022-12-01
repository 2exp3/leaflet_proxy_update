box::use(
  shiny[selectInput],
)

#' @export
color_selector <- function(id) {
  selectInput(
    inputId = id,
    label = "Change shape color",
    choices = c("blue", "green", "red", "yellow", "black")
  )
}
