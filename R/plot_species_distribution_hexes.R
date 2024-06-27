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
plot_species_distribution_hexes <- function(
  occurrences_weather,
  brisbane_river,
  occurrences_hexes
) {

  hex_occurrences <-
    occurrences_weather |>
    left_join(occurrences_hexes, by = "id") |>
    st_drop_geometry() |>
    select(scientificName, h3_hex_8) |>
    summarise(
      count = n(),
      .by = c("scientificName", "h3_hex_8")
    ) |>
    mutate(
      geometry = cell_to_polygon(h3_hex_8)
    ) |>
    st_as_sf()

  p <-
    ggplot() +
    geom_sf(
      data = brisbane_river
    ) +
    geom_sf(
      data = hex_occurrences,
      mapping = aes(fill = log(count)),
      alpha = 0.7
    ) +
    scale_fill_viridis_c(labels = \(x) round(exp(x))) +
    facet_wrap(~scientificName) +
    theme_light()

  p
}
