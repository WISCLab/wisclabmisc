test_that("format_year_month_age() converts to years;month format", {
  c(1, 13, 23, 24, NA) |>
    format_year_month_age() |>
    expect_equal(c("0;1", "1;1", "1;11", "2;0", "NA;NA"))
})


test_that("parse_year_month_age() converts years;months to months", {
  "0;6" |> parse_year_month_age() |> expect_equal(6)
  "1:6" |> parse_year_month_age(sep = ":") |> expect_equal(18)
  "0.0;6.0" |> parse_year_month_age() |> expect_equal(6)

  "-1;6"  |> parse_year_month_age() |> expect_error("years part")
  "1.5;6" |> parse_year_month_age() |> expect_error("years part")

  "1;-6"  |> parse_year_month_age() |> expect_error("months part")
  "1;1.5" |> parse_year_month_age() |> expect_error("months part")
  "1;12"  |> parse_year_month_age() |> expect_error("months part")

  "1;1.5;a" |> parse_year_month_age() |> expect_equal(NA_real_)
  "NA;1.5"  |> parse_year_month_age() |> expect_equal(NA_real_)
})


test_that("format_year_month_age() and parse_year_month_age() round-trip", {
  ages <- c(0L, 1L, 11L, 12L, 13L, 26L, 58L, 131L, NA_integer_)

  expect_equal(
    parse_year_month_age(format_year_month_age(ages)),
    ages
  )

  expect_equal(
    parse_year_month_age(format_year_month_age(ages, sep = ":"), sep = ":"),
    ages
  )
})


test_that("parse_yymm_age() converts YYMM into age in months", {
  c("0011", "1900", "0201") |>
    parse_yymm_age() |>
    expect_equal(c(11, 228, 25))

  c("_0011", "_1900", "_0201") |>
    parse_yymm_age(start = 2) |>
    expect_equal(c(11, 228, 25))

  c("aa01") |> parse_yymm_age() |> expect_warning() |> suppressWarnings()
  c("01aa") |> parse_yymm_age() |> expect_warning() |> suppressWarnings()
  c("aaaa") |> parse_yymm_age() |> expect_warning() |> suppressWarnings()
  c("aa01") |> parse_yymm_age() |> suppressWarnings() |> expect_equal(NA_real_)
  c("01aa") |> parse_yymm_age() |> suppressWarnings() |> expect_equal(NA_real_)
  c("aaaa") |> parse_yymm_age() |> suppressWarnings() |> expect_equal(NA_real_)

  c("0112") |> parse_yymm_age() |> expect_error()
  c("-100") |> parse_yymm_age() |> expect_error()
  c("01-2") |> parse_yymm_age() |> expect_error()
})

test_that("Chronological age in months", {
  # Two years exactly
  expect_equal(chrono_age("2014-01-20", "2012-01-20"), 24)

  # Shift a year
  expect_equal(chrono_age("2014-01-20", "2013-01-20"), 12)
  expect_equal(chrono_age("2014-01-20", "2011-01-20"), 36)

  # Shift a month
  expect_equal(chrono_age("2014-01-20", "2012-02-20"), 23)
  expect_equal(chrono_age("2014-01-20", "2011-12-20"), 25)

  # Multiple dates
  t1 <- c("2014-01-20", "2014-01-20")
  t2 <- c("2012-02-20", "2011-12-20")
  expect_equal(chrono_age(t1, t2), c(23, 25))

  # Missing dates raise warnings and default to NA
  expect_warning(chrono_age(NA, "2011-12-20"))
  expect_true(is.na(suppressWarnings(chrono_age(NA, "2011-12-20"))))

  # 3 months exactly
  expect_equal(chrono_age("2014-05-10", "2014-02-10"), 3)

  # Borrow a month when the earlier date has a later day
  expect_equal(chrono_age("2014-05-10", "2014-02-11"), 2)

  # Reversed arguments
  expect_equal(chrono_age("2012-01-20", "2014-01-20"), 24)

  # Checks against EVT/PPVT examples
  expect_equal(chrono_age("2007-06-29", "2001-03-03"),  (6 * 12) + 3)
  expect_equal(chrono_age("2007-05-08", "1999-08-02"),  (7 * 12) + 9)
  expect_equal(chrono_age("2007-08-13", "1985-11-24"), (21 * 12) + 8)
})


