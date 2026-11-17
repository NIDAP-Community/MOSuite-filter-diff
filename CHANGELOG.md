# Code Ocean capsule - MOSuite - filter differential expression results

## development version

- Accept MOO RDS or the specifically named `DEG_Analysis.csv`, automatically
  preferring MOO when both formats are present.
- Keep input discovery controls out of the user-facing panel and restore the
  capsule's concise README.
- Wrap tables in an analysis-only MOO without fabricated counts; preserve the
  existing filtering function and MOO output.
- Emit DEG_Analysis_Filtered.csv alongside moo-diff-filt.rds for both routes.
- Add any/all, boundary and MOO/table CLI parity tests; managed source is unchanged.

## v3.0

- Use MOSuite v0.5.0. (#9, @kelly-sovacool)
- Sync Code Ocean app panel parameter descriptions with MOSuite package documentation for MOSuite v0.4.1 (#6, @phoman14).
- Improved the Code Ocean parameter UI for the filter diff capsule (#2, @phoman14).

## v2.0

- Standardize app panel across MOSuite capsules.
- Fix: remove `regex_moo` parameter from configuration. multiOmicDataSet input files are now required to follow the standardized naming pattern (`.*\.rds$`).
- Use MOSuite v0.3.0.

## v1.0

Initial release

<https://poc-nci.codeocean.io/capsule/0936928/tree/v1> `54a711a`
