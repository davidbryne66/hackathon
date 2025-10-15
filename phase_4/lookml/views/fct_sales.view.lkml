view: fct_sales {
  sql_table_name: `dna-team-day-2025-20251003.team_4.fct_sales` ;;
  
  # Primary Key
  dimension: sales_order_detail_id {
    primary_key: yes
    type: number
    label: "Sales Order Detail ID"
    description: "Unique identifier for each order line item"
    sql: ${TABLE}.sales_order_detail_id ;;
  }
  
  # Foreign Keys (for joins)
  dimension: customer_key {
    type: number
    hidden: yes
    sql: ${TABLE}.customer_key ;;
  }
  
  dimension: product_key {
    type: number
    hidden: yes
    sql: ${TABLE}.product_key ;;
  }
  
  dimension: territory_key {
    type: number
    hidden: yes
    sql: ${TABLE}.territory_key ;;
  }
  
  dimension: salesperson_key {
    type: number
    hidden: yes
    sql: ${TABLE}.salesperson_key ;;
  }
  
  dimension: ship_method_key {
    type: number
    hidden: yes
    sql: ${TABLE}.ship_method_key ;;
  }
  
  dimension: special_offer_key {
    type: number
    hidden: yes
    sql: ${TABLE}.special_offer_key ;;
  }
  
  dimension: credit_card_key {
    type: number
    hidden: yes
    sql: ${TABLE}.credit_card_key ;;
  }
  
  dimension: bill_to_address_key {
    type: number
    hidden: yes
    sql: ${TABLE}.bill_to_address_key ;;
  }
  
  dimension: ship_to_address_key {
    type: number
    hidden: yes
    sql: ${TABLE}.ship_to_address_key ;;
  }
  
  # Date Keys
  dimension: order_date_key {
    type: number
    hidden: yes
    sql: ${TABLE}.order_date_key ;;
  }
  
  dimension: due_date_key {
    type: number
    hidden: yes
    sql: ${TABLE}.due_date_key ;;
  }
  
  dimension: ship_date_key {
    type: number
    hidden: yes
    sql: ${TABLE}.ship_date_key ;;
  }
  
  # Degenerate Dimensions
  dimension: sales_order_id {
    type: number
    label: "Sales Order ID"
    description: "Order header identifier"
    sql: ${TABLE}.sales_order_id ;;
  }
  
  dimension: sales_order_number {
    type: string
    label: "Sales Order Number"
    description: "Human-readable order number"
    sql: ${TABLE}.sales_order_number ;;
  }
  
  dimension: purchase_order_number {
    type: string
    label: "Purchase Order Number"
    description: "Customer's PO number"
    sql: ${TABLE}.purchase_order_number ;;
  }
  
  dimension: account_number {
    type: string
    label: "Account Number"
    description: "Customer account number"
    sql: ${TABLE}.account_number ;;
  }
  
  # Flags
  dimension: is_online_order {
    type: yesno
    label: "Online Order?"
    description: "Whether the order was placed online"
    sql: ${TABLE}.is_online_order ;;
  }
  
  dimension: order_status {
    type: number
    label: "Order Status"
    description: "Order processing status code"
    sql: ${TABLE}.order_status ;;
  }
  
  # Measures - Quantities
  measure: total_order_quantity {
    type: sum
    label: "Total Order Quantity"
    description: "Sum of all order quantities"
    sql: ${TABLE}.order_quantity ;;
  }
  
  measure: average_order_quantity {
    type: average
    label: "Average Order Quantity"
    description: "Average quantity per order line"
    sql: ${TABLE}.order_quantity ;;
    value_format_name: decimal_2
  }
  
  # Measures - Sales Amounts
  measure: total_sales_amount {
    type: sum
    label: "Total Sales Amount"
    description: "Sum of line totals (primary sales metric)"
    sql: ${TABLE}.line_total ;;
    value_format_name: usd
    drill_fields: [sales_detail*]
  }
  
  measure: total_subtotal {
    type: sum
    label: "Total Subtotal"
    description: "Sum of order subtotals"
    sql: ${TABLE}.order_subtotal ;;
    value_format_name: usd
  }
  
  measure: total_tax {
    type: sum
    label: "Total Tax"
    description: "Sum of tax amounts"
    sql: ${TABLE}.tax_amount ;;
    value_format_name: usd
  }
  
  measure: total_freight {
    type: sum
    label: "Total Freight"
    description: "Sum of freight charges"
    sql: ${TABLE}.freight ;;
    value_format_name: usd
  }
  
  measure: total_due {
    type: sum
    label: "Total Amount Due"
    description: "Sum of total amounts due (includes tax and freight)"
    sql: ${TABLE}.total_due ;;
    value_format_name: usd
  }
  
  measure: total_discount_amount {
    type: sum
    label: "Total Discount Amount"
    description: "Sum of discount amounts applied"
    sql: ${TABLE}.discount_amount ;;
    value_format_name: usd
  }
  
  # Measures - Unit Prices
  measure: average_unit_price {
    type: average
    label: "Average Unit Price"
    description: "Average selling price per unit"
    sql: ${TABLE}.unit_price ;;
    value_format_name: usd
  }
  
  measure: average_discount_percent {
    type: average
    label: "Average Discount %"
    description: "Average discount percentage"
    sql: ${TABLE}.unit_price_discount * 100 ;;
    value_format_name: percent_2
  }
  
  # Measures - Counts
  measure: order_count {
    type: count_distinct
    label: "Order Count"
    description: "Number of distinct orders"
    sql: ${TABLE}.sales_order_id ;;
    drill_fields: [sales_detail*]
  }
  
  measure: line_item_count {
    type: count
    label: "Line Item Count"
    description: "Number of order line items"
    drill_fields: [sales_detail*]
  }
  
  # Calculated Measures
  measure: average_order_value {
    type: number
    label: "Average Order Value"
    description: "Average sales amount per order"
    sql: ${total_sales_amount} / NULLIF(${order_count}, 0) ;;
    value_format_name: usd
  }
  
  # Drill Fields
  set: sales_detail {
    fields: [
      sales_order_number,
      dim_product.product_name,
      dim_customer.customer_name,
      total_sales_amount,
      total_order_quantity
    ]
  }
}

