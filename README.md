# MOSuite-filter-diff

Code Ocean capsule: MOSuite - filter differential expression analysis results

[![tests](https://github.com/NIDAP-Community/MOSuite-filter-diff/actions/workflows/tests.yml/badge.svg)](https://github.com/NIDAP-Community/MOSuite-filter-diff/actions/workflows/tests.yml)

- [Code Ocean Capsule](https://poc-nci.codeocean.io/capsule/8221739/tree) | [Latest Release](https://poc-nci.codeocean.io/capsule/5215013/tree/latest)
- [MOSuite R package docs](https://ccbr.github.io/MOSuite/)

## DEG inputs and outputs

Attach a MOSuite DEG MOO (`.rds`) or the wide `DEG_Analysis.csv` emitted by
[OMIX DEG Analysis](https://github.com/NIDAP-Community/OMIX/tree/main/modules/OMIX-DEG-Analysis).
No additional counts or metadata are required for filtering DEG statistics.

- `--input_type`: `auto` (default), `moo`, or `table`. Auto prefers exactly
  one RDS; otherwise it discovers one `DEG_Analysis.csv`, `.tsv`, or `.txt`
  recursively, ignoring companion metadata and count tables.
- `--input_file`: optional explicit selector for different filenames or
  ambiguous attachments. Select `table` to use CSV when both formats exist.
- Tables need unique feature IDs and contrast-prefixed `FC`, `logFC`, `tstat`,
  `pval`, and `adjpval` for the default settings. Configure estimates and
  selection columns using their existing unprefixed controls. The first column
  is the default feature ID (`GeneName` for OMIX); it can be overridden.

Table input is wrapped in an **analysis-only MOO** so the unchanged
MOSuite `filter_diff()` function performs selection and rounding. The object
contains named per-contrast statistics and the original table at
`analyses$deg_input$source_table`. Its required raw slot and sample metadata
are empty, and `analyses$deg_input$raw_counts_available` is false:
it is NOT reconstructed count data and must not feed count-processing nodes.
OMIX `SE` stays a standard error, never an `sd` alias.

Both routes emit:

- `results/moo/moo-diff-filt.rds`: existing output with `analyses$diff_filt`;
  MOO inputs retain their counts, annotation, metadata and unrelated analyses.
- `results/moo/DEG_Analysis_Filtered.csv`: the same filtered statistics as
  `analyses$diff_filt`, using the chosen estimates and rounding options.
- Existing significance-summary plots and package inventory.

Thresholds and any/all behavior are unchanged: significance is strictly less
than the cutoff and absolute change strictly greater than the cutoff.

## Validation and maintenance

Run `Rscript tests/testthat.R` from the repository root. Tests cover MOO/table
CLI parity, exact any/all feature selection and threshold boundaries, companion
files, ambiguity and invalid inputs. Code Ocean validation is still required.

`code/deg-input.R` is capsule-owned and shared verbatim with the Volcano and
Venn capsules. Keep copies and input tests synchronized. SyncWeaver-managed
MOSuite code and its source pin are unchanged.