test_that("tocs_item()", {
  x <- c(
    "XXv17_SLOW_s4T06.TextGrid",
    "XXv14_SLOW_s5T04.TextGrid",
    "XXv16s6T06.TextGrid",
    "XX(b)v16s7T03.TextGrid",
    "XXv15_SLOW_s2T01.TextGrid",
    "XXv18wT11.wav",
    "XXv16s7T06.lab",
    "XXv15s5T06.lab",
    "XXv13s3T10.WAV",
    "XXv16S2T09.wav",
    "s2T01",
    "invalid-file.txt",
    "XXv01s4B01.wav",
    "XXv01wB01.wav",
    "XXv01wB01v.wav"
  )

  expected <- c(
    "S4T06",
    "S5T04",
    "S6T06",
    "S7T03",
    "S2T01",
    "WT11",
    "S7T06",
    "S5T06",
    "S3T10",
    "S2T09",
    "S2T01",
    NA_character_,
    "S4B01",
    "WB01",
    "WB01"
  )

  expected_length <- c(
    4,
    5,
    6,
    7,
    2,
    1,
    7,
    5,
    3,
    2,
    2,
    NA_integer_,
    4,
    1,
    1
  )

  x |>
    tocs_item() |>
    expect_equal(expected) |>
    # i.e., item parsing works on standardized item names
    tocs_item() |>
    expect_equal(expected)

  x |>
    tocs_length() |>
    expect_equal(expected_length)
})


test_that("Overlap rate is computed correctly", {
  m <- matrix(c(
    0.10, 0.20,  0.21, 0.30,  # 1 no overlap
    0.10, 0.30,  0.20, 0.40,  # 2 overlap
    0.10, 0.20,  0.20, 0.30,  # 3 touching edges
    0.25, 0.50,  0.25, 0.50,  # 4 identical spans
    NA,   0.50,  0.25, 0.50,  # 5 NA min value
    0.25,   NA,  0.25, 0.50  # 6 NA max value
  ), ncol = 4, byrow = TRUE)

  x1 <- m[,1]
  x2 <- m[,2]
  y1 <- m[,3]
  y2 <- m[,4]
  expected <- c(0, .1 / .3, 0, 1, NA, NA)
  expect_equal(compute_overlap_rate(x1, x2, y1, y2), expected)

  # intervals entered backwards
  expect_equal(compute_overlap_rate(x2, x1, y1, y2), expected)
  expect_equal(compute_overlap_rate(x1, x2, y2, y1), expected)

  # switch which (x or y) starts first
  expect_equal(compute_overlap_rate(y1, y2, x1, x2), expected)

  # both point intervals
  expect_equal(compute_overlap_rate(1, 1, 1, 1), NA_real_)

  # length 1 is recycled
  expect_no_error(compute_overlap_rate(x1, x2, 0, y2))

  # lengths must be 1 or N
  expect_error(compute_overlap_rate(x1, x2, c(0, 0), y2))

  # negatives not supported
  expect_error(compute_overlap_rate(x1, x2, -y1, y2))
})


test_that("skip_block() ignores code", {
  expect_error(skip_block())
  expect_error(skip_block(1, 2, 3))

  # Default message
  expect_null(skip_block(stop()))
  expect_message(skip_block(stop()), regexp = "Skipping code block")

  # Custom message
  expect_null(skip_block("testing a message", stop()))
  expect_message(skip_block("testing a message", stop()), regexp = "message")

  # Message in a variable gets evaluated
  msg <- "howdy"
  expect_null(skip_block(msg, stop()))
  expect_message(skip_block(msg, stop()), regexp = "howdy")
})
