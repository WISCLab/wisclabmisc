# Convert .docx versions of supplemental materials files to .md

convert_one <- function(input_path) {
  output_path <- input_path |>
    tools::file_path_sans_ext() |>
    paste0(".md") |>
    basename()

  rmarkdown::pandoc_convert(
    input = file.path("docx", basename(input_path)),
    to = "markdown+fenced_code_blocks",
    output = basename(output_path),
    options = c(
      # make the sure code blocks are explicitly labeled ` r`
      "--lua-filter=docx/r-codeblock.lua",
      "--extract-media=.",
      # add calls to xfun::base64_uri() to embed images until
      # https://github.com/r-lib/pkgdown/pull/2811 is fixed in the
      # CRAN version
      "--lua-filter=docx/add-base64-calls.lua"
    ),
    wd = "vignettes/articles/",
    verbose = TRUE
  )

  create_host_file_from_template(basename(input_path))
  invisible(output_path)

}

create_host_file_from_template <- function(basename) {
  template <- "---
title: >
  Analysis code: '[??? long title]'
author: Tristan Mahr
date: [??? date]
---

The following is a reproduction of the Supplemental Material (analysis
code) for [??? APA reference]. All code is in
the R programming language.

- Publication DOI: [[??? __doi__]](https://doi.org/[_??? _doi__])
- Supplemental Material DOI: [[??? __doi__]](https://doi.org/[??? __doi__])
- Analysis notes: [??? topic]; [??? topic]

***

```{r, child=\"%s\"}
```
"

  rmd <- basename |> tools::file_path_sans_ext() |> paste0(".Rmd")
  md <- basename |> tools::file_path_sans_ext() |> paste0(".md")
  target_file <- file.path("./vignettes/articles", rmd)

  if (!file.exists(target_file)) {
    cli::cli_alert_info("Creating host file {.path {target_file}}")
    cli::cli_alert("Update metadata fields in that file")
    writeLines(sprintf(template, md), target_file)
  } else {
    cli::cli_alert_info("Host file found {.path {target_file}}")
  }

  target_file
}


convert_one("vignettes/articles/docx/sm-2025-mahr-intel-rate.docx")
convert_one("vignettes/articles/docx/sm-2022-long-vss.docx")
convert_one("vignettes/articles/docx/sm-2021-mahr-aligners.docx")
convert_one("vignettes/articles/docx/sm-2026-salvo-prolific.docx")
# pkgdown::build_article("articles/sm-2022-long-vss")
