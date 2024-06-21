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
  occurrences_weather_hexes,
  brisbane_river
) {
  p <-
  ggplot() +
  geom_sf(
    data = brisbane_river
  ) +
    geom_sf(
      data = occurrences_weather_hexes
    ) +
    facet_wrap(~scientificName) +
    theme_light() +
    theme()

  p

}
