# Compute the percentage of points under each centile line

`check_model_centiles()` computes centiles from a model and computes the
calibration of each centile. `check_computed_centiles()` works on a
dataframe with precomputed `c[XX]` columns of centiles.

## Usage

``` r
check_model_centiles(
  data,
  model,
  var_x,
  var_y,
  centiles = c(5, 10, 25, 50, 75, 90, 95)
)

check_computed_centiles(data, var_y)
```

## Arguments

- data:

  a dataset used to fit a model. If the dataframe is grouped with
  [`dplyr::group_by()`](https://dplyr.tidyverse.org/reference/group_by.html),
  sample centiles are computed for each group.

- model:

  a gamlss model prepared by
  [`mem_gamlss()`](https://wisclab.github.io/wisclabmisc/reference/mem_gamlss.md)

- var_x, var_y:

  bare column names of the predictor and outcome variables

- centiles:

  centiles to use for prediction. Defaults to
  `c(5, 10, 25, 50, 75, 90, 95)`.

## Value

a tibble the number of points and the percentage of points less than or
equal to each quantile value.
