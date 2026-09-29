#' A lightweight container for auditing or logging
#' @param data data to wrap into an audit
#' @param x an audit object
#' @param fn a function to apply to the data inside of the audit object
#' @param ... further arguments for `fn`
#' @return `audit_wrap()`, `audit_peek()`, `audit_poke()` return audit objects.
#' `audit_unwrap()` returns the `$data` from an `audit`.
#' @export
#' @rdname audit
#' @description
#' An `audit` is a `list()` with two fields:
#'
#' 1. `data`: most recently updated (or poked) data
#' 2. `notes`: a history of the `fn` calls and results applied to the object.
#'
#' Usage:
#'
#' - `audit_wrap(data)` wraps some data inside of an audit.
#' - `audit_peek(x, fn, ...)` applies a function to the data, log the results
#'   in the `notes`, but *not* overwrite the audit data.
#' - `audit_poke(x, fn, ...)` applies a function to the data, log the results
#'   in the `notes`, and overwrite the audit data.
#' - `audit_unwrap()` returns the underlying data.
#'
#' @details There is no `audit_notes()` function at this time because it is not
#'   clear what the most convenient or tidy format would be for the notes.
#'
#' These container was designed for piping a vector of filenames through a
#' series of data validation functions. Therefore, the intended use case is a
#' vector of a data and not larger objects.
#'
#' @concept programming-utils
#' @examples
#' x <- letters |>
#'   audit_wrap() |>
#'   audit_peek(rev) |>
#'   audit_peek(toupper)
#'
#' # Note that none of the underlying data has changed. This is useful for
#' # finding values that fail validation checks.
#' x
#'
#' # Use _poke() to update the data:
#' x <- letters |>
#'   audit_wrap() |>
#'   audit_peek(rev) |>
#'   audit_poke(toupper) |>
#'   audit_peek(getElement, 1) |>
#'   audit_peek(function(x) character(0))
#' x
#'
#' # Index into the notes to pull the data
#' x$notes[[3]][["result"]]
audit_wrap <- function(data) {
  structure(
    list(data = data, notes = list()),
    class = c("audit", "list")
  )
}

#' @export
#' @rdname audit
audit_peek <- function(x, fn, ...) {
  result <- fn(x$data, ...)
  call <- rlang::call2(substitute(fn), quote(x), ...)
  label <- audit_label_call(call, length(x$notes) + 1)

  n <- list(new_audit_note(result, label, "peek"))
  names(n) <- label

  x$notes <- c(x$notes, n)
  x
}

#' @export
#' @rdname audit
audit_poke <- function(x, fn, ...) {
  result <- fn(x$data, ...)
  call <- rlang::call2(substitute(fn), quote(x), ...)
  label <- audit_label_call(call, length(x$notes) + 1)

  n <- list(new_audit_note(result, label, "poke"))
  names(n) <- label

  x$data <- result
  x$notes <- c(x$notes, n)
  x
}

#' @export
#' @rdname audit
audit_unwrap <- function(x) x$data

#' @export
print.audit <- function(x, ...) {
  create_note_name <- function(n) {
    sprintf("%s [%s]", n$label, n$type)
  }
  copy <- x
  copy$notes <- lapply(x$notes, getElement, "result")
  names(copy$notes) <- lapply(x$notes, create_note_name)

  b <- copy["data"] |>
    utils::str(
      comp.str = "",
      no.list = TRUE,
      nest.lev = 0,
      indent.str = "",
      strict.width = "wrap"
    ) |>
    utils::capture.output()

  c <- copy$notes |>
    utils::str(
      comp.str = "> ",
      max.level = 1,
      no.list = TRUE,
      strict.width = "wrap"
    ) |>
    utils::capture.output()

  lines <- c("<audit> object", b, "notes:", c)
  writeLines(lines)
  invisible(x)
}

new_audit_note <- function(result, label, type = c("peek", "poke")) {
  type <- match.arg(type)

  structure(
    list(result = result, type = type, label = label),
    class = c("audit_note", "list")
  )
}

audit_label_call <- function(call, unnamed_id) {
  if (!rlang::is_call_simple(call)) {
    f <- paste0("<unnamed-function-", unnamed_id, ">")
    call <- rlang::call2(rlang::sym(f), !!! rlang::call_args(call))
  }
  deparse1(call)
}





