#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param study_species
#' @param study_date
#' @param boundary_path
#' @return
#' @author Miles McBain
#' @export
fetch_data <- function(study_species, study_date, study_area_file) {
  study_area <- st_read(study_area_file)
  occurrences <-
    galah_call() |>
    identify(study_species) |>
    galah_geolocate(study_area) |>
    select(
      recordID,
      eventDate,
      scientificName,
      occurrenceStatus,
      geodeticDatum,
      decimalLatitude,
      decimalLongitude,
      dataResourceName,
      sex,
      reproductiveCondition,
      lifeStage,
      organismID
    ) |>
    atlas_occurrences() |>
    filter(
      eventDate < study_date
    )

}
