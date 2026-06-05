# Rename file basenames using functions

`file_replace_name()` uses
[`stringr::str_replace()`](https://stringr.tidyverse.org/reference/str_replace.html)
to rename files. `file_rename_with()` allows you to rename files with a
generic string-transforming function.

## Usage

``` r
file_replace_name(
  path,
  pattern,
  replacement,
  .dry_run = FALSE,
  .overwrite = FALSE
)

file_rename_with(path, .fn, ..., .dry_run = FALSE, .overwrite = FALSE)
```

## Arguments

- path:

  vector of paths for files to rename

- pattern, replacement:

  arguments forwarded to
  [`stringr::str_replace()`](https://stringr.tidyverse.org/reference/str_replace.html)

- .dry_run:

  when `FALSE` (the default), files are renamed. When `TRUE`, no files
  are renamed but the affected files are printed out.

- .overwrite:

  Whether to overwrite files. Defaults to `FALSE` so that overwriting
  files is opt-in.

- .fn:

  function to call file paths

- ...:

  arguments passed onto `.fn`

## Value

the contents of `paths` with updated file names. Duplicated elements are
removed. This function throws an error if a name collision is detected
(where two files are both renamed into the same target path).

## Details

Only the basename of the file (returned by
[`basename()`](https://rdrr.io/r/base/basename.html) undergoes string
replacement).

## Examples

``` r
# With .dry_run = TRUE, we can make up some file paths.
dir <- "//some-fake-location/"
path <- file.path(
  dir,
  c("report_1.csv", "report_2.csv", "report-1.csv", "skipped.csv")
)

updated <- file_replace_name(path, "report_", "report-", .dry_run = TRUE)
#> Rename plan:
#>   report_1.csv -> report-1.csv
#>   report_2.csv -> report-2.csv

# Collisions are detected
updated <- file_replace_name(path, "report_\\d", "report-1", .dry_run = TRUE)
#> Warning: Cannot safely rename files
#> ✖ 2 files have naming collisions
#> • Ensure that files do not rename to the same destination
#> 
#> Rename plan:
#> ✖ (report_1.csv, report_2.csv) -> report-1.csv (naming collision)
```
