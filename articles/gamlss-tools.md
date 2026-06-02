# Tools for GAMLSS models

wisclabmisc includes for that making with GAMLSS models easier.
Normally, when [`gamlss()`](https://rdrr.io/pkg/gamlss/man/gamlss.html)
fit a model, it does not store the data alongside the model. We provide
a function that fixes that. We also provide some functions extracting
centiles (percentile curves) from models easiers.

## A `gamlss()` that remembers the data

[`mem_gamlss()`](https://wisclab.github.io/wisclabmisc/reference/mem_gamlss.md)
(memory gamlss) provides a drop-in replacement for the
[`gamlss()`](https://rdrr.io/pkg/gamlss/man/gamlss.html) function.

``` r

library(wisclabmisc)
library(gamlss)
library(tidyverse)

data <- as.data.frame(nlme::Orthodont)
model <- mem_gamlss(distance ~ age, data = data)
#> GAMLSS-RS iteration 1: Global Deviance = 505.577 
#> GAMLSS-RS iteration 2: Global Deviance = 505.577
```

The only difference between
[`mem_gamlss()`](https://wisclab.github.io/wisclabmisc/reference/mem_gamlss.md)
and [`gamlss()`](https://rdrr.io/pkg/gamlss/man/gamlss.html) is that the
modified version includes a bundle of data in `.user` that records the
original dataset, session information and the call used to fit the
model.

``` r

str(model$.user, max.level = 1)
#> List of 3
#>  $ data        :'data.frame':    108 obs. of  4 variables:
#>  $ session_info:List of 2
#>   ..- attr(*, "class")= chr [1:2] "session_info" "list"
#>  $ call        : language mem_gamlss(distance ~ age, data = data)
```

gamlss does not store the data as part of the model object, and we need
the dataset because prediction and centile prediction often fails
without the dataset:

``` r

newdata <- distinct(data, age)
centiles.pred(
  model, 
  cent = c(25, 50, 75),
  xname = "age", 
  xvalues = newdata$age, 
  plot = FALSE
)
#> Error in `data.frame()`:
#> ! arguments imply differing number of rows: 4, 5
```

But including the original dataset works:

``` r

centiles.pred(
  model, 
  cent = c(25, 50, 75),
  xname = "age", 
  xvalues = newdata$age, 
  plot = FALSE,
  data = model$.user$data
)
#>    x       25       50       75
#> 1  8 20.34723 22.04259 23.73796
#> 2 10 21.66760 23.36296 25.05833
#> 3 12 22.98797 24.68333 26.37870
#> 4 14 24.30834 26.00370 27.69907
```

(“Centile prediction” means predicting the percentiles of the data along
a single variable. That’s why the above function just needs a single
`xname`: A single predictor variable is used. We use centile prediction
compute growth curves so that we can look at smooth changes in the
percentiles over age.)

## Centile prediction and tidying

This package provides
[`predict_centiles()`](https://wisclab.github.io/wisclabmisc/reference/predict_centiles.md)
as a streamlined version of the above code, but:

- assumes the model was fitted with
  [`mem_gamlss()`](https://wisclab.github.io/wisclabmisc/reference/mem_gamlss.md)
- returns a tibble
- keeps the predictor name (here, `age` instead of `x`)
- prefixes the centiles with `q` (for quantile)

``` r

centiles <- predict_centiles(
  newdata,
  model, 
  cent = c(25, 50, 75)
)
centiles
#> # A tibble: 4 × 4
#>     age   c25   c50   c75
#>   <dbl> <dbl> <dbl> <dbl>
#> 1     8  20.3  22.0  23.7
#> 2    10  21.7  23.4  25.1
#> 3    12  23.0  24.7  26.4
#> 4    14  24.3  26.0  27.7
```

Those predicted centiles are in wide format. We can tidy them into a
long format with
[`pivot_centiles_longer()`](https://wisclab.github.io/wisclabmisc/reference/predict_centiles.md).
This also includes `.pair` column that helps mark commonly paired
quantiles 25:75, 10:90, and 5:95.

``` r

pivot_centiles_longer(centiles)
#> # A tibble: 12 × 4
#>      age .centile .value .centile_pair  
#>    <dbl>    <dbl>  <dbl> <chr>          
#>  1     8       25   20.3 centiles 25, 75
#>  2     8       50   22.0 median         
#>  3     8       75   23.7 centiles 25, 75
#>  4    10       25   21.7 centiles 25, 75
#>  5    10       50   23.4 median         
#>  6    10       75   25.1 centiles 25, 75
#>  7    12       25   23.0 centiles 25, 75
#>  8    12       50   24.7 median         
#>  9    12       75   26.4 centiles 25, 75
#> 10    14       25   24.3 centiles 25, 75
#> 11    14       50   26.0 median         
#> 12    14       75   27.7 centiles 25, 75
```

### Sample centiles checks

Half of the data should be above the 50% centile line and half should be
below the 50% centile line. The same holds for the other centile lines.
This
[`check_model_centiles()`](https://wisclab.github.io/wisclabmisc/reference/check_model_centiles.md)
performs this check by computing the percentages of observations less
than or equal to each centile line.

``` r

check_model_centiles(data, model, age, distance)
#> # A tibble: 7 × 4
#>   .centile     n n_under_centile percent_under_centile
#>      <dbl> <int>           <int>                 <dbl>
#> 1        5   108               6                  5.56
#> 2       10   108               9                  8.33
#> 3       25   108              25                 23.1 
#> 4       50   108              61                 56.5 
#> 5       75   108              85                 78.7 
#> 6       90   108              95                 88.0 
#> 7       95   108             100                 92.6
```

Which matches the gamlss package’s output:

``` r

centiles(
  model, 
  model$.user$data$age, 
  data = model$.user$data, 
  cent = c(5, 10,25, 50, 75, 90, 95), 
  plot = FALSE
)
#> % of cases below  5 centile is  5.555556 
#> % of cases below  10 centile is  8.333333 
#> % of cases below  25 centile is  23.14815 
#> % of cases below  50 centile is  56.48148 
#> % of cases below  75 centile is  78.7037 
#> % of cases below  90 centile is  87.96296 
#> % of cases below  95 centile is  92.59259
```

This function also supports grouped data to check centile performance
for different subsets of data.

``` r

data %>% 
  mutate(age_bin = ntile(age, 2)) %>% 
  group_by(age_bin) %>% 
  check_model_centiles(model, age, distance)
#> # A tibble: 14 × 5
#>    age_bin .centile     n n_under_centile percent_under_centile
#>      <int>    <dbl> <int>           <int>                 <dbl>
#>  1       1        5    54               3                  5.56
#>  2       1       10    54               4                  7.41
#>  3       1       25    54              13                 24.1 
#>  4       1       50    54              29                 53.7 
#>  5       1       75    54              44                 81.5 
#>  6       1       90    54              49                 90.7 
#>  7       1       95    54              51                 94.4 
#>  8       2        5    54               3                  5.56
#>  9       2       10    54               5                  9.26
#> 10       2       25    54              12                 22.2 
#> 11       2       50    54              32                 59.3 
#> 12       2       75    54              41                 75.9 
#> 13       2       90    54              46                 85.2 
#> 14       2       95    54              49                 90.7
```

This output also matches the output provide by gamlss’s
`centile.split()` function:

``` r

centiles.split(
  model, 
  model$.user$data$age, 
  data = model$.user$data, 
  n.inter = 2,
  cent = c(5, 10,25, 50, 75, 90, 95), 
  plot = FALSE
)
#>      7 to 11  11 to 15
#> 5   5.555556  5.555556
#> 10  7.407407  9.259259
#> 25 24.074074 22.222222
#> 50 53.703704 59.259259
#> 75 81.481481 75.925926
#> 90 90.740741 85.185185
#> 95 94.444444 90.740741
```
