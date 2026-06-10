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
  path <-     c("a1", "b1", "c1", "cc1", "d", "f", "g")
  path_new <- c("a2", "b2", "c2",  "c2", "e", "g", "h")
  dir |> file.path(path) |> file.create()

  file_rename_impl(path, path_new, .overwrite = FALSE, .dry_run = TRUE)

})





test_that("dir_sync_down() works when destination does not exist", {
  from <- tempfile()
  to <- tempfile()
  fs::dir_create(from)
  writeLines("a", fs::path(from, "a.txt"))

  plan <- dir_sync_down(from, to, .dry_run = TRUE)

  expect_true(any(plan$action == "copy"))
  expect_false(fs::dir_exists(to))

  dir_sync_down(from, to, .dry_run = FALSE)

  expect_true(fs::file_exists(fs::path(to, "a.txt")))
})


test_that("dir_sync_down() skips extra files unless delete is allowed", {
  from <- tempfile()
  to <- tempfile()
  fs::dir_create(from)
  fs::dir_create(to)

  writeLines("a", fs::path(from, "a.txt"))
  writeLines("extra", fs::path(to, "extra.txt"))

  plan <- dir_sync_down(from, to, .dry_run = TRUE, .delete = FALSE)

  expect_true(any(plan$action == "ignore"))
  expect_true(any(plan$reason == "delete disabled"))

  dir_sync_down(from, to, .dry_run = FALSE, .delete = FALSE)

  expect_true(fs::file_exists(fs::path(to, "extra.txt")))

  dir_sync_down(from, to, .dry_run = FALSE, .delete = TRUE)

  expect_false(fs::file_exists(fs::path(to, "extra.txt")))
})

test_that("dir_sync_down() overwrites changed files", {
  from <- tempfile()
  to <- tempfile()
  fs::dir_create(from)
  fs::dir_create(to)

  writeLines("new", fs::path(from, "a.txt"))
  writeLines("old", fs::path(to, "a.txt"))

  plan <- dir_sync_down(from, to, .dry_run = TRUE, .compare = "md5")

  expect_true(any(plan$action == "overwrite"))

  dir_sync_down(from, to, .dry_run = FALSE, .compare = "md5")

  expect_equal(readLines(fs::path(to, "a.txt")), "new")
})














make_demo_sync_dirs <- function(root = tempfile("demo-sync-")) {
  from <- fs::path(root, "from")
  to <- fs::path(root, "to")

  fs::dir_create(from)
  fs::dir_create(to)

  fs::dir_create(fs::path(from, "subdir"))
  fs::dir_create(fs::path(to, "subdir"))

  # Same in both: overwrite
  writeLines("same file", fs::path(from, "same.txt"))
  writeLines("same file", fs::path(to, "same.txt"))

  # Same in both: no actoin
  writeLines("same file", fs::path(from, "copied.txt"))
  fs::file_copy(fs::path(from, "copied.txt"), fs::path(to, "copied.txt"))

  # Missing from destination: should copy
  writeLines("copy me", fs::path(from, "copy-me.txt"))

  # Changed in destination: should overwrite
  writeLines("new contents", fs::path(from, "changed.txt"))
  writeLines("old contents", fs::path(to, "changed.txt"))

  # Extra in destination: should skip/delete depending on .delete
  writeLines("extra file", fs::path(to, "extra.txt"))

  # Recursive copy
  writeLines("nested copy me", fs::path(from, "subdir", "nested-copy.txt"))

  # Recursive overwrite
  writeLines("nested new contents", fs::path(from, "subdir", "nested-changed.txt"))
  writeLines("nested old contents", fs::path(to, "subdir", "nested-changed.txt"))

  # Recursive extra
  writeLines("nested extra file", fs::path(to, "subdir", "nested-extra.txt"))

  # Same contents, but newer mtime in source.
  # Under metadata comparison this should overwrite.
  # Under hash comparison this should be unchanged.
  writeLines("unchanged contents", fs::path(to, "newer-but-unchanged.txt"))
  Sys.sleep(1.1)
  writeLines("unchanged contents", fs::path(from, "newer-but-unchanged.txt"))

  # Also test same contents/newer source inside a subdirectory
  writeLines("nested unchanged contents", fs::path(to, "subdir", "nested-newer-but-unchanged.txt"))
  Sys.sleep(1.1)
  writeLines("nested unchanged contents", fs::path(from, "subdir", "nested-newer-but-unchanged.txt"))

  list(
    root = root,
    from = from,
    to = to,
    files_from = fs::dir_ls(from, recurse = TRUE, type = "file"),
    files_to = fs::dir_ls(to, recurse = TRUE, type = "file")
  )
}



test_that("dir_sync_down demo", {
  testthat::skip(message = "demo")
  l <- make_demo_sync_dirs()

  dir_sync_down(l$from, l$to)


  dir_sync_down(l$from, l$to, .delete = TRUE)



  dir <- tempfile()
  dir.create(dir)
  path <-     c("a1", "b1", "c1", "cc1", "d", "f", "g")
  path_new <- c("a2", "b2", "c2",  "c2", "e", "g", "h")
  dir |> file.path(path) |> file.create()

  file_rename_impl(path, path_new, .overwrite = FALSE, .dry_run = TRUE)

})

