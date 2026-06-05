
#' Convert between age in months, years;months, and yymm age formats
#' @param x
#' * `format_year_month_age()`: a numeric vector of (non-negative) ages in
#'   months.
#' * `parse_year_month_age()`: a character vector of ages in `"years;months"`
#'   format (or `years{sep}months` format more generally).
#' * `parse_yymm_age()`: a character vector of ages in `"yymm"` format.
#' @param sep Separator to use for `year_month` functions. Defaults to `;`.
#' @param start For `parse_yymm_age()`, the location of the starting
#'   character the `yymm` sequence. Defaults to 1.
#' @return
#' * `format_year_month_age()` returns a character vector in `"years;months"`
#'   format (or `years{sep}months` format more generally).
#' * `parse_year_month_age()` returns a vector of ages in months.
#' * `parse_yymm_age()`: returns a vector of ages in months.
#'
#'
#' @details
#' For `format_year_month_age()`, ages of `NA` return `"NA;NA"`.
#'
#' For `parse_year_month_age()`, values that cannot be parsed
#' return `NA`.
#'
#' This format by default is not numerically ordered. This means that `c("2;0",
#' "10;10", "10;9")` would sort as `c("10;10", "10;9", "2;0")`. The function
#' `stringr::str_sort(..., numeric = TRUE)` will sort this vector correctly.
#' @export
#' @rdname ages
#' @examples
#' ages <- c(26, 58, 25, 67, 21, 59, 36, 43, 27, 49, NA)
#' ym_ages <- format_year_month_age(ages)
#' ym_ages
#'
#' parse_year_month_age(ym_ages)
#'
#' parse_yymm_age(c("0204", "0310"))
#'
#' parse_yymm_age(c("ab_0204", "ab_0310"), start = 4)
#' @concept data-utils
format_year_month_age <- function(x, sep = ";") {
  stopifnot(length(sep) == 1L)
  assert_whole_number_vector(x, min = 0, allow_missing = TRUE)
  years <- x %/% 12L
  months <- x %% 12L
  paste0(years, sep, months)
}


#' @rdname ages
#' @export
parse_year_month_age <- function(x, sep = ";") {
  stopifnot(length(sep) == 1L)
  # set the context for the error message
  curr_call <- rlang::current_call()

  convert_one <- function(p) {
    # Convert any junk to c(NA, NA)
    if (length(p) != 2L || any(is.na(p))) p <- c(NA_integer_, NA_integer_)
    assert_whole_number_scalar(
      p[1], min = 0, allow_missing = TRUE,
      call = curr_call, arg = "x (years part)"
    )
    assert_whole_number_scalar(
      p[2], min = 0, max = 11, allow_missing = TRUE,
      call = curr_call, arg = "x (months part)"
    )
    12L * p[1] + p[2]
  }

  x |>
    strsplit(sep, fixed = TRUE) |>
    lapply(function(x) suppressWarnings(as.numeric(x))) |>
    vapply(convert_one, numeric(1))
}

#' @rdname ages
#' @export
parse_yymm_age <- function(x, start = 1L) {
  years <- x |> substr(start = start, stop = start + 1L) |> as.numeric()
  months <- x |> substr(start = start + 2L, stop = start + 3L) |> as.numeric()

  assert_whole_number_vector(
    years, min = 0, allow_missing = TRUE, arg = 'x (years part)'
  )
  assert_whole_number_vector(
    months, min = 0, max = 11, allow_missing = TRUE, arg = 'x (months part)'
  )
  years * 12 + months
}

# database friendly version
.db_parse_yymm_age <- function(x, start = 1L) {
  years <- x |> substr(start = start, stop = start + 1L) |> as.numeric()
  months <- x |> substr(start = start + 2L, stop = start + 3L) |> as.numeric()
  years * 12 + months
}


