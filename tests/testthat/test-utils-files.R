test_that("file_replace_name() works on empty vectors", {
  path <- character(0)

  path |>
    file_replace_name("report_", "report-", .dry_run = FALSE) |>
    expect_message("No files were")

  path |>
    file_replace_name("report_", "report-", .dry_run = TRUE) |>
    expect_message("No files would")
})


test_that("file_rename_impl() fails on chained renames", {
  dir <- tempfile()
  dir.create(dir)

  dir |> file.path(c("w", "x", "y", "z")) |> file.create()

  path <- c("w", "x", "y")
  path_new <- c("x", "y", "z")

  rename_plan <- path |>
    file_rename_impl(path_new, .overwrite = TRUE, .dry_run = TRUE) |>
    expect_warning("chained")

  rename_plan <- path |>
    file_rename_impl(path_new, .overwrite = TRUE, .dry_run = FALSE) |>
    expect_error("chained")
})


test_that("file_replace_name() works when nothing would change", {
  dir <- tempfile()
  dir.create(dir)

  dir |> file.path("skipped.csv") |> file.create()
  path <- list.files(dir, full.names = TRUE)

  path |>
    file_replace_name("report_", "report-", .dry_run = FALSE) |>
    expect_message("No files were")

  path |>
    file_replace_name("report_", "report-", .dry_run = TRUE) |>
    expect_message("No files would")
})

test_that("file_replace_name() errors on collisions", {
  dir <- tempfile()
  dir.create(dir)

  dir |> file.path(c("rep1", "rep2", "skip")) |> file.create()
  path <- list.files(dir, full.names = TRUE)

  path_new <- stringr::str_replace_all(path, "rep.", "report")

  path |>
    file_replace_name("rep.", "report", .dry_run = TRUE) |>
    expect_warning()

  path |>
    file_replace_name("rep.", "report", .dry_run = FALSE) |>
    expect_error()
})




test_that("file_replace_name() handles overwrites", {
  dir <- tempfile()
  dir.create(dir)

  path <- list.files(dir, full.names = TRUE)

  files <- c(
    # easy cases
    "report_0.csv", "skipped.csv", "skipped2.csv",
    # would overwrite
    "report_1.csv", "report-1.csv",
    # would collide
    "report_2.csv", "report__2.csv",
    # would overwrite and collide
    "report_3.csv", "report__3.csv", "report-3.csv"
  )

  dir |> file.path(files) |> file.create()
  path <- list.files(dir, full.names = TRUE)

  path |>
    file_replace_name("report_", "report-", .dry_run = TRUE, .overwrite = FALSE) |>
    expect_message(regexp = "would overwrite existing")

  path |>
    file_replace_name("report_+", "report-", .dry_run = TRUE, .overwrite = FALSE) |>
    expect_warning(regexp = "naming collision")

  path |>
    file_replace_name("report_+", "report-", .dry_run = FALSE, .overwrite = FALSE) |>
    expect_error(regexp = "naming collision")

  path |>
    file_replace_name("report_", "report-", .dry_run = FALSE, .overwrite = FALSE) |>
    expect_message(regexp = "would overwrite existing")

  path <- list.files(dir, full.names = TRUE)

  # With overwrites allowed
  path |>
    file_replace_name("report-_", "report-", .dry_run = TRUE, .overwrite = TRUE) |>
    expect_message(regexp = "overwrites an existing")

  path |>
    file_replace_name("report-_", "report-", .dry_run = FALSE, .overwrite = TRUE)

  path <- list.files(dir, full.names = TRUE)

  path |>
    file_replace_name("report_", "report-", .dry_run = FALSE, .overwrite = TRUE)

  path <- list.files(dir, full.names = TRUE)

  path |>
    basename() |>
    expect_equal(c(
      "report-0.csv", "report-1.csv", "report-2.csv", "report-3.csv",
      "skipped.csv", "skipped2.csv"
    ))
})


test_that("file_rename demo", {
  testthat::skip(message = "demo")
  dir <- tempfile()
  dir.create(dir)
  path <-     c("a1", "b1", "c1", "cc1", "d", "e", "f", "g")
  path_new <- c("a2", "b2", "c2",  "c2", "d", "e", "g", "h")
  dir |> file.path(path) |> file.create()

  file_rename_impl(path, path_new, .overwrite = FALSE, .dry_run = TRUE)

})
