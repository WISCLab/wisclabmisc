data_tocs_items <- readr::read_csv(
  "data-raw/tocs-items.csv",
  col_types = "cnccc"
) |>
  tibble::as_tibble()

usethis::use_data(
  data_tocs_items,
  overwrite = TRUE
)
