# Dataform Deployment Strategy - POC

## Environment

**Single Environment:** Development only

### BigQuery Dataset Naming
```
dna-team-day-2025.adventure_works_dev
```

## Repository Structure

```
dataform/
├── definitions/
│   ├── dimensions/
│   │   ├── dim_date.sqlx
│   │   ├── dim_product.sqlx
│   │   └── ... (13 more)
│   ├── facts/
│   │   ├── fct_sales.sqlx
│   │   ├── fct_product_inventory.sqlx
│   │   ├── fct_purchases.sqlx
│   │   ├── fct_work_orders.sqlx
│   │   └── fct_product_reviews.sqlx
│   ├── staging/
│   │   └── stg_*.sqlx
│   └── assertions/
│       └── data_quality_*.sqlx
├── includes/
│   ├── constants.js
│   └── helpers.js
├── dataform.json
├── package.json
└── .workflow_settings.yaml
```

## Configuration Files

### dataform.json
```json
{
  "warehouse": "bigquery",
  "defaultProject": "dna-team-day-2025",
  "defaultDataset": "adventure_works_dev",
  "defaultLocation": "US",
  "vars": {
    "source_project": "dna-team-day-2025",
    "source_dataset": "adventure_works_source"
  }
}
```

### .workflow_settings.yaml (Optional)
```yaml
defaultProject: dna-team-day-2025
defaultDataset: adventure_works_dev
defaultLocation: US
```

## Quick Start Deployment

### 1. Setup Dataform Workspace

In Google Cloud Console:
1. Navigate to Dataform
2. Create repository: `team-4-dev`
3. Connect to source control (optional for POC)

### 2. Upload SQLX Files

```
definitions/
├── dimensions/
│   └── (dimension files - create as needed)
└── facts/
    ├── fct_sales.sqlx
    ├── fct_product_inventory.sqlx
    ├── fct_purchases.sqlx
    ├── fct_work_orders.sqlx
    └── fct_product_reviews.sqlx
```

### 3. Update Source References

In each SQLX file, update source table references:
```sql
-- Replace this:
FROM ${ref('Sales_SalesOrderDetail')}

-- With your actual table:
FROM `dna-team-day-2025.adventure_works_source.Sales_SalesOrderDetail`
```

### 4. Deploy

**In Dataform UI:**
1. Click "Start execution"
2. Select "All actions" or specific tables
3. Click "Start"

**Via CLI:**
```bash
# Compile
dataform compile

# Run all
dataform run

# Run specific table
dataform run --actions adventure_works_dev.fct_sales

# Run dimensions first, then facts
dataform run --tags dimension
dataform run --tags fact
```

## Refresh Strategy

### For POC: Full Refresh Only

All tables use full refresh on-demand:
```sql
config {
  type: "table"
}
```

**When to refresh:**
- On-demand via UI or CLI
- After source data updates
- When testing changes

## Version Control (Optional)

For POC, manual deployment via UI is sufficient.

If using Git:
```bash
# Initialize repo
git init
git add .
git commit -m "initial dataform setup"

# Push to remote
git remote add origin <repo-url>
git push -u origin main
```

## Validation

### Post-Deployment Checks

**Row Count Validation:**
```sql
SELECT 
  table_name,
  row_count,
  TIMESTAMP_MILLIS(creation_time) as created
FROM `dna-team-day-2025.adventure_works_dev.__TABLES__`
WHERE table_name LIKE 'fct_%'
ORDER BY table_name
```

**Sample Data Check:**
```sql
-- Verify fct_sales
SELECT 
  COUNT(*) as row_count,
  MIN(order_date_key) as min_date,
  MAX(order_date_key) as max_date,
  SUM(line_total) as total_sales
FROM `dna-team-day-2025.adventure_works_dev.fct_sales`
```

## Rollback

### Time-Travel Restore (< 7 days)

```sql
CREATE OR REPLACE TABLE `dna-team-day-2025.adventure_works_dev.fct_sales`
AS SELECT * FROM `dna-team-day-2025.adventure_works_dev.fct_sales`
FOR SYSTEM_TIME AS OF TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR);
```

### Full Rebuild

```bash
# Drop table
bq rm -f -t dna-team-day-2025.adventure_works_dev.fct_sales

# Rerun in Dataform UI or CLI
dataform run --actions adventure_works_dev.fct_sales
```

## Monitoring

### Check Recent Jobs

```sql
SELECT
  job_id,
  user_email,
  state,
  error_result.message as error,
  TIMESTAMP_DIFF(end_time, start_time, SECOND) as runtime_seconds
FROM `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
WHERE creation_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 2 HOUR)
  AND statement_type IN ('CREATE_TABLE', 'INSERT')
ORDER BY creation_time DESC
LIMIT 20
```

## Performance Notes

All fact tables already include:
- Partitioning on date columns
- Clustering on commonly filtered dimensions
- Efficient CTEs and joins

For POC, performance is adequate as-is.

## Troubleshooting

**Table not found:**
- Check source table references in SQLX files
- Verify source dataset exists and has data

**Permission denied:**
- Verify you have BigQuery Data Editor role
- Check service account has bigquery.jobs.create permission

**Compilation errors:**
- Check SQL syntax
- Verify all ${ref()} references are valid
- Ensure dependencies exist

**Query fails:**
- Check Dataform execution logs
- Review BigQuery job logs
- Validate source data exists

