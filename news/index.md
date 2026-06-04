# Changelog

## wisclabmisc 0.1.1.9000 (dev version)

- Suppressed warnings from
  [`sessioninfo::session_info()`](https://sessioninfo.r-lib.org/reference/session_info.html)
  in
  [`mem_gamlss()`](https://wisclab.github.io/wisclabmisc/reference/mem_gamlss.md).
- Updated regex for
  [`tocs_item()`](https://wisclab.github.io/wisclabmisc/reference/tocs_item.md).
- Added
  [`compute_overlap_rate()`](https://wisclab.github.io/wisclabmisc/reference/compute_overlap_rate.md).
- Added
  [`compute_sens_spec_from_ecdf()`](https://wisclab.github.io/wisclabmisc/reference/compute_sens_spec_from_ecdf.md)
  to compute sensitivity, specificity and AUC on weighted data.
- Updated
  [`compute_empirical_roc()`](https://wisclab.github.io/wisclabmisc/reference/compute_empirical_roc.md)
  to handle multilevel data (like a rating scale) if the two levels to
  be compared are provided in `levels`.
- Updated
  [`compute_empirical_roc()`](https://wisclab.github.io/wisclabmisc/reference/compute_empirical_roc.md)
  to support aliases for `direction`: `"case-low"`/`"control-high"` and
  `"case-high"`/`"control-low"`. These forms help if you think about the
  direction or comparison as “which group gets a low/high score?”
- Added
  [`skip_block()`](https://wisclab.github.io/wisclabmisc/reference/skip_block.md).
- Added
  [`parse_year_month_age()`](https://wisclab.github.io/wisclabmisc/reference/ages.md)
  and
  [`parse_yymm_age()`](https://wisclab.github.io/wisclabmisc/reference/ages.md)
  to convert formatted ages into age in months.
- Add `audit` objects. These wrap some data and log the results of
  function applications on the underlying data. These are designed for
  validating vectors (e.g., filenames). Functions consist of
  [`audit_wrap()`](https://wisclab.github.io/wisclabmisc/reference/audit.md),
  [`audit_peek()`](https://wisclab.github.io/wisclabmisc/reference/audit.md),
  [`audit_poke()`](https://wisclab.github.io/wisclabmisc/reference/audit.md)
  and
  [`audit_unwrap()`](https://wisclab.github.io/wisclabmisc/reference/audit.md).
- Add `data_tocs_items` as a reusable source of the items used in our
  lab’s listening experiments.
- Add database helpers:
  [`tbl_bind()`](https://wisclab.github.io/wisclabmisc/reference/tbl_bind.md).

## wisclabmisc 0.1.1

- Added
  [`file_rename_with()`](https://wisclab.github.io/wisclabmisc/reference/file_rename_with.md)
  and
  [`file_replace_name()`](https://wisclab.github.io/wisclabmisc/reference/file_rename_with.md).
- Added
  [`info_surprisal()`](https://wisclab.github.io/wisclabmisc/reference/information.md)
  and friends for computing entropy.
- Deprecated
  [`check_sample_centiles()`](https://wisclab.github.io/wisclabmisc/reference/check_sample_centiles.md)
  deprecated. Use newly added
  [`check_model_centiles()`](https://wisclab.github.io/wisclabmisc/reference/check_model_centiles.md)
  instead.
- Added
  [`check_computed_centiles()`](https://wisclab.github.io/wisclabmisc/reference/check_model_centiles.md)
  for calibrating precomputed centiles (allows examining centiles
  outside of GAMLSS).

## wisclabmisc 0.1.0

- Package features up to November 2024