#' Skip a block of code without executing it
#'
#' `skip_block()` is a lightweight control-flow helper to deliberately
#' skip execution of a block of code while still documenting that the block
#' exists. It is intended as an alternative to commenting out code
#' or wrapping code in `if (FALSE) { ... }`.
#'
#' The function captures the unevaluated code block, reports how many lines
#' would have run, optionally prints a user-supplied message, and then returns
#' invisibly without evaluating the code.
#'
#' @param ... Either a single braced expression containing the code block to
#'   skip, or a character string followed by a single braced expression.
#'   When a message is supplied, it is printed instead of the default message.
#'
#' @return `NULL`, invisibly.
#'
#' @details
#' `skip_block()` uses non-standard evaluation to capture the code block via
#' `substitute()`. The code block is never evaluated.
#'
#' Supplying more than two arguments, or supplying no code block, is an error.
#' @concept programming-utils
#' @examples
#' skip_block({
#'   Sys.sleep(10)
#' })
#'
#' skip_block("Skipping slow preprocessing step", {
#'     Sys.sleep(10)
#'   }
#' )
#' @export
skip_block <- function(...) {
  dots <- substitute(list(...))[-1]
  dl <- length(dots)

  if (dl == 0) {
    stop("skip_block() requires a code block")
  }

  if (dl == 1) {
    msg  <- "Skipping code block"
    expr <- dots[[1]]
  } else if (dl == 2) {
    msg  <- ...elt(1)
    expr <- dots[[2]]
  } else {
    stop("skip_block() accepts at most a message and one code block")
  }

  lines <- deparse(expr, width.cutoff = 500L)
  cli::cli_inform("{msg} ({length(lines)} line{?s})")
  invisible(NULL)
}


#' Extract a function's source and preceding comments
#'
#' `extract_function_source()` returns the original source lines for a function,
#' including the contiguous block of comment lines immediately above it.
#' Formatting, indentation, and comments inside the function are preserved.
#'
#' @param fun A function with a `srcref` attribute whose `srcfile` contains
#'   the original source lines. Use `keep.source = TRUE` when calling
#'   [base::source()] or [base::parse()] to retain this information.
#'
#' @return A character vector with one element per source line, starting with
#'   any immediately preceding comments. An empty string is appended unless the
#'   last element is already empty, so concatenated results have a blank line
#'   between functions.
#'
#' @details
#' A comment line starts with `#`, optionally preceded by whitespace. This
#' includes roxygen comments. A blank line or a line of code ends the preceding
#' comment block.
#'
#' Complete lines are returned, so an assignment such as `f <-` on the same
#' line as `function` is included, as is any other text on the first or last
#' line. An assignment on an earlier line is not included.
#'
#' This function requires retained source text; it does not reconstruct code
#' from the function body. Functions without source references, including many
#' functions from installed packages, cannot be used.
#'
#' @section Supplemental materials:
#' The main use case is printing function definitions later in our supplemental
#' materials documents. This lets us curate which analysis functions are shown
#' and their ordering while preserving their original comments and formatting.
#'
#' In a knitr document, collect the source in a hidden chunk, then display it
#' in a later chunk using the `code` option:
#'
#' ````text
#' ```{r, include = FALSE}
#' # If not already source()-ed:
#' source("R/functions.R", keep.source = TRUE)
#' l <- c(
#'   extract_function_source(some_analysis_function),
#'   extract_function_source(some_other_analysis_function)
#' )
#' ```
#'
#' ```{r, code = l}
#' ```
#' ````
#'
#' @concept programming-utils
#' @export
#' @examples
#' code <- c(
#'   "# Add one to a number",
#'   "add_one <- function(x) {",
#'   "  x + 1",
#'   "}"
#' )
#' env <- new.env()
#' eval(parse(text = code, keep.source = TRUE), envir = env)
#' extract_function_source(env$add_one)
#' writeLines(extract_function_source(env$add_one))
extract_function_source <- function(fun) {
  stopifnot("`fun` must be a function" = is.function(fun))
  ref <- attr(fun, "srcref")
  if (is.null(ref)) {
    stop(
      "`fun` must have a source reference; use `keep.source = TRUE`.",
      call. = FALSE
    )
  }
  source_lines <- attr(ref, "srcfile") |> getElement("lines")
  if (is.null(source_lines)) {
    stop(
      "The source reference must contain the original source lines.",
      call. = FALSE
    )
  }

  line_range <- ref[c(1, 3)]

  is_comment <- function(x) grepl("^\\s*#", x)
  line_to_check <- line_range[1]

  repeat {
    line_to_check <- line_to_check - 1
    if (line_to_check < 1) break
    if (!is_comment(source_lines[line_to_check])) break
  }

  lines <- source_lines[seq(line_to_check + 1, line_range[2])]
  if (lines[length(lines)] != "") {
    lines <- c(lines, "")
  }

  lines
}
