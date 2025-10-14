# Adventure Works Dataform Repository

## Quick Setup

### 1. Copy to Dataform

Copy all contents of this directory to your Dataform workspace:
- Repository: `team4`
- Location: `us-central1`
- Workspace: `cursor-sandbox`

### 2. File Structure

```
dataform/
├── dataform.json                    # Project configuration
├── package.json                     # Dependencies
├── workflow_settings.yaml           # Workspace settings
├── .gitignore                      # Git exclusions
└── definitions/
    ├── staging/
    │   └── sources.js              # Source table declarations
    └── facts/
        ├── fct_sales.sqlx
        ├── fct_product_inventory.sqlx
        ├── fct_purchases.sqlx
        ├── fct_work_orders.sqlx
        └── fct_product_reviews.sqlx
```

### 3. Configuration

**Source Dataset:**
- Project: `dna-team-day-2025-20251003`
- Dataset: `team_day_2025_adventure_works_oltp`
- Location: `US`

**Target Dataset:**
- Project: `dna-team-day-2025-20251003`
- Dataset: `team_4`
- Location: `US`

### 4. Deploy

**In Dataform UI:**
1. Click "Start execution"
2. Select "All actions"
3. Click "Start"

**Via CLI (if configured):**
```bash
dataform run
```

## Tables Created

### Dimension Tables (15)

| Table | Rows (Est.) | Description |
|-------|-------------|-------------|
| `dim_date` | 1,461 | Date dimension (2011-2014) |
| `dim_product` | 504 | Products with category hierarchy |
| `dim_customer` | 19,820 | Customers (individuals + stores) |
| `dim_territory` | 10 | Sales territories |
| `dim_salesperson` | 17 | Sales representatives |
| `dim_address` | 19,614 | Addresses with geography |
| `dim_ship_method` | 5 | Shipping methods |
| `dim_special_offer` | 16 | Promotions and discounts |
| `dim_credit_card` | 19,118 | Credit cards (masked) |
| `dim_currency` | 105 | Currency types |
| `dim_vendor` | 104 | Suppliers/vendors |
| `dim_employee` | 290 | Employees |
| `dim_location` | 14 | Manufacturing locations |
| `dim_scrap_reason` | 16 | Scrap/quality reasons |

### Fact Tables (5)

| Table | Rows (Est.) | Description |
|-------|-------------|-------------|
| `fct_sales` | 121,317 | Sales transactions |
| `fct_product_inventory` | 1,069 | Inventory snapshots |
| `fct_purchases` | 8,845 | Purchase orders |
| `fct_work_orders` | 72,591 | Manufacturing data |
| `fct_product_reviews` | 4 | Customer reviews |

## Validation Queries

### Check All Tables Created

```sql
SELECT 
  table_name,
  row_count,
  TIMESTAMP_MILLIS(creation_time) as created
FROM `dna-team-day-2025-20251003.team_4.__TABLES__`
WHERE table_name LIKE 'dim_%' OR table_name LIKE 'fct_%'
ORDER BY 
  CASE WHEN table_name LIKE 'dim_%' THEN 1 ELSE 2 END,
  table_name;
```

### Sample Sales Data

```sql
SELECT 
  COUNT(*) as total_orders,
  SUM(line_total) as total_sales,
  AVG(line_total) as avg_order_value,
  MIN(order_date_key) as earliest_order,
  MAX(order_date_key) as latest_order
FROM `dna-team-day-2025-20251003.team_4.fct_sales`;
```

## Deployment Order

Dataform automatically determines build order based on dependencies:

1. **Dimension tables** (no dependencies, can run in parallel)
2. **Fact tables** (depend on dimensions)

The `dependencies` config in each fact table ensures dimensions are created first.

## Notes

- Simplified SCD Type 1 for POC (no full history tracking)
- Surrogate keys use natural IDs from source tables
- Fact tables join to dimensions for proper key lookups
- Some calculated fields simplified (e.g., work order routing costs not included)
- Ready for Phase 4: LookML semantic layer

## Troubleshooting

**Table not found errors:**
- Verify source dataset name: `team_day_2025_adventure_works_oltp`
- Check table names match exactly (case-sensitive)

**Permission errors:**
- Ensure service account has BigQuery Data Editor role
- Verify access to both source and target datasets

**Compilation errors:**
- Check `definitions/staging/sources.js` for correct table declarations
- Verify all source tables exist in source dataset

