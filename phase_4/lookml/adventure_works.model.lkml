connection: "teamday2025_team4"

# Include all view files
include: "/views/*.view.lkml"

# Main explore for sales analysis
explore: sales_analysis {
  label: "Sales Analysis"
  description: "Analyze sales performance by product, customer, territory, and time"

  from: fct_sales
  view_name: fct_sales

  # Product dimension
  join: dim_product {
    type: left_outer
    sql_on: ${fct_sales.product_key} = ${dim_product.product_key} ;;
    relationship: many_to_one
  }

  # Customer dimension
  join: dim_customer {
    type: left_outer
    sql_on: ${fct_sales.customer_key} = ${dim_customer.customer_key} ;;
    relationship: many_to_one
  }

  # Date dimensions (role-playing)
  join: dim_date_order {
    from: dim_date
    type: left_outer
    sql_on: ${fct_sales.order_date_key} = ${dim_date_order.date_key} ;;
    relationship: many_to_one
    fields: [dim_date_order.date_dimension_set*]
  }

  join: dim_date_ship {
    from: dim_date
    type: left_outer
    sql_on: ${fct_sales.ship_date_key} = ${dim_date_ship.date_key} ;;
    relationship: many_to_one
    fields: [dim_date_ship.date_dimension_set*]
  }

  # Territory dimension
  join: dim_territory {
    type: left_outer
    sql_on: ${fct_sales.territory_key} = ${dim_territory.territory_key} ;;
    relationship: many_to_one
  }

  # Salesperson dimension
  join: dim_salesperson {
    type: left_outer
    sql_on: ${fct_sales.salesperson_key} = ${dim_salesperson.salesperson_key} ;;
    relationship: many_to_one
  }

  # Ship method dimension
  join: dim_ship_method {
    type: left_outer
    sql_on: ${fct_sales.ship_method_key} = ${dim_ship_method.ship_method_key} ;;
    relationship: many_to_one
  }

  # Special offer dimension
  join: dim_special_offer {
    type: left_outer
    sql_on: ${fct_sales.special_offer_key} = ${dim_special_offer.special_offer_key} ;;
    relationship: many_to_one
  }

  # Credit card dimension
  join: dim_credit_card {
    type: left_outer
    sql_on: ${fct_sales.credit_card_key} = ${dim_credit_card.credit_card_key} ;;
    relationship: many_to_one
  }
  
  # Bill-to address
  join: dim_address_bill {
    from: dim_address
    type: left_outer
    sql_on: ${fct_sales.bill_to_address_key} = ${dim_address_bill.address_key} ;;
    relationship: many_to_one
    fields: [dim_address_bill.address_dimension_set*]
  }

  # Ship-to address
  join: dim_address_ship {
    from: dim_address
    type: left_outer
    sql_on: ${fct_sales.ship_to_address_key} = ${dim_address_ship.address_key} ;;
    relationship: many_to_one
    fields: [dim_address_ship.address_dimension_set*]
  }
}

# Explore for product reviews
explore: product_reviews {
  label: "Product Reviews"
  description: "Analyze customer product reviews and ratings"

  from: fct_product_reviews
  view_name: fct_product_reviews

  join: dim_product {
    type: left_outer
    sql_on: ${fct_product_reviews.product_key} = ${dim_product.product_key} ;;
    relationship: many_to_one
  }
}

# Explore for inventory analysis
explore: inventory_analysis {
  label: "Inventory Analysis"
  description: "Analyze product inventory levels by location"

  from: fct_product_inventory
  view_name: fct_product_inventory

  join: dim_product {
    type: left_outer
    sql_on: ${fct_product_inventory.product_key} = ${dim_product.product_key} ;;
    relationship: many_to_one
  }

  join: dim_location {
    type: left_outer
    sql_on: ${fct_product_inventory.location_key} = ${dim_location.location_key} ;;
    relationship: many_to_one
  }
}

# Explore for purchasing analysis
explore: purchasing_analysis {
  label: "Purchasing Analysis"
  description: "Analyze purchase orders and vendor performance"

  from: fct_purchases
  view_name: fct_purchases

  join: dim_product {
    type: left_outer
    sql_on: ${fct_purchases.product_key} = ${dim_product.product_key} ;;
    relationship: many_to_one
  }

  join: dim_vendor {
    type: left_outer
    sql_on: ${fct_purchases.vendor_key} = ${dim_vendor.vendor_key} ;;
    relationship: many_to_one
  }

  join: dim_employee {
    type: left_outer
    sql_on: ${fct_purchases.employee_key} = ${dim_employee.employee_key} ;;
    relationship: many_to_one
  }

  join: dim_ship_method {
    type: left_outer
    sql_on: ${fct_purchases.ship_method_key} = ${dim_ship_method.ship_method_key} ;;
    relationship: many_to_one
  }

  join: dim_date_order {
    from: dim_date
    type: left_outer
    sql_on: ${fct_purchases.order_date_key} = ${dim_date_order.date_key} ;;
    relationship: many_to_one
  }
}

# Explore for manufacturing/work orders
explore: manufacturing_analysis {
  label: "Manufacturing Analysis"
  description: "Analyze work orders and production metrics"

  from: fct_work_orders
  view_name: fct_work_orders

  join: dim_product {
    type: left_outer
    sql_on: ${fct_work_orders.product_key} = ${dim_product.product_key} ;;
    relationship: many_to_one
  }

  join: dim_scrap_reason {
    type: left_outer
    sql_on: ${fct_work_orders.scrap_reason_key} = ${dim_scrap_reason.scrap_reason_key} ;;
    relationship: many_to_one
  }
}
