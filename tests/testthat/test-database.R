
test_that("tbl_bind() selects tables", {
  skip_if_not_installed("dbplyr")
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  db <- duckdb::duckdb() |>
    DBI::dbConnect() |>
    withr::local_db_connection()

  DBI::dbWriteTable(db, "mtcars_g1", mtcars[mtcars$cyl == 4, ])
  DBI::dbWriteTable(db, "mtcars_g2", mtcars[mtcars$cyl == 6, ])
  DBI::dbWriteTable(db, "mtcars_g3", mtcars[mtcars$cyl == 8, ])
  DBI::dbWriteTable(db, "trees", trees)

  # Default
  r <- db |>
    tbl_bind(starts_with("mtcars")) |>
    count(.source) |>
    collect()
  expect_contains(r$.source, c("mtcars_g1", "mtcars_g2", "mtcars_g3"))

  # No double selection
  r2 <- db |>
    tbl_bind(c(mtcars_g1, mtcars_g1, mtcars_g2, mtcars_g3)) |>
    count(.source) |>
    collect()

  expect_equal(
    r[r$.source == "mtcars_g1", ],
    r2[r2$.source == "mtcars_g1", ]
  )

  # Custom id_name
  r <- db |>
    tbl_bind(starts_with("mtcars"), id_name = "g") |>
    count(g) |>
    collect()
  expect_contains(r$g, c("mtcars_g1", "mtcars_g2", "mtcars_g3"))

  # No ID name
  r <- db |>
    tbl_bind(starts_with("mtcars"), id_name = NULL) |>
    collect()
  expect_equal(table(r$cyl), table(mtcars$cyl))

  # Collision with an existing column name
  r <- db |>
    tbl_bind(starts_with("mtcars"), id_name = "cyl") |>
    expect_error(regexp = "already has a field")
})
