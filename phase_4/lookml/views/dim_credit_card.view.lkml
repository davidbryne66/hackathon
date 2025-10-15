view: dim_credit_card {
  sql_table_name: `dna-team-day-2025-20251003.team_4.dim_credit_card` ;;
  
  dimension: credit_card_key {
    primary_key: yes
    type: number
    label: "Credit Card Key"
    sql: ${TABLE}.credit_card_key ;;
  }
  
  dimension: credit_card_id {
    type: number
    label: "Credit Card ID"
    sql: ${TABLE}.credit_card_id ;;
    hidden: yes
  }
  
  dimension: card_type {
    type: string
    label: "Card Type"
    description: "Credit card brand (e.g., Visa, MasterCard)"
    sql: ${TABLE}.card_type ;;
  }
  
  dimension: card_number_masked {
    type: string
    label: "Card Number (Masked)"
    description: "Masked credit card number"
    sql: ${TABLE}.card_number_masked ;;
  }
  
  dimension: exp_month {
    type: number
    label: "Expiration Month"
    sql: ${TABLE}.exp_month ;;
    hidden: yes
  }
  
  dimension: exp_year {
    type: number
    label: "Expiration Year"
    sql: ${TABLE}.exp_year ;;
    hidden: yes
  }
  
  measure: card_count {
    type: count
    label: "Credit Card Count"
  }
  
  measure: cards_by_type {
    type: count
    label: "Cards by Type"
    drill_fields: [card_type]
  }
}

