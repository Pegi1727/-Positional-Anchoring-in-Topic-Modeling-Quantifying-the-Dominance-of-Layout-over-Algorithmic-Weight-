#!/usr/bin/env python3
"""
02_descriptive_summary.py
-------------------------
Calculates comprehensive descriptive statistics: selection rates by condition,
position-level aggregate metrics, participant summary, and model weight distributions.
"""

import os
import argparse
import pandas as pd
import numpy as np

def generate_summary(data_dir="data", output_dir="outputs/tables"):
    os.makedirs(output_dir, exist_ok=True)
    h2_path = os.path.join(data_dir, "h2_testing_dataset.csv")
    df = pd.read_csv(h2_path)
    
    # 1. Condition-level summary
    cond_summary = df.groupby('condition').agg(
        total_trials=('selected', 'count'),
        total_selections=('selected', 'sum'),
        mean_selection_rate=('selected', 'mean'),
        std_selection_rate=('selected', 'std'),
        mean_model_weight=('model_weight', 'mean')
    ).reset_index()
    
    # 2. Position-level summary
    pos_summary = df.groupby(['condition', 'displayed_position']).agg(
        selection_rate=('selected', 'mean'),
        selection_count=('selected', 'sum'),
        total_items=('selected', 'count'),
        mean_model_weight=('model_weight', 'mean')
    ).reset_index()
    
    # 3. Overall stats
    stats_path = os.path.join(output_dir, "descriptive_condition_summary.csv")
    pos_path = os.path.join(output_dir, "descriptive_position_summary.csv")
    cond_summary.to_csv(stats_path, index=False)
    pos_summary.to_csv(pos_path, index=False)
    
    print("=== Condition Summary ===")
    print(cond_summary.to_string(index=False))
    print(f"\nSaved: {stats_path} and {pos_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", default="data")
    parser.add_argument("--output_dir", default="outputs/tables")
    args = parser.parse_args()
    generate_summary(args.data_dir, args.output_dir)
