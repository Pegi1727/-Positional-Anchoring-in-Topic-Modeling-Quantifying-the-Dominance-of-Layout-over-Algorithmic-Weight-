#!/usr/bin/env -i Rscript
# =====================================================================
# 02_descriptive_summary.R
# ---------------------------------------------------------------------
# Descriptive statistics: condition-level and position-level summaries
# of selection rates and model weights. Mirrors 02_descriptive_summary.py
#
# Usage:
#   Rscript r/02_descriptive_summary.R --data_dir data --output_dir outputs/tables
# =====================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(flag, default) {
  i <- match(flag, args)
  if (!is.na(i) && length(args) >= i + 1) args[i + 1] else default
}
data_dir   <- get_arg("--data_dir", "data")
output_dir <- get_arg("--output_dir", "outputs/tables")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

df <- read_csv(file.path(data_dir, "h2_testing_dataset.csv"), show_col_types = FALSE)

# 1. Condition-level summary
cond_summary <- df %>%
  group_by(condition) %>%
  summarise(
    total_trials        = n(),
    total_selections    = sum(selected),
    mean_selection_rate = mean(selected),
    std_selection_rate  = sd(selected),
    mean_model_weight   = mean(model_weight),
    .groups = "drop"
  )

# 2. Position-level summary
pos_summary <- df %>%
  group_by(condition, displayed_position) %>%
  summarise(
    selection_rate    = mean(selected),
    selection_count   = sum(selected),
    total_items       = n(),
    mean_model_weight = mean(model_weight),
    .groups = "drop"
  )

write_csv(cond_summary, file.path(output_dir, "descriptive_condition_summary_r.csv"))
write_csv(pos_summary,  file.path(output_dir, "descriptive_position_summary_r.csv"))

cat("=== Condition Summary (R) ===\n")
print(as.data.frame(cond_summary))
cat("\nSaved:", file.path(output_dir, "descriptive_condition_summary_r.csv"),
    "and", file.path(output_dir, "descriptive_position_summary_r.csv"), "\n")
