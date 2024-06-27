#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param training_data
#' @param species_classification_model_training_summary
#' @param
#' @return
#' @author Miles McBain
#' @export
fit_final_species_classification_model <- function(
  training_data,
  species_classification_model_training_summary
) {

  summarised_training_results <- species_classification_model_training_summary
  # Our best model by AUC is not row 1
  # Train best model
  species_classification_model <-
    randomForest(
      scientificName ~ . - id,
      data = training_data,
      mtry = first(summarised_training_results$mtry),
      ntree = first(summarised_training_results$num_trees)
    )

  species_classification_model
}
