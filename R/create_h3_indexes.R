#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param occurrences_weather
#' @return
#' @author Miles McBain
#' @export
create_h3_indexes <- function(occurrences_weather, h3_hex_resolutions) {

  occurrences_hexes <-
    st_as_sf(
      occurrences_weather,
      coords = c("decimalLongitude", "decimalLatitude"),
      remove = FALSE,
      crs = first(occurrences_weather$geodeticDatum)
    ) |>
    mutate(
      compute_h3_indices_at_resolutions(h3_hex_resolutions, geometry)
    ) |>
    st_drop_geometry() |>
    select(
      id,
      starts_with("h3")
    )

  occurrences_hexes

}
