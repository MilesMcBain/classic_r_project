##### Libraries #####
library(conflicted)
library(lubridate)
library(sf)
library(dplyr)
library(h3jsr)
library(readr)

conflicts_prefer(
  dplyr::filter
)

##### Wrangle data #####
# Process raw data into more standard form:
#   - address data quality issues
#   - add features base on time
#   - add spatial indicies for hex plotting
DATA_START_DATE <- ymd("2004-01-01")
occurrences <-
  readRDS(species_data_file_path) |>
  filter(
    scientificName %in% STUDY_SPECIES$species,
    occurrenceStatus == "PRESENT",
  ) |>
  mutate(
    date = as_date(eventDate),
    week_day = wday(eventDate),
    hour = hour(eventDate),
    month = month(eventDate)
  ) |>
  filter(
    date >= DATA_START_DATE
  )

# Weather data
# Originally fetched from SILO via {weatherOz}
weather_data_path <- "data/brisbane_weather.csv"
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

# Add spatial H3 hex indices
source("R/compute_h3_indices_at_resolutions.R")
h3_hex_resolutions <- c(7, 8, 9)
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

# Save the wrangled data
wrangled_data_path <- "data/wrangled_occurences_weather_data.Rds"
saveRDS(occurrences_weather_hexes, wrangled_data_path)
# Aside: not a great way to serialise spatial data. Look into geoarrow /
# geoparquet: convert geometry to WKB column.
