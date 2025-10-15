view: fct_product_reviews {
  sql_table_name: `dna-team-day-2025-20251003.team_4.fct_product_reviews` ;;
  
  dimension: review_key {
    primary_key: yes
    type: number
    label: "Review Key"
    sql: ${TABLE}.review_key ;;
  }
  
  dimension: product_key {
    type: number
    hidden: yes
    sql: ${TABLE}.product_key ;;
  }
  
  dimension_group: review_date {
    type: time
    label: "Review"
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.review_date ;;
  }
  
  dimension: reviewer_name {
    type: string
    label: "Reviewer Name"
    sql: ${TABLE}.reviewer_name ;;
  }
  
  dimension: rating {
    type: number
    label: "Rating"
    description: "Product rating (1-5 stars)"
    sql: ${TABLE}.rating ;;
  }
  
  dimension: comments {
    type: string
    label: "Review Comments"
    sql: ${TABLE}.comments ;;
  }
  
  dimension: comment_length {
    type: number
    label: "Comment Length"
    sql: ${TABLE}.comment_length ;;
  }
  
  dimension: sentiment {
    type: string
    label: "Sentiment"
    description: "Review sentiment (Positive, Neutral, Negative)"
    sql: ${TABLE}.sentiment ;;
  }
  
  # Rating Tiers
  dimension: rating_tier {
    type: tier
    label: "Rating Tier"
    tiers: [1, 2, 3, 4, 5]
    style: integer
    sql: ${rating} ;;
  }
  
  # Measures
  measure: review_count {
    type: count
    label: "Review Count"
    description: "Total number of reviews"
    drill_fields: [review_detail*]
  }
  
  measure: average_rating {
    type: average
    label: "Average Rating"
    description: "Average product rating"
    sql: ${rating} ;;
    value_format_name: decimal_2
  }
  
  measure: positive_review_count {
    type: count
    label: "Positive Reviews"
    filters: [sentiment: "Positive"]
  }
  
  measure: negative_review_count {
    type: count
    label: "Negative Reviews"
    filters: [sentiment: "Negative"]
  }
  
  measure: positive_review_percent {
    type: number
    label: "% Positive Reviews"
    sql: 100.0 * ${positive_review_count} / NULLIF(${review_count}, 0) ;;
    value_format_name: percent_1
  }
  
  set: review_detail {
    fields: [
      dim_product.product_name,
      reviewer_name,
      rating,
      sentiment,
      comments
    ]
  }
}

