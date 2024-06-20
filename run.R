list.files(pattern = "^[0-9]+.*\\.R$", full.names = TRUE) |>
lapply(source, verbose = FALSE)
