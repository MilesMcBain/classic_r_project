##### Libraries #####
library(conflicted)
library(ggplot2)
library(sf)
library(h3jsr)

occurrences_weather_hexes <-
  readRDS("data/wrangled_occurences_weather_data.Rds")

##### Visualise data #####

brisbane_river <-
  st_read("data/brisbane_river.geojson")

# Species distriubtions, points, facetted
p <-
  ggplot() +
  geom_sf(
    data = brisbane_river
  ) +
  geom_sf(
    data = occurrences_weather_hexes
  ) +
  facet_wrap(~scientificName) +
  theme_light() +
  theme()

ggsave(
  "output/species_distibution_points.png",
  plot = p,
  bg = "white",
  width = 25,
  height = 15,
  units = "cm"
)


# Species distributions, h3 hex-binned, facetted
# Create hex-bin
hex_occurrences <-
  occurrences_weather_hexes |>
  st_drop_geometry() |>
  select(scientificName, h3_hex_8) |>
  summarise(
    count = n(),
    .by = c("scientificName", "h3_hex_8")
  ) |>
  mutate(
    geometry = cell_to_polygon(h3_hex_8)
  ) |>
  st_as_sf()

p <-
  ggplot() +
  geom_sf(
    data = brisbane_river
  ) +
  geom_sf(
    data = hex_occurrences,
    mapping = aes(fill = log(count)),
    alpha = 0.7
  ) +
  scale_fill_viridis_c(labels = \(x) round(exp(x))) +
  facet_wrap(~scientificName) +
  theme_light()

ggsave(
  "output/species_distibution_hexes.png",
  plot = p,
  bg = "white",
  width = 25,
  height = 15,
  units = "cm"
)

# Distribution of occurrences over months, facetted
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

ggsave(
  "output/species_distibution_month.png",
  plot = p,
  bg = "white",
  width = 25,
  height = 15,
  units = "cm"
)
