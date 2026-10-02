#!/usr/bin/env -i Rscript
# =====================================================================
# 07_plot_fig3_model_weight_quintiles.R
# ---------------------------------------------------------------------
# Generates Figure 3: Selection probability across model weight quintiles
# and experimental conditions. Mirrors 07_plot_fig3_model_weight_quintiles.py
#
# Usage:
#   Rscript r/07_plot_fig3_model_weight_quintiles.R --data_dir data --output_dir outputs/figures
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

df <- df %>%
  mutate(
    weight_quintile = cut(
      model_weight,
      breaks = quantile(model_weight, probs = seq(0, 1, 0.2), na.rm = TRUE),
      include.lowest = TRUE,
      labels = c("Q1 (Lowest)", "Q2", "Q3", "Q4", "Q5 (Highest)")
    )
  )

agg <- df %>%
  group_by(condition, weight_quintile) %>%
  summarise(
    mean_sel = mean(selected),
    se_sel   = sd(selected) / sqrt(n()),
    .groups  = "drop"
  )

p <- ggplot(agg, aes(x = weight_quintile, y = mean_sel, fill = condition)) +
  geom_bar(stat = "identity", position = position_dodge(0.8), width = 0.7, color = "black", linewidth = 0.3) +
  geom_errorbar(
    aes(ymin = pmax(0, mean_sel - 1.96 * se_sel), ymax = mean_sel + 1.96 * se_sel),
    position = position_dodge(0.8), width = 0.2, linewidth = 0.6
  ) +
  scale_fill_manual(values = c("Ranked" = "#4c72b0", "Randomized" = "#dd8452")) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0.5, margin = margin(b = 10)),
    legend.position = "top"
  ) +
  labs(
    title = "Figure 3: Selection Probability across Model Weight Quintiles",
    x = "Model Weight Quintile",
    y = "Mean Selection Probability",
    fill = "Condition"
  )

out_png <- file.path(output_dir, "figure3_model_weight_quintiles_r.png")
out_pdf <- file.path(output_dir, "figure3_model_weight_quintiles_r.pdf")
ggsave(out_png, plot = p, width = 9, height = 5.5, dpi = 300)
ggsave(out_pdf, plot = p, width = 9, height = 5.5)

cat("Figure 3 generated successfully:", out_png, "
")
