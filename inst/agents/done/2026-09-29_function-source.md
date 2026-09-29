---
status: done
---

# Add function_source

## Request and design

Add the supplied function-source helper with a better name, package documentation,
a runnable example, and unit tests.

- Selected function_source(): concise; documentation explains comment inclusion.
  Alternatives: extract_function_source(), function_source_with_comments().
- Place the export in R/utils-programming.R with concept programming-utils.
- Preserve complete original lines from the function srcref, extending upward
  over contiguous comment lines only. Blank lines or code end that block.
- Require a function with retained srcref and available source lines; report clear
  errors when these prerequisites are missing. No deparse fallback or file writes.
- Example and tests use parse(text = ..., keep.source = TRUE) and eval() in
  a fresh environment, avoiding files, connections, and ambient source settings.

## Work items

- [x] Inspect existing programming helpers and select name/location.
- [x] Write focused tests and verify they fail before implementation.
- [x] Add implementation, roxygen example, export and NEWS entry.
- [x] Regenerate documentation, run tests and example, check pkgdown coverage.
- [x] Review diff and record results.

## Results

- Added function_source to R/utils-programming.R with generated NAMESPACE export
  and man/function_source.Rd, a runnable example, and NEWS entry.
- Seven tests cover exact original text, ordinary/roxygen/body comments, stopping
  at code or blank lines, the start-of-file boundary, and missing source inputs.
- Observed four missing-function failures before implementation. Reviewed and
  accepted three error snapshots after implementation.
- Full devtools::test(reporter = "summary") passed; two pre-existing file demos
  skipped. The seven new tests passed without test warnings.
- pkgdown::check_pkgdown() reported no problems. Existing concept-based selection
  includes the new topic under Other functions, so no YAML edit was needed.
- Extracted and executed the generated Rd example successfully.
- Formatted the new code/tests with air; restored incidental formatting of older
  helpers and two unrelated roxygen-generated dataset documentation changes.
- git diff --check passed. Independent code/test review found no actionable issues.
- R startup retains the previously observed C.UTF-8 locale warnings.
- Full R CMD check was not run. No commit was created.

## Follow-up: preserve original coding style

User requested staying close to the original human-readable implementation.
Restored is_comment(), line_range, line_to_check, and a repeat block with explicit
break conditions. Kept documentation and source-information errors unchanged.
All seven focused tests passed; git diff --check passed.

## Follow-up: trailing separator

User requested a trailing empty string for clean concatenation of function sources.
The helper now appends "" unless its last output element is already empty.
Updated return documentation and existing expectations; added a concatenation test
using functions with blank lines already present in their source text. Observed
five expected failures before implementation; all eight focused tests then passed.
pkgdown::check_pkgdown() and git diff --check passed.

## Follow-up: verb-first name and supplemental materials

Renamed the new API to extract_function_source throughout code, tests, snapshots,
NEWS, export, and generated help. No compatibility alias for the unreleased name.
Added the primary use case: curate function definitions and their ordering later
in supplemental-materials documents, retaining original comments. Included the
hidden source/collection chunk and the later knitr code = l chunk; omitted the
trailing comma in c(...) to make the supplied pattern valid R.

Eight focused tests, pkgdown coverage, and the generated runnable example passed.
A knitr smoke check verified preserved comments and explicitly chosen ordering;
export checks confirm the new name is exported and the old name is absent.
