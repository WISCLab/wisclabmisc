# Extract a function's source and preceding comments

`extract_function_source()` returns the original source lines for a
function, including the contiguous block of comment lines immediately
above it. Formatting, indentation, and comments inside the function are
preserved.

## Usage

``` r
extract_function_source(fun)
```

## Arguments

- fun:

  A function with a `srcref` attribute whose `srcfile` contains the
  original source lines. Use `keep.source = TRUE` when calling
  [`base::source()`](https://rdrr.io/r/base/source.html) or
  [`base::parse()`](https://rdrr.io/r/base/parse.html) to retain this
  information.

## Value

A character vector with one element per source line, starting with any
immediately preceding comments. An empty string is appended unless the
last element is already empty, so concatenated results have a blank line
between functions.

## Details

A comment line starts with `#`, optionally preceded by whitespace. This
includes roxygen comments. A blank line or a line of code ends the
preceding comment block.

Complete lines are returned, so an assignment such as `f <-` on the same
line as `function` is included, as is any other text on the first or
last line. An assignment on an earlier line is not included.

This function requires retained source text; it does not reconstruct
code from the function body. Functions without source references,
including many functions from installed packages, cannot be used.

## Supplemental materials

The main use case is printing function definitions later in our
supplemental materials documents. This lets us curate which analysis
functions are shown and their ordering while preserving their original
comments and formatting.

In a knitr document, collect the source in a hidden chunk, then display
it in a later chunk using the `code` option:

## Examples

``` r
code <- c(
  "# Add one to a number",
  "add_one <- function(x) {",
  "  x + 1",
  "}"
)
env <- new.env()
eval(parse(text = code, keep.source = TRUE), envir = env)
extract_function_source(env$add_one)
#> [1] "# Add one to a number"    "add_one <- function(x) {"
#> [3] "  x + 1"                  "}"                       
#> [5] ""                        
writeLines(extract_function_source(env$add_one))
#> # Add one to a number
#> add_one <- function(x) {
#>   x + 1
#> }
#> 
```
