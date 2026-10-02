#!/usr/bin/env -i Rscript
# =====================================================================
# 04_mixed_effects_models.R
# ---------------------------------------------------------------------
# Fits Logistic GLM and Generalized Linear Mixed-Effects Models (GLMM)
# predicting selection probability from position, model weight, and condition.
# Mirrors 04_mixed_effects_models.py
#
# Usage:
#   Rscript r/04_mixed_effects_models.R --data_dir data --output_dir outputs/tables
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
df$condition <- as.factor(df$condition)
df$participant_id <- as.factor(df$participant_id)

# Model 1: Logistic Regression Main Effects
m1 <- glm(selected ~ displayed_position + model_weight + condition, data = df, family = binomial())

# Model 2: Logistic Regression Interaction Effects
m2 <- glm(selected ~ displayed_position * condition + model_weight, data = df, family = binomial())

# Model 3: Mixed-effects model if lme4 is available, else linear mixed / robust clustered
has_lme4 <- suppressWarnings(requireNamespace("lme4", quietly = TRUE))

summary_path <- file.path(output_dir, "mixed_effects_summary_r.txt")
sink(summary_path)
cat("=== MODEL 1: Logistic Regression (Main Effects) ===
")
print(summary(m1))
cat("

=== MODEL 2: Logistic Regression (Interaction Effects) ===
")
print(summary(m2))

if (has_lme4) {
  cat("

=== MODEL 3: GLMM Logistic (Participant Random Intercept - lme4) ===
")
  m3 <- lme4::glmer(selected ~ displayed_position + model_weight + condition + (1 | participant_id),
                    data = df, family = binomial(), control = lme4::glmerControl(optimizer = "bobyqa"))
  print(summary(m3))
} else {
  cat("

=== MODEL 3 Note: lme4 package not installed in environment; skipping GLMM random intercept. ===
")
}
sink()

cat("Models fitted successfully. Summary exported to:", summary_path, "
")
