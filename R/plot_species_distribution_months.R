#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param occurrences_weather_hexes
#' @return
#' @author Miles McBain
#' @export
plot_species_distribution_months <- function(occurrences_weather_hexes) {

  p <-
    occurrences_weather_hexes |>
    ggplot(aes(x = as.factor(month))) +
    scale_x_discrete(labels = month.abb) +
    geom_bar() +
    labs(
      title = "Count of species oberservations by month",
      x = "month"
    ) +
    facet_wrap(~scientificName) +
    theme_light()

  p

}
