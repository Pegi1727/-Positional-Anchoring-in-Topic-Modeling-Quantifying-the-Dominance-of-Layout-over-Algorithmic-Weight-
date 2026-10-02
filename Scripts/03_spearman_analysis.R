#!/usr/bin/env -i Rscript
# =====================================================================
# 03_spearman_analysis.R
# ---------------------------------------------------------------------
# Computes aggregate Spearman rank correlations between displayed position,
# model weight, and selection rates across conditions. Mirrors 03_spearman_analysis.py
#
# Usage:
#   Rscript r/03_spearman_analysis.R --data_dir data --output_dir outputs/tables
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

results <- list()

for (cond in unique(df$condition)) {
  sub <- df %>% filter(condition == cond)
  pos_agg <- sub %>%
    group_by(displayed_position) %>%
    summarise(
      sel_rate = mean(selected),
      mean_weight = mean(model_weight),
      .groups = "drop"
    )
  
  test_pos <- cor.test(pos_agg$displayed_position, pos_agg$sel_rate, method = "spearman", exact = FALSE)
  test_wt  <- cor.test(pos_agg$mean_weight, pos_agg$sel_rate, method = "spearman", exact = FALSE)
  
  results[[length(results) + 1]] <- tibble(
    condition = cond,
    comparison = "Position vs Selection Rate",
    spearman_rho = unname(test_pos$estimate),
    p_value = test_pos$p.value,
    n_positions = nrow(pos_agg)
  )
  
  results[[length(results) + 1]] <- tibble(
    condition = cond,
    comparison = "Model Weight vs Selection Rate",
    spearman_rho = unname(test_wt$estimate),
    p_value = test_wt$p.value,
    n_positions = nrow(pos_agg)
  )
}

res_df <- bind_rows(results)
out_path <- file.path(output_dir, "spearman_correlation_results_r.csv")
write_csv(res_df, out_path)

cat("=== Spearman Rank Correlation Results (R) ===
")
print(as.data.frame(res_df))
cat("
Saved to:", out_path, "
")
