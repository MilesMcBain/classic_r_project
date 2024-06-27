fit_fold_calc_results <- function(split, num_trees, mtry) {
  model <-
    randomForest(
      scientificName ~ . - id,
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
    accuracy = sum(test_set$is_moluccus > 0.5 & test_set$is_moluccus == 1) / nrow(test_set),
    num_trees = num_trees,
    mtry = mtry
  )
}
