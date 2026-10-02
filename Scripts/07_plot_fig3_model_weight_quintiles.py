#!/usr/bin/env python3
"""
07_plot_fig3_model_weight_quintiles.py
--------------------------------------
Generates Figure 3: Selection probability by Model Weight Quintiles across Conditions.
"""

import os
import argparse
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

def plot_figure3(data_dir="data", output_dir="outputs/figures"):
    os.makedirs(output_dir, exist_ok=True)
    df = pd.read_csv(os.path.join(data_dir, "h2_testing_dataset.csv"))
    
    # Create quintiles of model_weight
    df['weight_quintile'] = pd.qcut(df['model_weight'], q=5, labels=['Q1 (Lowest)', 'Q2', 'Q3', 'Q4', 'Q5 (Highest)'])
    
    agg = df.groupby(['condition', 'weight_quintile'], observed=False)['selected'].agg(['mean', 'sem']).reset_index()
    
    sns.set_theme(style="whitegrid", palette="muted")
    plt.figure(figsize=(9, 5.5), dpi=300)
    
    palette = {"Ranked": "#1f77b4", "Randomized": "#ff7f0e"}
    
    sns.barplot(
        data=df, x='weight_quintile', y='selected', hue='condition',
        palette="muted", errorbar=('ci', 95), capsize=0.1
    )
    
    plt.title("Figure 3: Selection Probability across Model Weight Quintiles", fontsize=13, fontweight='bold', pad=12)
    plt.xlabel("Model Weight Quintile", fontsize=11, labelpad=8)
    plt.ylabel("Mean Selection Probability", fontsize=11, labelpad=8)
    plt.legend(title="Condition", frameon=True, fontsize=10)
    plt.tight_layout()
    
    out_png = os.path.join(output_dir, "figure3_model_weight_quintiles.png")
    out_pdf = os.path.join(output_dir, "figure3_model_weight_quintiles.pdf")
    plt.savefig(out_png, dpi=300)
    plt.savefig(out_pdf)
    plt.close()
    print(f"Figure 3 generated successfully: {out_png}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", default="data")
    parser.add_argument("--output_dir", default="outputs/figures")
    args = parser.parse_args()
    plot_figure3(args.data_dir, args.output_dir)
