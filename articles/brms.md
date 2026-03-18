# A Workflow for brms

``` r
library(brms)
```

[brms](https://paulbuerkner.com/brms/) is the premier Bayesian
regression package in R, and we use it in many of our projects. In this
article, I describe the workflow for using brms that I have ~~stumbled
upon~~ iterated over our last few analysis projects.

## Context: A set of models

Suppose that we have a dataset of age and intelligibility.

``` r
data <- wisclabmisc::data_fake_intelligibility
data
#> # A tibble: 200 × 2
#>    age_months intelligibility
#>         <int>           <dbl>
#>  1         28           0.539
#>  2         29           0.375
#>  3         31           0.221
#>  4         31           0.253
#>  5         32           0.276
#>  6         32           0.750
#>  7         32           0.820
#>  8         33           0.325
#>  9         33           0.446
#> 10         33           0.592
#> # ℹ 190 more rows
```

We want to fit a *set of related models*. By “related”, I loosely mean
that the models have the same outcome variable and the same modeling
family. What can vary from model to model are the formulas or the
priors. For example, suppose we want to compare models with different
kinds of age trends using splines:

``` r
library(brms)
library(splines)
f1 <- bf(
  intelligibility ~ age_months, 
  phi ~ age_months, 
  family = Beta
)
f2 <- bf(
  intelligibility ~ ns(age_months, 2), 
  phi ~ ns(age_months, 2),
  family = Beta
)
f3 <- bf(
  intelligibility ~ ns(age_months, 3), 
  phi ~ ns(age_months, 3),
  family = Beta
)
```

Given these model formulas, we could then write a
[`brm()`](https://paulbuerkner.com/brms/reference/brm.html) for each
one, but that’s not a good plan. More models could arise as we start to
analyze and critique the results. We might need to set `adapt_delta` to
a higher value for all the models. Aside from the formulas, and
sometimes the priors, everything about the model-fitting should
generally be the same from model to model.

A solution for this problem to **make a function for fitting models from
the set**. A function provides two wins:

1.  We can standardize the model fitting across models.
2.  We can indicate the similarity of the models through the
    organization of the code. A function tells us “this is where we
    define possible age models”.

Here is what the workflow looks like at a very high level. We have a
helper function for retrieving priors, a helper function for computing
LOO scores, a helper function for the default/shared arguments to
[`brm()`](https://paulbuerkner.com/brms/reference/brm.html), and the
main function for fitting models from the set.

``` r
lookup_prior <- function(prior_slug) {
  # ...
} 

add_loo_criterion <- function(x, ..., use_reloo = FALSE) { 
  # ...
}

brm_args <- wisclabmisc::brms_args_create()

fit_age_model <- function(
    data,
    model_slug,
    prior_slug = "default",
    seed = NA,
    use_reloo = FALSE,
    ...
) {
  # 1. [looking up priors]

  # 2. [mapping from model_slug to formula]
  
  # 3. [creating a filename]
  
  # 4. [fitting model]
  
  # 5. [adding LOO score]
}
```

## Priors

We look up priors by using a helper function. Right now, we don’t have
any different set of priors we want to compare, so there are just two
options: use some weak priors for the logit-scale mu and the log-scale
phi, or use the brms defaults.

``` r
lookup_prior <- function(prior_slug) {
  l <- list(
    default = c(
      prior(normal(0, 1), class = b),
      prior(normal(0, 2), class = Intercept),
      prior(normal(0, 2), class = Intercept, dpar = phi),
      prior(normal(0, 2), class = b, dpar = phi)
    ),
    brms_default = NULL
  )
  l[[prior_slug]]
}
```

Priors are strict (in a good way): I can’t set a prior for a parameter
that doesn’t exist in the model formula. For example, I can’t set a
prior on the random effect variance when the formula doesn’t include
random effects:

``` r
validate_prior(
  c(lookup_prior("default"), prior(normal(0, 1), class = "sd")),
  formula = f1,
  data = data
)
#> Error in `.validate_prior()`:
#> ! The following priors do not correspond to any model parameter: 
#> sd ~ normal(0, 1)
#> Function 'default_prior' might be helpful to you.
```

The flipside of this strictness is that I will need to toggle between
priors, for example, when fitting a random-intercept model and a
random-slope model, or when fitting a model with regression splines
[`ns()`](https://rdrr.io/r/splines/ns.html) and a model with a smoothing
spline [`s()`](https://paulbuerkner.com/brms/reference/s.html). In my
most recent project, I had the following lookup function:

``` r
lookup_brms_priors <- function(prior_slug = "logit_ri") {
  l <- list(
    logit_ri = c(
      prior(normal(0, 1), class = b),
      prior(normal(0, 2), class = sds),
      prior(normal(0, 2), class = Intercept),
      prior(normal(0, 1), class = sd)
    ),
    logit_rs = c(
      prior(normal(0, 1), class = b),
      prior(normal(0, 1), class = sd),
      prior(normal(0, 2), class = sds),
      prior(normal(0, 2), class = Intercept),
      prior(lkj(2), class = cor)
    ),
    logit_phi_ri = c(
      prior(normal(0, 1), class = b),
      prior(normal(0, 2), class = sds),
      prior(normal(0, 2), class = Intercept),
      prior(normal(0, 1), class = sd),
      prior(normal(0, 2), class = b, dpar = phi)
    ),
    logit_phi_rs = c(
      prior(normal(0, 1), class = b),
      prior(normal(0, 2), class = sds),
      prior(normal(0, 2), class = Intercept),
      prior(normal(0, 1), class = sd),
      prior(lkj(2), class = cor),
      prior(normal(0, 2), class = b, dpar = phi)
    )
  )
  l[[prior_slug]]
}
```

In this case, there were two sets of models: one with a binomial outcome
that used `logit_ri` and `logit_rs` and one with a beta outcome that
needed additional priors on the precision parameter phi via
`logit_phi_ri` and `logit_phi_rs`. The `_ri` and `_rs` different in
whether they include a prior on the correlation of random effects.

## A helper function for LOO computation

I like to compute the LOO score by default. This operation can be
time-consuming, but it fortunately gets cached in the model `file` so I
just make it part of the model fitting. My function doesn’t do anything
noteworthy other than making it easy to toggle on exact LOO scores if
needed. The `reloo` argument gets forwarded to
[`brms::loo()`](https://mc-stan.org/loo/reference/loo.html). If
`use_reloo = TRUE`, brms refits the model to compute exact leave-one-out
scores for problematic observations.

``` r
add_loo_criterion <- function(x, ..., use_reloo = FALSE) {
  if (use_reloo) {
    brms::add_criterion(
      x,
      criterion = "loo",
      reloo = TRUE,
      recompile = FALSE,
      ...
    )
  } else {
    brms::add_criterion(
      x,
      criterion = "loo",
      ...
    )
  }
}
```

One thing I would like to figure out for my workflow is a smart way to
describe and fit LOGO (leave one group out) models for repeated-measures
models.

## Model-fitting defaults

We usually want knobs and dials of model fitting—number of chains,
number of iterations, Stan backend—to be the same from model-to-model.
So we create a function called `brm_args()` the prints out a list of
default arguments to
[`brm()`](https://paulbuerkner.com/brms/reference/brm.html). We create
this function using
[`wisclabmisc::brms_args_create()`](https://wisclab.github.io/wisclabmisc/reference/brms_args_create.md).

Here are the package-provided defaults. (These defaults are just my
preferred settings.)

``` r
brm_args <- wisclabmisc::brms_args_create()
brm_args()
#> List of 9
#>  $ backend   : chr "cmdstanr"
#>  $ threads   : num 2
#>  $ chains    : num 4
#>  $ cores     : num 4
#>  $ iter      : num 2000
#>  $ silent    : num 0
#>  $ file_refit: chr "on_change"
#>  $ refresh   : num 25
#>  $ control   : list()
#>  - attr(*, "class")= chr [1:2] "brm_args" "list"
```

The interesting ones might be `file_refit`, `threads` and `backend`. If
you provide [`brm()`](https://paulbuerkner.com/brms/reference/brm.html)
with a `file` like `"my-model"` it will save the fitted model into
`my-model.rds`. `file_refit = "on_change"` tells brms to refit this
model if the model’s Stan code or data change. By default
`file_refit = "never"`, meaning that it never refits the model. I set
`threads` and `backend` to try to make the model sample or compile more
quickly. I do set `refresh` to a small number because I like to see the
MCMC chains sampling.

If these defaults are troublesome (`refresh`), we can generate a new
`brm_args()` function with different defaults.

``` r
brm_args <- wisclabmisc::brms_args_create(iter = 5000, refresh = 100)
brm_args()
#> List of 9
#>  $ backend   : chr "cmdstanr"
#>  $ threads   : num 2
#>  $ chains    : num 4
#>  $ cores     : num 4
#>  $ iter      : num 5000
#>  $ silent    : num 0
#>  $ file_refit: chr "on_change"
#>  $ refresh   : num 100
#>  $ control   : list()
#>  - attr(*, "class")= chr [1:2] "brm_args" "list"
```

These `brm_args()` function lets us set default
[`brm()`](https://paulbuerkner.com/brms/reference/brm.html) argument
values. Importantly, we can deviate from these defaults if we need to.
Here we can overwrite the number of chains and set a value for
`adapt_delta`.

``` r
brm_args(chains = 2, adapt_delta = .98)
#> List of 9
#>  $ backend   : chr "cmdstanr"
#>  $ threads   : num 2
#>  $ chains    : num 2
#>  $ cores     : num 4
#>  $ iter      : num 5000
#>  $ silent    : num 0
#>  $ file_refit: chr "on_change"
#>  $ refresh   : num 100
#>  $ control   :List of 1
#>   ..$ adapt_delta: num 0.98
#>  - attr(*, "class")= chr [1:2] "brm_args" "list"
```

## Model fitting function

Now, we can fit a model. Each of the steps in the function are pretty
simple. We are generating and executing a call to
[`brm()`](https://paulbuerkner.com/brms/reference/brm.html) (via
[`do.call()`](https://rdrr.io/r/base/do.call.html)) but have to look up
the prior and formula to use, and create a filename for the `file`
argument.

``` r
# Use rstan for the article page
brm_args <- wisclabmisc::brms_args_create(backend = "rstan")

fit_age_model <- function(
    data,
    model_slug,
    prior_slug = "default",
    seed = NA,
    use_reloo = FALSE, 
    ...
) {
  # 1. [looking up priors]
  prior <- lookup_prior(prior_slug)

  # 2. [mapping from model_slug to formula]
  ns <- splines::ns
  
  formulas <- list(
    linear = bf(
      intelligibility ~ age_months, 
      phi ~ age_months, 
      family = Beta
    ),
    spline_2df = bf(
      intelligibility ~ ns(age_months, 2), 
      phi ~ ns(age_months, 2),
      family = Beta
    ),
    spline_3df = bf(
      intelligibility ~ ns(age_months, 3), 
      phi ~ ns(age_months, 3),
      family = Beta
    )
  )
  
  formula <- formulas[[model_slug]]
  
  # 3. [creating a filename]
  loo_slug <- ifelse(use_reloo, "_reloo", "")
  file <- file.path(
    "models", paste0(model_slug, "_", prior_slug, loo_slug)
  )
  
  # 4. [fitting model]
  args <- brm_args(
    formula = formula,
    data = data,
    prior = prior,
    file = file,
    seed = seed,
    ...
  )
  model <- do.call(brm, args)

  # 5. [adding LOO score]
  add_loo_criterion(model, use_reloo)
}
```

Let’s fit the models and compare them.

``` r
# I'm only using rstan to get the demo to work on GitHub pages
library(rstan)
#> Loading required package: StanHeaders
#> 
#> rstan version 2.32.7 (Stan version 2.32.2)
#> For execution on a local, multicore CPU with excess RAM we recommend calling
#> options(mc.cores = parallel::detectCores()).
#> To avoid recompilation of unchanged Stan programs, we recommend calling
#> rstan_options(auto_write = TRUE)
#> For within-chain threading using `reduce_sum()` or `map_rect()` Stan functions,
#> change `threads_per_chain` option:
#> rstan_options(threads_per_chain = 1)
m1 <- fit_age_model(data, "linear", seed = 20241023)
m2 <- fit_age_model(data, "spline_2df", seed = 20241023)
m3 <- fit_age_model(data, "spline_3df", seed = 20241023)

loo_compare(m1, m2, m3) |> 
  print(simplify = FALSE)
#>    elpd_diff se_diff elpd_loo se_elpd_loo p_loo  se_p_loo looic  se_looic
#> m1    0.0       0.0   248.6     14.8         3.2    0.4   -497.3   29.7  
#> m2   -0.6       2.1   248.0     14.7         4.8    0.6   -496.1   29.4  
#> m3   -4.1       2.5   244.5     14.9         6.5    0.7   -489.0   29.8
```

## The full workflow

Here is the full workflow from above, for easy copy-pasting as
boilerplate for new projects. Putting this code chunk in a easy to grab
place is my motivation for writing this article. 🤓

``` r
lookup_prior <- function(prior_slug) {
  l <- list(
    default = c(
      prior(normal(0, 1), class = b),
      prior(normal(0, 2), class = Intercept),
      prior(normal(0, 2), class = Intercept, dpar = phi),
      prior(normal(0, 2), class = b, dpar = phi)
    ),
    brms_default = NULL
  )
  l[[prior_slug]]
}

add_loo_criterion <- function(x, ..., use_reloo = FALSE) {
  if (use_reloo) {
    brms::add_criterion(
      x,
      criterion = "loo",
      reloo = TRUE,
      recompile = FALSE,
      ...
    )
  } else {
    brms::add_criterion(
      x,
      criterion = "loo",
      ...
    )
  }
}

brm_args <- wisclabmisc::brms_args_create()

fit_age_model <- function(
    data,
    model_slug,
    prior_slug = "default",
    seed = NA,
    use_reloo = FALSE, 
    ...
) {
  # 1. [looking up priors]
  prior <- lookup_prior(prior_slug)

  # 2. [mapping from model_slug to formula]
  ns <- splines::ns
  
  formulas <- list(
    linear = bf(
      intelligibility ~ age_months, 
      phi ~ age_months, 
      family = Beta
    ),
    spline_2df = bf(
      intelligibility ~ ns(age_months, 2), 
      phi ~ ns(age_months, 2),
      family = Beta
    ),
    spline_3df = bf(
      intelligibility ~ ns(age_months, 3), 
      phi ~ ns(age_months, 3),
      family = Beta
    )
  )
  
  formula <- formulas[[model_slug]]
  
  # 3. [creating a filename]
  loo_slug <- ifelse(use_reloo, "_reloo", "")
  file <- file.path(
    "models", paste0(model_slug, "_", prior_slug, loo_slug)
  )
  
  # 4. [fitting model]
  args <- brm_args(
    formula = formula,
    data = data,
    prior = prior,
    file = file,
    seed = seed,
    ...
  )
  model <- do.call(brm, args)

  # 5. [adding LOO score]
  add_loo_criterion(model, use_reloo)
}
```
