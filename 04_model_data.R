##### Libraries #####
library(conflicted)
library(dplyr)
library(randomForest)
library(rsample)
library(tidyr)
library(tibble)
library(sf)
library(purrr)
library(pROC)

conflicts_prefer(
  tidyr::unnest
)

occurrence_training_data <-
  readRDS("data/wrangled_occurences_weather_data.Rds") |>
  st_drop_geometry() |>
  select(
    scientificName,
    decimalLatitude,
    decimalLongitude,
    hour,
    month,
    air_tmin,
    air_tmax,
    vp
  ) |>
  mutate(
    scientificName = as.factor(scientificName)
  )

set.seed(2048)
# test/train split
test_train_split <-
  initial_split(occurrence_training_data)

# N fold SV of training set so we can get distribution of performance measures
N_CV_FOLDS <- 5
occurrence_cv_splits <-
  vfold_cv(training(test_train_split), v = 5, repeats = 1)

# Hyperparameter space
mtry_candidates <- c(1, 2, 3)
num_trees_candidates <- c(200, 500, 100)

# Each combination of hyper parameters gets an n-fold-cv fit
training_grid <-
  expand.grid(
    fold_id = occurrence_cv_splits$id,
    mtry = mtry_candidates,
    num_trees = num_trees_candidates
  ) |>
  as_tibble() |>
  left_join(
    occurrence_cv_splits,
    by = c(fold_id = "id")
  )

# A function that fits a single fold of data with a single set of hyperpameters
# 2 performance measures are reported: AUC and Accuracy
fit_fold_calc_results <- function(split, num_trees, mtry) {
  model <-
    randomForest(
      scientificName ~ .,
      data = training(split),
      mtry = mtry,
      ntree = num_trees
    )
  test_set <-
    testing(split) |>
    mutate(
      is_moluccus = if_else(
        scientificName == "Threskiornis moluccus",
        1,
        0
      )
    )
  test_set$predicted_prob_is_moluccus <-
    predict(
      model,
      newdata = test_set,
      type = "prob"
    ) |>
    _[, 1] # We get a matrix with 2 columns, 1 per class. Threskiornis moluccus is column 1.

  roc_object <- roc(
    test_set$is_moluccus,
    test_set$predicted_prob_is_moluccus
  )

  # use auc and accuracy as our summary statistics
  data.frame(
    auc = auc(roc_object) |> as.numeric(),
    accuracy = sum(test_set$is_moluccus > 0.5 & test_set$is_moluccus == 1) / nrow(test_set)
  )
}

# Fit model to every entry in training grid
# Can take a while on a single core...
# To go multi-core we could swap purrr iterator for furrr version.
training_results <-
  training_grid |>
  mutate(
    pmap(
      .l = list(
        training_grid$splits,
        training_grid$num_trees,
        training_grid$mtry
      ),
      .f = fit_fold_calc_results
    ) |>
      bind_rows()
    # by returning a dataframe inside mutate, the resulting columns are appended to training_grid
  )

summarised_training_results <-
  training_results |>
  summarise(
    mean_auc = mean(auc),
    sd_auc = sd(auc),
    mean_accuracy = mean(accuracy),
    sd_accuracy = sd(accuracy),
    .by = c(mtry, num_trees)
  ) |>
  arrange(-mean_auc)

# Our best model by AUC is not row 1
# Train best model
species_classification_model <-
  randomForest(
    scientificName ~ .,
    data = training(test_train_split),
    mtry = first(summarised_training_results$mtry),
    ntree = first(summarised_training_results$num_trees)
  )
saveRDS(species_classification_model, "output/species_classifier.Rds")

# Save our validation set so we can visualise performance
model_validation_data <-
  testing(test_train_split)

class_predictions <-
  predict(
    species_classification_model,
    newdata = model_validation_data,
  )
probability_predictions <-
  predict(
    species_classification_model,
    newdata = model_validation_data,
    type = "prob"
  ) |>
  as.data.frame() |>
  setNames(c("prob_moluccus", "prob_spinicollis"))

model_validation_predictions <-
  model_validation_data |>
  mutate(
    predicted_class = class_predictions
  ) |>
  bind_cols(probability_predictions)

saveRDS(model_validation_predictions, "output/model_validation_predicitons.Rds")
