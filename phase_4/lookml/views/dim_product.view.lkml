view: dim_product {
  sql_table_name: `dna-team-day-2025-20251003.team_4.dim_product` ;;
  
  # Primary Key
  dimension: product_key {
    primary_key: yes
    type: number
    label: "Product Key"
    description: "Unique surrogate key for products"
    sql: ${TABLE}.product_key ;;
  }
  
  # Product Identifiers
  dimension: product_id {
    type: number
    label: "Product ID"
    description: "Natural product identifier"
    sql: ${TABLE}.product_id ;;
  }
  
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
  
  dimension: product_number {
    type: string
    label: "Product Number"
    description: "Product SKU or part number"
    sql: ${TABLE}.product_number ;;
  }
  
  # Product Hierarchy - Category
  dimension: category_name {
    type: string
    label: "Product Category"
    description: "Top-level product category (e.g., Bikes, Clothing, Accessories)"
    sql: ${TABLE}.category_name ;;
    drill_fields: [subcategory_name, product_name]
  }
  
  dimension: category_id {
    type: number
    label: "Category ID"
    description: "Category identifier"
    sql: ${TABLE}.category_id ;;
    hidden: yes
  }
  
  # Product Hierarchy - Subcategory
  dimension: subcategory_name {
    type: string
    label: "Product Subcategory"
    description: "Product subcategory (e.g., Mountain Bikes, Road Bikes)"
    sql: ${TABLE}.subcategory_name ;;
    drill_fields: [product_name]
  }
  
  dimension: subcategory_id {
    type: number
    label: "Subcategory ID"
    description: "Subcategory identifier"
    sql: ${TABLE}.subcategory_id ;;
    hidden: yes
  }
  
  # Product Attributes
  dimension: color {
    type: string
    label: "Product Color"
    description: "Product color"
    sql: ${TABLE}.color ;;
  }
  
  # Pricing
  dimension: list_price {
    type: number
    label: "List Price"
    description: "Manufacturer's suggested retail price"
    sql: ${TABLE}.list_price ;;
    value_format_name: usd
  }
  
  dimension: standard_cost {
    type: number
    label: "Standard Cost"
    description: "Standard product cost"
    sql: ${TABLE}.standard_cost ;;
    value_format_name: usd
  }
  
  # Calculated Dimensions
  dimension: margin_amount {
    type: number
    label: "Margin Amount"
    description: "Difference between list price and standard cost"
    sql: ${list_price} - ${standard_cost} ;;
    value_format_name: usd
  }
  
  dimension: margin_percent {
    type: number
    label: "Margin %"
    description: "Gross margin percentage"
    sql: SAFE_DIVIDE(${list_price} - ${standard_cost}, ${list_price}) * 100 ;;
    value_format_name: decimal_1
  }
  
  # Price Tiers
  dimension: price_tier {
    type: tier
    label: "Price Tier"
    description: "Product price range"
    tiers: [0, 50, 100, 500, 1000, 2000]
    style: integer
    sql: ${list_price} ;;
  }
  
  # Measures
  measure: product_count {
    type: count
    label: "Product Count"
    description: "Number of distinct products"
    drill_fields: [product_detail*]
  }
  
  measure: average_list_price {
    type: average
    label: "Average List Price"
    description: "Average list price across products"
    sql: ${list_price} ;;
    value_format_name: usd
  }
  
  measure: average_standard_cost {
    type: average
    label: "Average Standard Cost"
    description: "Average cost across products"
    sql: ${standard_cost} ;;
    value_format_name: usd
  }
  
  # Drill Fields
  set: product_detail {
    fields: [
      product_name,
      product_number,
      category_name,
      subcategory_name,
      color,
      list_price
    ]
  }
}

