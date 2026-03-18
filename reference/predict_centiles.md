# Predict and tidy centiles from a GAMLSS model

gamlss has trouble doing predictions without the original training data.

## Usage

``` r
predict_centiles(newdata, model, centiles = c(5, 10, 50, 90, 95), ...)

pivot_centiles_longer(data)
```

## Arguments

- newdata:

  a one-column dataframe for predictions

- model:

  a gamlss model prepared by
  [`mem_gamlss()`](https://wisclab.github.io/wisclabmisc/reference/mem_gamlss.md)

- centiles:

  centiles to use for prediction. Defaults to `c(5, 10, 50, 90, 95)`.

- ...:

  arguments passed to
  [`gamlss::centiles.pred()`](https://rdrr.io/pkg/gamlss/man/centiles.pred.html)

- data:

  centile predictions to reshape for `pivot_centiles_longer()`

## Value

a tibble with fitted centiles for `predict_centiles()` and a long-format
tibble with one centile value per row in `pivot_centiles_longer()`
