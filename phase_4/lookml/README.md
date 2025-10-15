# Adventure Works Analytics - LookML Project

## Overview

Semantic layer for Adventure Works data warehouse built on BigQuery. Enables self-service analytics across sales, inventory, purchasing, manufacturing, and customer feedback.

## Configuration

**BigQuery Connection:**

- Project: `dna-team-day-2025-20251003`
- Dataset: `team_4`
- Location: US

**Connection Name in Looker:** `teamday2025_team4`

## Explores

### 1. Sales Analysis

**Primary Use:** Revenue analysis, product performance, customer behavior

- **Fact:** `fct_sales` (121K rows)
- **Dimensions:** Product, Customer, Territory, Date, Salesperson, Address, Special Offers
- **Key Measures:** Total Sales Amount, Average Order Value, Order Count

**Example Questions:**

- "What were total sales for road bikes in North America last year?"
- "Show me sales by product category and customer location"
- "Which salesperson has the highest revenue?"

### 2. Product Reviews

**Primary Use:** Customer sentiment, product ratings

- **Fact:** `fct_product_reviews` (4 rows)
- **Dimensions:** Product, Review Date
- **Key Measures:** Average Rating, Review Count, Sentiment Analysis

### 3. Inventory Analysis

**Primary Use:** Stock levels, warehouse management

- **Fact:** `fct_product_inventory` (~1K rows)
- **Dimensions:** Product, Location
- **Key Measures:** Total Inventory, Out of Stock Count, Stock Status

### 4. Purchasing Analysis

**Primary Use:** Vendor performance, procurement metrics

- **Fact:** `fct_purchases` (~8K rows)
- **Dimensions:** Product, Vendor, Employee, Ship Method
- **Key Measures:** Total Purchase Amount, Rejection Rate, Vendor Quality

### 5. Manufacturing Analysis

**Primary Use:** Production efficiency, quality metrics

- **Fact:** `fct_work_orders` (~72K rows)
- **Dimensions:** Product, Scrap Reason
- **Key Measures:** Total Production, Scrap Rate, Production Days

## View Files

### Facts (5)

| View                      | Description               | Rows |
| ------------------------- | ------------------------- | ---- |
| `fct_sales`             | Order line items          | 121K |
| `fct_product_inventory` | Inventory snapshots       | ~1K  |
| `fct_purchases`         | Purchase orders           | ~8K  |
| `fct_work_orders`       | Manufacturing work orders | ~72K |
| `fct_product_reviews`   | Customer reviews          | 4    |

### Dimensions (14)

| View                  | Description                                            | Type                     |
| --------------------- | ------------------------------------------------------ | ------------------------ |
| `dim_date`          | Date dimension with time intelligence                  | Conformed                |
| `dim_product`       | Product hierarchy (Category → Subcategory → Product) | Conformed                |
| `dim_customer`      | Customer attributes                                    | Sales                    |
| `dim_territory`     | Geographic sales territories                           | Sales                    |
| `dim_salesperson`   | Sales representatives                                  | Sales                    |
| `dim_address`       | Billing/shipping addresses                             | Sales                    |
| `dim_ship_method`   | Shipping methods                                       | Sales, Purchasing        |
| `dim_special_offer` | Promotions and discounts                               | Sales                    |
| `dim_credit_card`   | Payment methods                                        | Sales                    |
| `dim_currency`      | Currency codes                                         | Sales                    |
| `dim_location`      | Warehouses and facilities                              | Inventory, Manufacturing |
| `dim_vendor`        | Suppliers                                              | Purchasing               |
| `dim_employee`      | Employee information                                   | Purchasing               |
| `dim_scrap_reason`  | Manufacturing defect reasons                           | Manufacturing            |
