# Join data onto resampled IDs

Join data onto resampled IDs

## Usage

``` r
join_to_split(x, y, by, validate = FALSE)
```

## Arguments

- x:

  an rset object created by
  [`rsample::bootstraps()`](https://rsample.tidymodels.org/reference/bootstraps.html)

- y:

  y dataframe with a column of the id values which was resampled to
  create `x`

- by:

  the name of column in y with the data

- validate:

  whether to validate the join by counting the number of rows associated
  with each id. Defaults to `FALSE`.

## Value

the original rset object with its `x$data` updated to join with `y` and
with the row numbers `x$in_id` updated to work on the expanded dataset.

## Examples

``` r
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
data_trees <- tibble::as_tibble(datasets::Orange)

data_tree_ids <- distinct(data_trees, Tree)

# Resample ids
data_bootstraps <- data_tree_ids %>%
  rsample::bootstraps(times = 20) %>%
  rename(splits_id = splits) %>%
  # Attach data to resampled ids
  mutate(
    data_splits = splits_id %>% purrr::map(
      join_to_split,
      data_trees,
      by = "Tree",
      validate = TRUE
    )
  )

data_bootstraps
#> # A tibble: 20 × 3
#>    splits_id     id          data_splits    
#>    <list>        <chr>       <list>         
#>  1 <split [5/2]> Bootstrap01 <split [35/14]>
#>  2 <split [5/2]> Bootstrap02 <split [35/14]>
#>  3 <split [5/3]> Bootstrap03 <split [35/21]>
#>  4 <split [5/2]> Bootstrap04 <split [35/14]>
#>  5 <split [5/2]> Bootstrap05 <split [35/14]>
#>  6 <split [5/1]> Bootstrap06 <split [35/7]> 
#>  7 <split [5/1]> Bootstrap07 <split [35/7]> 
#>  8 <split [5/2]> Bootstrap08 <split [35/14]>
#>  9 <split [5/2]> Bootstrap09 <split [35/14]>
#> 10 <split [5/2]> Bootstrap10 <split [35/14]>
#> 11 <split [5/2]> Bootstrap11 <split [35/14]>
#> 12 <split [5/1]> Bootstrap12 <split [35/7]> 
#> 13 <split [5/2]> Bootstrap13 <split [35/14]>
#> 14 <split [5/2]> Bootstrap14 <split [35/14]>
#> 15 <split [5/2]> Bootstrap15 <split [35/14]>
#> 16 <split [5/2]> Bootstrap16 <split [35/14]>
#> 17 <split [5/2]> Bootstrap17 <split [35/14]>
#> 18 <split [5/2]> Bootstrap18 <split [35/14]>
#> 19 <split [5/1]> Bootstrap19 <split [35/7]> 
#> 20 <split [5/1]> Bootstrap20 <split [35/7]> 
```
