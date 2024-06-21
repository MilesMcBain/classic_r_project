#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param species_model_validation_data
#' @return
#' @author Miles McBain
#' @export
get_species_classifier_roc <- function(species_model_validation_data) {

  roc_object <- roc(
    species_model_validation_data$predicted_class == "Threskiornis moluccus" &
      species_model_validation_data$scientificName == "Threskiornis moluccus",
    species_model_validation_data$prob_moluccus
  )

  roc_object

}
