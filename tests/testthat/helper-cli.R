setup_cli_workspace <- function(prefix = "mosuite_filter_diff_test_") {
  workspace <- tempfile(prefix)
  dir.create(workspace)

  code_dir <- file.path(workspace, "code")
  data_dir <- file.path(workspace, "data")
  results_dir <- file.path(workspace, "results")
  dir.create(code_dir, recursive = TRUE)
  dir.create(data_dir, recursive = TRUE)
  dir.create(file.path(results_dir, "figures"), recursive = TRUE)
  dir.create(file.path(results_dir, "moo"), recursive = TRUE)

  repo_root <- normalizePath(
    file.path(testthat::test_path(), "..", ".."),
    mustWork = TRUE
  )

  test_data_file <- file.path(repo_root, "tests", "data", "moo-diff.rds")

  expect_true(
    file.exists(test_data_file),
    info = paste("Test data file should exist at", test_data_file)
  )

  moo <- readr::read_rds(test_data_file)
  for (count_name in names(moo@counts)) {
    counts_df <- as.data.frame(moo@counts[[count_name]])
    if (!is.null(counts_df) && nrow(counts_df) > 1000L) {
      counts_df <- counts_df[seq_len(1000L), , drop = FALSE]
      moo@counts[[count_name]] <- counts_df
    }
  }
  readr::write_rds(moo, file.path(data_dir, "moo.rds"))

  file.copy(
    file.path(repo_root, "code", "main.R"),
    file.path(code_dir, "main.R"),
    overwrite = TRUE
  )

  # Patch the hardcoded container path so tests work outside the container.
  main_copy <- file.path(code_dir, "main.R")
  main_lines <- readLines(main_copy)
  main_lines <- gsub(
    "devtools::load_all('/code/MOSuite')",
    sprintf(
      "devtools::load_all('%s')",
      file.path(repo_root, "code", "MOSuite")
    ),
    main_lines,
    fixed = TRUE
  )
  writeLines(main_lines, main_copy)

  list(
    workspace = workspace,
    code_dir = code_dir,
    results_dir = results_dir,
    repo_root = repo_root
  )
}

expect_outputs_created <- function(results_dir) {
  moo_path <- file.path(results_dir, "moo", "moo-diff-filt.rds")

  expect_true(
    file.exists(moo_path),
    info = "Filtered MOO output should be created"
  )
  expect_true(
    file.info(moo_path)$size > 0,
    info = "Filtered MOO output should be non-empty"
  )

  moo <- readr::read_rds(moo_path)
  moo_class_names <- class(moo)
  expect_true(
    any(grepl("multiOmicDataSet", moo_class_names, fixed = TRUE)),
    info = paste(
      "Output should be an S7 multiOmicDataSet object; actual classes:",
      paste(moo_class_names, collapse = ", ")
    )
  )

  expect_true(
    "diff" %in% names(moo@analyses),
    info = "Output should have diff results in moo@analyses"
  )
}

default_cli_args <- c(
  "--significance_column=adjpval",
  "--significance_cutoff=0.05",
  "--change_column=logFC",
  "--change_cutoff=1",
  "--filtering_mode=any"
)

custom_cli_args <- c(
  "--significance_column=pval",
  "--significance_cutoff=0.01",
  "--change_column=logFC",
  "--change_cutoff=2",
  "--filtering_mode=all",
  "--round_estimates=TRUE",
  "--plot_type=bar"
)
