# Package index

## Analyses 🔬

- [`fit_beta_gamlss()`](https://wisclab.github.io/wisclabmisc/reference/beta-intelligibility.md)
  [`fit_beta_gamlss_se()`](https://wisclab.github.io/wisclabmisc/reference/beta-intelligibility.md)
  [`predict_beta_gamlss()`](https://wisclab.github.io/wisclabmisc/reference/beta-intelligibility.md)
  [`optimize_beta_gamlss_slope()`](https://wisclab.github.io/wisclabmisc/reference/beta-intelligibility.md)
  [`uniroot_beta_gamlss()`](https://wisclab.github.io/wisclabmisc/reference/beta-intelligibility.md)
  : Fit a beta regression model (for intelligibility)
- [`fit_gen_gamma_gamlss()`](https://wisclab.github.io/wisclabmisc/reference/gen-gamma-rate.md)
  [`fit_gen_gamma_gamlss_se()`](https://wisclab.github.io/wisclabmisc/reference/gen-gamma-rate.md)
  [`predict_gen_gamma_gamlss()`](https://wisclab.github.io/wisclabmisc/reference/gen-gamma-rate.md)
  : Fit a generalized gamma regression model (for speaking rate)

## GAMLSS helpers ⛑️

- [`mem_gamlss()`](https://wisclab.github.io/wisclabmisc/reference/mem_gamlss.md)
  : Fit a gamlss model but store user data
- [`check_model_centiles()`](https://wisclab.github.io/wisclabmisc/reference/check_model_centiles.md)
  [`check_computed_centiles()`](https://wisclab.github.io/wisclabmisc/reference/check_model_centiles.md)
  : Compute the percentage of points under each centile line
- [`predict_centiles()`](https://wisclab.github.io/wisclabmisc/reference/predict_centiles.md)
  [`pivot_centiles_longer()`](https://wisclab.github.io/wisclabmisc/reference/predict_centiles.md)
  : Predict and tidy centiles from a GAMLSS model

## ROC statistics 🥅

- [`compute_smooth_density_roc()`](https://wisclab.github.io/wisclabmisc/reference/compute_smooth_density_roc.md)
  : Create an ROC curve from smoothed densities
- [`compute_empirical_roc()`](https://wisclab.github.io/wisclabmisc/reference/compute_empirical_roc.md)
  : Create an ROC curve from observed data
- [`compute_predictive_value_from_rates()`](https://wisclab.github.io/wisclabmisc/reference/compute_predictive_value_from_rates.md)
  : Compute positive and negative predictive value
- [`compute_sens_spec_from_ecdf()`](https://wisclab.github.io/wisclabmisc/reference/compute_sens_spec_from_ecdf.md)
  : Compute sensitivity and specificity scores from (weighted) observed
  data
- [`trapezoid_auc()`](https://wisclab.github.io/wisclabmisc/reference/trapezoid_auc.md)
  [`partial_trapezoid_auc()`](https://wisclab.github.io/wisclabmisc/reference/trapezoid_auc.md)
  : Compute AUCs using the trapezoid method

## Other statistics 🔦

- [`fit_kmeans()`](https://wisclab.github.io/wisclabmisc/reference/fit_kmeans.md)
  : Run (scaled) k-means on a dataset.
- [`info_surprisal()`](https://wisclab.github.io/wisclabmisc/reference/information.md)
  [`info_entropy()`](https://wisclab.github.io/wisclabmisc/reference/information.md)
  [`info_cross_entropy()`](https://wisclab.github.io/wisclabmisc/reference/information.md)
  [`info_kl_divergence()`](https://wisclab.github.io/wisclabmisc/reference/information.md)
  [`info_kl_divergence_matrix()`](https://wisclab.github.io/wisclabmisc/reference/information.md)
  : Compute entropy and related measures
- [`logitnorm_mean()`](https://wisclab.github.io/wisclabmisc/reference/logitnorm_mean.md)
  : Compute the mean of logit-normal distribution(s)
- [`check_model_centiles()`](https://wisclab.github.io/wisclabmisc/reference/check_model_centiles.md)
  [`check_computed_centiles()`](https://wisclab.github.io/wisclabmisc/reference/check_model_centiles.md)
  : Compute the percentage of points under each centile line

## WiscLab data prepartion 🧹

- [`format_year_month_age()`](https://wisclab.github.io/wisclabmisc/reference/ages.md)
  [`parse_year_month_age()`](https://wisclab.github.io/wisclabmisc/reference/ages.md)
  [`parse_yymm_age()`](https://wisclab.github.io/wisclabmisc/reference/ages.md)
  : Convert between age in months, years;months, and yymm age formats
- [`chrono_age()`](https://wisclab.github.io/wisclabmisc/reference/chrono_age.md)
  : Compute chronological age in months
- [`impute_values_by_length()`](https://wisclab.github.io/wisclabmisc/reference/impute_values_by_length.md)
  : Staged imputation
- [`tocs_item()`](https://wisclab.github.io/wisclabmisc/reference/tocs_item.md)
  [`tocs_type()`](https://wisclab.github.io/wisclabmisc/reference/tocs_item.md)
  [`tocs_length()`](https://wisclab.github.io/wisclabmisc/reference/tocs_item.md)
  : Extract the TOCS details from a string (usually a filename)
- [`weight_lengths_with_ordinal_model()`](https://wisclab.github.io/wisclabmisc/reference/weight_lengths_with_ordinal_model.md)
  : Weight utterance lengths by using an ordinal regression model

## Other functions 📌

- [`audit_wrap()`](https://wisclab.github.io/wisclabmisc/reference/audit.md)
  [`audit_peek()`](https://wisclab.github.io/wisclabmisc/reference/audit.md)
  [`audit_poke()`](https://wisclab.github.io/wisclabmisc/reference/audit.md)
  [`audit_unwrap()`](https://wisclab.github.io/wisclabmisc/reference/audit.md)
  : A lightweight container for auditing or logging
- [`brms_args_create()`](https://wisclab.github.io/wisclabmisc/reference/brms_args_create.md)
  : Set default arguments for brms model fitting
- [`compute_overlap_rate()`](https://wisclab.github.io/wisclabmisc/reference/compute_overlap_rate.md)
  : Compute overlap rate for (phoneme alignment) intervals
- [`file_replace_name()`](https://wisclab.github.io/wisclabmisc/reference/file_rename_with.md)
  [`file_rename_with()`](https://wisclab.github.io/wisclabmisc/reference/file_rename_with.md)
  : Rename file basenames using functions
- [`join_to_split()`](https://wisclab.github.io/wisclabmisc/reference/join_to_split.md)
  : Join data onto resampled IDs
- [`skip_block()`](https://wisclab.github.io/wisclabmisc/reference/skip_block.md)
  : Skip a block of code without executing it

## Datasets 🗺️

- [`data_acq_consonants`](https://wisclab.github.io/wisclabmisc/reference/data_acq_consonants.md)
  [`data_acq_vowels`](https://wisclab.github.io/wisclabmisc/reference/data_acq_consonants.md)
  : Acquisition and developmental descriptions of consonants and vowels
- [`data_example_intelligibility_by_length`](https://wisclab.github.io/wisclabmisc/reference/data_example_intelligibility_by_length.md)
  : Simulated intelligibility scores by utterance length
- [`data_fake_intelligibility`](https://wisclab.github.io/wisclabmisc/reference/data_fake_intelligibility.md)
  : Fake intelligibility data
- [`data_fake_rates`](https://wisclab.github.io/wisclabmisc/reference/data_fake_rates.md)
  : Fake speaking rate data
- [`data_features_consonants`](https://wisclab.github.io/wisclabmisc/reference/data_features_consonants.md)
  [`data_features_vowels`](https://wisclab.github.io/wisclabmisc/reference/data_features_consonants.md)
  : Phonetic features of consonants and vowels
