view: dim_employee {
  sql_table_name: `dna-team-day-2025-20251003.team_4.dim_employee` ;;
  
  dimension: employee_key {
    primary_key: yes
    type: number
    label: "Employee Key"
    sql: ${TABLE}.employee_key ;;
  }
  
  dimension: business_entity_id {
    type: number
    label: "Business Entity ID"
    sql: ${TABLE}.business_entity_id ;;
    hidden: yes
  }
  
  dimension: national_id {
    type: string
    label: "National ID"
    sql: ${TABLE}.national_id ;;
    hidden: yes
  }
  
  dimension: login_id {
    type: string
    label: "Login ID"
    sql: ${TABLE}.login_id ;;
    hidden: yes
  }
  
  dimension: full_name {
    type: string
    label: "Employee Name"
    description: "Employee full name"
    sql: ${TABLE}.full_name ;;
  }
  
  dimension: job_title {
    type: string
    label: "Job Title"
    description: "Employee job title"
    sql: ${TABLE}.job_title ;;
  }
  
  dimension_group: birth {
    type: time
    label: "Birth"
    timeframes: [date, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.birth_date ;;
  }
  
  dimension_group: hire {
    type: time
    label: "Hire"
    timeframes: [date, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.hire_date ;;
  }
  
  dimension: marital_status {
    type: string
    label: "Marital Status"
    sql: ${TABLE}.marital_status ;;
    hidden: yes
  }
  
  dimension: gender {
    type: string
    label: "Gender"
    sql: ${TABLE}.gender ;;
  }
  
  dimension: is_salaried {
    type: yesno
    label: "Salaried?"
    sql: ${TABLE}.is_salaried ;;
  }
  
  dimension: is_current {
    type: yesno
    label: "Current Employee?"
    sql: ${TABLE}.is_current ;;
  }
  
  dimension: vacation_hours {
    type: number
    label: "Vacation Hours"
    sql: ${TABLE}.vacation_hours ;;
  }
  
  dimension: sick_leave_hours {
    type: number
    label: "Sick Leave Hours"
    sql: ${TABLE}.sick_leave_hours ;;
  }
  
  # Calculated Dimensions
  dimension: years_employed {
    type: number
    label: "Years Employed"
    sql: DATE_DIFF(CURRENT_DATE(), ${hire_date}, YEAR) ;;
  }
  
  dimension: tenure_tier {
    type: tier
    label: "Tenure Tier"
    tiers: [0, 1, 3, 5, 10, 15]
    style: integer
    sql: ${years_employed} ;;
  }
  
  measure: employee_count {
    type: count
    label: "Employee Count"
  }
  
  measure: current_employee_count {
    type: count
    label: "Current Employee Count"
    filters: [is_current: "yes"]
  }
  
  measure: average_years_employed {
    type: average
    label: "Average Years Employed"
    sql: ${years_employed} ;;
    value_format_name: decimal_1
  }
}

