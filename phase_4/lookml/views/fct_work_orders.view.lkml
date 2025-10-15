view: fct_work_orders {
  sql_table_name: `dna-team-day-2025-20251003.team_4.fct_work_orders` ;;
  
  dimension: work_order_key {
    primary_key: yes
    type: number
    label: "Work Order Key"
    sql: ${TABLE}.work_order_key ;;
  }
  
  dimension: work_order_id {
    type: number
    label: "Work Order ID"
    sql: ${TABLE}.work_order_id ;;
  }
  
  # Foreign Keys
  dimension: product_key {
    type: number
    hidden: yes
    sql: ${TABLE}.product_key ;;
  }
  
  dimension: scrap_reason_key {
    type: number
    hidden: yes
    sql: ${TABLE}.scrap_reason_key ;;
  }
  
  dimension: start_date_key {
    type: number
    hidden: yes
    sql: ${TABLE}.start_date_key ;;
  }
  
  dimension: end_date_key {
    type: number
    hidden: yes
    sql: ${TABLE}.end_date_key ;;
  }
  
  dimension: due_date_key {
    type: number
    hidden: yes
    sql: ${TABLE}.due_date_key ;;
  }
  
  # Quantities
  dimension: order_quantity {
    type: number
    label: "Order Quantity"
    description: "Quantity to produce"
    sql: ${TABLE}.order_quantity ;;
  }
  
  dimension: stocked_quantity {
    type: number
    label: "Stocked Quantity"
    description: "Quantity completed and stocked"
    sql: ${TABLE}.stocked_quantity ;;
  }
  
  dimension: scrapped_quantity {
    type: number
    label: "Scrapped Quantity"
    description: "Quantity scrapped/defective"
    sql: ${TABLE}.scrapped_quantity ;;
  }
  
  dimension: good_quantity {
    type: number
    label: "Good Quantity"
    description: "Net good quantity produced"
    sql: ${TABLE}.good_quantity ;;
  }
  
  # Metrics
  dimension: scrap_rate {
    type: number
    label: "Scrap Rate %"
    description: "Percentage of production scrapped"
    sql: ${TABLE}.scrap_rate * 100 ;;
    value_format_name: percent_2
  }
  
  dimension: production_days {
    type: number
    label: "Production Days"
    description: "Days from start to end"
    sql: ${TABLE}.production_days ;;
  }
  
  # Quality Tiers
  dimension: scrap_rate_tier {
    type: tier
    label: "Scrap Rate Tier"
    tiers: [0, 5, 10, 20, 50]
    style: integer
    sql: ${scrap_rate} ;;
  }
  
  # Measures - Quantities
  measure: total_order_quantity {
    type: sum
    label: "Total Order Quantity"
    sql: ${order_quantity} ;;
  }
  
  measure: total_stocked_quantity {
    type: sum
    label: "Total Stocked Quantity"
    sql: ${stocked_quantity} ;;
  }
  
  measure: total_scrapped_quantity {
    type: sum
    label: "Total Scrapped Quantity"
    sql: ${scrapped_quantity} ;;
  }
  
  measure: total_good_quantity {
    type: sum
    label: "Total Good Quantity"
    sql: ${good_quantity} ;;
  }
  
  # Measures - Metrics
  measure: average_scrap_rate {
    type: average
    label: "Average Scrap Rate %"
    description: "Average scrap rate across work orders"
    sql: ${scrap_rate} ;;
    value_format_name: percent_2
  }
  
  measure: overall_scrap_rate {
    type: number
    label: "Overall Scrap Rate %"
    description: "Total scrapped / total ordered"
    sql: 100.0 * ${total_scrapped_quantity} / NULLIF(${total_order_quantity}, 0) ;;
    value_format_name: percent_2
  }
  
  measure: average_production_days {
    type: average
    label: "Average Production Days"
    sql: ${production_days} ;;
    value_format_name: decimal_1
  }
  
  # Measures - Counts
  measure: work_order_count {
    type: count
    label: "Work Order Count"
    drill_fields: [work_order_detail*]
  }
  
  measure: orders_with_scrap {
    type: count
    label: "Orders with Scrap"
    filters: [scrapped_quantity: ">0"]
  }
  
  set: work_order_detail {
    fields: [
      work_order_id,
      dim_product.product_name,
      order_quantity,
      stocked_quantity,
      scrapped_quantity,
      scrap_rate
    ]
  }
}

