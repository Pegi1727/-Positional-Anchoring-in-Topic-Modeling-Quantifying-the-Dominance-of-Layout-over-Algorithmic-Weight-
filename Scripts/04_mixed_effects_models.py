#!/usr/bin/env python3
"""
04_mixed_effects_models.py
--------------------------
Fits Generalized Linear Mixed-Effects Models (GLMM logistic / MixedLM) predicting
selection probability from Position, Model Weight, Condition, and interaction terms.
"""

import os
import argparse
import pandas as pd
import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf

def fit_models(data_dir="data", output_dir="outputs/tables"):
    os.makedirs(output_dir, exist_ok=True)
    df = pd.read_csv(os.path.join(data_dir, "h2_testing_dataset.csv"))
    
    # 1. Logit GLM with robust clustering / MixedLM approximation
    # Model 1: Main effects of displayed_position, model_weight, condition
    model1 = smf.logit("selected ~ displayed_position + model_weight + C(condition)", data=df).fit(disp=False)
    
    # Model 2: Interaction between condition and displayed_position
    model2 = smf.logit("selected ~ displayed_position * C(condition) + model_weight", data=df).fit(disp=False)
    
    # Model 3: Linear MixedLM with participant random intercept
    mixed_lm = smf.mixedlm("selected ~ displayed_position + model_weight + C(condition)", 
                           data=df, groups=df["participant_id"]).fit()
    
    summary_path = os.path.join(output_dir, "mixed_effects_summary.txt")
    with open(summary_path, "w") as f:
        f.write("=== MODEL 1: Logistic Regression (Main Effects) ===
")
        f.write(model1.summary().as_text())
        f.write("

=== MODEL 2: Logistic Regression (Interaction Effects) ===
")
        f.write(model2.summary().as_text())
        f.write("

=== MODEL 3: Mixed Linear Model (Participant Random Effects) ===
")
        f.write(mixed_lm.summary().as_text())
        
    print(f"Models fitted successfully. Summary exported to: {summary_path}")
    print("
--- Model 1 Summary Snippet ---")
    print(model1.summary().tables[1])

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", default="data")
    parser.add_argument("--output_dir", default="outputs/tables")
    args = parser.parse_args()
    fit_models(args.data_dir, args.output_dir)
