view: dim_address {
  sql_table_name: `dna-team-day-2025-20251003.team_4.dim_address` ;;
  
  dimension: address_key {
    primary_key: yes
    type: number
    label: "Address Key"
    sql: ${TABLE}.address_key ;;
  }
  
  dimension: address_id {
    type: number
    label: "Address ID"
    sql: ${TABLE}.address_id ;;
    hidden: yes
  }
  
  dimension: address_line1 {
    type: string
    label: "Address Line 1"
    sql: ${TABLE}.address_line1 ;;
  }
  
  dimension: address_line2 {
    type: string
    label: "Address Line 2"
    sql: ${TABLE}.address_line2 ;;
  }
  
  dimension: city {
    type: string
    label: "City"
    description: "City name"
    sql: ${TABLE}.city ;;
    drill_fields: [address_detail*]
  }
  
  dimension: state_province_code {
    type: string
    label: "State/Province Code"
    sql: ${TABLE}.state_province_code ;;
  }
  
  dimension: state_province_name {
    type: string
    label: "State/Province"
    description: "State or province name"
    sql: ${TABLE}.state_province_name ;;
    drill_fields: [city]
  }
  
  dimension: country_code {
    type: string
    label: "Country Code"
    sql: ${TABLE}.country_code ;;
  }
  
  dimension: country_name {
    type: string
    label: "Country"
    description: "Country name"
    sql: ${TABLE}.country_name ;;
    drill_fields: [state_province_name, city]
  }
  
  dimension: postal_code {
    type: string
    label: "Postal Code"
    sql: ${TABLE}.postal_code ;;
  }
  
  # Full Address
  dimension: full_address {
    type: string
    label: "Full Address"
    description: "Complete address formatted"
    sql: CONCAT(
           ${address_line1},
           CASE WHEN ${address_line2} IS NOT NULL THEN CONCAT(' ', ${address_line2}) ELSE '' END,
           ', ', ${city},
           ', ', ${state_province_name},
           ' ', ${postal_code},
           ', ', ${country_name}
         ) ;;
  }
  
  measure: address_count {
    type: count
    label: "Address Count"
  }
  
  measure: unique_cities {
    type: count_distinct
    label: "Unique Cities"
    sql: ${city} ;;
  }
  
  measure: unique_states {
    type: count_distinct
    label: "Unique States/Provinces"
    sql: ${state_province_name} ;;
  }
  
  measure: unique_countries {
    type: count_distinct
    label: "Unique Countries"
    sql: ${country_name} ;;
  }
  
  set: address_detail {
    fields: [full_address, city, state_province_name, country_name]
  }
  
  set: address_dimension_set {
    fields: [
      city,
      state_province_name,
      state_province_code,
      country_name,
      country_code,
      postal_code,
      full_address
    ]
  }
}

