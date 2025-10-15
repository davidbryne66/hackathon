import os
import json
import google.generativeai as genai
from typing import Dict, Any

class GeminiClient:
    """Client for interacting with Google Gemini API for natural language to Looker query translation"""
    
    def __init__(self):
        """Initialize Gemini client with API key"""
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            raise ValueError("GEMINI_API_KEY not found in environment variables")
        
        genai.configure(api_key=api_key)
        # Use latest Gemini model
        self.model = genai.GenerativeModel('gemini-2.0-flash')
        
        # LookML context from Phase 4
        self.lookml_context = """
You are a data analyst assistant for Adventure Works, a bicycle manufacturer.
Convert user questions to Looker queries using the fields below.

=== EXPLORE: sales_analysis ===
Use for: Sales, revenue, orders, customers, territories
Dimensions:
- dim_product.category_name (e.g., Bikes, Clothing, Accessories)
- dim_product.subcategory_name (e.g., Mountain Bikes, Road Bikes)
- dim_product.product_name (Specific product name)
- dim_customer.customer_name
- dim_customer.customer_type (Individual or Store)
- dim_territory.territory_name (e.g., Northwest, Northeast)
- dim_territory.country_name (e.g., United States, Canada)
- dim_date_order.year, dim_date_order.month_name, dim_date_order.quarter (Order date)
- dim_date_ship.year, dim_date_ship.month_name (Ship date - optional)
- dim_salesperson.salesperson_name
Measures:
- fct_sales.total_sales_amount (Revenue)
- fct_sales.order_count (Number of orders)
- fct_sales.average_order_value
- fct_sales.line_item_count

=== EXPLORE: product_reviews ===
Use for: Product ratings, reviews, customer feedback
Dimensions:
- dim_product.product_name
- dim_product.category_name
- dim_product.subcategory_name
- fct_product_reviews.reviewer_name
- fct_product_reviews.sentiment
Measures:
- fct_product_reviews.average_rating (1-5 stars)
- fct_product_reviews.review_count

=== EXPLORE: inventory_analysis ===
Use for: Stock levels, inventory, warehouse, product availability
Dimensions:
- dim_product.product_name (Product name)
- dim_product.category_name (Bikes, Components, etc.)
- dim_product.subcategory_name (Mountain Bikes, etc.)
- dim_location.location_name (Warehouse/facility name)
- fct_product_inventory.stock_status (Out of Stock, Low Stock, Medium Stock, Well Stocked)
- fct_product_inventory.shelf (Shelf location)
Measures:
- fct_product_inventory.total_inventory (Total quantity on hand)
- fct_product_inventory.average_inventory
- fct_product_inventory.out_of_stock_count
- fct_product_inventory.low_stock_count
- fct_product_inventory.inventory_location_count

=== EXPLORE: purchasing_analysis ===
Use for: Vendor orders, procurement, purchasing
Dimensions:
- dim_vendor.vendor_name
- dim_product.product_name
- dim_product.category_name
- dim_employee.employee_name (Purchasing employee)
- dim_date_order.year, dim_date_order.month_name (Order date)
Measures:
- fct_purchases.total_order_quantity
- fct_purchases.total_received_quantity
- fct_purchases.total_line_total (Purchase amount)

=== EXPLORE: manufacturing_analysis ===
Use for: Production, work orders, scrap, quality
Dimensions:
- dim_product.product_name
- dim_scrap_reason.scrap_reason_name
Measures:
- fct_work_orders.total_order_qty
- fct_work_orders.total_scrapped_qty
- fct_work_orders.scrap_rate

Date range: 2011-2014
"""
    
    def translate_to_looker_query(self, user_question: str, conversation_history: list = None) -> Dict[str, Any]:
        """
        Translate natural language question to Looker query structure
        
        Args:
            user_question: Natural language question from user
            conversation_history: List of previous messages for context (optional)
            
        Returns:
            Dictionary with explore, dimensions, measures, and filters
        """
        
        # Build conversation context if available
        context_section = ""
        if conversation_history and len(conversation_history) > 0:
            context_section = "\n\nCONVERSATION HISTORY (for context):\n"
            # Include last 3 messages for context
            recent_messages = conversation_history[-3:] if len(conversation_history) > 3 else conversation_history
            for i, msg in enumerate(recent_messages, 1):
                context_section += f"{i}. User asked: \"{msg.get('question', '')}\"\n"
                if 'query' in msg:
                    context_section += f"   Explored: {msg['query'].get('explore', 'N/A')}, "
                    context_section += f"Dimensions: {msg['query'].get('dimensions', [])}, "
                    context_section += f"Filters: {msg['query'].get('filters', {})}\n"
            context_section += "\nUse this context to understand references like 'compare it', 'same data', 'that category', etc.\n"
        
        prompt = f"""{self.lookml_context}
{context_section}
USER QUESTION: "{user_question}"

Convert this to a Looker query. Return ONLY valid JSON with this structure:

CRITICAL RULES FOR ACTIONABLE QUERIES:
1. ALWAYS include at least one dimension AND at least one measure
2. If conversation history is provided, use it to resolve references:
   - "compare it to" or "vs" → add to filters or dimensions from previous query
   - "same thing for" or "what about" → reuse explore/measures, change dimension/filter
   - "now show" or "break down by" → keep filters, change dimension
   - "drill into" → add more specific dimension or filter
3. Choose the most relevant explore based on the question topic
4. Use appropriate dimensions for grouping that tell a story:
   - For "what" questions: use category, product, or name dimensions
   - For "when" questions: use year, month, or quarter dimensions
   - For "where" questions: use territory, location, or region dimensions
   - For comparisons: include the dimension being compared (e.g., year for year-over-year)
5. Use appropriate measures for metrics (totals, counts, averages)
6. Add filters to narrow scope when mentioned (year ranges, categories, etc.)
7. Sort by the main measure descending to show top performers
8. Set reasonable limits (Top N: exact number, comparisons: items compared, categories: 10-15, trends: 12-24)
9. Make queries visualization-friendly: pair one dimension with one measure

EXAMPLES:

Question: "What were total sales for road bikes last year?"
{{
    "explore": "sales_analysis",
    "dimensions": ["dim_product.subcategory_name"],
    "measures": ["fct_sales.total_sales_amount"],
    "filters": {{"dim_product.subcategory_name": "Road Bikes", "dim_date_order.year": "2014"}},
    "sorts": ["fct_sales.total_sales_amount desc"],
    "limit": 10
}}

Question: "Show me current inventory levels by category"
{{
    "explore": "inventory_analysis",
    "dimensions": ["dim_product.category_name"],
    "measures": ["fct_product_inventory.total_inventory"],
    "filters": {{}},
    "sorts": ["fct_product_inventory.total_inventory desc"],
    "limit": 10
}}

Question: "Show me top 5 products by revenue"
{{
    "explore": "sales_analysis",
    "dimensions": ["dim_product.product_name"],
    "measures": ["fct_sales.total_sales_amount"],
    "filters": {{}},
    "sorts": ["fct_sales.total_sales_amount desc"],
    "limit": 5
}}

Question: "What's the average product rating by category?"
{{
    "explore": "product_reviews",
    "dimensions": ["dim_product.category_name"],
    "measures": ["fct_product_reviews.average_rating"],
    "filters": {{}},
    "sorts": ["fct_product_reviews.average_rating desc"],
    "limit": 10
}}

Question: "Show me sales by month for 2014"
{{
    "explore": "sales_analysis",
    "dimensions": ["dim_date_order.month_name"],
    "measures": ["fct_sales.total_sales_amount"],
    "filters": {{"dim_date_order.year": "2014"}},
    "sorts": ["fct_sales.total_sales_amount desc"],
    "limit": 12
}}

CONTEXT-AWARE EXAMPLES:
Previous: User asked "Show me sales by category for 2014"
Current: "Now compare it to 2013"
{{
    "explore": "sales_analysis",
    "dimensions": ["dim_product.category_name", "dim_date_order.year"],
    "measures": ["fct_sales.total_sales_amount"],
    "filters": {{"dim_date_order.year": "2013,2014"}},
    "sorts": ["fct_sales.total_sales_amount desc"],
    "limit": 10
}}

Previous: User asked "Show me sales for Bikes"
Current: "What about Components?"
{{
    "explore": "sales_analysis",
    "dimensions": ["dim_product.category_name"],
    "measures": ["fct_sales.total_sales_amount"],
    "filters": {{"dim_product.category_name": "Components"}},
    "sorts": ["fct_sales.total_sales_amount desc"],
    "limit": 10
}}

Now convert the user's question. Return ONLY the JSON, no markdown, no explanations:
"""

        try:
            response = self.model.generate_content(prompt)
            response_text = response.text.strip()
            
            # Clean up response (remove markdown code blocks if present)
            if response_text.startswith('```'):
                lines = response_text.split('\n')
                # Remove first and last lines if they're markdown delimiters
                if lines[0].startswith('```'):
                    lines = lines[1:]
                if lines and lines[-1].startswith('```'):
                    lines = lines[:-1]
                response_text = '\n'.join(lines).strip()
            
            # Remove any "json" prefix
            if response_text.lower().startswith('json'):
                response_text = response_text[4:].strip()
            
            # Parse JSON
            query = json.loads(response_text)
            
            # Validate required fields
            required_fields = ['explore', 'dimensions', 'measures']
            for field in required_fields:
                if field not in query:
                    raise ValueError(f"Missing required field: {field}")
            
            # Ensure dimensions and measures are lists with at least one item
            if not isinstance(query['dimensions'], list) or len(query['dimensions']) == 0:
                raise ValueError("dimensions must be a non-empty list")
            if not isinstance(query['measures'], list) or len(query['measures']) == 0:
                raise ValueError("measures must be a non-empty list")
            
            # Set defaults for optional fields
            if 'filters' not in query:
                query['filters'] = {}
            if 'sorts' not in query:
                query['sorts'] = []
            if 'limit' not in query:
                query['limit'] = 10
            
            return query
            
        except json.JSONDecodeError as e:
            # Fallback: simple sales query
            print(f"JSON decode error: {str(e)}")
            print(f"Response was: {response_text[:200]}")
            return {
                "explore": "sales_analysis",
                "dimensions": ["dim_product.category_name"],
                "measures": ["fct_sales.total_sales_amount"],
                "filters": {},
                "sorts": ["fct_sales.total_sales_amount desc"],
                "limit": 10
            }
        except Exception as e:
            print(f"Error translating question: {str(e)}")
            # Return fallback instead of raising
            return {
                "explore": "sales_analysis",
                "dimensions": ["dim_product.category_name"],
                "measures": ["fct_sales.total_sales_amount"],
                "filters": {},
                "sorts": [],
                "limit": 10
            }
    
    def generate_insight(self, question: str, results_df) -> str:
        """
        Generate natural language insight from query results
        
        Args:
            question: Original user question
            results_df: Pandas DataFrame with results
            
        Returns:
            Natural language summary of results
        """
        
        # Convert first few rows to string for context
        data_sample = results_df.head(5).to_string()
        
        prompt = f"""
Based on this data query result, provide a brief, conversational summary (2-3 sentences).

QUESTION: {question}

DATA:
{data_sample}

SUMMARY:"""

        try:
            response = self.model.generate_content(prompt)
            return response.text.strip()
        except Exception as e:
            return f"Query returned {len(results_df)} results."

