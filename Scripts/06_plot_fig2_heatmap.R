#!/usr/bin/env -i Rscript
# =====================================================================
# 06_plot_fig2_heatmap.R
# ---------------------------------------------------------------------
# Generates Figure 2: Selection heatmap across Position x Topic Clusters.
# Mirrors 06_plot_fig2_heatmap.py
#
# Usage:
#   Rscript r/06_plot_fig2_heatmap.R --data_dir data --output_dir outputs/figures
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

pivot_df <- df %>%
  group_by(topic_id, displayed_position) %>%
  summarise(sel_rate = mean(selected), .groups = "drop")

p <- ggplot(pivot_df, aes(x = factor(displayed_position), y = factor(topic_id), fill = sel_rate)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.3f", sel_rate)), size = 3.2, color = "black") +
  scale_fill_distiller(palette = "YlGnBu", direction = 1, name = "Selection Rate") +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0.5, margin = margin(b = 10)),
    panel.grid = element_blank()
  ) +
  labs(
    title = "Figure 2: Empirical Selection Rate Heatmap (Topic vs. Position)",
    x = "Displayed Position",
    y = "Topic Cluster ID"
  )

out_png <- file.path(output_dir, "figure2_topic_position_heatmap_r.png")
out_pdf <- file.path(output_dir, "figure2_topic_position_heatmap_r.pdf")
ggsave(out_png, plot = p, width = 10, height = 5, dpi = 300)
ggsave(out_pdf, plot = p, width = 10, height = 5)

cat("Figure 2 generated successfully:", out_png, "
")
