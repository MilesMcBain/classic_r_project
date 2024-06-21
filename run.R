##### Libraries #####
library(conflicted)
library(dplyr)
library(galah)
library(ggplot2)
library(h3jsr)
library(lubridate)
library(pROC)
library(purrr)
library(randomForest)
library(readr)
library(rmarkdown)
library(rsample)
library(sf)
library(tibble)
library(tidyr)
# Source all functions
list.files(path = "R", pattern = "^.*\\.R$", full.names = TRUE) |>
lapply(source, verbose = FALSE)

conflicts_prefer(
  dplyr::filter,
  tidyr::unnest
)

##### Options / Environment variables / GLOBALS #####
galah_config(
  atlas = "ALA",
  email = Sys.getenv("ALA_EMAIL") # You can replace this with your email to run. But you might now want to commit it to a public repository!
)
study_species <- search_taxa(c("Threskiornis molucca", "Threskiornis spinicollis"))
study_date <- ymd("2024-05-08")
data_start_date <- ymd("2004-01-01")
h3_hex_resolutions <- c(7, 8, 9)
set.seed(2048)

##### Data files #####
weather_data_path <- "data/brisbane_weather.csv"
inner_brisbane_boundary <- "data/inner_brisbane.geojson"
brisbane_river_file <- "data/brisbane_river.geojson"


##### Fetch Data ####
occurrences <- fetch_data(
  study_species,
  study_date,
  study_area_file = inner_brisbane_boundary
)

#### Wrangle Data #####
occurrences_weather_hexes <-
  wrangle_and_join_weather(
    species_data = occurrences,
    study_species,
    data_start_date,
    weather_data_path,
    h3_hex_resolutions
  )

##### Visualise Data #####
brisbane_river <- st_read(brisbane_river_file)
gg_species_distribution_points <-
  plot_species_distribution_points(
    occurrences_weather_hexes,
    brisbane_river
  )

gg_species_distribution_hexes <-
  plot_species_distribution_hexes(
    occurrences_weather_hexes,
    brisbane_river
  )

gg_species_distribution_months <-
  plot_species_distribution_months(
    occurrences_weather_hexes
  )

##### Model Data #####
occurrences_training_data <-
  create_trainging_data(occurrences_weather_hexes)

test_train_split <-
  initial_split(occurrences_training_data)

species_classification_model_training_summary <-
  species_classification_model_grid_search(
    training_data = training(test_train_split),
    n_cv_folds = 5,
    mtry_candidates = c(1, 2, 3),
    num_trees_candidates = c(200, 500, 100)
  )

species_classification_model <-
  fit_final_species_classification_model(
    training_data = training(test_train_split),
    species_classification_model_training_summary
  )

species_model_validation_data <-
  create_validation_data(
    species_classification_model,
    test_data = testing(test_train_split)
  )

##### Visualise Model #####
gg_species_class_accuracy_hexes <-
  plot_species_class_accuracy_hexes(
    species_model_validation_data,
    brisbane_river,
    h3_hex_resolutions
  )

# need to call plot on this one in our Rmd
base_plot_model_roc_object <-
  get_species_classifier_roc(
    species_model_validation_data
  )

render("docs/report.Rmd")
