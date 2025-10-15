view: fct_product_inventory {
  sql_table_name: `dna-team-day-2025-20251003.team_4.fct_product_inventory` ;;
  
  dimension: inventory_key {
    primary_key: yes
    type: string
    label: "Inventory Key"
    sql: ${TABLE}.inventory_key ;;
  }
  
  dimension: product_key {
    type: number
    hidden: yes
    sql: ${TABLE}.product_key ;;
  }
  
  dimension: location_key {
    type: number
    hidden: yes
    sql: ${TABLE}.location_key ;;
  }
  
  dimension: snapshot_date_key {
    type: number
    hidden: yes
    sql: ${TABLE}.snapshot_date_key ;;
  }
  
  dimension: quantity_on_hand {
    type: number
    label: "Quantity on Hand"
    description: "Current inventory quantity"
    sql: ${TABLE}.quantity_on_hand ;;
  }
  
  dimension: shelf {
    type: string
    label: "Shelf"
    sql: ${TABLE}.shelf ;;
  }
  
  dimension: bin_number {
    type: number
    label: "Bin Number"
    sql: ${TABLE}.bin_number ;;
  }
  
  # Stock Level Categories
  dimension: stock_status {
    type: string
    label: "Stock Status"
    description: "Inventory level status"
    sql: CASE
           WHEN ${quantity_on_hand} = 0 THEN 'Out of Stock'
           WHEN ${quantity_on_hand} < 10 THEN 'Low Stock'
           WHEN ${quantity_on_hand} < 50 THEN 'Medium Stock'
           ELSE 'Well Stocked'
         END ;;
  }
  
  # Measures
  measure: total_inventory {
    type: sum
    label: "Total Inventory"
    description: "Total quantity on hand"
    sql: ${quantity_on_hand} ;;
  }
  
  measure: average_inventory {
    type: average
    label: "Average Inventory"
    sql: ${quantity_on_hand} ;;
    value_format_name: decimal_1
  }
  
  measure: inventory_location_count {
    type: count
    label: "Inventory Location Count"
    description: "Number of inventory locations"
  }
  
  measure: out_of_stock_count {
    type: count
    label: "Out of Stock Items"
    filters: [quantity_on_hand: "0"]
  }
  
  measure: low_stock_count {
    type: count
    label: "Low Stock Items"
    filters: [stock_status: "Low Stock"]
  }
}

