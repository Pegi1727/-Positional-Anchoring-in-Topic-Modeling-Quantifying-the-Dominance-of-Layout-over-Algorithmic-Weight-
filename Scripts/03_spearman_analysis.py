#!/usr/bin/env python3
"""
03_spearman_analysis.py
-----------------------
Computes participant-level and aggregate Spearman rank correlations between
model weights, displayed positions, and empirical selection rates.
"""

import os
import argparse
import pandas as pd
import numpy as np
from scipy import stats

def run_spearman(data_dir="data", output_dir="outputs/tables"):
    os.makedirs(output_dir, exist_ok=True)
    df = pd.read_csv(os.path.join(data_dir, "h2_testing_dataset.csv"))
    
    results = []
    
    # 1. Aggregate position vs selection rate by condition
    for cond in df['condition'].unique():
        sub = df[df['condition'] == cond]
        pos_agg = sub.groupby('displayed_position').agg(
            sel_rate=('selected', 'mean'),
            mean_weight=('model_weight', 'mean')
        ).reset_index()
        
        rho_pos, p_pos = stats.spearmanr(pos_agg['displayed_position'], pos_agg['sel_rate'])
        rho_wt, p_wt = stats.spearmanr(pos_agg['mean_weight'], pos_agg['sel_rate'])
        
        results.append({
            "condition": cond,
            "comparison": "Position vs Selection Rate",
            "spearman_rho": rho_pos,
            "p_value": p_pos,
            "n_positions": len(pos_agg)
        })
        results.append({
            "condition": cond,
            "comparison": "Model Weight vs Selection Rate",
            "spearman_rho": rho_wt,
            "p_value": p_wt,
            "n_positions": len(pos_agg)
        })
        
    res_df = pd.DataFrame(results)
    out_path = os.path.join(output_dir, "spearman_correlation_results.csv")
    res_df.to_csv(out_path, index=False)
    
    print("=== Spearman Rank Correlation Results ===")
    print(res_df.to_string(index=False))
    print(f"\nSaved to: {out_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", default="data")
    parser.add_argument("--output_dir", default="outputs/tables")
    args = parser.parse_args()
    run_spearman(args.data_dir, args.output_dir)
