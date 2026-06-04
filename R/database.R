

#' Custom function for printing duckdb database connections
#'
#' @param object a database connection to a duckdb database
#' @return `NULL` invisibly
#' @concept database
#' @details Use the following to overwrite the S4 method for printing duckdb
#' objects.
#' ```
#' setMethod("show", "duckdb_connection", wisclabmisc::print_duckdb)
#' ```
print_duckdb <- function(object) {
  rlang::check_installed(c("DBI", "duckdb"))
  is_installed <- rlang::is_installed(c("DBI", "duckdb"))

  if (!is_installed) {
    print(object)
    return(invisible(NULL))
  }

  version <- DBI::dbGetInfo(object)[["db.version"]]
  tables <- DBI::dbListTables(object)

  cli_tables <- if (length(tables)) {
    "{.emph tables}: {.field {tables}}"
  } else {
    "{.emph tables}: [none]"
  }

  cli::cli_bullets(
    c(
      "{.cls {class(object)}}",
      "*" = "{.emph driver}: {duckdb:::drv_to_string(object@driver)}",
      "*" = "{.emph db_version}: {.value {version}}",
      "*" = cli_tables
    )
  )

  invisible(NULL)
}


#' Select and row-bind multiple database tables from the same source together
#'
#' @param src a database connection
#' @param table_selection a [`tidy-select`][tidyselect::language] name
#'   selection. For example, `starts_with("loc_")` would select all tables that
#'   start with `"loc_"`. Place multiple selections inside of `c()`.
#' @param id_name Name for the table ID column. The names of the original tables
#'   will be included in a column named by `id_name`. By default, this column is
#'   `".source"`. If `NULL`, then the ID column is not included.
#' @return a tbl (query to a remote table)
#' @export
#' @details
#' In dplyr, `tbl(src, table_name)` names and queries a database table.
#' `tbl_bind(src, <selection>)` extends this idea into selecting and
#' combining multiple database tables.
#'
#' To manually combine two tbls `x` and `y`, use [`dplyr::union_all(x,
#' y)`][dplyr::union_all].
#' @concept database
#' @examples
#' library(dplyr)
#' db <- duckdb::duckdb() |>
#'   DBI::dbConnect()
#' db
#'
#' DBI::dbWriteTable(db, "mtcars_g1", mtcars[mtcars$cyl == 4, ])
#' DBI::dbWriteTable(db, "mtcars_g2", mtcars[mtcars$cyl == 6, ])
#' DBI::dbWriteTable(db, "mtcars_g3", mtcars[mtcars$cyl == 8, ])
#' DBI::dbWriteTable(db, "trees", trees)
#'
#' DBI::dbListTables(db)
#'
#' r <- db |>
#'   tbl_bind(starts_with("mtcars")) |>
#'   count(.source)
#' r
#'
#' # the query is several UNIONs
#' show_query(r)
#'
#' DBI::dbDisconnect(db, shutdown = TRUE)
tbl_bind <- function(src, table_selection, id_name = ".source") {
  f_include_id_name <- function(nm) {
    has_name <- id_name %in% DBI::dbListFields(src, nm)
    if (has_name) {
      message <- "Cannot add table source column: Table {.field {nm}} already has a field named {.field {id_name}}"
      cli::cli_abort(message)
    }
    tbl(src, nm) |> mutate("{id_name}" := nm)
  }
  f_exclude_id_name <- function(nm) tbl(src, nm)

  rlang::check_installed(c("DBI"))

  names <- DBI::dbListTables(src)
  names <- stats::setNames(names, names)
  selection <- tidyselect::eval_select(
    enquo(table_selection),
    data = names,
    allow_predicates = FALSE,
    allow_rename = FALSE
  )
  to_pull <- unique(names[selection])

  f_select <- if (is.null(id_name)) f_exclude_id_name else f_include_id_name

  to_pull |>
    lapply(f_select) |>
    Reduce(f = dplyr::union_all, x = _)
}

# # todo: a direct version of binding
# bind_tbls_direct <- function(src, ..., id_name = ".source") {
#
# }
