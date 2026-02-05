#!/usr/bin/env Rscript
rlang::global_entrace()
library(argparse)
library(glue)
library(MOSuite)
library(readr)
library(stringr)
library(dplyr)

# set up results directory
results_dir <- file.path('..','results')
plots_dir <- file.path(results_dir, 'figures')
options(moo_plots_dir = plots_dir, moo_save_plots = TRUE)

# log installed packages & versions
pkg_versions <- tibble::as_tibble(installed.packages())
write_csv(pkg_versions, file.path(results_dir, 'r-packages.csv'))

# parse CLI arguments
parser <- ArgumentParser()

parser$add_argument("--feature_id_colname", type="character", default=NULL, help="Column name for feature IDs")
parser$add_argument("--significance_column", type="character", default="adjpval", help="Column name for significance")
parser$add_argument("--significance_cutoff", type="double", default=0.05, help="Significance cutoff threshold")
parser$add_argument("--change_column", type="character", default="logFC", help="Column name for change")
parser$add_argument("--change_cutoff", type="double", default=1, help="Change cutoff threshold")
parser$add_argument("--filtering_mode", type="character", default="any", help="Filter mode: any or all")
parser$add_argument("--include_estimates", type="character", default="FC,logFC,tstat,pval,adjpval", help="Comma-separated list of estimates to include")
parser$add_argument("--round_estimates", type="logical", default=TRUE, help="Round estimates")
parser$add_argument("--rounding_decimal_for_percent_cells", type="integer", default=0, help="Decimal places for percent labels")
parser$add_argument("--contrast_filter", type="character", default="none", help="Filter contrasts: keep, remove, or none")
parser$add_argument("--contrasts", type="character", default="", help="Comma-separated list of contrasts")
parser$add_argument("--groups", type="character", default="", help="Comma-separated list of groups")
parser$add_argument("--groups_filter", type="character", default="none", help="Filter groups: keep, remove, or none")
parser$add_argument("--label_font_size", type="double", default=6, help="Font size for labels")
parser$add_argument("--label_distance", type="double", default=1, help="Distance of labels from bars")
parser$add_argument("--y_axis_expansion", type="double", default=0.08, help="Y-axis expansion")
parser$add_argument("--fill_colors", type="character", default="steelblue1,whitesmoke", help="Comma-separated fill colors")
parser$add_argument("--pie_chart_in_3d", type="logical", default=TRUE, help="Draw pie charts in 3D")
parser$add_argument("--bar_width", type="double", default=0.4, help="Bar width")
parser$add_argument("--draw_bar_border", type="logical", default=TRUE, help="Draw bar borders")
parser$add_argument("--plot_type", type="character", default="bar", help="Plot type: bar or pie")
parser$add_argument("--plot_titles_fontsize", type="integer", default=12, help="Font size for plot titles")

args <- parser$parse_args()

parse_optional_vector <- function(x) {
    if (is.null(x) || identical(x, "") || length(x) == 0) {
        return(NULL)
    }
    return(trimws(unlist(strsplit(x, ","))))
}

# validate inputs
regex_moo <- ".*\\.rds$"
data_files <- list.files(file.path('../data'), recursive = TRUE, full.names = TRUE)
moo_files <- Filter(\(x) str_detect(x, regex(regex_moo, ignore_case = TRUE)), data_files)

if (length(moo_files) == 0) {
    stop(glue("No files matching regex: {regex_moo}"))
}
moo_filename <- moo_files[1]
moo <- read_rds(moo_filename)
message(glue('Reading multiOmicDataSet from {moo_filename}'))
if (!inherits(moo, 'MOSuite::multiOmicDataSet')) {
    stop(glue('The input is not a multiOmicDataSet. class: {class(moo)}'))
}

# run MOSuite
moo |> 
    filter_diff(
        feature_id_colname = args$feature_id_colname,
        significance_column = args$significance_column,
        significance_cutoff = args$significance_cutoff,
        change_column = args$change_column,
        change_cutoff = args$change_cutoff,
        filtering_mode = args$filtering_mode,
        include_estimates = parse_optional_vector(args$include_estimates),
        round_estimates = args$round_estimates,
        rounding_decimal_for_percent_cells = args$rounding_decimal_for_percent_cells,
        contrast_filter = args$contrast_filter,
        contrasts = parse_optional_vector(args$contrasts),
        groups = parse_optional_vector(args$groups),
        groups_filter = args$groups_filter,
        label_font_size = args$label_font_size,
        label_distance = args$label_distance,
        y_axis_expansion = args$y_axis_expansion,
        fill_colors = parse_optional_vector(args$fill_colors),
        pie_chart_in_3d = args$pie_chart_in_3d,
        bar_width = args$bar_width,
        draw_bar_border = args$draw_bar_border,
        plot_type = args$plot_type,
        plot_titles_fontsize = args$plot_titles_fontsize
        ) |> 
    write_rds(file.path(results_dir, 'moo', 'moo.rds'))
