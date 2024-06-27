#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param species_model_validation_data
#' @param brisbane_river
#' @param h3_hex_resolutions
#' @return
#' @author Miles McBain
#' @export
plot_species_class_accuracy_hexes <- function(
  species_model_validation_data,
  brisbane_river,
  occurrences_hexes
) {

  # Add hexagon indicies
  model_validation_predictions_hex <-
    species_model_validation_data |>
    left_join(occurrences_hexes, by = "id")

  # Summarise by hexagon
  validation_data_hex_summary <-
    model_validation_predictions_hex |>
    summarise(
      accuracy = sum(correct) / n(),
      .by = c(scientificName, h3_hex_8),
    ) |>
    mutate(
      geometry = cell_to_polygon(h3_hex_8)
    ) |>
    st_as_sf(
      crs = 4326
    )

  p <-
    ggplot() +
    geom_sf(
      data = brisbane_river
    ) +
    geom_sf(
      data = validation_data_hex_summary,
      mapping = aes(fill = accuracy),
      alpha = 0.7
    ) +
    scale_fill_viridis_c() +
    facet_wrap(~scientificName) +
    labs(
      title = "Spatial distribution of model accuracy"
    ) +
    theme_light()

  p
}
