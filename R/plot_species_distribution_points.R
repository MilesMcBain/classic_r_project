#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param occurrences_weather_hexes
#' @param brisbane_river
#' @return
#' @author Miles McBain
#' @export
plot_species_distribution_points <- function(
  occurrences_weather,
  brisbane_river
) {

  occurrences_weather_points <-
    occurrences_weather |>
    st_as_sf(
      coords = c("decimalLongitude", "decimalLatitude"),
      remove = FALSE,
      crs = first(occurrences_weather$geodeticDatum)
    )

  p <-
  ggplot() +
  geom_sf(
    data = brisbane_river
  ) +
    geom_sf(
      data = occurrences_weather_points
    ) +
    facet_wrap(~scientificName) +
    theme_light() +
    theme()

  p

}
