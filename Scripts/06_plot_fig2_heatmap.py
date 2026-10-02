#!/usr/bin/env python3
"""
06_plot_fig2_heatmap.py
-----------------------
Generates Figure 2: Selection heatmap across Position x Topic Clusters.
"""

import os
import argparse
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def plot_figure2(data_dir="data", output_dir="outputs/figures"):
    os.makedirs(output_dir, exist_ok=True)
    df = pd.read_csv(os.path.join(data_dir, "h2_testing_dataset.csv"))
    
    pivot = df.pivot_table(index='topic_id', columns='displayed_position', values='selected', aggfunc='mean')
    
    plt.figure(figsize=(10, 5), dpi=300)
    sns.heatmap(pivot, annot=True, fmt=".3f", cmap="YlGnBu", cbar_kws={'label': 'Selection Rate'}, linewidths=0.5)
    
    plt.title("Figure 2: Empirical Selection Rate Heatmap (Topic vs. Position)", fontsize=13, fontweight='bold', pad=12)
    plt.xlabel("Displayed Position", fontsize=11)
    plt.ylabel("Topic Cluster ID", fontsize=11)
    plt.tight_layout()
    
    out_png = os.path.join(output_dir, "figure2_topic_position_heatmap.png")
    out_pdf = os.path.join(output_dir, "figure2_topic_position_heatmap.pdf")
    plt.savefig(out_png, dpi=300)
    plt.savefig(out_pdf)
    plt.close()
    print(f"Figure 2 generated successfully: {out_png}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", default="data")
    parser.add_argument("--output_dir", default="outputs/figures")
    args = parser.parse_args()
    plot_figure2(args.data_dir, args.output_dir)
