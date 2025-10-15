view: dim_salesperson {
  sql_table_name: `dna-team-day-2025-20251003.team_4.dim_salesperson` ;;
  
  dimension: salesperson_key {
    primary_key: yes
    type: number
    label: "Salesperson Key"
    sql: ${TABLE}.salesperson_key ;;
  }
  
  dimension: business_entity_id {
    type: number
    label: "Business Entity ID"
    sql: ${TABLE}.business_entity_id ;;
    hidden: yes
  }
  
  dimension: salesperson_name {
    type: string
    label: "Salesperson Name"
    description: "Full name of salesperson"
    sql: ${TABLE}.salesperson_name ;;
  }
  
  dimension: job_title {
    type: string
    label: "Job Title"
    description: "Salesperson's job title"
    sql: ${TABLE}.job_title ;;
  }
  
  dimension: sales_quota {
    type: number
    label: "Sales Quota"
    description: "Salesperson's quota target"
    sql: ${TABLE}.sales_quota ;;
    value_format_name: usd
  }
  
  dimension: commission_pct {
    type: number
    label: "Commission %"
    description: "Commission percentage"
    sql: ${TABLE}.commission_pct * 100 ;;
    value_format_name: percent_2
  }
  
  measure: salesperson_count {
    type: count
    label: "Salesperson Count"
  }
  
  measure: average_quota {
    type: average
    label: "Average Quota"
    sql: ${sales_quota} ;;
    value_format_name: usd
  }
}

