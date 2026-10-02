#!/usr/bin/env python3
"""
05_plot_fig1_position_decay.py
------------------------------
Generates Figure 1: Selection rate decay curve by displayed rank position across conditions.
"""

import os
import argparse
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

def plot_figure1(data_dir="data", output_dir="outputs/figures"):
    os.makedirs(output_dir, exist_ok=True)
    df = pd.read_csv(os.path.join(data_dir, "h2_testing_dataset.csv"))
    
    agg = df.groupby(['condition', 'displayed_position'])['selected'].agg(['mean', 'sem']).reset_index()
    
    sns.set_theme(style="whitegrid", palette="muted")
    plt.figure(figsize=(9, 5.5), dpi=300)
    
    palette = {"Ranked": "#1f77b4", "Randomized": "#ff7f0e"}
    markers = {"Ranked": "o", "Randomized": "s"}
    
    for cond in df['condition'].unique():
        sub = agg[agg['condition'] == cond]
        plt.errorbar(
            sub['displayed_position'], sub['mean'], yerr=sub['sem'],
            label=f"Condition: {cond}", marker=markers.get(cond, 'o'),
            linewidth=2.2, markersize=7, capsize=3.5, color=palette.get(cond, None)
        )
        
    plt.title("Figure 1: Position-Dependent Selection Probability", fontsize=14, fontweight='bold', pad=12)
    plt.xlabel("Displayed Position (Rank)", fontsize=12, labelpad=8)
    plt.ylabel("Empirical Selection Rate", fontsize=12, labelpad=8)
    plt.xticks(range(1, agg['displayed_position'].max() + 1))
    plt.legend(frameon=True, fontsize=11, loc='upper right')
    plt.tight_layout()
    
    out_png = os.path.join(output_dir, "figure1_position_decay.png")
    out_pdf = os.path.join(output_dir, "figure1_position_decay.pdf")
    plt.savefig(out_png, dpi=300)
    plt.savefig(out_pdf)
    plt.close()
    print(f"Figure 1 generated successfully: {out_png}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", default="data")
    parser.add_argument("--output_dir", default="outputs/figures")
    args = parser.parse_args()
    plot_figure1(args.data_dir, args.output_dir)
