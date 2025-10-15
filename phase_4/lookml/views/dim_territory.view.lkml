view: dim_territory {
  sql_table_name: `dna-team-day-2025-20251003.team_4.dim_territory` ;;
  
  dimension: territory_key {
    primary_key: yes
    type: number
    label: "Territory Key"
    sql: ${TABLE}.territory_key ;;
  }
  
  dimension: territory_id {
    type: number
    label: "Territory ID"
    sql: ${TABLE}.territory_id ;;
    hidden: yes
  }
  
  dimension: territory_name {
    type: string
    label: "Territory Name"
    description: "Sales territory name (e.g., Northwest, Northeast)"
    sql: ${TABLE}.territory_name ;;
  }
  
  dimension: country_code {
    type: string
    label: "Country Code"
    description: "ISO country code"
    sql: ${TABLE}.country_code ;;
  }
  
  dimension: country_name {
    type: string
    label: "Country"
    description: "Country name"
    sql: ${TABLE}.country_name ;;
    drill_fields: [territory_name]
  }
  
  dimension: territory_group {
    type: string
    label: "Territory Group"
    description: "Geographic region (e.g., North America, Europe)"
    sql: ${TABLE}.territory_group ;;
    drill_fields: [country_name, territory_name]
  }
  
  measure: territory_count {
    type: count
    label: "Territory Count"
  }
}

