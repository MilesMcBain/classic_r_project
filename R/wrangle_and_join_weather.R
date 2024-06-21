#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param data_start_date
#' @param weather_data_path
#' @param specie_data
#' @return
#' @author Miles McBain
#' @export
wrangle_and_join_weather <- function(
  species_data,
  study_species,
  data_start_date,
  weather_data_path,
  h3_hex_resolutions
) {

  occurrences <-
    species_data |>
    filter(
      scientificName %in% study_species$species,
      occurrenceStatus == "PRESENT",
    ) |>
    mutate(
      date = as_date(eventDate),
      week_day = wday(eventDate),
      hour = hour(eventDate),
      month = month(eventDate)
    ) |>
    filter(
      date >= data_start_date
    )

  brisbane_weather_history <-
    read_csv(weather_data_path) |>
    select(
      date,
      air_tmax,
      air_tmin,
      vp
    )

  # join weather data
  occurrences_weather <-
    occurrences |>
    left_join(
      brisbane_weather_history,
      by = "date"
    )

  occurrences_weather_hexes <-
    st_as_sf(
      occurrences_weather,
      coords = c("decimalLongitude", "decimalLatitude"),
      remove = FALSE,
      crs = first(occurrences$geodeticDatum)
    ) |>
    mutate(
      compute_h3_indices_at_resolutions(h3_hex_resolutions, geometry)
    )

  occurrences_weather_hexes
}
