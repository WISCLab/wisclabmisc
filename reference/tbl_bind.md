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
  DBI::dbConnect()
db
#> <duckdb_connection d2b30 driver=<duckdb_driver dbdir=':memory:' read_only=FALSE bigint=numeric>>

DBI::dbWriteTable(db, "mtcars_g1", mtcars[mtcars$cyl == 4, ])
DBI::dbWriteTable(db, "mtcars_g2", mtcars[mtcars$cyl == 6, ])
DBI::dbWriteTable(db, "mtcars_g3", mtcars[mtcars$cyl == 8, ])
DBI::dbWriteTable(db, "trees", trees)

DBI::dbListTables(db)
#> [1] "mtcars_g1" "mtcars_g2" "mtcars_g3" "trees"    

r <- db |>
  tbl_bind(starts_with("mtcars")) |>
  count(.source)
r
#> # Source:   SQL [?? x 2]
#> # Database: DuckDB 1.5.2 [unknown@Linux 6.17.0-1018-azure:R 4.6.0/:memory:]
#>   .source       n
#>   <chr>     <dbl>
#> 1 mtcars_g3    14
#> 2 mtcars_g1    11
#> 3 mtcars_g2     7

# the query is several UNIONs
show_query(r)
#> <SQL>
#> SELECT ".source", COUNT(*) AS n
#> FROM (
#>   SELECT mtcars_g1.*, 'mtcars_g1' AS ".source"
#>   FROM mtcars_g1
#> 
#>   UNION ALL
#> 
#>   SELECT mtcars_g2.*, 'mtcars_g2' AS ".source"
#>   FROM mtcars_g2
#> 
#>   UNION ALL
#> 
#>   SELECT mtcars_g3.*, 'mtcars_g3' AS ".source"
#>   FROM mtcars_g3
#> ) q01
#> GROUP BY ".source"

DBI::dbDisconnect(db, shutdown = TRUE)
```
