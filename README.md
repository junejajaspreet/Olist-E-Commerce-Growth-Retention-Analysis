# Olist E-Commerce Growth & Retention Analysis

**Diagnosing why 96.88% of customers never return, and where Olist should fix it first.**

A full-funnel business analysis of the Olist Brazilian e-commerce dataset, built to go beyond descriptive reporting and identify the actual root causes behind Olist's growth plateau and low customer retention, using SQL for investigation and Power BI for visualization.

---

## Business Problem

Olist scaled order volume and revenue year over year, but almost no customers place a second order. This project investigates:
- Is Olist's growth real, or masked by constant new-customer acquisition?
- Why is the repeat purchase rate so low, delivery, price, or something structural?
- Where exactly is delivery underperforming, company-wide or specific sellers?
- Which products, categories, and regions are quietly underperforming despite generating revenue?

---

## Tech Stack

- **MySQL 8.0** — database design, data loading, SQL analysis
- **Power BI Desktop** — data modeling, DAX measures, dashboard visualization
- **Excel** — initial data inspection

---

## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle), ~1.3 million rows across 9 tables: customers, orders, order items, payments, reviews, products, sellers, geolocation, and category translations.

---

## Methodology

1. **Database design** — built a normalized 8-table MySQL schema from raw CSVs, handling real-world data quality issues (leading-zero zip codes, malformed CSV escaping, missing delivery dates) with documented, deliberate fixes rather than silent defaults.
2. **Structured SQL investigation** — 24 questions across 9 sections (Revenue, Retention, Delivery, Seller Quality, Regional, Satisfaction, Payments, Product, Customer Value), each with a standalone finding plus a section-level synthesis.
3. **Power BI dashboard** — 6-page interactive report translating every SQL finding into a visual, built on a proper relational data model with custom DAX measures (not pre-aggregated exports), so the dashboard is genuinely interactive, not static charts.

---

## Key Findings

- **Retention is the core problem, not delivery or satisfaction.** Only 3.12% of customers order more than once. Delivery delay (-11.8 vs -12.6 days) and review scores (4.08 vs 4.11) are nearly identical between one-time and repeat customers, ruling out both as the driver.
- **Growth was volume-driven, not price-driven.** AOV stayed flat (₹146-175) throughout 2017-2018 while order count grew then plateaued after November 2017, meaning the 2018 slowdown is a demand problem, not a pricing one.
- **Delivery delay is a seller problem, not a platform-wide one.** Just 20 sellers (out of 3,000+) account for ~35% of all late orders, and the same sellers show both high delay and low review scores.
- **`office_furniture` is a flagged category.** High revenue (₹2.67L+) but the lowest review score (3.52) of any major category, backed by a large, reliable sample size.
- **A small high-value segment exists.** 1.23% of customers (High spend tier) generate ~12% of revenue at 14x the average per-customer spend of the Low tier.

*(Full section-by-section analysis and SQL is in `/sql/02_analysis_queries.sql`, with inline insights as comments above each query.)*

---

## Dashboard Pages

1. **Executive Summary** — headline KPIs, revenue trend, retention split
2. **Revenue & Growth** — monthly revenue, order volume, and AOV trends
3. **Customer Retention & Value** — one-time vs. repeat comparison, spend tier breakdown
4. **Delivery & Seller Performance** — late delivery rate, seller-level delay and review analysis
5. **Regional Performance** — revenue and delay by state, same-state vs. cross-state shipping
6. **Product, Category & Payments** — top products, category performance, payment method analysis

Screenshots of all 6 pages are in `/screenshots`.

---

## Repository Structure

```
├── sql/
│   ├── 01_schema_setup.sql       # Table creation + LOAD DATA INFILE scripts
│   └── 02_analysis_queries.sql   # All 24 analysis questions with inline insights
├── powerbi/
│   └── Olist_Ecommerce_Dashboard.pbix
├── screenshots/                  # Exported dashboard pages
└── README.md
```

---

## How to Reproduce

1. Download the [Olist dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) from Kaggle
2. Run `sql/01_schema_setup.sql` in MySQL to create the schema and load the data
3. Run `sql/02_analysis_queries.sql` to reproduce the analysis
4. Open `powerbi/Olist_Ecommerce_Dashboard.pbix` in Power BI Desktop and refresh the data connection

---

## Author

**Jaspreet Singh Juneja**
[LinkedIn](#) · [Portfolio](#)
