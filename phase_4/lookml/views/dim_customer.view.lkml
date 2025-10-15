view: dim_customer {
  sql_table_name: `dna-team-day-2025-20251003.team_4.dim_customer` ;;
  
  # Primary Key
  dimension: customer_key {
    primary_key: yes
    type: number
    label: "Customer Key"
    description: "Unique surrogate key for customers"
    sql: ${TABLE}.customer_key ;;
  }
  
  # Customer Identifiers
  dimension: customer_id {
    type: number
    label: "Customer ID"
    description: "Natural customer identifier"
    sql: ${TABLE}.customer_id ;;
  }
  
  dimension: account_number {
    type: string
    label: "Account Number"
    description: "Customer account number"
    sql: ${TABLE}.account_number ;;
  }
  
  # Customer Information
  dimension: customer_name {
    type: string
    label: "Customer Name"
    description: "Customer full name"
    sql: ${TABLE}.customer_name ;;
    link: {
      label: "Customer Profile"
      url: "/dashboards/customer?customer={{ value }}"
    }
  }
  
  dimension: person_type {
    type: string
    label: "Person Type"
    description: "Type of person (individual, store contact, etc.)"
    sql: ${TABLE}.person_type ;;
  }
  
  # Store Information
  dimension: store_name {
    type: string
    label: "Store Name"
    description: "Associated store name"
    sql: ${TABLE}.store_name ;;
  }
  
  dimension: store_id {
    type: number
    label: "Store ID"
    description: "Store identifier"
    sql: ${TABLE}.store_id ;;
    hidden: yes
  }
  
  # Territory/Location
  dimension: territory_id {
    type: number
    label: "Territory ID"
    description: "Sales territory identifier"
    sql: ${TABLE}.territory_id ;;
    hidden: yes
  }
  
  # Customer Segmentation
  dimension: customer_type {
    type: string
    label: "Customer Type"
    description: "Individual or Store customer"
    sql: CASE 
           WHEN ${store_id} IS NOT NULL THEN 'Store'
           ELSE 'Individual'
         END ;;
  }
  
  # Measures
  measure: customer_count {
    type: count
    label: "Customer Count"
    description: "Number of distinct customers"
    drill_fields: [customer_detail*]
  }
  
  measure: individual_customer_count {
    type: count
    label: "Individual Customer Count"
    description: "Number of individual customers"
    filters: [customer_type: "Individual"]
  }
  
  measure: store_customer_count {
    type: count
    label: "Store Customer Count"
    description: "Number of store customers"
    filters: [customer_type: "Store"]
  }
  
  # Drill Fields
  set: customer_detail {
    fields: [
      customer_name,
      account_number,
      person_type,
      store_name,
      customer_type
    ]
  }
}

