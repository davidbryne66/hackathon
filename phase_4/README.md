# Phase 4: Looker LookML Semantic Layer

## Problem Statement

Data in BigQuery is structured for storage efficiency, not business user understanding. Tables use technical names, relationships are implicit, and business logic is scattered. **Goal:** Create a semantic layer that translates technical schema into business-friendly dimensions and measures that enable self-service analytics.

---

## Deliverable

A LookML project that:
- Defines business-friendly views for all fact and dimension tables
- Creates explores with proper joins for analytical queries
- Enables users to analyze sales, inventory, reviews, purchasing, and manufacturing
- Provides clear dimension and measure definitions with descriptions
- Works with Phase 5's natural language interface

**Technical Requirements:**
- LookML views for 5 fact tables and 14 dimension tables
- 5 explores covering major business areas
- Proper relationships and join logic
- Field descriptions optimized for AI understanding

---

## Solution

### Architecture

```
BigQuery Tables (Phase 3)
    ↓
LookML Views (Field Definitions)
    ↓
LookML Explores (Joins & Relationships)
    ↓
Looker API (Query Interface)
    ↓
Phase 5 Application
```

### Files Created

**Model File:**
- `adventure_works.model.lkml` - Main model with connection and explore definitions

**View Files (19 total):**

**Fact Tables (5):**
1. `fct_sales.view.lkml` - Sales transactions (121K rows)
2. `fct_product_reviews.view.lkml` - Customer reviews (4 rows)
3. `fct_product_inventory.view.lkml` - Stock levels (~1K rows)
4. `fct_purchases.view.lkml` - Purchase orders (~8K rows)
5. `fct_work_orders.view.lkml` - Manufacturing orders (~72K rows)

**Dimension Tables (14):**
1. `dim_product.view.lkml` - Products, categories, subcategories
2. `dim_customer.view.lkml` - Customer information
3. `dim_date.view.lkml` - Date dimension (2011-2014)
4. `dim_territory.view.lkml` - Sales territories
5. `dim_salesperson.view.lkml` - Sales representatives
6. `dim_location.view.lkml` - Warehouses/facilities
7. `dim_vendor.view.lkml` - Suppliers
8. `dim_employee.view.lkml` - Employees
9. `dim_ship_method.view.lkml` - Shipping methods
10. `dim_special_offer.view.lkml` - Promotions
11. `dim_credit_card.view.lkml` - Payment methods
12. `dim_currency.view.lkml` - Currency codes
13. `dim_address.view.lkml` - Locations
14. `dim_scrap_reason.view.lkml` - Manufacturing issues

### Explores Implemented

**1. Sales Analysis**
- Fact: fct_sales
- Joins: Product, Customer, Territory, Date, Salesperson, Ship Method, Special Offer, Credit Card, Currency, Address
- Use: Revenue analysis, product performance, customer behavior

**2. Product Reviews**
- Fact: fct_product_reviews
- Joins: Product, Date
- Use: Customer sentiment, product ratings

**3. Inventory Analysis**
- Fact: fct_product_inventory
- Joins: Product, Location
- Use: Stock levels, warehouse management

**4. Purchasing Analysis**
- Fact: fct_purchases
- Joins: Product, Vendor, Employee, Ship Method, Date
- Use: Vendor performance, procurement metrics

**5. Manufacturing Analysis**
- Fact: fct_work_orders
- Joins: Product, Location, Scrap Reason, Date
- Use: Production efficiency, quality metrics

### Key Design Decisions

**1. Business-Friendly Labels**
- Technical: `product_key` → Label: "Product Key"
- Technical: `order_quantity` → Label: "Order Quantity"
- All fields have clear descriptions

**2. Hidden Foreign Keys**
- Foreign key dimensions marked as `hidden: yes`
- Users see joined dimension fields, not raw keys
- Cleaner field picker in Looker UI

**3. Comprehensive Measures**
- Totals (sum): `total_sales_amount`, `total_inventory`
- Counts: `order_count`, `review_count`
- Averages: `average_rating`, `average_order_value`
- Ratios: `scrap_rate`

**4. Descriptive Fields**
- Every dimension and measure has a description
- Optimized for LLM understanding (Phase 5)
- Business terminology over technical jargon

**5. Drill Fields**
- Natural drill paths defined (category → subcategory → product)
- Enables exploratory analysis in Looker

### Example Field Definitions

**Dimension Example:**
```lkml
dimension: product_name {
  type: string
  label: "Product Name"
  description: "Full product name"
  sql: ${TABLE}.product_name ;;
  link: {
    label: "Product Dashboard"
    url: "/dashboards/product?product={{ value }}"
  }
}
```

**Measure Example:**
```lkml
measure: total_sales_amount {
  type: sum
  label: "Total Sales Amount"
  description: "Total sales amount for all line items."
  sql: ${TABLE}.line_total ;;
  value_format_name: usd
}
```

**Join Example:**
```lkml
join: dim_product {
  type: left_outer
  sql_on: ${fct_sales.product_key} = ${dim_product.product_key} ;;
  relationship: many_to_one
}
```

---

## Deployment

### Prerequisites
- BigQuery tables created (Phase 3)
- Looker instance with admin access
- BigQuery connection configured in Looker

### Steps

1. **Create Looker Project:**
   - Navigate to Develop → Projects
   - Create new project: "adventure_works"
   - Enable development mode

2. **Upload LookML Files:**
   - Copy all files from `lookml/` directory
   - Maintain structure: model file + views/ folder
   - Commit changes

3. **Configure Connection:**
   - Update `adventure_works.model.lkml`
   - Set connection name to your BigQuery connection
   - Example: `connection: "teamday2025_team4"`

