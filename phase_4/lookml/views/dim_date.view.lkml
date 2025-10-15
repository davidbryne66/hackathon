view: dim_date {
  sql_table_name: `dna-team-day-2025-20251003.team_4.dim_date` ;;
  
  # Primary Key
  dimension: date_key {
    primary_key: yes
    type: number
    label: "Date Key"
    description: "Unique date key in YYYYMMDD format"
    sql: ${TABLE}.date_key ;;
  }
  
  # Full Date
  dimension_group: date {
    type: time
    label: "Order"
    description: "Full date"
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.full_date ;;
  }
  
  # Year
  dimension: year {
    type: number
    label: "Year"
    description: "Four-digit year"
    sql: ${TABLE}.year ;;
  }
  
  # Quarter
  dimension: quarter {
    type: number
    label: "Quarter"
    description: "Quarter (1-4)"
    sql: ${TABLE}.quarter ;;
  }
  
  dimension: year_quarter {
    type: string
    label: "Year-Quarter"
    description: "Year and quarter combined"
    sql: CONCAT(CAST(${year} AS STRING), '-Q', CAST(${quarter} AS STRING)) ;;
  }
  
  # Month
  dimension: month_number {
    type: number
    label: "Month Number"
    description: "Month number (1-12)"
    sql: ${TABLE}.month_number ;;
  }
  
  dimension: month_name {
    type: string
    label: "Month Name"
    description: "Month name (January, February, etc.)"
    sql: ${TABLE}.month_name ;;
    order_by_field: month_number
  }
  
  dimension: year_month {
    type: string
    label: "Year-Month"
    description: "Year and month combined"
    sql: CONCAT(CAST(${year} AS STRING), '-', FORMAT('%02d', ${month_number})) ;;
  }
  
  # Day
  dimension: day_of_month {
    type: number
    label: "Day of Month"
    description: "Day of month (1-31)"
    sql: ${TABLE}.day_of_month ;;
  }
  
  dimension: day_name {
    type: string
    label: "Day Name"
    description: "Day name (Monday, Tuesday, etc.)"
    sql: ${TABLE}.day_name ;;
  }
  
  # Weekend Flag
  dimension: is_weekend {
    type: yesno
    label: "Is Weekend?"
    description: "Whether the date is a weekend (Saturday or Sunday)"
    sql: ${TABLE}.is_weekend ;;
  }
  
  # Relative Date Filters (useful for Phase 5 queries)
  dimension: is_current_year {
    type: yesno
    label: "Is Current Year?"
    description: "Whether the date is in the current year"
    sql: ${year} = EXTRACT(YEAR FROM CURRENT_DATE()) ;;
  }
  
  dimension: is_last_year {
    type: yesno
    label: "Is Last Year?"
    description: "Whether the date is in the last year"
    sql: ${year} = EXTRACT(YEAR FROM CURRENT_DATE()) - 1 ;;
  }
  
  dimension: is_ytd {
    type: yesno
    label: "Is Year-to-Date?"
    description: "Whether the date is in the current year up to today"
    sql: ${date_date} >= DATE_TRUNC(CURRENT_DATE(), YEAR) 
         AND ${date_date} <= CURRENT_DATE() ;;
  }
  
  # Measures
  measure: date_count {
    type: count
    label: "Date Count"
    description: "Number of dates"
  }
  
  # Field Sets for role-playing dimensions
  set: date_dimension_set {
    fields: [
      date_date,
      date_week,
      date_month,
      date_quarter,
      date_year,
      year,
      quarter,
      year_quarter,
      month_number,
      month_name,
      year_month,
      day_name,
      is_weekend
    ]
  }
}

