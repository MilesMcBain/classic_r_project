#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param species_classification_model
#' @param testing_data
#' @return
#' @author Miles McBain
#' @export
create_validation_data <- function(
  species_classification_model,
  test_data
) {

  model_validation_data <- test_data

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
    bind_cols(probability_predictions) |>
    mutate(
      correct = if_else(scientificName == predicted_class, 1, 0)
    )

  model_validation_predictions
}
