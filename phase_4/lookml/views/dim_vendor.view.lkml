view: dim_vendor {
  sql_table_name: `dna-team-day-2025-20251003.team_4.dim_vendor` ;;
  
  dimension: vendor_key {
    primary_key: yes
    type: number
    label: "Vendor Key"
    sql: ${TABLE}.vendor_key ;;
  }
  
  dimension: business_entity_id {
    type: number
    label: "Business Entity ID"
    sql: ${TABLE}.business_entity_id ;;
    hidden: yes
  }
  
  dimension: account_number {
    type: string
    label: "Account Number"
    sql: ${TABLE}.account_number ;;
  }
  
  dimension: vendor_name {
    type: string
    label: "Vendor Name"
    description: "Supplier/vendor name"
    sql: ${TABLE}.vendor_name ;;
  }
  
  dimension: credit_rating {
    type: number
    label: "Credit Rating"
    description: "Vendor credit rating (1-5)"
    sql: ${TABLE}.credit_rating ;;
  }
  
  dimension: is_preferred_vendor {
    type: yesno
    label: "Preferred Vendor?"
    description: "Whether vendor is preferred"
    sql: ${TABLE}.is_preferred_vendor ;;
  }
  
  dimension: is_active {
    type: yesno
    label: "Active?"
    description: "Whether vendor is currently active"
    sql: ${TABLE}.is_active ;;
  }
  
  # Credit Rating Tier
  dimension: credit_rating_tier {
    type: tier
    label: "Credit Rating Tier"
    tiers: [1, 2, 3, 4, 5]
    style: integer
    sql: ${credit_rating} ;;
  }
  
  measure: vendor_count {
    type: count
    label: "Vendor Count"
  }
  
  measure: preferred_vendor_count {
    type: count
    label: "Preferred Vendor Count"
    filters: [is_preferred_vendor: "yes"]
  }
  
  measure: active_vendor_count {
    type: count
    label: "Active Vendor Count"
    filters: [is_active: "yes"]
  }
  
  measure: average_credit_rating {
    type: average
    label: "Average Credit Rating"
    sql: ${credit_rating} ;;
    value_format_name: decimal_2
  }
}

