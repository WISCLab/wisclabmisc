# extract_function_source explains when source references are missing

    Code
      extract_function_source(fun)
    Condition
      Error:
      ! `fun` must have a source reference; use `keep.source = TRUE`.

# extract_function_source requires a function

    Code
      extract_function_source(1)
    Condition
      Error in `extract_function_source()`:
      ! `fun` must be a function

# extract_function_source explains when original source lines are unavailable

    Code
      extract_function_source(fun)
    Condition
      Error:
      ! The source reference must contain the original source lines.

