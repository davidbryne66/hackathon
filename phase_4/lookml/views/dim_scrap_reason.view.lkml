view: dim_scrap_reason {
  sql_table_name: `dna-team-day-2025-20251003.team_4.dim_scrap_reason` ;;
  
  dimension: scrap_reason_key {
    primary_key: yes
    type: number
    label: "Scrap Reason Key"
    sql: ${TABLE}.scrap_reason_key ;;
  }
  
  dimension: scrap_reason_id {
    type: number
    label: "Scrap Reason ID"
    sql: ${TABLE}.scrap_reason_id ;;
    hidden: yes
  }
  
  dimension: scrap_reason_name {
    type: string
    label: "Scrap Reason"
    description: "Reason for manufacturing defect/scrap"
    sql: ${TABLE}.scrap_reason_name ;;
  }
  
  measure: scrap_reason_count {
    type: count
    label: "Scrap Reason Count"
  }
}

