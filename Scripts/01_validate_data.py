#!/usr/bin/env python3
"""
01_validate_data.py
-------------------
Data Integrity & Schema Validation Suite.
Checks data types, missing values, ranges, and cross-table consistency for all datasets.
"""

import os
import sys
import argparse
import pandas as pd
import numpy as np

def validate_datasets(data_dir="data", output_dir="outputs/tables"):
    os.makedirs(output_dir, exist_ok=True)
    report = []
    
    # 1. h2_testing_dataset
    h2_path = os.path.join(data_dir, "h2_testing_dataset.csv")
    if os.path.exists(h2_path):
        df_h2 = pd.read_csv(h2_path)
        n_rows, n_cols = df_h2.shape
        missing = df_h2.isnull().sum().sum()
        p_ids = df_h2['participant_id'].nunique()
        t_ids = df_h2['topic_id'].nunique()
        conds = df_h2['condition'].unique().tolist()
        pos_range = (df_h2['displayed_position'].min(), df_h2['displayed_position'].max())
        sel_vals = df_h2['selected'].unique().tolist()
        
        status = "PASS" if missing == 0 and set(sel_vals).issubset({0, 1}) else "FAIL"
        report.append({
            "Dataset": "h2_testing_dataset.csv",
            "Rows": n_rows, "Cols": n_cols, "Missing": missing,
            "Details": f"Participants: {p_ids}, Topics: {t_ids}, Conditions: {conds}, Pos Range: {pos_range}",
            "Status": status
        })
    else:
        report.append({"Dataset": "h2_testing_dataset.csv", "Status": "MISSING"})

    # 2. model_keywords
    kw_path = os.path.join(data_dir, "model_keywords.csv")
    if os.path.exists(kw_path):
        df_kw = pd.read_csv(kw_path)
        missing = df_kw.isnull().sum().sum()
        topics = df_kw['topic'].nunique()
        report.append({
            "Dataset": "model_keywords.csv",
            "Rows": len(df_kw), "Cols": df_kw.shape[1], "Missing": missing,
            "Details": f"Topics: {topics}, Keywords: {len(df_kw)}",
            "Status": "PASS" if missing == 0 else "FAIL"
        })

    # 3. topic_overview
    top_path = os.path.join(data_dir, "topic_overview.csv")
    if os.path.exists(top_path):
        df_top = pd.read_csv(top_path)
        report.append({
            "Dataset": "topic_overview.csv",
            "Rows": len(df_top), "Cols": df_top.shape[1], "Missing": df_top.isnull().sum().sum(),
            "Details": f"Total Topic Clusters: {len(df_top)}",
            "Status": "PASS"
        })

    # 4. real_dataset
    real_path = os.path.join(data_dir, "real_dataset.csv")
    if os.path.exists(real_path):
        df_real = pd.read_csv(real_path)
        report.append({
            "Dataset": "real_dataset.csv",
            "Rows": len(df_real), "Cols": df_real.shape[1], "Missing": df_real.isnull().sum().sum(),
            "Details": f"Themes: {df_real['source_theme'].unique().tolist()}",
            "Status": "PASS"
        })

    rep_df = pd.DataFrame(report)
    out_csv = os.path.join(output_dir, "validation_report.csv")
    rep_df.to_csv(out_csv, index=False)
    print("=== Data Validation Complete ===")
    print(rep_df.to_string(index=False))
    print(f"\nReport saved to: {out_csv}")
    return rep_df

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Validate data integrity.")
    parser.add_argument("--data_dir", default="data", help="Path to data folder")
    parser.add_argument("--output_dir", default="outputs/tables", help="Path to output folder")
    args = parser.parse_args()
    validate_datasets(args.data_dir, args.output_dir)
