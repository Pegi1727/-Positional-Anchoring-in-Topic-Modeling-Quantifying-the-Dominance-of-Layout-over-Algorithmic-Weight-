#!/usr/bin/env -i Rscript
# =====================================================================
# 08_plot_fig4_cumulative_budget.R
# ---------------------------------------------------------------------
# Generates Figure 4: Cumulative selection yield over evaluation budget (k).
# Mirrors 08_plot_fig4_cumulative_budget.py
#
# Usage:
#   Rscript r/08_plot_fig4_cumulative_budget.R --data_dir data --output_dir outputs/figures
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

df_cum <- df %>%
  arrange(participant_id, topic_id, displayed_position) %>%
  group_by(participant_id, topic_id) %>%
  mutate(cum_selected = cumsum(selected)) %>%
  ungroup()

cum_agg <- df_cum %>%
  group_by(condition, displayed_position) %>%
  summarise(
    mean_cum = mean(cum_selected),
    se_cum   = sd(cum_selected) / sqrt(n()),
    .groups  = "drop"
  )

p <- ggplot(cum_agg, aes(x = displayed_position, y = mean_cum, color = condition, fill = condition, group = condition)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  geom_ribbon(aes(ymin = mean_cum - se_cum, ymax = mean_cum + se_cum), alpha = 0.18, color = NA) +
  scale_color_manual(values = c("Ranked" = "#1f77b4", "Randomized" = "#ff7f0e")) +
  scale_fill_manual(values = c("Ranked" = "#1f77b4", "Randomized" = "#ff7f0e")) +
  scale_x_continuous(breaks = seq(1, max(cum_agg$displayed_position), by = 1)) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0.5, margin = margin(b = 10)),
    legend.position = "top"
  ) +
  labs(
    title = "Figure 4: Cumulative Relevant Discoveries vs. Evaluation Depth (k)",
    x = "Evaluation Depth / Cutoff Position (k)",
    y = "Cumulative Selections per Topic",
    color = "Condition",
    fill = "Condition"
  )

out_png <- file.path(output_dir, "figure4_cumulative_discovery_r.png")
out_pdf <- file.path(output_dir, "figure4_cumulative_discovery_r.pdf")
ggsave(out_png, plot = p, width = 9, height = 5.5, dpi = 300)
ggsave(out_pdf, plot = p, width = 9, height = 5.5)

cat("Figure 4 generated successfully:", out_png, "
")
