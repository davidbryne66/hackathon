view: dim_ship_method {
  sql_table_name: `dna-team-day-2025-20251003.team_4.dim_ship_method` ;;
  
  dimension: ship_method_key {
    primary_key: yes
    type: number
    label: "Ship Method Key"
    sql: ${TABLE}.ship_method_key ;;
  }
  
  dimension: ship_method_id {
    type: number
    label: "Ship Method ID"
    sql: ${TABLE}.ship_method_id ;;
    hidden: yes
  }
  
  dimension: ship_method_name {
    type: string
    label: "Ship Method"
    description: "Shipping method name (e.g., Overnight, Standard)"
    sql: ${TABLE}.ship_method_name ;;
  }
  
  dimension: ship_base_cost {
    type: number
    label: "Base Shipping Cost"
    sql: ${TABLE}.ship_base_cost ;;
    value_format_name: usd
  }
  
  dimension: ship_rate {
    type: number
    label: "Shipping Rate"
    sql: ${TABLE}.ship_rate ;;
    value_format_name: usd
  }
  
  measure: ship_method_count {
    type: count
    label: "Ship Method Count"
  }
}

