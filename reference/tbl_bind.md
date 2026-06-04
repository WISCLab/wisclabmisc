# Select and row-bind multiple database tables from the same source together

Select and row-bind multiple database tables from the same source
together

## Usage

``` r
tbl_bind(src, table_selection, id_name = ".source")
```

## Arguments

- src:

  a database connection

- table_selection:

  a
  [`tidy-select`](https://tidyselect.r-lib.org/reference/language.html)
  name selection. For example, `starts_with("loc_")` would select all
  tables that start with `"loc_"`. Place multiple selections inside of
  [`c()`](https://rdrr.io/r/base/c.html).

- id_name:

  Name for the table ID column. The names of the original tables will be
  included in a column named by `id_name`. By default, this column is
  `".source"`. If `NULL`, then the ID column is not included.

## Value

a tbl (query to a remote table)

## Details

In dplyr, `tbl(src, table_name)` names and queries a database table.
`tbl_bind(src, <selection>)` extends this idea into selecting and
combining multiple database tables.

To manually combine two tbls `x` and `y`, use
[`dplyr::union_all(x, y)`](https://dplyr.tidyverse.org/reference/setops.html).

## Examples

``` r
library(dplyr)
db <- duckdb::duckdb() |>
  DBI::dbConnect() |>
  withr::local_db_connection()

DBI::dbWriteTable(db, "mtcars_g1", mtcars[mtcars$cyl == 4, ])
#> Error in dbExistsTable(conn, name): Invalid connection
DBI::dbWriteTable(db, "mtcars_g2", mtcars[mtcars$cyl == 6, ])
#> Error in dbExistsTable(conn, name): Invalid connection
DBI::dbWriteTable(db, "mtcars_g3", mtcars[mtcars$cyl == 8, ])
#> Error in dbExistsTable(conn, name): Invalid connection
DBI::dbWriteTable(db, "trees", trees)
#> Error in dbExistsTable(conn, name): Invalid connection

DBI::dbListTables(db)
#> Error in dbSendQuery(conn, statement, ...): Invalid connection
#> ℹ Context: rapi_prepare

r <- db |>
  tbl_bind(starts_with("mtcars")) |>
  count(.source)
#> Error in dbSendQuery(conn, statement, ...): Invalid connection
#> ℹ Context: rapi_prepare
r
#> Error: object 'r' not found

show_query(r)
#> Error: object 'r' not found
```
