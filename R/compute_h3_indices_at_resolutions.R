#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param h3_hex_resolutions
#' @param geometry
#' @return
#' @author Miles McBain
#' @export
compute_h3_indices_at_resolutions <- function(
  resolutions,
  point_geometry
) {
  lapply(
    resolutions,
    \(res, geometry) {
      h3jsr::point_to_cell(geometry, res = res)
    },
    point_geometry
  ) |>
    setNames(paste0("h3_hex_", resolutions)) |>
    as.data.frame()
}
