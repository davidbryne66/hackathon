view: dim_location {
  sql_table_name: `dna-team-day-2025-20251003.team_4.dim_location` ;;
  
  dimension: location_key {
    primary_key: yes
    type: number
    label: "Location Key"
    sql: ${TABLE}.location_key ;;
  }
  
  dimension: location_id {
    type: number
    label: "Location ID"
    sql: ${TABLE}.location_id ;;
    hidden: yes
  }
  
  dimension: location_name {
    type: string
    label: "Location Name"
    description: "Warehouse or facility name"
    sql: ${TABLE}.location_name ;;
  }
  
  dimension: cost_rate {
    type: number
    label: "Cost Rate"
    description: "Hourly cost rate for this location"
    sql: ${TABLE}.cost_rate ;;
    value_format_name: usd
  }
  
  dimension: availability {
    type: number
    label: "Availability"
    description: "Hours available"
    sql: ${TABLE}.availability ;;
  }
  
  measure: location_count {
    type: count
    label: "Location Count"
  }
  
  measure: average_cost_rate {
    type: average
    label: "Average Cost Rate"
    sql: ${cost_rate} ;;
    value_format_name: usd
  }
}

