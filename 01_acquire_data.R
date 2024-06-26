##### Libraries #####
library(conflicted)
library(galah)
library(lubridate)
library(sf)
library(dplyr)

conflicts_prefer()

##### Options / Environment variables / GLOBALS #####

galah_config(
  atlas = "ALA",
  email = Sys.getenv("ALA_EMAIL") # You can replace this with your email to run. But you might not want to commit it to a public repository!
)
STUDY_SPECIES <- search_taxa(c("Threskiornis molucca", "Threskiornis spinicollis"))
STUDY_DATE <- ymd("2024-05-08")

search_taxa("Ibis")

##### Fetch Data #####

# Species distriubtion data
# If data file not present, fetch it from API
# and save it for local use.
species_data_file_path <- file.path("data", "species_data.Rds")
if (!file.exists(species_data_file_path)) {
  inner_brisbane_boundary <- "data/inner_brisbane.geojson"
  study_area <- read_sf(inner_brisbane_boundary)
  occurrences <-
    galah_call() |>
    identify(STUDY_SPECIES) |>
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
      eventDate < STUDY_DATE
    )
  # for some reason eventDate <= study_date did not work in galah_filter
  # it gave a HTTP 400 bad request with auth failure.
  # Perhaps some fields are restricted for queries?
  # So instead we do filtering here.

  # Save dataset
  saveRDS(occurrences, species_data_file_path)
}
