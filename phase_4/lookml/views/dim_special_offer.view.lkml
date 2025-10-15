view: dim_special_offer {
  sql_table_name: `dna-team-day-2025-20251003.team_4.dim_special_offer` ;;
  
  dimension: special_offer_key {
    primary_key: yes
    type: number
    label: "Special Offer Key"
    sql: ${TABLE}.special_offer_key ;;
  }
  
  dimension: special_offer_id {
    type: number
    label: "Special Offer ID"
    sql: ${TABLE}.special_offer_id ;;
    hidden: yes
  }
  
  dimension: special_offer_description {
    type: string
    label: "Special Offer"
    description: "Promotion or special offer description"
    sql: ${TABLE}.special_offer_description ;;
  }
  
  dimension: offer_type {
    type: string
    label: "Offer Type"
    description: "Type of promotion"
    sql: ${TABLE}.offer_type ;;
  }
  
  dimension: offer_category {
    type: string
    label: "Offer Category"
    description: "Category of promotion"
    sql: ${TABLE}.offer_category ;;
  }
  
  dimension: discount_pct {
    type: number
    label: "Discount %"
    description: "Discount percentage"
    sql: ${TABLE}.discount_pct * 100 ;;
    value_format_name: percent_2
  }
  
  dimension: min_quantity {
    type: number
    label: "Minimum Quantity"
    sql: ${TABLE}.min_quantity ;;
  }
  
  dimension: max_quantity {
    type: number
    label: "Maximum Quantity"
    sql: ${TABLE}.max_quantity ;;
  }
  
  measure: offer_count {
    type: count
    label: "Offer Count"
  }
  
  measure: average_discount {
    type: average
    label: "Average Discount %"
    sql: ${discount_pct} ;;
    value_format_name: percent_2
  }
}

