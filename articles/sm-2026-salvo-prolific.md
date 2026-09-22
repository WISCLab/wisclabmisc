# Analysis code: 'Does the Use of Crowdsourced Listeners Yield Different Speech Intelligibility Results Than In-Person Listeners for Typically Developing Children?'

The following is a reproduction of the Supplemental Material (analysis
code) for Salvo, Mahr, Sandgren, Mabie, & Hustad (2026). All code is in
the R programming language.

- Publication DOI:
  [10.1044/2025_JSLHR-25-00391](https://doi.org/10.1044/2025_JSLHR-25-00391)
- Supplemental Material DOI:
  [10.23641/asha.31101451](https://doi.org/10.23641/asha.31101451)
- Analysis notes: Bayesian mixed effects regression; generalized
  additive models; marginal means; brms
- Project repo (private): `2024-10-hs-prolific`

------------------------------------------------------------------------

In this document, we provide and describe the R code used to produce the
main statistical findings of the manuscript.

## Data

Listeners transcribed children’s speech, and we measured the children’s
intelligibilities. Two different sets or sources of listeners were
compared (in-person versus crowdsourced). Crowdsourced listeners were
presented with an additional set of *fidelity* trials with an adult
speaker so that we could compute *fidelity intelligibility* scores.
These adult speakers should be easy for a reliable listener to
transcribe, so they provide a basis for screening out unreliable
listeners. We consider three different data screening scenarios based on
whether we apply a fidelity criterion of 0 (i.e., no criterion), .8 or
.9. We modeled intelligibility for single-word trials and multiword
trials separately.

Sample values from each column of the dataset are given below:

``` r

library(tidyverse)
data <- targets::tar_read("data_anon")
glimpse(data)
#> Rows: 6,480
#> Columns: 14
#> $ scenario         <chr> "screened_at_00", "screened_at_00", "screened…
#> $ set              <chr> "prolific", "prolific", "prolific", "prolific…
#> $ o_set            <ord> prolific, prolific, prolific, prolific, proli…
#> $ listener         <chr> "l86", "l86", "l86", "l86", "l86", "l86", "l2…
#> $ listener_order   <int> 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, …
#> $ child            <chr> "c34", "c34", "c34", "c34", "c34", "c34", "c3…
#> $ speaker_type     <chr> "adult", "participant", "adult", "participant…
#> $ tocs_type        <chr> "multiword", "multiword", "overall", "overall…
#> $ intelligibility  <dbl> 1.0000000, 0.2166667, 1.0000000, 0.3742690, 1…
#> $ intelligibility2 <dbl> 0.9950000, 0.2166667, 0.9950000, 0.3742690, 0…
#> $ sum_m_word       <dbl> 16, 10, 20, 27, 4, 17, 13, 13, 17, 28, 4, 15,…
#> $ sum_s_word       <dbl> 16, 50, 20, 87, 4, 37, 16, 50, 20, 87, 4, 37,…
#> $ age_months       <dbl> NA, 30, NA, 30, NA, 30, NA, 30, NA, 30, NA, 3…
#> $ age_48           <dbl> NA, -18, NA, -18, NA, -18, NA, -18, NA, -18, …
```

Columns represent the following values:

- `scenario` - Data-screening scenario: `"screened_at_00"` (no data
  screening), `"screened_at_80"` (at least 80% intelligibility on
  fidelity trials), and `"screened_at_90"` (at least 90% intelligibility
  on fidelity trials)

- `set`/`o_set` - Listener type: `"in_person"` or `"prolific"`
  (crowdsourced). The `o_set` version is an ordered factor used for
  modeling.

- `listener` - Random ID for the listener who is transcribing the speech
  samples.

- `listener_order` - Ordering of the listeners (from earliest to latest)
  within listener type and within each child. This ordering matters
  because in each data-screening `scenario`, we select the first 5
  listeners that meet a data-screening criterion.

- `child` - Random ID for the speaker whose speech samples are being
  played and transcribed.

- `speaker_type` - Speaker type on intelligibility trials:
  `"participant"` for the main intelligibility trials (where the speaker
  is the `child`) or `"adult"` for the fidelity trials used for
  data-screening.

- `tocs_type` - Intelligibility or speech sample type: `"multiword"` for
  connected speech samples, `"single-word"` for single words, and
  `"overall"` for an average across all trials.

- `intelligibility`, `intelligibility2`: Average of trial-level
  intelligibilities. For each trial, we compute the intelligibility as
  the proportion of words correctly transcribed on that trials. These
  proportions are then averaged together to produce intelligibility
  scores. `intelligibility2` is `intelligibility` squished into the
  range 0.005–0.995 (for use with beta regression).

- `sum_m_word`, `sum_s_word`: Total number of words correctly
  transcribed (`sum_m_word`, *matching* words) and total number of words
  in the speech samples (`sum_s_word`, *sample* words). These
  aggregations provide a way to compute a different intelligibility
  measure (proportion of words correctly transcribed), and they are used
  in a logistic regression model for the single-word trials.

- `age_months`, `age_48`: Age of the `child` in months (`age_months`),
  and a centered age where 48 months has the value 0 (`age_48`). The
  `"adult"` `speaker_type` trials don’t have an age associated with
  them.

Each child has 2 in-person listeners and 5 crowdsourced listeners in
each data-screening scenario. We can verify these listener counts.

``` r

data |> 
  distinct(child, listener, set, scenario) |> 
  count(child, set, scenario, name = "num_listeners") |> 
  count(set, scenario, num_listeners, name = "num_children")
#> # A tibble: 6 × 4
#>   set       scenario       num_listeners num_children
#>   <chr>     <chr>                  <int>        <int>
#> 1 in_person screened_at_00             2           60
#> 2 in_person screened_at_80             2           60
#> 3 in_person screened_at_90             2           60
#> 4 prolific  screened_at_00             5           60
#> 5 prolific  screened_at_80             5           60
#> 6 prolific  screened_at_90             5           60
```

We can verify the fidelity intelligibility data screening thresholds in
each group.

``` r

data |> 
  filter(
    speaker_type == "adult", 
    # average of single-word and connected speech trials
    tocs_type == "overall"
  ) |> 
  group_by(scenario, set) |> 
  summarise(
    min_intell = min(intelligibility),
    n_under_80 = sum(intelligibility < .80),
    n_under_90 = sum(intelligibility < .90),
    .groups = "drop"
  )
#> # A tibble: 3 × 5
#>   scenario       set      min_intell n_under_80 n_under_90
#>   <chr>          <chr>         <dbl>      <int>      <int>
#> 1 screened_at_00 prolific      0.625         12         27
#> 2 screened_at_80 prolific      0.812          0         15
#> 3 screened_at_90 prolific      0.906          0          0
```

(These counts slightly differ from a table in the manuscript because
that table includes an additional 3 exclusions where an excluded
listener’s first replacement also had to be excluded but here we just
count the first 5 listeners that satisfy inclusions.)

### Intraclass correlation

We report the intraclass correlation statistic as a measure of
interrater reliability. We deferred ICC calculation to the psych package
(vers. 2.5.3, Revelle, 2024). `pysch::ICC()` requires the data to have
one column per “judge” and no grouping variables, so we use
[`unstack()`](https://rdrr.io/r/utils/stack.html) (a no-frills
[`pivot_wider()`](https://tidyr.tidyverse.org/reference/pivot_wider.html))
in each `set` × `scenario` × `tocs_type` subgroup, compute the ICCs and
extract the relevant values.

``` r

data |> 
  filter(speaker_type == "participant", tocs_type != "overall") |>
  # Number the listeners within each child and each subsample
  group_by(set, scenario, tocs_type, child) |> 
  mutate(
    listener_number = seq_along(listener)
  ) |> 
  ungroup() |> 
  # Compute ICCs in each subsample
  group_by(set, scenario, tocs_type) |> 
  reframe(
    datasets = pick(c(listener_number, intelligibility)) |> 
      unstack(intelligibility ~ listener_number) |> 
      list(),
    iccs = datasets |> 
      lapply(psych::ICC, lmer = FALSE) |> 
      lapply(getElement, "results")
  ) |> 
  unnest(iccs) |> 
  filter(type %in% c("ICC2", "ICC2k")) |> 
  select(-F, -p, -df1, -df2, -datasets) |>
  mutate(
    set = set |> printy::str_replace_same_as_previous(""),
    scenario = scenario |> printy::str_replace_same_as_previous(""),
    tocs_type = tocs_type |> printy::str_replace_same_as_previous(""),
  ) |> 
  rename(ll = `lower bound`, ul = `upper bound`) |> 
  print(n = Inf)
#> # A tibble: 24 × 7
#>    set         scenario         tocs_type     type    ICC    ll    ul
#>    <chr>       <chr>            <chr>         <chr> <dbl> <dbl> <dbl>
#>  1 "in_person" "screened_at_00" "multiword"   ICC2  0.976 0.961 0.986
#>  2 ""          ""               ""            ICC2k 0.988 0.980 0.993
#>  3 ""          ""               "single-word" ICC2  0.913 0.859 0.947
#>  4 ""          ""               ""            ICC2k 0.955 0.924 0.973
#>  5 ""          "screened_at_80" "multiword"   ICC2  0.976 0.961 0.986
#>  6 ""          ""               ""            ICC2k 0.988 0.980 0.993
#>  7 ""          ""               "single-word" ICC2  0.913 0.859 0.947
#>  8 ""          ""               ""            ICC2k 0.955 0.924 0.973
#>  9 ""          "screened_at_90" "multiword"   ICC2  0.976 0.961 0.986
#> 10 ""          ""               ""            ICC2k 0.988 0.980 0.993
#> 11 ""          ""               "single-word" ICC2  0.913 0.859 0.947
#> 12 ""          ""               ""            ICC2k 0.955 0.924 0.973
#> 13 "prolific"  "screened_at_00" "multiword"   ICC2  0.813 0.744 0.872
#> 14 ""          ""               ""            ICC2k 0.956 0.936 0.971
#> 15 ""          ""               "single-word" ICC2  0.681 0.582 0.772
#> 16 ""          ""               ""            ICC2k 0.914 0.875 0.944
#> 17 ""          "screened_at_80" "multiword"   ICC2  0.869 0.818 0.912
#> 18 ""          ""               ""            ICC2k 0.971 0.957 0.981
#> 19 ""          ""               "single-word" ICC2  0.763 0.681 0.835
#> 20 ""          ""               ""            ICC2k 0.941 0.914 0.962
#> 21 ""          "screened_at_90" "multiword"   ICC2  0.888 0.842 0.925
#> 22 ""          ""               ""            ICC2k 0.975 0.964 0.984
#> 23 ""          ""               "single-word" ICC2  0.817 0.749 0.875
#> 24 ""          ""               ""            ICC2k 0.957 0.937 0.972
```

## Bayesian generalized additive mixed models

We fit a pair of Bayesian regression models with brms: one for connected
speech intelligibility and one for single-word intelligibility. We
regressed intelligibility onto age and listener type with by-child
random effects of listener type. We only examined `"participant"`
intelligibility scores (the fidelity trials were only used for
data-screening). These models had repeated measures with 1
intelligibility score per listener and 2 or 5 listeners per child.

The same basic regression setup was used to fit each model, so we
describe the first model in more detail.

### Connected speech model

We used beta regression for the connected speech model. brms uses the
mean-precision ($`\mu,\phi`$) parameterization of the beta distribution
where the mean is a proportion and the precision is a positive number.
We used the default link functions: logit for the mean (so the model for
the mean works on the log-odds scale) and log for the precision.

``` r

targets::tar_load("model_stocs_difference_smooth")
model_stocs_difference_smooth |> 
  family() |> 
  _[c("family", "dpars", "link", "link_phi")] |> 
  str()
#> List of 4
#>  $ family  : chr "beta"
#>  $ dpars   : chr [1:2] "mu" "phi"
#>  $ link    : chr "logit"
#>  $ link_phi: chr "log"
```

Beta regression does not allow proportions of 0 or 1, so these floor and
ceiling values were squished into the range 0.005 and .995.

``` r

y <- model_stocs_difference_smooth$data$intelligibility2
range(y)
#> [1] 0.08333333 0.99500000
sum(y == .005)
#> [1] 0
sum(y == .995)
#> [1] 6
```

The regression model in brms syntax is given below:

``` r

formula(model_stocs_difference_smooth)
#> intelligibility2 ~ set + s(age_48) + s(age_48, by = o_set) + (set | child) 
#> phi ~ set + age_48
```

For the mean model, we have a parametric effect of listener type (`set`)
and by-child random effects of listener type (`(set | child)`). We also
have a thin-plate spline smooth of age (`s(age_48)`) and a *difference
smooth* of age for the two listener types. Supplying an ordered factor
(`o_set`) causes mgcv/brms to compute a difference smooth.

Below we plot the baseline smooth (in-person listeners) and the
difference smooth (in-person minus crowdsourced listeners). There is not
a clear difference in the effects of age on intelligibility in the
smooths between the two listener groups (on the logit scale):

``` r

library(ggplot2)
library(patchwork)

cs1 <- model_stocs_difference_smooth |> 
  brms::conditional_smooths("s(age_48)") |> 
  # i.e., return the plot object but don't display it
  plot(plot = FALSE)
#> Loading required namespace: rstan

cs2 <- model_stocs_difference_smooth |> 
  brms::conditional_smooths(
    "s(age_48, by = o_set)", 
    int_conditions = list(o_set = "prolific")
  ) |> 
  plot(plot = FALSE)

cs1[[1]] + ylim(-2.75, 2.75) + cs2[[1]] + ylim(-2.75, 2.75)
```

![](data:image/png;base64,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)

#### Marginal means

Our visualizations used marginal means from each model. That is, a mixed
effects model’s fixed effects estimates a conditional mean: It is the
expected intelligibility score for a participant whose random effect
values have all been set to 0. This conditional mean is not the same as
the *marginal* or population mean, so we have take additional steps to
compute this marginal mean. Namely, we simulate new children based on
the model (sample new random effect values) and then average (or
*marginalize*) over them.

We used the following recipe to compute marginal means.

``` r

# 0. Prepare a prediction grid for a new out-of-sample participant
newdata <- targets::tar_read(newdata_stocs)
compute_tocs_marginal_means <- function(
    newdata,
    model,
    n = 1000,
    seed = NULL
) {
  # This model has 2 correlated random effects, so we need to draw n
  # participants from the model's random-effect variance-covariance matrix
  # on each posterior draw.

  if (!is.null(seed)) withr::local_seed(as.integer(seed))

  # 1. Get conditional means (logits) when random effects are zeroed out
  data_linpreds <- newdata |>
    tidybayes::add_linpred_rvars(
      model,
      ndraws = posterior::ndraws(model),
      re_formula = NA
    ) |>
    dplyr::select(-o_set, -control_file) |>
    tidyr::pivot_wider(names_from = "set", values_from = ".linpred")

  # 2. Get random effect variance-covariance matrix.
  cov <- model |>
    brms::VarCorr(summary = FALSE) |>
    _$child$cov |>
    posterior::rvar()
  means <- rep(0, ncol(cov))

  # 3. Simulate n new random effects (children) on each posterior draw.
  new_children <- posterior::rdo(mvtnorm::rmvnorm(n, means, cov))

  # 4. Add conditional means to simulated random effects, convert to
  #    proportion scale and average the proportions within each
  #    posterior draw

  # Handle random effects like (0 + set | child) where the marginal is
  #   `fixed effects + new_children[, <1 or 2>]`
  if (all(rownames(cov) == c("setin_person", "setprolific"))) {
    data_marginal_preds <- data_linpreds |>
      dplyr::rowwise() |>
      dplyr::mutate(
        in_person.conditional = .data$in_person |>
          brms::inv_logit_scaled(),
        prolific.conditional = .data$prolific |>
          brms::inv_logit_scaled(),
        in_person.marginal = (.data$in_person + new_children[, 1]) |>
          brms::inv_logit_scaled() |>
          posterior::rvar_mean(),
        prolific.marginal = (.data$prolific + new_children[, 2]) |>
          brms::inv_logit_scaled() |>
          posterior::rvar_mean()
      ) |>
      dplyr::ungroup() |>
      dplyr::mutate(
        diff.conditional = in_person.conditional - prolific.conditional,
        diff.marginal = in_person.marginal - prolific.marginal
      ) |>
      dplyr::select(age_48, ends_with("marginal"), ends_with("conditional"))

  }

  # Handle random effects like (set | child) where the marginal is
  #   `fixed effect + new_children[, 1] + <0 or new_children[, 2]`
  if (all(rownames(cov) == c("Intercept", "setprolific"))) {
    data_marginal_preds <- data_linpreds |>
      dplyr::rowwise() |>
      dplyr::mutate(
        in_person.conditional = .data$in_person |>
          brms::inv_logit_scaled(),
        prolific.conditional = .data$prolific |>
          brms::inv_logit_scaled(),
        in_person.marginal = (.data$in_person + new_children[, 1]) |>
          brms::inv_logit_scaled() |>
          posterior::rvar_mean(),
        prolific.marginal =
          (.data$prolific + new_children[, 1] + new_children[, 2]) |>
          brms::inv_logit_scaled() |>
          posterior::rvar_mean()
      ) |>
      dplyr::ungroup() |>
      dplyr::mutate(
        diff.conditional = in_person.conditional - prolific.conditional,
        diff.marginal = in_person.marginal - prolific.marginal
      ) |>
      dplyr::select(age_48, ends_with("marginal"), ends_with("conditional"))
  }

  # 5. Reshape to have one row per set
  data_marginal_preds |>
    tidyr::pivot_longer(
      cols = c(-age_48),
      names_pattern = "(.+)(.conditional|.marginal)",
      names_to = c("set", "type"),
      values_to = "value"
    ) |>
    tidyr::pivot_wider(names_from = type, values_from = value) |>
    # unnested form is faster/smaller to write to disk
    tidybayes::unnest_rvars()
}
```

Because of the long computation time, we instead read in and preview a
precomputed copy of the marginal means.

``` r

data_stocs_marginal_means <- targets::tar_read(data_stocs_marginal_means)
data_stocs_marginal_means
#> # A tibble: 1,056,000 × 9
#>    age_48 set     .marginal .conditional .chain .iteration .draw outcome
#>     <dbl> <chr>       <dbl>        <dbl>  <int>      <int> <int> <chr>  
#>  1    -18 in_per…     0.462        0.456      1          1     1 stocs  
#>  2    -18 in_per…     0.510        0.515      1          2     2 stocs  
#>  3    -18 in_per…     0.509        0.502      1          3     3 stocs  
#>  4    -18 in_per…     0.508        0.513      1          4     4 stocs  
#>  5    -18 in_per…     0.495        0.493      1          5     5 stocs  
#>  6    -18 in_per…     0.390        0.378      1          6     6 stocs  
#>  7    -18 in_per…     0.411        0.403      1          7     7 stocs  
#>  8    -18 in_per…     0.437        0.421      1          8     8 stocs  
#>  9    -18 in_per…     0.410        0.409      1          9     9 stocs  
#> 10    -18 in_per…     0.411        0.402      1         10    10 stocs  
#> # ℹ 1,055,990 more rows
#> # ℹ 1 more variable: level <chr>
```

From these conditional means, it is straightforward to compute growth
curves presented in the manuscript:

``` r

ggplot(data_stocs_marginal_means) + 
  aes(x = age_48, y = .marginal) +
  ggdist::stat_lineribbon(
    aes(group = set, fill = set), 
    .width = .95,
    alpha = .5
  )
```

![](data:image/png;base64,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)

#### Effect of intelligibility on listener type difference

For the plot of the in-person listener advantage versus in-person
intelligibility, we fix the in-person intelligibility to a narrow range
of values (i.e., we bin them) and gather all of the intelligibility
difference scores for that range of values.

For example, here are all the rows in the marginal means dataframe where
the in-person marginal means that are binned to .65.

``` r

d <- data_stocs_marginal_means |> 
  select(-.conditional) |> 
  filter(set != "prolific") |> 
  tidyr::pivot_wider(names_from = set, values_from = .marginal) |> 
  ungroup()

d_at_65 <- d |> 
  mutate(
    in_person = plyr::round_any(in_person, .025)
  ) |> 
  filter(in_person == .65)

d_at_65
#> # A tibble: 5,763 × 8
#>    age_48 .chain .iteration .draw outcome level in_person   diff
#>     <dbl>  <int>      <int> <int> <chr>   <chr>     <dbl>  <dbl>
#>  1    -18      1       3848  3848 stocs   i90        0.65 0.0400
#>  2    -17      1       1189  1189 stocs   i90        0.65 0.0608
#>  3    -17      1       3848  3848 stocs   i90        0.65 0.0436
#>  4    -16      1        477   477 stocs   i90        0.65 0.0425
#>  5    -16      1       1189  1189 stocs   i90        0.65 0.0614
#>  6    -16      1       3848  3848 stocs   i90        0.65 0.0472
#>  7    -15      1        477   477 stocs   i90        0.65 0.0459
#>  8    -15      1        478   478 stocs   i90        0.65 0.0793
#>  9    -15      1       1189  1189 stocs   i90        0.65 0.0620
#> 10    -15      1       3848  3848 stocs   i90        0.65 0.0509
#> # ℹ 5,753 more rows
```

There are 5763 ages × posterior draws where the marginal mean is binned
to this value. These include predictions from different ages and
different amounts of listener type differences (`diff`). We can look at
the distribution of these listener type differences.

``` r

hist(d_at_65$diff)
```

![](data:image/png;base64,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)

This distribution, for each difference, are presented in the manuscript.
We used the general recipe given below. The main details are that the
differences 1) we exclude any bins with fewer than 200 posterior draws
and 2) within each bin the differences within a posterior draw are
averaged together.

``` r

# Bin the in-person scores and count the differences in each bin. Discard 
# any bin with fewer than 200 posterior total draws.
d_intervals <- d |> 
  mutate(
    in_person = plyr::round_any(in_person, .025)
  ) |> 
  group_by(outcome, level, in_person) |> 
  mutate(n_draws = n()) |> 
  ungroup() |> 
  filter(n_draws > 200) |> 
  # If a posterior draw hits an in-person intelligibility bin multiple
  # times, because a curve plateaus or horseshoes, take the average
  # of the differences for each draw. Now each posterior draw
  # can only have one vote.
  group_by(outcome, level, in_person, .draw) |> 
  summarise(
    diff = mean(diff),
    .group = "drop"
  ) |> 
  # For each in-person intelligibility bin, get median and 95% interval.
  group_by(outcome, level, in_person) |> 
  ggdist::median_qi(diff)
#> `summarise()` has grouped output by 'outcome', 'level', 'in_person'.
#> You can override using the `.groups` argument.

d_intervals
#> # A tibble: 27 × 9
#>    outcome level in_person   diff   .lower .upper .width .point
#>    <chr>   <chr>     <dbl>  <dbl>    <dbl>  <dbl>  <dbl> <chr> 
#>  1 stocs   i90       0.35  0.0336 -0.00834 0.0618   0.95 median
#>  2 stocs   i90       0.375 0.0370 -0.00256 0.0666   0.95 median
#>  3 stocs   i90       0.4   0.0393  0.00313 0.0700   0.95 median
#>  4 stocs   i90       0.425 0.0417  0.00600 0.0735   0.95 median
#>  5 stocs   i90       0.45  0.0456  0.0113  0.0773   0.95 median
#>  6 stocs   i90       0.475 0.0493  0.0163  0.0806   0.95 median
#>  7 stocs   i90       0.5   0.0528  0.0210  0.0827   0.95 median
#>  8 stocs   i90       0.525 0.0561  0.0257  0.0843   0.95 median
#>  9 stocs   i90       0.55  0.0594  0.0312  0.0858   0.95 median
#> 10 stocs   i90       0.575 0.0624  0.0358  0.0872   0.95 median
#> # ℹ 17 more rows
#> # ℹ 1 more variable: .interval <chr>

ggplot(d_intervals) + 
  aes(x = in_person) + 
  geom_ribbon(aes(ymin = .lower, ymax = .upper), alpha = .2) +
  geom_line(aes(y = diff))
```

![](data:image/png;base64,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)

## Single-word intelligibility

The single-word intelligibility model was completely analogous to the
multiword model except that it was used logistic regression model (a
binomial family with logit link).

``` r

targets::tar_load("model_wtocs_difference_smooth")
model_wtocs_difference_smooth |> 
  family() |> 
  _[c("family", "dpars", "link")] |> 
  str()
#> List of 3
#>  $ family: chr "binomial"
#>  $ dpars : chr "mu"
#>  $ link  : chr "logit"
```

The binomial family estimates a number of successes in a number of
trials. The brms `trials()` syntax capture those values in the lefthand
side of the regression formula:

``` r

formula(model_wtocs_difference_smooth)
#> sum_m_word | trials(sum_s_word) ~ set + s(age_48) + s(age_48, by = o_set) + (set | child)
```

Recall that `sum_m_word` is the total number of words correctly
transcribed by a listener and `sum_s_word` is the total number of words
presented to the listener.

This model also used a difference smooth, and we can visualize the two
smooths as we did above.

``` r

cs1 <- model_wtocs_difference_smooth |> 
  brms::conditional_smooths("s(age_48)") |> 
  # i.e., return the plot object but don't display it
  plot(plot = FALSE)
#> Setting all 'trials' variables to 1 by default if not specified otherwise.

cs2 <- model_wtocs_difference_smooth |> 
  brms::conditional_smooths(
    "s(age_48, by = o_set)", 
    int_conditions = list(o_set = "prolific")
  ) |> 
  plot(plot = FALSE)
#> Setting all 'trials' variables to 1 by default if not specified otherwise.

cs1[[1]] + ylim(-2.75, 2.75) + cs2[[1]] + ylim(-2.75, 2.75)
```

![](data:image/png;base64,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)

The marginal means computation and
differences-by-in-person-intelligibility computation used the same
recipes (and code) as outlined above.

## Model comparisons

Do we need the difference smooth in each of these models? The right
panel of the marginal smooths mostly shows a horizontal line hovering
around 0, suggesting a limited difference. Model comparison with
approximate leave-one-out (LOO) techniques (Vehtari et al., 2017), on
the other hand, does not strongly favor the simpler shared smooth model
over the model with a baseline smooth and difference smooth.

``` r

targets::tar_load(model_stocs_difference_smooth)
targets::tar_load(model_stocs_shared_smooth)
targets::tar_load(model_wtocs_difference_smooth)
targets::tar_load(model_wtocs_shared_smooth)

brms::loo_compare(
  model_wtocs_shared_smooth, 
  model_wtocs_difference_smooth
) |> 
  print(simplify = FALSE) 
#>                               elpd_diff se_diff elpd_loo se_elpd_loo
#> model_wtocs_difference_smooth     0.0       0.0 -1066.3     27.8    
#> model_wtocs_shared_smooth        -2.1       2.4 -1068.4     28.1    
#>                               p_loo   se_p_loo looic   se_looic
#> model_wtocs_difference_smooth    87.5     8.5   2132.6    55.6 
#> model_wtocs_shared_smooth        90.0     8.8   2136.7    56.2

brms::loo_compare(
  model_stocs_shared_smooth, 
  model_stocs_difference_smooth
) |> 
  print(simplify = FALSE) 
#>                               elpd_diff se_diff elpd_loo se_elpd_loo
#> model_stocs_difference_smooth     0.0       0.0   680.5     25.4    
#> model_stocs_shared_smooth        -5.0       3.1   675.5     26.5    
#>                               p_loo   se_p_loo looic   se_looic
#> model_stocs_difference_smooth    65.5     5.3  -1361.1    50.8 
#> model_stocs_shared_smooth        65.7     5.5  -1351.1    53.0
```

We interpret this output by looking at ``` elpd_``loo ``` (expected log
predictive density). Higher values indicate better expected predictive
performance on out of sample data. The difference in ELPD between each
model and the highest ELPD model (i.e., first row) is given in
`elpd_diff`. We need to interpret these differences in light of the
standard error `se_diff`. Neither of the differences reported above is
greater than 2-SEs in magnitude, so there is not a statistically clear
difference between the models in terms of predictive performance.

We also note that leave-one-out comparison is not ideal for
repeated-measures data but leave-one-group-out techniques are
computationally prohibitive.

## Sampling details

Hamilitonian Monte Carlo sampling diagnostics indicated no major issues.
There were no divergent transitions, the max treedepth on the iterations
did not reach the treedepth limit, and the so-called estimated fraction
of missing information statistic was greater than .3 on every chain.

``` r

get_hmc_details <- function(model, ...) {
  df <- brms::nuts_params(model, ...)
  df$model <- as.character(substitute(model))
  df$limit_treedepth <- model$stan_args$control$max_treedepth %||% 10
  tidyr::pivot_wider(
    data = df,
    names_from = "Parameter", 
    values_from = "Value"
  )
}

bind_rows(
  get_hmc_details(model_stocs_difference_smooth),
  get_hmc_details(model_wtocs_difference_smooth)
) |> 
  group_by(model, chain = Chain) |> 
  summarise(
    n_draws = n(),
    efmi = mean(diff(energy__) ^ 2) / var(energy__),
    n_divergent = sum(divergent__),
    max_depth = max(treedepth__),
    limit_depth = unique(limit_treedepth),
    .groups = "drop"
  )
#> # A tibble: 8 × 7
#>   model            chain n_draws  efmi n_divergent max_depth limit_depth
#>   <chr>            <int>   <int> <dbl>       <dbl>     <dbl>       <dbl>
#> 1 model_stocs_dif…     1    1000 0.659           0         9          10
#> 2 model_stocs_dif…     2    1000 0.705           0         9          10
#> 3 model_stocs_dif…     3    1000 0.830           0         9          10
#> 4 model_stocs_dif…     4    1000 0.673           0         9          10
#> 5 model_wtocs_dif…     1    1000 0.683           0        10          15
#> 6 model_wtocs_dif…     2    1000 0.773           0         9          15
#> 7 model_wtocs_dif…     3    1000 0.696           0         9          15
#> 8 model_wtocs_dif…     4    1000 0.773           0         9          15
```

The Rhat and effective sample size statistics were also satisfactory
(Rhats \<= 1.01, ESS \> 100 per chain, or 400):

``` r

get_convergence_stats <- function(model) {
  df <- posterior::summarise_draws(
    model, 
    posterior::default_convergence_measures()
  )
  df$model <- as.character(substitute(model))
  df
}

bind_rows(
  get_convergence_stats(model_stocs_difference_smooth),
  get_convergence_stats(model_wtocs_difference_smooth)
) |> 
  group_by(model) |> 
  summarise(
    model = "model_stocs_difference_smooth",
    max_rhat = max(rhat), 
    min_ess_bulk = min(ess_bulk),
    min_ess_tail = min(ess_tail)
  )
#> # A tibble: 2 × 4
#>   model                         max_rhat min_ess_bulk min_ess_tail
#>   <chr>                            <dbl>        <dbl>        <dbl>
#> 1 model_stocs_difference_smooth     1.01         724.         968.
#> 2 model_stocs_difference_smooth     1.01         470.        1220.
```

## Prior description

Because these models estimate means on the logit scale, we used weakly
informative priors of Normal(0, 1) for the regression coefficients and
standard deviations of the random effects. Because mgcv transforms a
spline basis to absorb constraints and penalty terms in sophisticated
ways, appropriate scale values for the smooth terms are not clear a
priori. Therefore, we used wider Normal(0, 2) priors for the SDs of the
smoothing coefficients.

We used a weakly informative LKJ(2) prior on the correlations in the
random-effect matrix. This prior pulls probability mass away from
boundary correlations (1 or −1).

For the beta regression model, we also estimated a phi parameter with a
log link function and as a result, the effect of age on the precision on
the outcome scale is multiplicative. Therefore, we used a weakly
informative Normal(0, 2) prior.

Any other unspecified priors used brms defaults.

``` r

model_stocs_difference_smooth$prior
#>                 prior     class                    coef group resp dpar
#>          normal(0, 1)         b                                        
#>          normal(0, 1)         b sage_48:o_setprolific_1                
#>          normal(0, 1)         b               sage_48_1                
#>          normal(0, 1)         b             setprolific                
#>          normal(0, 2)         b                                     phi
#>          normal(0, 2)         b                  age_48             phi
#>          normal(0, 2)         b             setprolific             phi
#>          normal(0, 1) Intercept                                        
#>  student_t(3, 0, 2.5) Intercept                                     phi
#>  lkj_corr_cholesky(2)         L                                        
#>  lkj_corr_cholesky(2)         L                         child          
#>          normal(0, 1)        sd                                        
#>          normal(0, 1)        sd                         child          
#>          normal(0, 1)        sd               Intercept child          
#>          normal(0, 1)        sd             setprolific child          
#>          normal(0, 2)       sds                                        
#>          normal(0, 2)       sds               s(age_48)                
#>          normal(0, 2)       sds   s(age_48, by = o_set)                
#>  nlpar lb ub       source
#>                      user
#>              (vectorized)
#>              (vectorized)
#>              (vectorized)
#>                      user
#>              (vectorized)
#>              (vectorized)
#>                      user
#>                   default
#>                      user
#>              (vectorized)
#>         0            user
#>         0    (vectorized)
#>         0    (vectorized)
#>         0    (vectorized)
#>         0            user
#>         0    (vectorized)
#>         0    (vectorized)

model_wtocs_difference_smooth$prior 
#>                 prior     class                    coef group resp dpar
#>          normal(0, 1)         b                                        
#>          normal(0, 1)         b sage_48:o_setprolific_1                
#>          normal(0, 1)         b               sage_48_1                
#>          normal(0, 1)         b             setprolific                
#>          normal(0, 1) Intercept                                        
#>  lkj_corr_cholesky(2)         L                                        
#>  lkj_corr_cholesky(2)         L                         child          
#>          normal(0, 1)        sd                                        
#>          normal(0, 1)        sd                         child          
#>          normal(0, 1)        sd               Intercept child          
#>          normal(0, 1)        sd             setprolific child          
#>          normal(0, 2)       sds                                        
#>          normal(0, 2)       sds               s(age_48)                
#>          normal(0, 2)       sds   s(age_48, by = o_set)                
#>  nlpar lb ub       source
#>                      user
#>              (vectorized)
#>              (vectorized)
#>              (vectorized)
#>                      user
#>                      user
#>              (vectorized)
#>         0            user
#>         0    (vectorized)
#>         0    (vectorized)
#>         0    (vectorized)
#>         0            user
#>         0    (vectorized)
#>         0    (vectorized)
```

## Software details

Analyses were conducted in the R programming language (vers. 4.5.0, R
Core Team, 2025). Models were fit using the Stan programming language
(vers. 2.36.0, Stan Development Team, 2024) via the brms (vers. 2.22.0,
Bürkner, 2017) and cmdstanr (vers. 0.9.0, Gabry et al., 2024) R
packages. The implementation of smoothing splines relies on mgcv
(vers. 1.9.1, Wood, 2017). Handling the posterior samples was greatly
simplified by tidybayes (vers. 3.0.7, Kay, 2024b) and ggdist
(vers. 3.3.3, Kay, 2024a).

Because we rely on reading in cached models, it’s important to ask the
models for their software versions as well:

``` r

model_stocs_difference_smooth$version |> 
  lapply(as.character) |> 
  str()
#> List of 5
#>  $ brms       : chr "2.22.0"
#>  $ rstan      : chr "2.32.7"
#>  $ stanHeaders: chr "2.32.10"
#>  $ cmdstanr   : chr "0.9.0"
#>  $ cmdstan    : chr "2.36.0"

model_wtocs_difference_smooth$version |> 
  lapply(as.character) |> 
  str()
#> List of 5
#>  $ brms       : chr "2.22.0"
#>  $ rstan      : chr "2.32.7"
#>  $ stanHeaders: chr "2.32.10"
#>  $ cmdstanr   : chr "0.9.0"
#>  $ cmdstan    : chr "2.36.0"
```

## Full Model Summaries

For completeness, here are the full model summaries, but note that these
are generalized linear models with nonlinear link functions so it is
difficulty to interpret individual coefficients in isolation. Note also
that the quantities for the smoothing spline SDs and linear effects from
each smooth are generally uninterpretable because of several matrix
transformations. Thus, these models are best understood through the
expectations or predictions computed from them.

Multiword intelligibility:

``` r

summary(model_stocs_difference_smooth, priors = TRUE)
#>  Family: beta 
#>   Links: mu = logit; phi = log 
#> Formula: intelligibility2 ~ set + s(age_48) + s(age_48, by = o_set) + (set | child) 
#>          phi ~ set + age_48
#>    Data: structure(list(scenario = c("screened_at_90", "scr (Number of observations: 420) 
#>   Draws: 4 chains, each with iter = 2000; warmup = 1000; thin = 1;
#>          total post-warmup draws = 4000
#> 
#> Priors:
#> b ~ normal(0, 1)
#> b_phi ~ normal(0, 2)
#> Intercept ~ normal(0, 1)
#> Intercept_phi ~ student_t(3, 0, 2.5)
#> L ~ lkj_corr_cholesky(2)
#> <lower=0> sd ~ normal(0, 1)
#> <lower=0> sds ~ normal(0, 2)
#> 
#> Smoothing Spline Hyperparameters:
#>                             Estimate Est.Error l-95% CI u-95% CI Rhat
#> sds(sage_48_1)                  1.68      0.73     0.68     3.48 1.00
#> sds(sage_48o_setprolific_1)     0.33      0.30     0.01     1.15 1.00
#>                             Bulk_ESS Tail_ESS
#> sds(sage_48_1)                  1220     2098
#> sds(sage_48o_setprolific_1)     1297     1956
#> 
#> Multilevel Hyperparameters:
#> ~child (Number of levels: 60) 
#>                            Estimate Est.Error l-95% CI u-95% CI Rhat
#> sd(Intercept)                  0.67      0.07     0.54     0.82 1.00
#> sd(setprolific)                0.13      0.05     0.02     0.23 1.00
#> cor(Intercept,setprolific)    -0.66      0.23    -0.95    -0.07 1.00
#>                            Bulk_ESS Tail_ESS
#> sd(Intercept)                   944     1724
#> sd(setprolific)                1372      968
#> cor(Intercept,setprolific)     2958     1876
#> 
#> Regression Coefficients:
#>                         Estimate Est.Error l-95% CI u-95% CI Rhat
#> Intercept                   1.97      0.09     1.78     2.15 1.00
#> phi_Intercept               4.89      0.17     4.55     5.23 1.00
#> setprolific                -0.46      0.05    -0.56    -0.37 1.00
#> phi_setprolific            -1.57      0.19    -1.94    -1.19 1.00
#> phi_age_48                  0.00      0.00    -0.00     0.01 1.00
#> sage_48_1                   0.74      0.96    -1.19     2.62 1.00
#> sage_48:o_setprolific_1    -0.55      0.54    -1.66     0.59 1.00
#>                         Bulk_ESS Tail_ESS
#> Intercept                    750     1388
#> phi_Intercept               3153     2753
#> setprolific                 3647     3069
#> phi_setprolific             3588     3117
#> phi_age_48                  6466     3636
#> sage_48_1                   5196     2582
#> sage_48:o_setprolific_1     2719     2599
#> 
#> Draws were sampled using sample(hmc). For each parameter, Bulk_ESS
#> and Tail_ESS are effective sample size measures, and Rhat is the potential
#> scale reduction factor on split chains (at convergence, Rhat = 1).
```

Single word intelligibility:

``` r

summary(model_wtocs_difference_smooth, priors = TRUE)
#>  Family: binomial 
#>   Links: mu = logit 
#> Formula: sum_m_word | trials(sum_s_word) ~ set + s(age_48) + s(age_48, by = o_set) + (set | child) 
#>    Data: structure(list(scenario = c("screened_at_90", "scr (Number of observations: 420) 
#>   Draws: 4 chains, each with iter = 2000; warmup = 1000; thin = 1;
#>          total post-warmup draws = 4000
#> 
#> Priors:
#> b ~ normal(0, 1)
#> Intercept ~ normal(0, 1)
#> L ~ lkj_corr_cholesky(2)
#> <lower=0> sd ~ normal(0, 1)
#> <lower=0> sds ~ normal(0, 2)
#> 
#> Smoothing Spline Hyperparameters:
#>                             Estimate Est.Error l-95% CI u-95% CI Rhat
#> sds(sage_48_1)                  1.23      0.60     0.48     2.72 1.00
#> sds(sage_48o_setprolific_1)     0.36      0.36     0.01     1.39 1.00
#>                             Bulk_ESS Tail_ESS
#> sds(sage_48_1)                  1664     2662
#> sds(sage_48o_setprolific_1)     1597     1930
#> 
#> Multilevel Hyperparameters:
#> ~child (Number of levels: 60) 
#>                            Estimate Est.Error l-95% CI u-95% CI Rhat
#> sd(Intercept)                  0.60      0.07     0.47     0.75 1.00
#> sd(setprolific)                0.14      0.08     0.01     0.31 1.01
#> cor(Intercept,setprolific)     0.05      0.35    -0.60     0.76 1.00
#>                            Bulk_ESS Tail_ESS
#> sd(Intercept)                  1712     2513
#> sd(setprolific)                 470     1474
#> cor(Intercept,setprolific)     2780     1731
#> 
#> Regression Coefficients:
#>                         Estimate Est.Error l-95% CI u-95% CI Rhat
#> Intercept                   1.39      0.09     1.21     1.56 1.00
#> setprolific                -0.30      0.05    -0.40    -0.19 1.00
#> sage_48_1                   0.47      0.93    -1.39     2.26 1.00
#> sage_48:o_setprolific_1    -0.30      0.54    -1.35     0.90 1.00
#>                         Bulk_ESS Tail_ESS
#> Intercept                    985     1779
#> setprolific                 6484     3400
#> sage_48_1                   4254     3055
#> sage_48:o_setprolific_1     3689     2544
#> 
#> Draws were sampled using sample(hmc). For each parameter, Bulk_ESS
#> and Tail_ESS are effective sample size measures, and Rhat is the potential
#> scale reduction factor on split chains (at convergence, Rhat = 1).
```

## Modeling functions

The following code block shows the modeling workflow we used to fit
these models. Each family of models has a single function. A user passes
in a dataset, a model `flavor`, an optional random number seed and
optional `tag`. The `flavor` is used to look up the appropriate model
formula, and the `tag` is used to differentiate two models with
different datasets but the same flavor.

``` r

fit_stocs_model <- function(
    data,
    flavor,
    tag = "",
    seed = NA,
    use_reloo = FALSE
) {
  formulas <- list(
    stocs_shared_smooth = bf(
      intelligibility2 ~ set + s(age_48) +
        (set | child),
      phi ~ set + age_48,
      family = Beta
    ),
    stocs_difference_smooth = bf(
      intelligibility2 ~
        set +
        s(age_48) +
        s(age_48, by = o_set) +
        (set | child),
      phi ~ set + age_48,
      family = Beta
    )
  )

  formula <- formulas[[flavor]]
  loo_slug <- ifelse(use_reloo, "_reloo", "")
  file <- file.path(
    "models", paste0(flavor, tag, loo_slug)
  )

  prior <- if (has_random_slope_correlation(formula, data)) {
    lookup_brms_priors("logit_phi_w_random_slopes")
  } else {
    lookup_brms_priors("logit_phi_w_random_intercepts")
  }

  args <- brm_args(
    formula = formula,
    data = data,
    prior = prior,
    file = file,
    seed = seed,
    adapt_delta = .98,
    iter = 2000
  )
  model <- do.call(brms::brm, args)

  add_loo_criterion(model, use_reloo)
}

fit_wtocs_model <- function(
    data,
    flavor,
    tag = "",
    seed = NA,
    use_reloo = FALSE
) {
  formulas <- list(
    wtocs_shared_smooth = bf(
      sum_m_word | trials(sum_s_word) ~
        set +
        s(age_48) +
        (set | child),
      family = binomial
    ),
    wtocs_difference_smooth = bf(
      sum_m_word | trials(sum_s_word) ~
        set +
        s(age_48) +
        s(age_48, by = o_set) +
        (set | child),
      family = binomial
    ),
    wtocs_difference_smooth_simple_ranef = bf(
      sum_m_word | trials(sum_s_word) ~
        set +
        s(age_48) +
        s(age_48, by = o_set) +
        (0 + set | child),
      family = binomial
    )
  )

  formula <- formulas[[flavor]]
  loo_slug <- ifelse(use_reloo, "_reloo", "")
  file <- file.path(
    "models", paste0(flavor, tag, loo_slug)
  )

  prior <- if (has_random_slope_correlation(formula, data)) {
    lookup_brms_priors("logit_w_random_slopes")
  } else {
    lookup_brms_priors("logit_w_random_intercepts")
  }

  args <- brm_args(
    formula = formula,
    data = data,
    prior = prior,
    file = file,
    seed = seed,
    adapt_delta = .99,
    max_treedepth = 15
  )
  model <- do.call(brms::brm, args)

  add_loo_criterion(model, use_reloo)
}

lookup_brms_priors <- function(set = "logit_w_random_intercepts") {
  l <- list(
    logit_w_random_intercepts = c(
      prior(normal(0, 1), class = b),
      prior(normal(0, 2), class = sds),
      prior(normal(0, 1), class = Intercept),
      prior(normal(0, 1), class = sd)
    ),
    logit_w_random_slopes = c(
      prior(normal(0, 1), class = b),
      prior(normal(0, 1), class = sd),
      prior(normal(0, 2), class = sds),
      prior(normal(0, 1), class = Intercept),
      prior(lkj(2), class = cor)
    ),
    logit_phi_w_random_intercepts = c(
      prior(normal(0, 1), class = b),
      prior(normal(0, 2), class = sds),
      prior(normal(0, 1), class = Intercept),
      prior(normal(0, 1), class = sd),
      prior(normal(0, 2), class = b, dpar = phi)
    ),
    logit_phi_w_random_slopes = c(
      prior(normal(0, 1), class = b),
      prior(normal(0, 2), class = sds),
      prior(normal(0, 1), class = Intercept),
      prior(normal(0, 1), class = sd),
      prior(lkj(2), class = cor),
      prior(normal(0, 2), class = b, dpar = phi)
    )
  )
  l[[set]]
}

has_random_slope_correlation <- function(formula, data) {
  num_cors <- brms::default_prior(formula, data) |>
    filter(group != "") |>
    filter(class == "cor") |>
    nrow()
  num_cors > 0
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

brm_args <- function(
    .backend = "cmdstanr",
    .threads = 2,
    .chains = 4,
    .cores = 4,
    .iter = 2000,
    .silent = 0,
    .file_refit = "on_change",
    .refresh = 25,
    ...
) {
  # the .names prevent `file` from partial matching `file_refit`
  defaults <- list(
    backend = .backend,
    threads = .threads,
    chains = .chains,
    cores = .cores,
    iter = .iter,
    silent = .silent,
    file_refit = .file_refit,
    refresh = .refresh
  )
  dots <- list(...)
  if (is.null(dots$control)) {
    dots$control <- list()
  }
  if (!is.null(dots$adapt_delta)) {
    dots$control$adapt_delta <- dots$adapt_delta
    dots$adapt_delta <- NULL
  }
  if (!is.null(dots$max_treedepth )) {
    dots$control$max_treedepth <- dots$max_treedepth
    dots$max_treedepth <- NULL
  }
  if (length(dots$control) == 0) {
    dots$control <- NULL
  }
  utils::modifyList(defaults, dots)
}
```

## References

Bürkner, P.-C. (2017). brms: An R package for Bayesian multilevel models
using Stan. *Journal of Statistical Software*, *80*(1), 1–28.
<https://doi.org/10.18637/jss.v080.i01>

Gabry, J., Češnovar, R., & Johnson, A. (2024). *cmdstanr: R interface to
CmdStan*. <https://mc-stan.org/cmdstanr/>

Kay, M. (2024a). ggdist: Visualizations of distributions and uncertainty
in the grammar of graphics. *IEEE Transactions on Visualization and
Computer Graphics*, *30*(1), 414–424.
<https://doi.org/10.1109/TVCG.2023.3327195>

Kay, M. (2024b). *tidybayes: Tidy data and geoms for Bayesian models*.
<https://doi.org/10.5281/zenodo.1308151>

R Core Team. (2025). *R: A language and environment for statistical
computing*. R Foundation for Statistical Computing.
<https://www.R-project.org/>

Revelle, W. (2024). *psych: Procedures for psychological, psychometric,
and personality research*. Northwestern University.
<https://doi.org/10.32614/CRAN.package.psych>

Stan Development Team. (2024). *Stan modeling language users guide and
reference manual*. <https://mc-stan.org>

Vehtari, A., Gelman, A., & Gabry, J. (2017). Practical Bayesian model
evaluation using leave-one-out cross-validation and WAIC. *Statistics
and Computing*, *27*, 1413–1432.
<https://doi.org/10.1007/s11222-016-9696-4>

Wood, S. N. (2017). *Generalized additive models: An introduction with
R* (2nd ed.). Chapman; Hall/CRC.
