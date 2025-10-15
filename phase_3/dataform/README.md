# Dataform - Minimal POC

## Single Fact Table: fct_product_reviews

Starting with the smallest fact table (4 rows) to validate the pipeline.

## Structure

```
dataform/
├── dataform.json              # Configuration
├── workflow_settings.yaml     # Workspace settings
└── definitions/
    ├── staging/
    │   └── sources.js        # Source table declarations
    ├── dimensions/
    │   ├── dim_date.sqlx     # Date dimension
    │   └── dim_product.sqlx  # Product dimension
    └── facts/
        └── fct_product_reviews.sqlx
```

## Tables Created (3 total)

| Table | Type | Rows | Description |
|-------|------|------|-------------|
| dim_date | Dimension | 1,461 | 2011-2014 dates |
| dim_product | Dimension | 504 | Products with categories |
| fct_product_reviews | Fact | 4 | Product reviews |

## Deployment

1. Copy all files from `dataform/` to your Dataform repo
2. In Dataform UI: Click "Start execution"
3. Select "All actions"

## Build Order

Dataform automatically builds in correct order:
1. dim_date (no dependencies)
2. dim_product (needs source tables)
3. fct_product_reviews (needs both dimensions)

## Validation

```sql
-- Check tables created
SELECT 
  table_name,
  row_count
FROM `dna-team-day-2025-20251003.team_4.__TABLES__`
WHERE table_name IN ('dim_date', 'dim_product', 'fct_product_reviews')
ORDER BY table_name;

-- Sample the fact table
SELECT * 
FROM `dna-team-day-2025-20251003.team_4.fct_product_reviews`
LIMIT 10;
```

## Next Steps

Once this works, add more fact tables one at a time:
- fct_product_inventory (1K rows)
- fct_purchases (8K rows)
- fct_work_orders (72K rows)
- fct_sales (121K rows)
