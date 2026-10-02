#!/usr/bin/env python3
"""
10_export_q1_tables.py
----------------------
Exports publication-quality summary tables in LaTeX, Markdown, and CSV formats
formatted according to top-tier Q1 journal specifications.
"""

import os
import argparse
import pandas as pd
import numpy as np

def export_tables(data_dir="data", output_dir="outputs/tables"):
    os.makedirs(output_dir, exist_ok=True)
    df = pd.read_csv(os.path.join(data_dir, "h2_testing_dataset.csv"))
    
    # Table 1: Main descriptive statistics
    t1 = df.groupby(['condition', 'displayed_position']).agg(
        N=('selected', 'count'),
        Selections=('selected', 'sum'),
        Mean_Selection=('selected', 'mean'),
        SD_Selection=('selected', 'std'),
        Mean_Weight=('model_weight', 'mean'),
        SD_Weight=('model_weight', 'std')
    ).round(4).reset_index()
    
    t1.to_csv(os.path.join(output_dir, "table1_position_descriptives.csv"), index=False)
    with open(os.path.join(output_dir, "table1_position_descriptives.tex"), "w") as f:
        f.write(t1.to_latex(index=False, caption="Descriptive Statistics by Condition and Position", label="tab:desc_pos"))
        
    # Table 2: Condition Comparison Summary
    t2 = df.groupby('condition').agg(
        Total_Trials=('selected', 'count'),
        Total_Selected=('selected', 'sum'),
        Selection_Rate=('selected', 'mean'),
        SE=('selected', lambda x: np.std(x, ddof=1) / np.sqrt(len(x))),
        Avg_Model_Weight=('model_weight', 'mean')
    ).round(4).reset_index()
    
    t2.to_csv(os.path.join(output_dir, "table2_condition_summary.csv"), index=False)
    with open(os.path.join(output_dir, "table2_condition_summary.tex"), "w") as f:
        f.write(t2.to_latex(index=False, caption="Aggregate Condition Performance", label="tab:cond_summary"))
        
    print(f"Exported Table 1 and Table 2 (CSV and LaTeX) to {output_dir}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", default="data")
    parser.add_argument("--output_dir", default="outputs/tables")
    args = parser.parse_args()
    export_tables(args.data_dir, args.output_dir)
