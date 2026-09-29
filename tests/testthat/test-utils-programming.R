test_that("extract_function_source preserves the adjacent comment block and source", {
  lines <- c(
    "# Unrelated comment",
    "",
    "# Add one",
    "  #' A roxygen comment",
    "f <- function(x) {",
    "  # Keep body comments too",
    "  x + 1",
    "}",
    "# Following comment"
  )
  env <- new.env()
  eval(parse(text = lines, keep.source = TRUE), envir = env)

  expect_identical(extract_function_source(env$f), c(lines[3:8], ""))
})

test_that("extract_function_source stops at intervening code", {
  lines <- c("# Unrelated", "x <- 1", "# Adjacent", "f <- function() 2")
  env <- new.env()
  eval(parse(text = lines, keep.source = TRUE), envir = env)

  expect_identical(extract_function_source(env$f), c(lines[3:4], ""))
})

test_that("extract_function_source handles a function on the first line", {
  lines <- "function(x) x"
  fun <- eval(parse(text = lines, keep.source = TRUE))

  expect_identical(extract_function_source(fun), c(lines, ""))
})

test_that("extract_function_source does not cross a blank line before the function", {
  lines <- c("# Detached", "", "function(x) x")
  fun <- eval(parse(text = lines, keep.source = TRUE))

  expect_identical(extract_function_source(fun), c("function(x) x", ""))
})

test_that("extract_function_source explains when source references are missing", {
  fun <- eval(parse(text = "function(x) x", keep.source = FALSE))

  expect_snapshot(error = TRUE, extract_function_source(fun))
})

test_that("extract_function_source requires a function", {
  expect_snapshot(error = TRUE, extract_function_source(1))
})

test_that("extract_function_source explains when original source lines are unavailable", {
  fun <- eval(parse(text = "function(x) x", keep.source = TRUE))
  attr(attr(fun, "srcref"), "srcfile") <- new.env(parent = emptyenv())

  expect_snapshot(error = TRUE, extract_function_source(fun))
})

test_that("extract_function_source separates concatenated functions with one blank line", {
  lines <- c("f <- function(x) x", "", "g <- function(x) x + 1", "")
  env <- new.env()
  eval(parse(text = lines, keep.source = TRUE), envir = env)

  expect_identical(c(extract_function_source(env$f), extract_function_source(env$g)), lines)
})
