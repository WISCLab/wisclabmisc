# Items from the TOCS+ used by the WISC Lab

We use items from the Test of Children's Speech (TOCS+, Hodge & Gotzke,
2014) in our child speech and listener intelligibility studies.

## Usage

``` r
data_tocs_items
```

## Format

A data frame with 103 rows and 4 variables:

- tocs_type:

  whether the item is a `single-word` or `multiword` utterance

- tocs_level:

  number of words in the prompt

- tocs_item:

  identifier for the item (e.g., within filenames)

- tocs_prompt:

  the actual prompt presented to the child

- tocs_item_note:

  any notes about an item's usage in experiments or analyses

## Details

Most of these items are subset from a larger pool of items on the TOCS+.
Hustad and colleagues (2021) is a supplemental material for a larger
study about speech intelligibility which describes where the items were
taken from within the larger TOCS+ task. (It is unclear, as I write this
in 2026, which items were added by our group to the TOCS+ pool, so I
have added "possibly not an original TOCS item" to items that do not
appear in that supplemental material.)

In this picture-prompted repetition task, a child hears a *prompt*,
repeats it (*production*), and later on listeners transcribe it
(*transcription*). In our listener-response database, we differentiate
these three forms with fields named `tocs_prompt` (prompt), `sentence`
(production), and `response` (transcription).

## References

Hodge, M. M., & Gotzke, C. (2014). Construct-related validity of the
TOCS+ measures: Comparison of intelligibility and speaking rate scores
in children with and without speech disorders. *Journal of Communication
Disorders*, *51*, 51–63. <https://doi.org/10.1016/j.jcomdis.2014.06.007>

Hustad, K. C., Mahr, T. J., Natzke, P., & Rathouz, P. J. (2021).
Supplemental Material 1: Intelligibility growth between 30 and 119
months (Hustad et al., 2021) (Version 1). ASHA Journals.
<https://doi.org/10.23641/asha.16583426.v1>
