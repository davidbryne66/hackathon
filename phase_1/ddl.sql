-- =====================================================================================
-- ADVENTURE WORKS - BIGQUERY DDL SCRIPTS
-- =====================================================================================
-- Dimensional Model: Star Schema for Sales & Product Performance Analytics
-- Target Platform: Google BigQuery
-- Date: October 14, 2025
-- =====================================================================================

-- Note: BigQuery doesn't enforce primary key or foreign key constraints, but we
-- document them as comments for clarity and documentation purposes.

-- =====================================================================================
-- DIMENSION TABLES
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- DIM_DATE - Date Dimension (Role-Playing)
-- -------------------------------------------------------------------------------------
-- Purpose: Time dimension for all date-based analysis
-- Grain: One row per day
-- Type: Conformed dimension used across all fact tables
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.dim_date` (
  -- Primary Key
  date_key INT64 NOT NULL, -- Surrogate key (format: YYYYMMDD, e.g., 20250101)
  
  -- Date Attributes
  full_date DATE NOT NULL,
  day_of_week INT64,
  day_of_month INT64,
  day_of_year INT64,
  day_name STRING,
  day_name_short STRING,
  
  -- Week Attributes
  week_of_year INT64,
  week_of_month INT64,
  
  -- Month Attributes
  month_number INT64,
  month_name STRING,
  month_name_short STRING,
  first_day_of_month DATE,
  last_day_of_month DATE,
  
  -- Quarter Attributes
  quarter INT64,
  quarter_name STRING,
  first_day_of_quarter DATE,
  last_day_of_quarter DATE,
  
  -- Year Attributes
  year INT64,
  
  -- Fiscal Period Attributes (assuming fiscal year starts July 1)
  fiscal_year INT64,
  fiscal_quarter INT64,
  fiscal_month INT64,
  
  -- Special Day Flags
  is_weekend BOOL,
  is_holiday BOOL,
  holiday_name STRING,
  is_weekday BOOL,
  
  -- Relative Period Helpers
  is_current_day BOOL,
  is_current_month BOOL,
  is_current_quarter BOOL,
  is_current_year BOOL,
  
  -- Audit Fields
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
PARTITION BY full_date
CLUSTER BY year, quarter, month_number
OPTIONS(
  description="Date dimension table for time-based analysis. Role-playing dimension used for order_date, ship_date, due_date, etc.",
  labels=[("domain", "dimension"), ("type", "conformed")]
);


-- -------------------------------------------------------------------------------------
-- DIM_PRODUCT - Product Dimension with Category Hierarchy
-- -------------------------------------------------------------------------------------
-- Purpose: Product master with category hierarchy
-- Grain: One row per product per version
-- Type: Slowly Changing Dimension Type 2
-- Hierarchy: Product → Subcategory → Category
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.dim_product` (
  -- Primary Key
  product_key INT64 NOT NULL, -- Surrogate key
  
  -- Natural Key
  product_id INT64 NOT NULL, -- Business key from source system
  
  -- Product Attributes
  product_name STRING NOT NULL,
  product_number STRING,
  color STRING,
  size STRING,
  size_unit_measure_code STRING,
  weight FLOAT64,
  weight_unit_measure_code STRING,
  standard_cost NUMERIC(19, 4),
  list_price NUMERIC(19, 4),
  
  -- Product Classification
  product_line STRING, -- R=Road, M=Mountain, T=Touring, S=Standard
  product_class STRING, -- H=High, M=Medium, L=Low
  product_style STRING, -- W=Women, M=Men, U=Universal
  
  -- Manufacturing Attributes
  days_to_manufacture INT64,
  make_flag BOOL,
  finished_goods_flag BOOL,
  
  -- Product Dates
  sell_start_date DATE,
  sell_end_date DATE,
  discontinued_date DATE,
  
  -- Category Hierarchy - Subcategory Level
  product_subcategory_id INT64,
  product_subcategory_name STRING,
  
  -- Category Hierarchy - Category Level
  product_category_id INT64,
  product_category_name STRING,
  
  -- Model Attributes
  product_model_id INT64,
  product_model_name STRING,
  
  -- Derived/Calculated Attributes
  profit_margin NUMERIC(5, 4), -- (list_price - standard_cost) / list_price
  is_active BOOL, -- Based on sell dates
  price_category STRING, -- Economy, Standard, Premium (derived from list_price)
  
  -- SCD Type 2 Attributes
  effective_start_date DATE NOT NULL,
  effective_end_date DATE, -- NULL for current record
  is_current BOOL NOT NULL,
  version_number INT64,
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
CLUSTER BY product_category_name, product_subcategory_name, is_current
OPTIONS(
  description="Product dimension with category hierarchy. SCD Type 2 for tracking product attribute changes over time.",
  labels=[("domain", "dimension"), ("scd_type", "2"), ("type", "conformed")]
);


-- -------------------------------------------------------------------------------------
-- DIM_CUSTOMER - Customer Dimension
-- -------------------------------------------------------------------------------------
-- Purpose: Customer master with demographic information
-- Grain: One row per customer per version
-- Type: Slowly Changing Dimension Type 2
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.dim_customer` (
  -- Primary Key
  customer_key INT64 NOT NULL, -- Surrogate key
  
  -- Natural Key
  customer_id INT64 NOT NULL, -- Business key from source system
  
  -- Customer Attributes
  account_number STRING,
  customer_type STRING, -- 'Individual' or 'Store'
  
  -- Individual Customer Attributes
  person_id INT64,
  person_type STRING, -- SC=Store Contact, IN=Individual, etc.
  title STRING,
  first_name STRING,
  middle_name STRING,
  last_name STRING,
  full_name STRING, -- Calculated: first + middle + last
  suffix STRING,
  email_promotion_preference INT64, -- 0=No email, 1=Adventure Works, 2=Partners too
  
  -- Store Customer Attributes
  store_id INT64,
  store_name STRING,
  store_salesperson_id INT64,
  
  -- Demographics (from XML parsing if available)
  total_purchases NUMERIC(19, 2),
  yearly_income STRING,
  
  -- Customer Segmentation (derived)
  customer_segment STRING, -- High Value, Medium Value, Low Value, New
  
  -- SCD Type 2 Attributes
  effective_start_date DATE NOT NULL,
  effective_end_date DATE, -- NULL for current record
  is_current BOOL NOT NULL,
  version_number INT64,
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
CLUSTER BY customer_type, is_current
OPTIONS(
  description="Customer dimension with individual and store customer information. SCD Type 2 for tracking customer changes.",
  labels=[("domain", "dimension"), ("scd_type", "2"), ("type", "conformed")]
);


-- -------------------------------------------------------------------------------------
-- DIM_TERRITORY - Sales Territory Dimension
-- -------------------------------------------------------------------------------------
-- Purpose: Sales territory hierarchy and performance
-- Grain: One row per territory
-- Type: Slowly Changing Dimension Type 1
-- Hierarchy: Territory → Country → Group (Continent)
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.dim_territory` (
  -- Primary Key
  territory_key INT64 NOT NULL, -- Surrogate key
  
  -- Natural Key
  territory_id INT64 NOT NULL, -- Business key from source system
  
  -- Territory Attributes
  territory_name STRING NOT NULL,
  country_region_code STRING,
  country_region_name STRING,
  territory_group STRING, -- North America, Europe, Pacific
  
  -- Performance Metrics (Type 1 - overwritten)
  sales_ytd NUMERIC(19, 4),
  sales_last_year NUMERIC(19, 4),
  cost_ytd NUMERIC(19, 4),
  cost_last_year NUMERIC(19, 4),
  
  -- Derived Attributes
  sales_growth_pct NUMERIC(10, 2), -- (sales_ytd - sales_last_year) / sales_last_year * 100
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
CLUSTER BY territory_group, country_region_code
OPTIONS(
  description="Sales territory dimension with geographic hierarchy. SCD Type 1 for current state only.",
  labels=[("domain", "dimension"), ("scd_type", "1"), ("type", "conformed")]
);


-- -------------------------------------------------------------------------------------
-- DIM_SALESPERSON - Sales Representative Dimension
-- -------------------------------------------------------------------------------------
-- Purpose: Sales representative information and performance
-- Grain: One row per salesperson per version
-- Type: Slowly Changing Dimension Type 2
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.dim_salesperson` (
  -- Primary Key
  salesperson_key INT64 NOT NULL, -- Surrogate key
  
  -- Natural Key
  business_entity_id INT64 NOT NULL, -- Business key from source system
  
  -- Employee Attributes
  national_id_number STRING,
  login_id STRING,
  job_title STRING,
  birth_date DATE,
  marital_status STRING, -- M=Married, S=Single
  gender STRING, -- M=Male, F=Female
  hire_date DATE,
  
  -- Employment Status
  salaried_flag BOOL,
  vacation_hours INT64,
  sick_leave_hours INT64,
  current_flag BOOL,
  
  -- Person Attributes
  first_name STRING,
  middle_name STRING,
  last_name STRING,
  full_name STRING, -- Calculated
  
  -- Sales Performance Attributes
  sales_quota NUMERIC(19, 4),
  bonus NUMERIC(19, 4),
  commission_pct NUMERIC(5, 4),
  sales_ytd NUMERIC(19, 4),
  sales_last_year NUMERIC(19, 4),
  
  -- Derived Attributes
  tenure_years INT64, -- Calculated from hire_date
  age INT64, -- Calculated from birth_date
  quota_attainment_pct NUMERIC(10, 2), -- (sales_ytd / sales_quota) * 100
  
  -- SCD Type 2 Attributes
  effective_start_date DATE NOT NULL,
  effective_end_date DATE, -- NULL for current record
  is_current BOOL NOT NULL,
  version_number INT64,
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
CLUSTER BY is_current, current_flag
OPTIONS(
  description="Salesperson dimension with employee and performance information. SCD Type 2 for tracking changes.",
  labels=[("domain", "dimension"), ("scd_type", "2"), ("type", "conformed")]
);


-- -------------------------------------------------------------------------------------
-- DIM_STORE - Retail Store Dimension
-- -------------------------------------------------------------------------------------
-- Purpose: Retail store information
-- Grain: One row per store per version
-- Type: Slowly Changing Dimension Type 2
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.dim_store` (
  -- Primary Key
  store_key INT64 NOT NULL, -- Surrogate key
  
  -- Natural Key
  business_entity_id INT64 NOT NULL, -- Business key from source system
  
  -- Store Attributes
  store_name STRING NOT NULL,
  salesperson_id INT64,
  demographics STRING, -- XML data (may need parsing)
  
  -- Parsed Demographics (if available)
  annual_sales NUMERIC(19, 2),
  annual_revenue NUMERIC(19, 2),
  bank_name STRING,
  business_type STRING,
  number_employees INT64,
  specialty STRING,
  square_feet INT64,
  
  -- SCD Type 2 Attributes
  effective_start_date DATE NOT NULL,
  effective_end_date DATE, -- NULL for current record
  is_current BOOL NOT NULL,
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
CLUSTER BY is_current
OPTIONS(
  description="Store dimension for retail store customers. SCD Type 2 for tracking changes.",
  labels=[("domain", "dimension"), ("scd_type", "2")]
);


-- -------------------------------------------------------------------------------------
-- DIM_ADDRESS - Address Dimension
-- -------------------------------------------------------------------------------------
-- Purpose: Address information for shipping and billing
-- Grain: One row per address
-- Type: Slowly Changing Dimension Type 1
-- Note: Role-playing dimension (bill_to_address, ship_to_address)
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.dim_address` (
  -- Primary Key
  address_key INT64 NOT NULL, -- Surrogate key
  
  -- Natural Key
  address_id INT64 NOT NULL, -- Business key from source system
  
  -- Address Attributes
  address_line_1 STRING,
  address_line_2 STRING,
  city STRING,
  postal_code STRING,
  spatial_location GEOGRAPHY, -- Geographic point
  
  -- State/Province Attributes
  state_province_id INT64,
  state_province_code STRING,
  state_province_name STRING,
  is_only_state_province_flag BOOL,
  
  -- Country Attributes
  country_region_code STRING,
  country_region_name STRING,
  
  -- Territory Link
  territory_id INT64, -- For geographic rollup to territory
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
CLUSTER BY country_region_code, state_province_code
OPTIONS(
  description="Address dimension for billing and shipping. Role-playing dimension (bill_to, ship_to).",
  labels=[("domain", "dimension"), ("scd_type", "1"), ("type", "role_playing")]
);


-- -------------------------------------------------------------------------------------
-- DIM_SHIP_METHOD - Shipping Method Dimension
-- -------------------------------------------------------------------------------------
-- Purpose: Shipping method details and costs
-- Grain: One row per shipping method
-- Type: Slowly Changing Dimension Type 1
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.dim_ship_method` (
  -- Primary Key
  ship_method_key INT64 NOT NULL, -- Surrogate key
  
  -- Natural Key
  ship_method_id INT64 NOT NULL, -- Business key from source system
  
  -- Ship Method Attributes
  ship_method_name STRING NOT NULL,
  ship_base_cost NUMERIC(19, 4),
  ship_rate NUMERIC(19, 4),
  
  -- Derived Attributes
  is_express BOOL, -- Derived from name
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
OPTIONS(
  description="Shipping method dimension with cost information.",
  labels=[("domain", "dimension"), ("scd_type", "1")]
);


-- -------------------------------------------------------------------------------------
-- DIM_SPECIAL_OFFER - Special Offer/Promotion Dimension
-- -------------------------------------------------------------------------------------
-- Purpose: Promotions and discounts
-- Grain: One row per special offer per version
-- Type: Slowly Changing Dimension Type 2
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.dim_special_offer` (
  -- Primary Key
  special_offer_key INT64 NOT NULL, -- Surrogate key
  
  -- Natural Key
  special_offer_id INT64 NOT NULL, -- Business key from source system
  
  -- Offer Attributes
  description STRING,
  discount_percent NUMERIC(5, 4),
  offer_type STRING,
  category STRING,
  start_date DATE,
  end_date DATE,
  min_quantity INT64,
  max_quantity INT64,
  
  -- Derived Attributes
  is_active BOOL, -- Based on current date between start and end
  offer_duration_days INT64, -- end_date - start_date
  
  -- SCD Type 2 Attributes
  effective_start_date DATE NOT NULL,
  effective_end_date DATE, -- NULL for current record
  is_current BOOL NOT NULL,
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
CLUSTER BY is_current, category
OPTIONS(
  description="Special offer dimension for promotions and discounts. SCD Type 2 for tracking offer changes.",
  labels=[("domain", "dimension"), ("scd_type", "2")]
);


-- -------------------------------------------------------------------------------------
-- DIM_CREDIT_CARD - Credit Card Dimension
-- -------------------------------------------------------------------------------------
-- Purpose: Payment method information
-- Grain: One row per credit card
-- Type: Slowly Changing Dimension Type 1
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.dim_credit_card` (
  -- Primary Key
  credit_card_key INT64 NOT NULL, -- Surrogate key
  
  -- Natural Key
  credit_card_id INT64 NOT NULL, -- Business key from source system
  
  -- Credit Card Attributes
  card_type STRING,
  card_number_masked STRING, -- Only last 4 digits shown (e.g., ****1234)
  expiration_month INT64,
  expiration_year INT64,
  
  -- Derived Attributes
  is_expired BOOL, -- Based on current date vs expiration
  card_bin STRING, -- First 6 digits (if available)
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
CLUSTER BY card_type
OPTIONS(
  description="Credit card dimension for payment method analysis.",
  labels=[("domain", "dimension"), ("scd_type", "1")]
);


-- -------------------------------------------------------------------------------------
-- DIM_CURRENCY - Currency Dimension
-- -------------------------------------------------------------------------------------
-- Purpose: Currency information for international sales
-- Grain: One row per currency
-- Type: Slowly Changing Dimension Type 1
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.dim_currency` (
  -- Primary Key
  currency_key INT64 NOT NULL, -- Surrogate key
  
  -- Natural Key
  currency_code STRING NOT NULL, -- Business key (ISO code: USD, EUR, CAD, etc.)
  
  -- Currency Attributes
  currency_name STRING NOT NULL,
  symbol STRING, -- $, €, £, etc.
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
OPTIONS(
  description="Currency dimension for international sales analysis.",
  labels=[("domain", "dimension"), ("scd_type", "1"), ("type", "conformed")]
);


-- -------------------------------------------------------------------------------------
-- DIM_VENDOR - Vendor/Supplier Dimension
-- -------------------------------------------------------------------------------------
-- Purpose: Supplier/vendor information
-- Grain: One row per vendor per version
-- Type: Slowly Changing Dimension Type 2
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.dim_vendor` (
  -- Primary Key
  vendor_key INT64 NOT NULL, -- Surrogate key
  
  -- Natural Key
  business_entity_id INT64 NOT NULL, -- Business key from source system
  
  -- Vendor Attributes
  account_number STRING,
  vendor_name STRING NOT NULL,
  credit_rating INT64, -- 1-5 scale
  preferred_vendor_status BOOL,
  active_flag BOOL,
  purchasing_web_service_url STRING,
  
  -- Derived Attributes
  vendor_tier STRING, -- Premium, Standard, Basic (derived from credit_rating)
  
  -- SCD Type 2 Attributes
  effective_start_date DATE NOT NULL,
  effective_end_date DATE, -- NULL for current record
  is_current BOOL NOT NULL,
  version_number INT64,
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
CLUSTER BY is_current, credit_rating
OPTIONS(
  description="Vendor dimension for supplier analysis. SCD Type 2 for tracking vendor changes.",
  labels=[("domain", "dimension"), ("scd_type", "2")]
);


-- -------------------------------------------------------------------------------------
-- DIM_EMPLOYEE - Employee Dimension
-- -------------------------------------------------------------------------------------
-- Purpose: Employee master for HR and operational analysis
-- Grain: One row per employee per version
-- Type: Slowly Changing Dimension Type 2
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.dim_employee` (
  -- Primary Key
  employee_key INT64 NOT NULL, -- Surrogate key
  
  -- Natural Key
  business_entity_id INT64 NOT NULL, -- Business key from source system
  
  -- Employee Attributes
  national_id_number STRING,
  login_id STRING,
  organization_node STRING,
  organization_level INT64,
  job_title STRING,
  birth_date DATE,
  marital_status STRING,
  gender STRING,
  hire_date DATE,
  
  -- Employment Status
  salaried_flag BOOL,
  vacation_hours INT64,
  sick_leave_hours INT64,
  current_flag BOOL,
  
  -- Person Attributes
  first_name STRING,
  middle_name STRING,
  last_name STRING,
  full_name STRING, -- Calculated
  
  -- Derived Attributes
  tenure_years INT64, -- Calculated from hire_date
  age INT64, -- Calculated from birth_date
  
  -- SCD Type 2 Attributes
  effective_start_date DATE NOT NULL,
  effective_end_date DATE, -- NULL for current record
  is_current BOOL NOT NULL,
  version_number INT64,
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
CLUSTER BY is_current, job_title
OPTIONS(
  description="Employee dimension for HR and operational analysis. SCD Type 2 for tracking employee changes.",
  labels=[("domain", "dimension"), ("scd_type", "2"), ("type", "conformed")]
);


-- -------------------------------------------------------------------------------------
-- DIM_LOCATION - Manufacturing Location Dimension
-- -------------------------------------------------------------------------------------
-- Purpose: Manufacturing/warehouse locations
-- Grain: One row per location
-- Type: Slowly Changing Dimension Type 1
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.dim_location` (
  -- Primary Key
  location_key INT64 NOT NULL, -- Surrogate key
  
  -- Natural Key
  location_id INT64 NOT NULL, -- Business key from source system
  
  -- Location Attributes
  location_name STRING NOT NULL,
  cost_rate NUMERIC(10, 4), -- Cost per hour
  availability NUMERIC(10, 2), -- Available hours
  
  -- Derived Attributes
  location_type STRING, -- Warehouse, Manufacturing, Distribution (derived)
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
OPTIONS(
  description="Location dimension for manufacturing and warehouse locations.",
  labels=[("domain", "dimension"), ("scd_type", "1")]
);


-- -------------------------------------------------------------------------------------
-- DIM_SCRAP_REASON - Scrap Reason Dimension
-- -------------------------------------------------------------------------------------
-- Purpose: Reasons for scrapped production
-- Grain: One row per scrap reason
-- Type: Slowly Changing Dimension Type 1
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.dim_scrap_reason` (
  -- Primary Key
  scrap_reason_key INT64 NOT NULL, -- Surrogate key
  
  -- Natural Key
  scrap_reason_id INT64 NOT NULL, -- Business key from source system
  
  -- Scrap Reason Attributes
  reason_name STRING NOT NULL,
  reason_category STRING, -- Quality, Damage, Defect, etc. (derived)
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
OPTIONS(
  description="Scrap reason dimension for production quality analysis.",
  labels=[("domain", "dimension"), ("scd_type", "1")]
);


-- =====================================================================================
-- FACT TABLES
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- FCT_SALES - Sales Fact Table (PRIMARY FACT TABLE)
-- -------------------------------------------------------------------------------------
-- Purpose: Captures all sales transactions with associated metrics
-- Grain: One row per order line item (most atomic level)
-- Source: Sales_SalesOrderHeader + Sales_SalesOrderDetail
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.fct_sales` (
  -- Surrogate Key
  sales_order_key INT64 NOT NULL, -- Surrogate key for fact table
  
  -- Foreign Keys to Dimensions (Star Schema Joins)
  order_date_key INT64 NOT NULL, -- FK to dim_date
  ship_date_key INT64, -- FK to dim_date (role-playing)
  due_date_key INT64, -- FK to dim_date (role-playing)
  customer_key INT64 NOT NULL, -- FK to dim_customer
  product_key INT64 NOT NULL, -- FK to dim_product
  territory_key INT64, -- FK to dim_territory
  salesperson_key INT64, -- FK to dim_salesperson
  ship_method_key INT64, -- FK to dim_ship_method
  special_offer_key INT64, -- FK to dim_special_offer
  credit_card_key INT64, -- FK to dim_credit_card
  currency_key INT64, -- FK to dim_currency
  store_key INT64, -- FK to dim_store
  bill_to_address_key INT64, -- FK to dim_address (role-playing)
  ship_to_address_key INT64, -- FK to dim_address (role-playing)
  
  -- Degenerate Dimensions (attributes kept in fact table)
  sales_order_id INT64 NOT NULL, -- Natural key from source
  sales_order_number STRING,
  sales_order_detail_id INT64 NOT NULL,
  purchase_order_number STRING,
  carrier_tracking_number STRING,
  revision_number INT64,
  
  -- Additive Measures (can be summed across any dimension)
  order_quantity INT64 NOT NULL,
  unit_price NUMERIC(19, 4) NOT NULL,
  unit_price_discount NUMERIC(19, 4),
  line_total NUMERIC(19, 4) NOT NULL, -- Extended amount for this line
  subtotal NUMERIC(19, 4), -- Order subtotal (denormalized from header)
  tax_amount NUMERIC(19, 4),
  freight NUMERIC(19, 4),
  total_due NUMERIC(19, 4), -- Total order amount
  
  -- Calculated Measures
  discount_amount NUMERIC(19, 4), -- unit_price * unit_price_discount * order_quantity
  gross_sales NUMERIC(19, 4), -- line_total + discount_amount
  gross_profit NUMERIC(19, 4), -- line_total - (standard_cost * order_quantity)
  profit_margin_pct NUMERIC(10, 2), -- (gross_profit / line_total) * 100
  
  -- Semi-Additive/Non-Additive Measures
  product_standard_cost NUMERIC(19, 4), -- Cost at time of sale (snapshot)
  
  -- Flags (for filtering and segmentation)
  online_order_flag BOOL,
  order_status INT64, -- 1=Pending, 2=Approved, 3=Backordered, 4=Rejected, 5=Shipped, 6=Cancelled
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
PARTITION BY order_date_key
CLUSTER BY customer_key, product_key, territory_key
OPTIONS(
  description="Primary fact table for sales transactions. Grain: One row per order line item. Contains all sales measures and links to dimension tables.",
  labels=[("domain", "fact"), ("grain", "order_line_item"), ("type", "transactional")]
);


-- -------------------------------------------------------------------------------------
-- FCT_PRODUCT_INVENTORY - Product Inventory Snapshot Fact Table
-- -------------------------------------------------------------------------------------
-- Purpose: Track inventory levels over time
-- Grain: Product inventory by location by day (periodic snapshot)
-- Source: Production_ProductInventory
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.fct_product_inventory` (
  -- Surrogate Key
  inventory_snapshot_key INT64 NOT NULL, -- Surrogate key for fact table
  
  -- Foreign Keys to Dimensions
  snapshot_date_key INT64 NOT NULL, -- FK to dim_date
  product_key INT64 NOT NULL, -- FK to dim_product
  location_key INT64 NOT NULL, -- FK to dim_location
  
  -- Degenerate Dimensions
  shelf STRING,
  bin INT64,
  
  -- Semi-Additive Measures (additive across products/locations, not time)
  quantity_on_hand INT64 NOT NULL,
  reorder_point INT64,
  safety_stock_level INT64,
  
  -- Snapshot Context
  unit_cost NUMERIC(19, 4), -- Current cost at snapshot time
  list_price NUMERIC(19, 4), -- Current list price at snapshot time
  
  -- Calculated Measures
  inventory_value NUMERIC(19, 4), -- quantity_on_hand * unit_cost
  days_of_inventory INT64, -- Estimated days until stockout (requires sales velocity)
  below_reorder_point BOOL, -- quantity_on_hand < reorder_point
  below_safety_stock BOOL, -- quantity_on_hand < safety_stock_level
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
PARTITION BY snapshot_date_key
CLUSTER BY product_key, location_key
OPTIONS(
  description="Inventory snapshot fact table. Grain: Product inventory by location by day. Semi-additive measures for inventory tracking.",
  labels=[("domain", "fact"), ("grain", "product_location_day"), ("type", "periodic_snapshot")]
);


-- -------------------------------------------------------------------------------------
-- FCT_PURCHASES - Purchase Order Fact Table
-- -------------------------------------------------------------------------------------
-- Purpose: Analyze purchasing patterns and vendor performance
-- Grain: One row per purchase order line item
-- Source: Purchasing_PurchaseOrderHeader + Purchasing_PurchaseOrderDetail
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.fct_purchases` (
  -- Surrogate Key
  purchase_order_key INT64 NOT NULL, -- Surrogate key for fact table
  
  -- Foreign Keys to Dimensions
  order_date_key INT64 NOT NULL, -- FK to dim_date
  ship_date_key INT64, -- FK to dim_date (role-playing)
  due_date_key INT64, -- FK to dim_date (role-playing)
  product_key INT64 NOT NULL, -- FK to dim_product
  vendor_key INT64 NOT NULL, -- FK to dim_vendor
  employee_key INT64, -- FK to dim_employee (purchasing agent)
  ship_method_key INT64, -- FK to dim_ship_method
  
  -- Degenerate Dimensions
  purchase_order_id INT64 NOT NULL, -- Natural key from source
  purchase_order_detail_id INT64 NOT NULL,
  revision_number INT64,
  
  -- Additive Measures
  order_quantity INT64 NOT NULL,
  unit_price NUMERIC(19, 4) NOT NULL,
  line_total NUMERIC(19, 4) NOT NULL,
  received_quantity NUMERIC(10, 2),
  rejected_quantity NUMERIC(10, 2),
  stocked_quantity NUMERIC(10, 2),
  subtotal NUMERIC(19, 4),
  tax_amount NUMERIC(19, 4),
  freight NUMERIC(19, 4),
  total_due NUMERIC(19, 4),
  
  -- Calculated Measures
  rejected_amount NUMERIC(19, 4), -- (rejected_quantity / order_quantity) * line_total
  acceptance_rate_pct NUMERIC(10, 2), -- (stocked_quantity / received_quantity) * 100
  fulfillment_rate_pct NUMERIC(10, 2), -- (received_quantity / order_quantity) * 100
  
  -- Flags
  order_status INT64, -- 1=Pending, 2=Approved, 3=Rejected, 4=Complete
  is_fully_received BOOL, -- received_quantity >= order_quantity
  has_rejections BOOL, -- rejected_quantity > 0
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
PARTITION BY order_date_key
CLUSTER BY vendor_key, product_key
OPTIONS(
  description="Purchase order fact table. Grain: One row per purchase order line item. Tracks vendor performance and purchasing patterns.",
  labels=[("domain", "fact"), ("grain", "purchase_order_line_item"), ("type", "transactional")]
);


-- -------------------------------------------------------------------------------------
-- FCT_WORK_ORDERS - Work Order Fact Table
-- -------------------------------------------------------------------------------------
-- Purpose: Analyze production efficiency and manufacturing performance
-- Grain: One row per work order
-- Source: Production_WorkOrder + Production_WorkOrderRouting (aggregated)
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.fct_work_orders` (
  -- Surrogate Key
  work_order_key INT64 NOT NULL, -- Surrogate key for fact table
  
  -- Foreign Keys to Dimensions
  product_key INT64 NOT NULL, -- FK to dim_product
  start_date_key INT64, -- FK to dim_date (role-playing)
  end_date_key INT64, -- FK to dim_date (role-playing)
  due_date_key INT64 NOT NULL, -- FK to dim_date (role-playing)
  location_key INT64, -- FK to dim_location (primary location)
  scrap_reason_key INT64, -- FK to dim_scrap_reason
  
  -- Degenerate Dimensions
  work_order_id INT64 NOT NULL, -- Natural key from source
  
  -- Additive Measures
  order_quantity INT64 NOT NULL,
  stocked_quantity INT64,
  scrapped_quantity INT64,
  planned_cost NUMERIC(19, 4),
  actual_cost NUMERIC(19, 4),
  actual_resource_hours NUMERIC(10, 2),
  
  -- Calculated Measures
  cost_variance NUMERIC(19, 4), -- actual_cost - planned_cost
  cost_variance_pct NUMERIC(10, 2), -- (cost_variance / planned_cost) * 100
  scrap_rate_pct NUMERIC(10, 2), -- (scrapped_quantity / order_quantity) * 100
  yield_rate_pct NUMERIC(10, 2), -- (stocked_quantity / order_quantity) * 100
  cost_per_unit NUMERIC(19, 4), -- actual_cost / stocked_quantity
  
  -- Derived Time Measures
  production_days INT64, -- end_date - start_date
  days_early_late INT64, -- end_date - due_date (negative = early, positive = late)
  
  -- Flags
  is_completed BOOL,
  is_on_time BOOL, -- end_date <= due_date
  has_scrap BOOL, -- scrapped_quantity > 0
  is_over_budget BOOL, -- actual_cost > planned_cost
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
PARTITION BY due_date_key
CLUSTER BY product_key, location_key
OPTIONS(
  description="Work order fact table. Grain: One row per work order. Tracks manufacturing efficiency and production quality.",
  labels=[("domain", "fact"), ("grain", "work_order"), ("type", "accumulating_snapshot")]
);


-- -------------------------------------------------------------------------------------
-- FCT_PRODUCT_REVIEWS - Product Review Fact Table
-- -------------------------------------------------------------------------------------
-- Purpose: Analyze customer satisfaction and product feedback
-- Grain: One row per product review
-- Source: Production_ProductReview
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.fct_product_reviews` (
  -- Surrogate Key
  review_key INT64 NOT NULL, -- Surrogate key for fact table
  
  -- Foreign Keys to Dimensions
  product_key INT64 NOT NULL, -- FK to dim_product
  review_date_key INT64 NOT NULL, -- FK to dim_date
  
  -- Degenerate Dimensions
  product_review_id INT64 NOT NULL, -- Natural key from source
  reviewer_name STRING,
  reviewer_email STRING,
  
  -- Additive Measures
  rating INT64 NOT NULL, -- 1-5 scale
  review_count INT64 DEFAULT 1, -- Always 1, for aggregation purposes
  
  -- Text Fields (for sentiment analysis)
  comments STRING,
  
  -- Derived Measures (from sentiment analysis if implemented)
  sentiment_score NUMERIC(5, 2), -- -1 to 1 scale
  sentiment_category STRING, -- Positive, Neutral, Negative
  
  -- Flags
  is_verified_purchase BOOL,
  has_comments BOOL,
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
PARTITION BY review_date_key
CLUSTER BY product_key, rating
OPTIONS(
  description="Product review fact table. Grain: One row per review. Tracks customer satisfaction and product feedback.",
  labels=[("domain", "fact"), ("grain", "product_review"), ("type", "transactional")]
);


-- =====================================================================================
-- BRIDGE TABLES (for many-to-many relationships)
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- BRIDGE_SALES_REASON - Bridge table for order sales reasons
-- -------------------------------------------------------------------------------------
-- Purpose: Handle many-to-many relationship between orders and sales reasons
-- Source: Sales_SalesOrderHeaderSalesReason + Sales_SalesReason
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.bridge_sales_reason` (
  -- Foreign Keys
  sales_order_id INT64 NOT NULL,
  sales_reason_id INT64 NOT NULL,
  
  -- Sales Reason Attributes (denormalized for performance)
  reason_name STRING,
  reason_type STRING,
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
CLUSTER BY sales_order_id
OPTIONS(
  description="Bridge table for many-to-many relationship between sales orders and sales reasons.",
  labels=[("domain", "bridge"), ("type", "many_to_many")]
);


-- =====================================================================================
-- HELPER/REFERENCE TABLES
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- REF_CURRENCY_RATES - Currency Exchange Rate Reference
-- -------------------------------------------------------------------------------------
-- Purpose: Store historical currency exchange rates for conversion
-- Source: Sales_CurrencyRate
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE `adventure_works.ref_currency_rates` (
  currency_rate_id INT64 NOT NULL,
  currency_rate_date DATE NOT NULL,
  from_currency_code STRING NOT NULL,
  to_currency_code STRING NOT NULL,
  average_rate NUMERIC(19, 10),
  end_of_day_rate NUMERIC(19, 10),
  
  -- Audit Fields
  source_system STRING DEFAULT 'Adventure_Works',
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
PARTITION BY currency_rate_date
CLUSTER BY from_currency_code, to_currency_code
OPTIONS(
  description="Currency exchange rate reference table for multi-currency conversions.",
  labels=[("domain", "reference"), ("type", "lookup")]
);


-- =====================================================================================
-- INDEXES AND CONSTRAINTS (Documentation)
-- =====================================================================================
-- Note: BigQuery uses clustering and partitioning instead of traditional indexes
-- All PRIMARY KEY and FOREIGN KEY constraints are documented but not enforced

-- Primary Keys (for documentation):
-- dim_date: date_key
-- dim_product: product_key
-- dim_customer: customer_key
-- dim_territory: territory_key
-- dim_salesperson: salesperson_key
-- dim_store: store_key
-- dim_address: address_key
-- dim_ship_method: ship_method_key
-- dim_special_offer: special_offer_key
-- dim_credit_card: credit_card_key
-- dim_currency: currency_key
-- dim_vendor: vendor_key
-- dim_employee: employee_key
-- dim_location: location_key
-- dim_scrap_reason: scrap_reason_key
-- fct_sales: sales_order_key
-- fct_product_inventory: inventory_snapshot_key
-- fct_purchases: purchase_order_key
-- fct_work_orders: work_order_key
-- fct_product_reviews: review_key

-- =====================================================================================
-- VIEWS FOR SIMPLIFIED ACCESS
-- =====================================================================================

-- Create a view that joins fct_sales with commonly used dimensions
CREATE OR REPLACE VIEW `adventure_works.v_sales_summary` AS
SELECT 
  f.sales_order_id,
  f.sales_order_number,
  d.full_date as order_date,
  p.product_name,
  p.product_category_name,
  c.full_name as customer_name,
  c.customer_type,
  t.territory_name,
  t.country_region_name,
  s.full_name as salesperson_name,
  f.order_quantity,
  f.unit_price,
  f.line_total,
  f.gross_profit,
  f.profit_margin_pct,
  f.online_order_flag
FROM `adventure_works.fct_sales` f
LEFT JOIN `adventure_works.dim_date` d ON f.order_date_key = d.date_key
LEFT JOIN `adventure_works.dim_product` p ON f.product_key = p.product_key AND p.is_current = TRUE
LEFT JOIN `adventure_works.dim_customer` c ON f.customer_key = c.customer_key AND c.is_current = TRUE
LEFT JOIN `adventure_works.dim_territory` t ON f.territory_key = t.territory_key
LEFT JOIN `adventure_works.dim_salesperson` s ON f.salesperson_key = s.salesperson_key AND s.is_current = TRUE;

-- =====================================================================================
-- END OF DDL SCRIPT
-- =====================================================================================
-- Tables Created:
--   Dimensions: 15 tables
--   Facts: 5 tables
--   Bridge: 1 table
--   Reference: 1 table
--   Views: 1 view
--   Total: 23 objects
-- =====================================================================================

