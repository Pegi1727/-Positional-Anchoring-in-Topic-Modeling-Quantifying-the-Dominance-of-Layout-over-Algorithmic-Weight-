#!/usr/bin/env -i Rscript
# =====================================================================
# 10_export_q1_tables.R
# ---------------------------------------------------------------------
# Exports publication-quality summary tables in CSV and LaTeX formats.
# Mirrors 10_export_q1_tables.py
#
# Usage:
#   Rscript r/10_export_q1_tables.R --data_dir data --output_dir outputs/tables
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

# Table 1: Main descriptive statistics
t1 <- df %>%
  group_by(condition, displayed_position) %>%
  summarise(
    N = n(),
    Selections = sum(selected),
    Mean_Selection = round(mean(selected), 4),
    SD_Selection = round(sd(selected), 4),
    Mean_Weight = round(mean(model_weight), 4),
    SD_Weight = round(sd(model_weight), 4),
    .groups = "drop"
  )

write_csv(t1, file.path(output_dir, "table1_position_descriptives_r.csv"))

# Table 2: Condition Comparison Summary
t2 <- df %>%
  group_by(condition) %>%
  summarise(
    Total_Trials = n(),
    Total_Selected = sum(selected),
    Selection_Rate = round(mean(selected), 4),
    SE = round(sd(selected) / sqrt(n()), 4),
    Avg_Model_Weight = round(mean(model_weight), 4),
    .groups = "drop"
  )

write_csv(t2, file.path(output_dir, "table2_condition_summary_r.csv"))

# Helper for LaTeX tables
df_to_latex <- function(d, caption, label) {
  cols <- colnames(d)
  header <- paste(cols, collapse = " & ")
  rows <- apply(d, 1, function(r) paste(r, collapse = " & "))
  body <- paste(rows, collapse = " \\ 
")
  align <- paste(rep("r", ncol(d)), collapse = "")
  
  tex <- sprintf(
    "\begin{table}[htbp]
\centering
\caption{%s}
\label{%s}
\begin{tabular}{%s}
\hline
%s \\
\hline
%s \\
\hline
\end{tabular}
\end{table}",
    caption, label, align, header, body
  )
  return(tex)
}

writeLines(df_to_latex(t1, "Descriptive Statistics by Condition and Position (R)", "tab:desc_pos_r"),
           file.path(output_dir, "table1_position_descriptives_r.tex"))
writeLines(df_to_latex(t2, "Aggregate Condition Performance (R)", "tab:cond_summary_r"),
           file.path(output_dir, "table2_condition_summary_r.tex"))

cat("Exported Table 1 and Table 2 (CSV and LaTeX - R) to", output_dir, "
")
