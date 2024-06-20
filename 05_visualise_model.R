##### Libraries #####
library(conflicted)
library(dplyr)
library(sf)
library(h3jsr)
library(ggplot2)
library(pROC)

model_validation_predictions <-
  readRDS("output/model_validation_predicitons.Rds") |>
  mutate(
    correct = if_else(scientificName == predicted_class, 1, 0)
  )


# Spatial distribution of model class accuracy
source("R/compute_h3_indices_at_resolutions.R")
h3_hex_resolutions <- c(7, 8, 9)
model_validation_predictions_hex <-
  model_validation_predictions |>
  st_as_sf(
    coords = c("decimalLongitude", "decimalLatitude"),
    remove = FALSE,
    crs = 4326
  ) |>
  mutate(
    compute_h3_indices_at_resolutions(h3_hex_resolutions, geometry)
  ) |>
  st_drop_geometry()

# plot data
validation_data_hex_summary <-
  model_validation_predictions_hex |>
  summarise(
    accuracy = sum(correct) / n(),
    .by = c(scientificName, h3_hex_8),
  ) |>
  mutate(
    geometry = cell_to_polygon(h3_hex_8)
  ) |>
  st_as_sf(
    crs = 4326
  )

## plot background
brisbane_river <-
  st_read("data/brisbane_river.geojson")

p <-
  ggplot() +
  geom_sf(
    data = brisbane_river
  ) +
  geom_sf(
    data = validation_data_hex_summary,
    mapping = aes(fill = accuracy),
    alpha = 0.7
  ) +
  scale_fill_viridis_c() +
  facet_wrap(~scientificName) +
  labs(
    title = "Spatial distribution of model accuracy"
  ) +
  theme_light()
ggsave(
  "output/species_classification_accuracy_spatial.png",
  p,
  width = 25,
  height = 15,
  units = "cm"
)

# ROC curve
model_validation_predictions
roc_object <- roc(
  model_validation_predictions$predicted_class == "Threskiornis moluccus" &
    model_validation_predictions$scientificName == "Threskiornis moluccus",
  model_validation_predictions$prob_moluccus
)
png(
  filename = "output/species_classification_ROC.png",
  width = 10,
  height = 10,
  units = "cm",
  res = 300
)
plot(roc_object)
dev.off()
