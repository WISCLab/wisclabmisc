# Custom function for printing duckdb database connections

Custom function for printing duckdb database connections

## Usage

``` r
print_duckdb(object, table_limit = 50)
```

## Arguments

- object:

  a database connection to a duckdb database

- table_limit:

  number of table names to print before truncating with `...`. Defaults
  to 50.

## Value

`NULL` invisibly

## Details

Use the following to overwrite the S4 method for printing duckdb
objects.

    setMethod("show", "duckdb_connection", wisclabmisc::print_duckdb)
