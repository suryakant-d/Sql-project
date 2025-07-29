# 🎵 Chinook Music Store SQL Analysis

A comprehensive SQL‑based analytics project that leverages the Chinook sample database to answer real‑world business questions around sales performance, customer behavior, and product affinity.

---

## 📁 Repository Structure

├── data/
│ └── Chinook_Schema.sql # DDL for tables & sample data
├── queries/
│ ├── 01_top_selling_tracks.sql # Top tracks, artists & genres in USA
│ ├── 02_customer_demographics.sql # Country‑level customer breakdown
│ ├── 03_revenue_by_region.sql # Revenue & invoice counts by country/state
│ ├── 04_top_customers_by_country.sql
│ ├── 05_customer_churn.sql
│ ├── 06_rfm_analysis.sql
│ ├── 07_clv_model.sql
│ ├── 08_product_affinity.sql
│ └── 09_regional_market_analysis.sql
├── results/
│ └── *.csv # Exported query outputs
├── reports/
│ └── visualizations.png # Charts & dashboards
└── README.md # (You are here)

---

## 🎯 Project Overview

1. **Data & Schema Exploration**  
   - Loaded the Chinook database (tables: `Customer`, `Invoice`, `InvoiceLine`, `Track`, `Album`, `Artist`, `Genre`).  
   - Examined for missing values, duplicates, and basic data quality.

2. **Core Analyses & Queries**  
   - **Sales Performance:** Top‑selling tracks, artists & genres (USA & global).  
   - **Customer Profiling:** Demographics by country, RFM segmentation, churn rates.  
   - **Revenue Breakdown:** Total and average spend per customer, region & session category.  
   - **Customer Lifetime Value (CLV):** Approximation using lifespan, frequency & monetary spend.  
   - **Product Affinity:** Co‑purchase patterns among tracks, albums & genres.  
   - **Regional Market Trends:** Comparative performance & churn across geographies.

3. **Insights & Recommendations**  
   - Rock dominates global sales; Argentina favors Alternative/Punk.  
   - High‑value, low‑risk segments identified in Czech Republic, Germany & Ireland.  
   - Medium‑risk markets (USA, Brazil, UK) need targeted retention campaigns.  
   - Cross‑sell opportunities: rock & adjacent genres, album‑level bundles.

sd

---


## 🛠 How to Run

1. **Import** `data/Chinook_Schema.sql` into your SQL engine (MySQL, SQLite, etc.).  
2. **Execute** each `.sql` script in the `queries/` folder.  
3. **Export** the results as CSV or connect directly to your BI tool for dashboards.  

---


