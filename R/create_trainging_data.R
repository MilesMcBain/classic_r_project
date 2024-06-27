#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param occurrences_weather_hexes
#' @return
#' @author Miles McBain
#' @export
create_trainging_data <- function(occurrences_weather_hexes) {

  occurrences_weather_hexes |>
  st_drop_geometry() |>
  select(
    scientificName,
    decimalLatitude,
    decimalLongitude,
    hour,
    month,
    air_tmin,
    air_tmax,
    vp,
    id
  ) |>
  mutate(
    scientificName = as.factor(scientificName)
  )

}