#' Compute chronological age in months
#'
#' Ages are rounded down to the nearest month. A difference of 20 months, 29
#' days is interpreted as 20 months.
#'
#' @param t1,t2 dates in "yyyy-mm-dd" format
#' @return the chronological ages in months. NA is returned if the age cannot be
#'   computed.
#' @export
#' @concept data-utils
#' @examples
#' # Two years exactly
#' chrono_age("2014-01-20", "2012-01-20")
#' #> 24
#'
#' # Shift a year
#' chrono_age("2014-01-20", "2013-01-20")
#' #> 12
#' chrono_age("2014-01-20", "2011-01-20")
#' #> 36
#'
#' # Shift a month
#' chrono_age("2014-01-20", "2012-02-20")
#' #> 23
#' chrono_age("2014-01-20", "2011-12-20")
#' #> 25
#'
#' # 3 months exactly
#' chrono_age("2014-05-10", "2014-02-10")
#' #> 3
#'
#' # Borrow a month when the earlier date has a later day
#' chrono_age("2014-05-10", "2014-02-11")
#' #> 2, equal to 2 months, 29 days rounded down to nearest month
#'
#' # Inverted argument order
#' chrono_age("2012-01-20", "2014-01-20")
#' #> 24
#'
#' # Multiple dates
#' t1 <- c("2012-01-20", "2014-02-10", "2010-10-10")
#' t2 <- c("2014-01-20", "2014-05-10", "2014-11-10")
#' chrono_age(t1, t2)
#' #> [1] 24  3 49
chrono_age <- function(t1, t2) {
  stopifnot(length(t1) == length(t2))
  purrr::map2_dbl(t1, t2, purrr::possibly(chrono_age_single, NA))
}

#' Compute difference between two dates in months
#' @noRd
chrono_age_single <- function(t1, t2) {
  difference <- diff_date(t1, t2)
  12 * difference$y  + difference$m
}

#' Compute the difference between two dates
#' @noRd
diff_date <- function(t1, t2) {
  stopifnot(length(t1) == 1, length(t2) == 1)

  if (is.na(t1) || is.na(t2)) {
    warning("Missing date: t1 = ", t1, ", t2 = ", t2, call. = FALSE)
    return(list(y = NA, m = NA, d = NA))
  }

  t1 <- as.Date(t1)
  t2 <- as.Date(t2)

  # Sort dates and convert to a list
  d1 <- as_date_list(min(t1, t2))
  d2 <- as_date_list(max(t1, t2))

  # Borrow a month
  if (d2$d < d1$d) {
    d2$m <- d2$m - 1
    d2$d <- d2$d + 30
  }

  # Borrow a year
  if (d2$m < d1$m) {
    d2$y <- d2$y - 1
    d2$m <- d2$m + 12
  }

  diff <- list(
    y = d2$y - d1$y,
    m = d2$m - d1$m,
    d = d2$d - d1$d
  )
  diff
}

# A lightweight data structure for hand-manipulating dates
as_date_list <- function(date) {
  date <- as.Date(date)
  y <- date |> format("%Y") |> as.numeric()
  m <- date |> format("%m") |> as.numeric()
  d <- date |> format("%d") |> as.numeric()

  list(y = y, m = m, d = d)
}






#' Extract the TOCS details from a string (usually a filename)
#' @param xs a character vector
#' @return `tocs_item()` returns the substring with the TOCS item, `tocs_type()`
#'   returns whether the item is `"single-word"` or `"multiword"`, and
#'   `tocs_length()` returns the length of the TOCS item (i.e., the number of
#'   words).
#' @rdname tocs_item
#' @concept data-utils
#' @export
#' @examples
#' x <- c(
#'   "XXv16s7T06.lab", "XXv15s5T06.TextGrid", "XXv13s3T10.WAV",
#'   "XXv18wT11.wav", "non-matching", "s2T01",
#'   "XXv01s4B01.wav", "XXv01wB01.wav",
#'   # sometimes these have tags for *v*irtual visits or recording attempts
#'   "XXv13s3T10v.WAV", "XXv13s3T10a.lab"
#' )
#' data.frame(
#'   x = x,
#'   item = tocs_item(x),
#'   type = tocs_type(x),
#'   length = tocs_length(x)
#' )
tocs_item <- function(xs) {
  xs |>
    toupper() |>
    stringr::str_extract(
      "(S[2-7]|W)(T|B)[0-4][0-9](?=[ABCDEV]?([.]WAV|[.]TEXTGRID|[.]LAB|$))"
    )
}

