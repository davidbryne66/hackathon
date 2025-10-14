# Phase 3: Dataform SQLX Fact Tables

## Overview

This directory contains production-ready Dataform SQLX scripts for all 5 fact tables in the Adventure Works dimensional model. Each script implements the transformation logic defined in Phase 2's source-to-target mapping document.

## Files Created

### Fact Tables (5 files)

| File | Fact Table | Grain | Partitioning | Clustering | Key Measures |
|------|-----------|-------|--------------|------------|--------------|
| `fct_sales.sqlx` | Sales transactions | Order line item | order_date | customer, product, territory | line_total, gross_profit, quantity |
| `fct_product_inventory.sqlx` | Inventory snapshots | Product/Location/Day | snapshot_date | product, location | quantity_on_hand, inventory_value |
| `fct_purchases.sqlx` | Purchase orders | PO line item | order_date | vendor, product, employee | line_total, acceptance_rate |
| `fct_work_orders.sqlx` | Work orders | Work order | due_date | product, location | actual_cost, scrap_rate, yield_rate |
| `fct_product_reviews.sqlx` | Product reviews | Review | review_date | product, rating | rating, sentiment_score |

## Key Features

### ✅ Production-Ready Code
- **Optimized BigQuery SQL** with proper partitioning and clustering
- **CTEs for readability** - clear data flow and transformations
- **Comprehensive comments** - explains complex logic
- **Error handling** - SAFE_DIVIDE, COALESCE for NULL handling
- **Data quality** - filters, validations, and business rules

### ✅ Best Practices Implemented

#### 1. **Partitioning & Clustering**
```sql
bigquery: {
  partitionBy: "DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING)))",
  clusterBy: ["customer_key", "product_key", "territory_key"]
}
```
- Partitioning on date for efficient time-based queries
- Clustering on commonly filtered dimensions

#### 2. **Surrogate Key Lookups**
```sql
LEFT JOIN ${ref('dim_customer')} dc
  ON sb.CustomerID = dc.customer_id
  AND dc.is_current = TRUE
```
- Joins to dimension tables to get surrogate keys
- Handles SCD Type 2 with `is_current` flag
- Uses COALESCE with -1 for missing references

#### 3. **Calculated Measures**
```sql
SAFE_DIVIDE(
  (sb.LineTotal - (sb.OrderQty * COALESCE(sb.product_standard_cost, 0))),
  NULLIF(sb.LineTotal, 0)
) * 100 AS profit_margin_pct
```
- Pre-calculated metrics for query performance
- Safe division to avoid divide-by-zero errors
- NULL handling with COALESCE

#### 4. **Business Rules**
```sql
WHERE soh.Status >= 5  -- Only completed orders
  AND sb.OrderDate IS NOT NULL
  AND sb.CustomerID IS NOT NULL
```
- Data quality filters
- Business logic enforcement
- Required field validation

### ✅ Advanced Features

#### **FCT_SALES** (Primary Fact)
- ✅ 11 dimension foreign keys
- ✅ Role-playing date dimension (order, ship, due dates)
- ✅ Role-playing address dimension (bill to, ship to)
- ✅ Complex calculations (gross_profit, profit_margin_pct)
- ✅ Currency lookup through currency rate
- ✅ Store lookup through customer relationship

#### **FCT_PRODUCT_INVENTORY** (Snapshot)
- ✅ Semi-additive measures (inventory quantities)
- ✅ Days of inventory calculation with sales velocity
- ✅ Alert flags (below_reorder_point, below_safety_stock)
- ✅ Inventory status categorization

#### **FCT_PURCHASES** (Vendor Performance)
- ✅ Quality metrics (acceptance_rate, rejection calculations)
- ✅ Delivery performance (days_to_ship, days_early_late)
- ✅ Order receipt status tracking
- ✅ Vendor performance indicators

#### **FCT_WORK_ORDERS** (Manufacturing)
- ✅ Routing aggregation (sum costs across operations)
- ✅ Cost variance analysis (actual vs planned)
- ✅ Quality metrics (scrap_rate, yield_rate)
- ✅ Efficiency metrics (units_per_day, units_per_hour)
- ✅ Time-based analysis (production_days, days_early_late)

