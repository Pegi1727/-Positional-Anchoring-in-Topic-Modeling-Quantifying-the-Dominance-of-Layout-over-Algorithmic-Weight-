#!/usr/bin/env -i Rscript
# =====================================================================
# 05_plot_fig1_position_decay.R
# ---------------------------------------------------------------------
# Generates Figure 1: Selection rate decay curve by displayed rank position
# across conditions. Mirrors 05_plot_fig1_position_decay.py
#
# Usage:
#   Rscript r/05_plot_fig1_position_decay.R --data_dir data --output_dir outputs/figures
# =====================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
})

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(flag, default) {
  i <- match(flag, args)
  if (!is.na(i) && length(args) >= i + 1) args[i + 1] else default
}
data_dir   <- get_arg("--data_dir", "data")
output_dir <- get_arg("--output_dir", "outputs/figures")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

df <- read_csv(file.path(data_dir, "h2_testing_dataset.csv"), show_col_types = FALSE)

agg <- df %>%
  group_by(condition, displayed_position) %>%
  summarise(
    mean_sel = mean(selected),
    se_sel   = sd(selected) / sqrt(n()),
    .groups  = "drop"
  )

p <- ggplot(agg, aes(x = displayed_position, y = mean_sel, color = condition, shape = condition, group = condition)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean_sel - se_sel, ymax = mean_sel + se_sel), width = 0.25, linewidth = 0.7) +
  scale_color_manual(values = c("Ranked" = "#1f77b4", "Randomized" = "#ff7f0e")) +
  scale_x_continuous(breaks = seq(1, max(agg$displayed_position), by = 1)) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5, margin = margin(b = 10)),
    legend.position = "top",
    panel.grid.minor = element_blank()
  ) +
  labs(
    title = "Figure 1: Position-Dependent Selection Probability",
    x = "Displayed Position (Rank)",
    y = "Empirical Selection Rate",
    color = "Condition",
    shape = "Condition"
  )

out_png <- file.path(output_dir, "figure1_position_decay_r.png")
out_pdf <- file.path(output_dir, "figure1_position_decay_r.pdf")
ggsave(out_png, plot = p, width = 9, height = 5.5, dpi = 300)
ggsave(out_pdf, plot = p, width = 9, height = 5.5)

cat("Figure 1 generated successfully:", out_png, "
")
