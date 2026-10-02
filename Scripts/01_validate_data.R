#!/usr/bin/env -i Rscript
# =====================================================================
# 01_validate_data.R
# ---------------------------------------------------------------------
# Validates the experimental dataset used in the replication suite.
# Checks: file existence, required columns, missingness, duplicate
# participant x topic x condition x position combinations, value ranges
# (positions 1-20, weights in [0,1], binary outcome).
#
# Usage:
#   Rscript r/01_validate_data.R --data_dir data --output_dir outputs/tables
# =====================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
})

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(flag, default) {
  i <- match(flag, args)
  if (!is.na(i) && length(args) >= i + 1) args[i + 1] else default
}
data_dir   <- get_arg("--data_dir", "data")
output_dir <- get_arg("--output_dir", "outputs/tables")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

cat("=== Data Validation (R) ===\n")
file_path <- file.path(data_dir, "h2_testing_dataset.csv")
if (!file.exists(file_path)) {
  stop("Required input file not found: ", file_path)
}

df <- read_csv(file_path, show_col_types = FALSE)

required_cols <- c("participant_id", "topic_id", "condition",
                   "displayed_position", "model_weight", "selected")
missing_cols <- setdiff(required_cols, names(df))
if (length(missing_cols) > 0) stop("Missing columns: ", paste(missing_cols, collapse = ", "))

# Missingness
miss <- sapply(df[required_cols], function(x) sum(is.na(x)))

# Duplicates
dupes <- df %>% count(participant_id, topic_id, condition, displayed_position) %>% filter(n > 1) %>% nrow()

# Range checks
pos_ok  <- all(df$displayed_position >= 1 & df$displayed_position <= 20, na.rm = TRUE)
wt_ok   <- all(df$model_weight >= 0 & df$model_weight <= 1, na.rm = TRUE)
sel_ok  <- all(df$selected %in% c(0, 1), na.rm = TRUE)

validation <- tibble(
  dataset = "h2_testing_dataset.csv",
  rows = nrow(df),
  cols = ncol(df),
  total_missing = sum(miss),
  duplicate_keys = dupes,
  positions_in_1_20 = pos_ok,
  weights_in_0_1 = wt_ok,
  outcome_binary = sel_ok
)
cat("\nValidation summary:\n"); print(validation)

write_csv(validation, file.path(output_dir, "validation_report_r.csv"))

if (sum(miss) == 0 && dupes == 0 && pos_ok && wt_ok && sel_ok) {
  cat("\n[PASS] All validation checks succeeded.\n")
} else {
  cat("\n[WARN] One or more validation checks flagged issues - inspect summary above.\n")
}
cat("=== Data Validation Complete ===\n")
