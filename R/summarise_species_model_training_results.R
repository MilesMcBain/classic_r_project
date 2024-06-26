#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param species_classification_model_training_results
#' @return
#' @author Miles McBain
#' @export
summarise_species_model_training_results <- function(species_classification_model_training_results) {

  summarised_training_results <-
    species_classification_model_training_results |>
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
