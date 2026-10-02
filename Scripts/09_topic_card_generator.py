#!/usr/bin/env python3
"""
09_topic_card_generator.py
--------------------------
Generates publication-ready Topic Cards (Markdown, HTML, JSON) summarizing topic
keywords, weights, representative documents, and validation metrics.
"""

import os
import json
import argparse
import pandas as pd

def generate_topic_cards(data_dir="data", output_dir="outputs/cards"):
    os.makedirs(output_dir, exist_ok=True)
    
    df_kw = pd.read_csv(os.path.join(data_dir, "model_keywords.csv"))
    df_top = pd.read_csv(os.path.join(data_dir, "topic_overview.csv"))
    df_real = pd.read_csv(os.path.join(data_dir, "real_dataset.csv"))
    
    cards = []
    
    for _, row in df_top.iterrows():
        t_id = int(row['topic'])
        t_kw = df_kw[df_kw['topic'] == t_id].sort_values('rank')
        t_docs = df_real[df_real['topic'] == t_id]
        
        card_data = {
            "topic_id": t_id,
            "document_count": int(row['document_count']),
            "representative_document": row['representative_document'],
            "overview_keywords": row['keywords'],
            "top_keywords": t_kw[['rank', 'keyword', 'weight']].to_dict(orient='records'),
            "theme_distribution": t_docs['source_theme'].value_counts().to_dict()
        }
        cards.append(card_data)
        
        # Save individual Markdown card
        md_content = f"""# Topic Card: Cluster {t_id}

**Document Count:** {card_data['document_count']}  
**Primary Themes:** {', '.join([f'{k} ({v})' for k, v in card_data['theme_distribution'].items()])}

### Representative Exemplar
> "{card_data['representative_document']}"

### Top Ranked Keywords & Term Weights
| Rank | Keyword | Model Weight |
|:---:|:---|:---:|
"""
        for kw in card_data['top_keywords']:
            md_content += f"| {kw['rank']} | {kw['keyword']} | {kw['weight']:.4f} |\n"
            
        with open(os.path.join(output_dir, f"topic_card_{t_id}.md"), "w") as f:
            f.write(md_content)
            
    # Save combined JSON
    with open(os.path.join(output_dir, "all_topic_cards.json"), "w") as f:
        json.dump(cards, f, indent=2)
        
    print(f"Generated {len(cards)} topic cards in {output_dir}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", default="data")
    parser.add_argument("--output_dir", default="outputs/cards")
    args = parser.parse_args()
    generate_topic_cards(args.data_dir, args.output_dir)
