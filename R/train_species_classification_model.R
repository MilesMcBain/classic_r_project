#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param trainging_data
#' @param n_cv_folds
#' @param mtry_candidates
#' @param num_trees_candidates
#' @return
#' @author Miles McBain
#' @export
species_classification_model_grid_search <- function(
  training_data,
  n_cv_folds,
  mtry_candidates,
  num_trees_candidates
) {

  occurrence_cv_splits <-
    vfold_cv(training_data, v = 5, repeats = 1)

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

  summarised_training_results
}

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