#### **FCT_PRODUCT_REVIEWS** (Customer Satisfaction)
- ✅ Unix timestamp conversion for review date
- ✅ Simple sentiment analysis (rule-based)
- ✅ Text analysis (comment length, word count)
- ✅ Review quality scoring
- ✅ Email masking for privacy (show domain only)

## Dataform Configuration

Each SQLX file includes a `config` block that defines:

```javascript
config {
  type: "table",                    // Creates a table (not view)
  schema: "adventure_works",        // Target BigQuery dataset
  name: "fct_sales",               // Table name
  description: "...",              // Documentation
  
  bigquery: {
    partitionBy: "...",            // Partition strategy
    clusterBy: [...]               // Clustering columns
  },
  
  dependencies: [...],             // Which tables to build first
  tags: [...],                     // Organization tags
  
  assertions: {
    uniqueKey: [...],              // Composite key validation
    nonNull: [...]                 // Required field validation
  }
}
```

## Dependencies

### Required Dimension Tables

All fact tables depend on dimensions being created first:

**fct_sales requires:**
- dim_date
- dim_product
- dim_customer
- dim_territory
- dim_salesperson
- dim_ship_method
- dim_special_offer
- dim_credit_card
- dim_currency
- dim_store
- dim_address

**fct_product_inventory requires:**
- dim_date
- dim_product
- dim_location

**fct_purchases requires:**
- dim_date
- dim_product
- dim_vendor
- dim_employee
- dim_ship_method

**fct_work_orders requires:**
- dim_date
- dim_product
- dim_location
- dim_scrap_reason

**fct_product_reviews requires:**
- dim_date
- dim_product

## Usage in Dataform

### 1. **Project Structure**
Place these files in your Dataform project:
```
your-dataform-project/
├── definitions/
│   ├── dimensions/
│   │   └── (dimension SQLX files)
│   └── facts/
│       ├── fct_sales.sqlx
│       ├── fct_product_inventory.sqlx
│       ├── fct_purchases.sqlx
│       ├── fct_work_orders.sqlx
│       └── fct_product_reviews.sqlx
└── dataform.json
```

