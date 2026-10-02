#!/usr/bin/env python3
"""
08_plot_fig4_cumulative_budget.py
---------------------------------
Generates Figure 4: Cumulative selection yield over evaluation budget (k items inspected).
"""

import os
import argparse
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

def plot_figure4(data_dir="data", output_dir="outputs/figures"):
    os.makedirs(output_dir, exist_ok=True)
    df = pd.read_csv(os.path.join(data_dir, "h2_testing_dataset.csv"))
    
    # Sort and compute cumulative selections per participant-topic trial
    df_sorted = df.sort_values(['participant_id', 'topic_id', 'displayed_position'])
    df_sorted['cum_selected'] = df_sorted.groupby(['participant_id', 'topic_id'])['selected'].cumsum()
    
    cum_agg = df_sorted.groupby(['condition', 'displayed_position'])['cum_selected'].agg(['mean', 'sem']).reset_index()
    
    sns.set_theme(style="whitegrid", palette="muted")
    plt.figure(figsize=(9, 5.5), dpi=300)
    
    palette = {"Ranked": "#1f77b4", "Randomized": "#ff7f0e"}
    
    for cond in df['condition'].unique():
        sub = cum_agg[cum_agg['condition'] == cond]
        plt.plot(sub['displayed_position'], sub['mean'], label=f"{cond} Condition", 
                 linewidth=2.5, marker='o', color=palette.get(cond, None))
        plt.fill_between(sub['displayed_position'], sub['mean'] - sub['sem'], sub['mean'] + sub['sem'], 
                         alpha=0.15, color=palette.get(cond, None))
        
    plt.title("Figure 4: Cumulative Relevant Discoveries vs. Evaluation Depth (k)", fontsize=13, fontweight='bold', pad=12)
    plt.xlabel("Evaluation Depth / Cutoff Position (k)", fontsize=11, labelpad=8)
    plt.ylabel("Cumulative Selections per Topic", fontsize=11, labelpad=8)
    plt.xticks(range(1, cum_agg['displayed_position'].max() + 1))
    plt.legend(frameon=True, fontsize=11, loc='lower right')
    plt.tight_layout()
    
    out_png = os.path.join(output_dir, "figure4_cumulative_discovery.png")
    out_pdf = os.path.join(output_dir, "figure4_cumulative_discovery.pdf")
    plt.savefig(out_png, dpi=300)
    plt.savefig(out_pdf)
    plt.close()
    print(f"Figure 4 generated successfully: {out_png}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", default="data")
    parser.add_argument("--output_dir", default="outputs/figures")
    args = parser.parse_args()
    plot_figure4(args.data_dir, args.output_dir)
