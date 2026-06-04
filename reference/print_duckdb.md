# Custom function for printing duckdb database connections

Custom function for printing duckdb database connections

## Usage

``` r
print_duckdb(object)
```

## Arguments

- object:

  a database connection to a duckdb database

## Value

`NULL` invisibly

## Details

Use the following to overwrite the S4 method for printing duckdb
objects.

    setMethod("show", "duckdb_connection", wisclabmisc::print_duckdb)