### 2. **Build Order**
Dataform automatically determines build order based on `dependencies`. The execution will be:
1. All dimension tables
2. Fact tables (can run in parallel since they don't depend on each other)

### 3. **Run Commands**
```bash
# Compile and validate
dataform compile

# Run all fact tables
dataform run --tags fact

# Run specific fact table
dataform run --actions adventure_works.fct_sales

# Run with full refresh
dataform run --tags fact --full-refresh
```

### 4. **Testing**
```bash
# Run assertions only
dataform run --tags fact --actions-only assertions

# Test specific table
dataform test adventure_works.fct_sales
```

## Performance Optimization

### Query Optimization Techniques Used

1. **CTEs for Clarity**
   - Break complex logic into readable steps
   - Allows BigQuery to optimize execution plan

2. **Efficient Joins**
   - LEFT JOIN for optional dimensions
   - INNER JOIN for required relationships
   - Join on indexed columns (natural keys)

3. **Partitioning**
   - All tables partitioned by date
   - Enables partition pruning for date-filtered queries
   - Reduces cost and improves performance

4. **Clustering**
   - Columns commonly used in WHERE and JOIN clauses
   - Improves query performance for filtered queries

5. **Pre-calculated Measures**
   - Complex calculations done once at load time
   - Query time just reads the values
   - Examples: gross_profit, profit_margin_pct

## Data Quality

### Built-in Validations

Each fact table includes:

1. **Unique Key Assertions**
   ```sql
   assertions: {
     uniqueKey: ["sales_order_id", "sales_order_detail_id"]
   }
   ```

2. **NOT NULL Checks**
   ```sql
   assertions: {
     nonNull: ["order_date_key", "customer_key", "product_key"]
   }
   ```

3. **WHERE Clause Filters**
   - Required field validation
   - Status filters (e.g., completed orders only)
   - Date range validations

4. **COALESCE for Missing References**
   ```sql
   COALESCE(dc.customer_key, -1) AS customer_key
   ```
   - Uses -1 for missing dimension records
   - Prevents broken foreign key references

## Common Patterns

### Pattern 1: Date Key Generation
```sql
CAST(FORMAT_DATE('%Y%m%d', date_column) AS INT64) AS date_key
```

### Pattern 2: SCD Type 2 Lookup
```sql
LEFT JOIN ${ref('dim_product')} dp
  ON source.ProductID = dp.product_id
  AND dp.is_current = TRUE
  AND source.OrderDate BETWEEN dp.effective_start_date 
    AND COALESCE(dp.effective_end_date, DATE('9999-12-31'))
```

### Pattern 3: Safe Division
```sql
SAFE_DIVIDE(numerator, NULLIF(denominator, 0))
```

### Pattern 4: Percentage Calculation
```sql
CAST(
  SAFE_DIVIDE(value, NULLIF(total, 0)) * 100
  AS NUMERIC(10,2)
) AS percentage
```

## Troubleshooting

### Common Issues

**Issue: "Table not found" errors**
- **Solution:** Ensure dimension tables are created first
- **Check:** Verify `dependencies` in config block
- **Fix:** Run dimensions before facts

**Issue: "Column not found" errors**
- **Solution:** Check source table schema
- **Verify:** Source table names match your BigQuery dataset
- **Update:** Modify ${ref('...')} to match your source tables

**Issue: "NULL dimension keys"**
- **Solution:** Check for missing dimension records
- **Create:** "Unknown" dimension records with key = -1
- **Verify:** COALESCE logic is correct

**Issue: "Partition errors"**
- **Solution:** Ensure date columns are valid
- **Check:** No NULL dates in partitioning column
- **Filter:** Add WHERE clause to exclude NULL dates

## Next Steps

### Immediate Actions
1. ✅ **Review code** - Understand the transformation logic
2. ✅ **Update source references** - Match your BigQuery dataset/table names
3. ✅ **Create dimension tables** - Build all 15 dimensions first
4. ✅ **Test individual facts** - Run one at a time initially
5. ✅ **Validate results** - Check row counts and measure values

### Phase 4 Preparation
After facts are loaded:
- ✅ Create LookML views for each fact table
- ✅ Define explores with proper joins
- ✅ Build business-friendly metrics
- ✅ Create dashboards for analysis

## Sample Queries

### Query fct_sales
```sql
SELECT 
  d.year,
  p.product_category_name,
  SUM(f.line_total) as total_sales,
  SUM(f.gross_profit) as total_profit,
  COUNT(DISTINCT f.sales_order_id) as order_count
FROM adventure_works.fct_sales f
INNER JOIN adventure_works.dim_date d 
  ON f.order_date_key = d.date_key
INNER JOIN adventure_works.dim_product p 
  ON f.product_key = p.product_key
WHERE d.year = 2023
GROUP BY d.year, p.product_category_name
ORDER BY total_sales DESC;
```

### Query fct_product_inventory
```sql
SELECT 
  p.product_name,
  l.location_name,
  f.quantity_on_hand,
  f.inventory_value,
  f.below_reorder_point,
  f.inventory_status
FROM adventure_works.fct_product_inventory f
INNER JOIN adventure_works.dim_product p 
  ON f.product_key = p.product_key
INNER JOIN adventure_works.dim_location l 
  ON f.location_key = l.location_key
WHERE f.below_reorder_point = TRUE
ORDER BY f.quantity_on_hand;
```

## Summary Statistics

| Metric | Value |
|--------|-------|
| **Fact Tables Created** | 5 |
| **Total SQL Lines** | ~1,500+ |
| **Dependencies Managed** | 15 dimensions |
| **Calculated Measures** | 40+ |
| **Business Rules** | 30+ |
| **Data Quality Checks** | 20+ |

## Support & Resources

- **Phase 1:** Star schema design (`phase_1/schema.txt`)
- **Phase 2:** Source-to-target mappings (`phase_2/stt.md`)
- **Dataform Docs:** https://cloud.google.com/dataform/docs
- **BigQuery Best Practices:** https://cloud.google.com/bigquery/docs/best-practices

---

**Status:** ✅ Phase 3 Fact Tables Complete  
**Next Phase:** Phase 4 - LookML Semantic Layer  
**Created:** October 14, 2025

