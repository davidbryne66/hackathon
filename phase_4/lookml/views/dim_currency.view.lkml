view: dim_currency {
  sql_table_name: `dna-team-day-2025-20251003.team_4.dim_currency` ;;
  
  dimension: currency_key {
    primary_key: yes
    type: number
    label: "Currency Key"
    sql: ${TABLE}.currency_key ;;
  }
  
  dimension: currency_code {
    type: string
    label: "Currency Code"
    description: "Three-letter currency code (e.g., USD, EUR)"
    sql: ${TABLE}.currency_code ;;
  }
  
  dimension: currency_name {
    type: string
    label: "Currency Name"
    description: "Full currency name"
    sql: ${TABLE}.currency_name ;;
  }
  
  measure: currency_count {
    type: count
    label: "Currency Count"
  }
}