4. **Validate:**
   - Run LookML validator
   - Test each explore with sample queries
   - Verify all joins work correctly

5. **Deploy to Production:**
   - Commit to Git
   - Deploy to production branch
   - Enable for all users

**See `lookml/README.md` for detailed deployment instructions.**

---

## Field Catalog

### Sales Analysis Fields

**Dimensions:**
- Product: category_name, subcategory_name, product_name
- Customer: customer_name, customer_type, city, state, country
- Territory: territory_name, country_region_name
- Date: year, quarter, month_name, day_name
- Salesperson: salesperson_name

**Measures:**
- total_sales_amount (Revenue)
- order_count (Number of orders)
- average_order_value
- total_gross_profit

### Inventory Analysis Fields

**Dimensions:**
- Product: product_name, category_name
- Location: location_name
- Stock Status: Out of Stock, Low Stock, Medium Stock, Well Stocked

**Measures:**
- total_inventory (Quantity on hand)
- out_of_stock_count
- low_stock_count

### Product Reviews Fields

**Dimensions:**
- Product: product_name, category_name
- Reviewer: reviewer_name, sentiment

**Measures:**
- average_rating (1-5 stars)
- review_count

**Full catalog available in Phase 5's `gemini_client.py`**

---

## Validation

### Tests Performed

**1. Explore Functionality**
- ✅ All 5 explores load without errors
- ✅ Joins execute correctly
- ✅ Field picker shows all dimensions/measures
- ✅ No orphaned fields

**2. Query Execution**
- ✅ Sample queries run successfully
- ✅ Aggregations calculate correctly
- ✅ Filters work as expected
- ✅ Sorts function properly

**3. Data Accuracy**
- ✅ Measure totals match source tables
- ✅ Dimension values correct
- ✅ Join cardinality appropriate
- ✅ No duplicate records

**4. Integration Testing**
- ✅ Looker API accessible
- ✅ Phase 5 can query explores
- ✅ Field names match catalog
- ✅ All data types compatible

---

## Troubleshooting

### "Unknown database connection"
- Update `adventure_works.model.lkml` with your connection name
- Verify connection exists in Looker: Admin → Connections
- Check connection has access to BigQuery dataset

### "Field not found"
- Verify table exists in BigQuery
- Check field name spelling in LookML
- Confirm dataset permissions

### "Join produces unexpected results"
- Review join type (left_outer vs inner)
- Check relationship (many_to_one vs one_to_one)
- Verify key fields have proper data

### "Explore not visible"
- Check LookML validator for errors
- Ensure explores are defined in model file
- Verify user permissions

---

## Best Practices Applied

**1. Naming Conventions**
- Snake_case for field names
- Clear, descriptive labels
- Business terminology in descriptions

**2. Performance**
- Primary keys defined for caching
- Appropriate join types (left_outer where needed)
- Hidden unnecessary fields

**3. Maintainability**
- One view per table
- Organized by explore area
- Comments for complex logic

**4. User Experience**
- Drill fields for exploration
- Value formatting (USD, percentages)
- Helpful descriptions

**5. AI Integration**
- Descriptive field labels for LLM understanding
- Complete measure definitions
- Clear dimension groupings

---

## Success Metrics

**Completeness:**
- ✅ 19 views created (5 facts, 14 dimensions)
- ✅ 5 explores covering all business areas
- ✅ 100+ dimensions defined
- ✅ 30+ measures defined

**Quality:**
- ✅ All fields have descriptions
- ✅ Proper data types assigned
- ✅ Value formatting applied
- ✅ Zero LookML validation errors

**Integration:**
- ✅ Phase 5 can query all explores
- ✅ Natural language queries work
- ✅ Field catalog complete
- ✅ API accessible

---

## File Structure

```
phase_4/
├── lookml/
│   ├── adventure_works.model.lkml    # Main model file
│   ├── views/
│   │   ├── fct_sales.view.lkml       # Fact tables (5)
│   │   ├── fct_product_reviews.view.lkml
│   │   ├── fct_product_inventory.view.lkml
│   │   ├── fct_purchases.view.lkml
│   │   ├── fct_work_orders.view.lkml
│   │   ├── dim_product.view.lkml     # Dimensions (14)
│   │   ├── dim_customer.view.lkml
│   │   ├── dim_date.view.lkml
│   │   ├── dim_territory.view.lkml
│   │   ├── dim_salesperson.view.lkml
│   │   ├── dim_location.view.lkml
│   │   ├── dim_vendor.view.lkml
│   │   ├── dim_employee.view.lkml
│   │   ├── dim_ship_method.view.lkml
│   │   ├── dim_special_offer.view.lkml
│   │   ├── dim_credit_card.view.lkml
│   │   ├── dim_currency.view.lkml
│   │   ├── dim_address.view.lkml
│   │   └── dim_scrap_reason.view.lkml
│   └── README.md                      # Deployment instructions
├── README.md                          # This file
└── prompt.txt                         # Build instructions
```

---

## Learning Resources

- **LookML Docs:** https://cloud.google.com/looker/docs/lookml-intro
- **View Files:** https://cloud.google.com/looker/docs/reference/param-view
- **Explores:** https://cloud.google.com/looker/docs/reference/param-explore
- **Best Practices:** https://cloud.google.com/looker/docs/best-practices

---

## Status

**Phase 4:** ✅ Complete  
**LookML Files:** 20 (1 model + 19 views)  
**Explores:** 5  
**Deployment:** Ready for Looker  
**Integration:** Phase 5 compatible

---

**Built for the Adventure Works AI Hackathon**

*Semantic layer enabling self-service analytics*

