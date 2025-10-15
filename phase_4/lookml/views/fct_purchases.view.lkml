view: fct_purchases {
  sql_table_name: `dna-team-day-2025-20251003.team_4.fct_purchases` ;;
  
  dimension: purchase_order_key {
    primary_key: yes
    type: number
    label: "Purchase Order Key"
    sql: ${TABLE}.purchase_order_key ;;
  }
  
  dimension: purchase_order_id {
    type: number
    label: "Purchase Order ID"
    sql: ${TABLE}.purchase_order_id ;;
  }
  
  # Foreign Keys
  dimension: product_key {
    type: number
    hidden: yes
    sql: ${TABLE}.product_key ;;
  }
  
  dimension: vendor_key {
    type: number
    hidden: yes
    sql: ${TABLE}.vendor_key ;;
  }
  
  dimension: employee_key {
    type: number
    hidden: yes
    sql: ${TABLE}.employee_key ;;
  }
  
  dimension: ship_method_key {
    type: number
    hidden: yes
    sql: ${TABLE}.ship_method_key ;;
  }
  
  dimension: order_date_key {
    type: number
    hidden: yes
    sql: ${TABLE}.order_date_key ;;
  }
  
  dimension: ship_date_key {
    type: number
    hidden: yes
    sql: ${TABLE}.ship_date_key ;;
  }
  
  # Quantities
  dimension: order_quantity {
    type: number
    label: "Order Quantity"
    sql: ${TABLE}.order_quantity ;;
  }
  
  dimension: received_quantity {
    type: number
    label: "Received Quantity"
    sql: ${TABLE}.received_quantity ;;
  }
  
  dimension: rejected_quantity {
    type: number
    label: "Rejected Quantity"
    sql: ${TABLE}.rejected_quantity ;;
  }
  
  dimension: stocked_quantity {
    type: number
    label: "Stocked Quantity"
    sql: ${TABLE}.stocked_quantity ;;
  }
  
  # Amounts
  dimension: unit_price {
    type: number
    label: "Unit Price"
    sql: ${TABLE}.unit_price ;;
    value_format_name: usd
  }
  
  dimension: line_total {
    type: number
    label: "Line Total"
    sql: ${TABLE}.line_total ;;
    value_format_name: usd
  }
  
  # Status
  dimension: order_status {
    type: number
    label: "Order Status"
    sql: ${TABLE}.order_status ;;
  }
  
  dimension: revision_number {
    type: number
    label: "Revision Number"
    sql: ${TABLE}.revision_number ;;
  }
  
  # Calculated Dimensions
  dimension: rejection_rate {
    type: number
    label: "Rejection Rate %"
    sql: 100.0 * ${rejected_quantity} / NULLIF(${received_quantity}, 0) ;;
    value_format_name: percent_2
  }
  
  # Measures - Quantities
  measure: total_order_quantity {
    type: sum
    label: "Total Order Quantity"
    sql: ${order_quantity} ;;
  }
  
  measure: total_received_quantity {
    type: sum
    label: "Total Received Quantity"
    sql: ${received_quantity} ;;
  }
  
  measure: total_rejected_quantity {
    type: sum
    label: "Total Rejected Quantity"
    sql: ${rejected_quantity} ;;
  }
  
  # Measures - Amounts
  measure: total_purchase_amount {
    type: sum
    label: "Total Purchase Amount"
    description: "Total purchase order value"
    sql: ${line_total} ;;
    value_format_name: usd
  }
  
  measure: average_unit_price {
    type: average
    label: "Average Unit Price"
    sql: ${unit_price} ;;
    value_format_name: usd
  }
  
  # Measures - Counts
  measure: purchase_order_count {
    type: count_distinct
    label: "Purchase Order Count"
    sql: ${purchase_order_id} ;;
  }
  
  measure: purchase_line_count {
    type: count
    label: "Purchase Line Count"
  }
  
  # Measures - Quality Metrics
  measure: average_rejection_rate {
    type: average
    label: "Average Rejection Rate %"
    sql: ${rejection_rate} ;;
    value_format_name: percent_2
  }
}

