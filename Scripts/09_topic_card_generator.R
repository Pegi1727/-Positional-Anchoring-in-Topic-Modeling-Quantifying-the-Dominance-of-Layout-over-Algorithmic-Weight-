#!/usr/bin/env -i Rscript
# =====================================================================
# 09_topic_card_generator.R
# ---------------------------------------------------------------------
# Generates publication-ready Topic Cards in Markdown and JSON formats.
# Mirrors 09_topic_card_generator.py
#
# Usage:
#   Rscript r/09_topic_card_generator.R --data_dir data --output_dir outputs/cards
# =====================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(jsonlite)
})

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(flag, default) {
  i <- match(flag, args)
  if (!is.na(i) && length(args) >= i + 1) args[i + 1] else default
}
data_dir   <- get_arg("--data_dir", "data")
output_dir <- get_arg("--output_dir", "outputs/cards")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

df_kw   <- read_csv(file.path(data_dir, "model_keywords.csv"), show_col_types = FALSE)
df_top  <- read_csv(file.path(data_dir, "topic_overview.csv"), show_col_types = FALSE)
df_real <- read_csv(file.path(data_dir, "real_dataset.csv"), show_col_types = FALSE)

cards <- list()

for (i in seq_len(nrow(df_top))) {
  row <- df_top[i, ]
  t_id <- as.integer(row$topic)
  
  t_kw <- df_kw %>%
    filter(topic == t_id) %>%
    arrange(rank)
  
  t_docs <- df_real %>%
    filter(topic == t_id)
  
  theme_dist <- as.list(table(t_docs$source_theme))
  
  top_kw_list <- lapply(seq_len(nrow(t_kw)), function(k) {
    list(
      rank = t_kw$rank[k],
      keyword = t_kw$keyword[k],
      weight = round(t_kw$weight[k], 4)
    )
  })
  
  card_data <- list(
    topic_id = t_id,
    document_count = as.integer(row$document_count),
    representative_document = row$representative_document,
    overview_keywords = row$keywords,
    top_keywords = top_kw_list,
    theme_distribution = theme_dist
  )
  cards[[length(cards) + 1]] <- card_data
  
  # Markdown card formatting
  theme_strs <- sapply(names(theme_dist), function(tn) paste0(tn, " (", theme_dist[[tn]], ")"))
  themes_formatted <- paste(theme_strs, collapse = ", ")
  
  md_lines <- c(
    paste0("# Topic Card: Cluster ", t_id, "
"),
    paste0("**Document Count:** ", card_data$document_count, "  "),
    paste0("**Primary Themes:** ", themes_formatted, "
"),
    "### Representative Exemplar",
    paste0('> "', card_data$representative_document, '"
'),
    "### Top Ranked Keywords & Term Weights",
    "| Rank | Keyword | Model Weight |",
    "|:---:|:---|:---:|"
  )
  for (kw in top_kw_list) {
    md_lines <- c(md_lines, sprintf("| %d | %s | %.4f |", kw$rank, kw$keyword, kw$weight))
  }
  
  writeLines(md_lines, file.path(output_dir, paste0("topic_card_", t_id, "_r.md")))
}

# Export combined JSON
write_json(cards, file.path(output_dir, "all_topic_cards_r.json"), pretty = TRUE, auto_unbox = TRUE)

cat("Generated", length(cards), "topic cards (R) in", output_dir, "
")