#' @rdname tocs_item
#' @export
tocs_type <- function(xs) {
  starts <- xs |> tocs_item() |> substr(1, 1)
  types <- rep_len(NA_character_, length(starts))
  types[starts == "W"] <- "single-word"
  types[starts == "S"] <- "multiword"
  types
}

#' @rdname tocs_item
#' @export
tocs_length <- function(xs) {
  items <- xs |> tocs_item()
  char2 <- substr(items, 2, 2)
  char2[char2 %in% c("T", "B")] <- "1"
  as.integer(char2)
}




#' Compute overlap rate for (phoneme alignment) intervals
#'
#' @param x1,x2 start and end times for the first interval
#' @param y1,y2 start and end times for the second interval
#' @return the overlap rate
#' @export
#' @details
#' Paulo and Oliveira (2004) provide an "overlap rate" statistic for computing
#' the amount of overlap between two (time) intervals. To my knowledge, nobody
#' has described the Overlap Rate in this way, but it is the
#' [Jaccard index](https://en.wikipedia.org/wiki/Jaccard_index) applied to time
#' intervals.
#'
#' Let \eqn{X=[x_\text{min}, x_\text{max}]} and
#' \eqn{Y=[y_\text{min}, y_\text{max}]} be the sets of times spanned by the
#' intervals \eqn{x} and \eqn{y}. Then, \eqn{X \cap Y} is the *intersection* or the
#' times covered by both intervals, and \eqn{X \cup Y} is the *union* or the
#' times covered by either interval. The size of a set \eqn{A} is denoted
#' \eqn{|A|}. Then the overlap rate is the Jaccard index or the proportion of
#' elements that the two sets have in common:
#'
#' \deqn{\text{overlap rate} = \frac{|X \cap Y|}{|X \cup Y|}}
#'
#' @references Paulo, S., & Oliveira, L. C. (2004). Automatic Phonetic
#' Alignment and Its Confidence Measures. In J. L. Vicedo, P. Martínez-Barco,
#' R. Muńoz, & M. Saiz Noeda (Eds.), *Advances in Natural Language Processing*
#' (pp. 36–44). Springer. <https://doi.org/10.1007/978-3-540-30228-5_4>
#'
#' @examples
#' compute_overlap_rate(
#'   c(0.0, 0.0, 0.0, 0.0),
#'   c(1.0, 1.0, 1.0,  NA),
#'   c(0.5, 2.0, 1.0, 1.0),
#'   c(2.0, 3.0, 2.0, 2.0)
#' )
compute_overlap_rate <- function(x1, x2, y1, y2) {
  lengths <- lengths(list(x1, x2, y1, y2))
  pts <- c(x1, x2, y1, y2)
  stopifnot(
    # they should have length 1 or length N
    all(lengths %in% c(1, max(lengths))),
    # not dealing with negative times for now
    all(pts >= 0 | is.na(pts))
  )

  # normalize intervals so x1 < x2, y1 < y2
  min_x <- pmin(x1, x2)
  max_x <- pmax(x1, x2)
  min_y <- pmin(y1, y2)
  max_y <- pmax(y1, y2)
  dur_x <- max_x - min_x
  dur_y <- max_y - min_y

  # i for "intersect", u for "union"
  min_i <- pmax(min_x, min_y)    # latest start
  max_i <- pmin(max_x, max_y)    # earliest end
  dur_i <- max_i - min_i
  dur_i[dur_i < 0] <- 0          # negative means no overlap
  dur_u <- dur_x + dur_y - dur_i
  dur_u[dur_u == 0] <- NA_real_  # use explicit NA for division by 0
  dur_i / dur_u
}
