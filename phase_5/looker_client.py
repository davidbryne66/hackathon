import os
import looker_sdk
from looker_sdk import models40 as models
from typing import Dict, Any, List
import pandas as pd

class LookerClient:
    """Client for interacting with Looker API"""
    
    def __init__(self):
        """Initialize Looker SDK"""
        # Looker SDK reads from looker.ini or environment variables
        try:
            self.sdk = looker_sdk.init40()
            # Test connection
            me = self.sdk.me()
            print(f"Looker connected successfully as: {me.display_name}")
        except Exception as e:
            print(f"Looker SDK initialization warning: {str(e)}")
            print("Will use mock data as fallback.")
            self.sdk = None
    
    def run_query(self, query_config: Dict[str, Any]) -> List[Dict]:
        """
        Execute a Looker query based on configuration
        
        Args:
            query_config: Dictionary with explore, dimensions, measures, filters, etc.
            
        Returns:
            List of dictionaries with query results
        """
        
        # If SDK not initialized, use mock data
        if self.sdk is None:
            print("Looker SDK not available, using mock data")
            return self._get_mock_data(query_config)
        
        try:
            # Extract query parameters
            explore = query_config.get('explore', 'sales_analysis')
            dimensions = query_config.get('dimensions', [])
            measures = query_config.get('measures', [])
            filters = query_config.get('filters', {})
            sorts = query_config.get('sorts', [])
            limit = query_config.get('limit', 100)
            
            # Map explore names to model
            model_name = "adventure_works"
            
            # Normalize filters - convert lists to comma-separated strings
            normalized_filters = {}
            for key, value in filters.items():
                if isinstance(value, list):
                    # Convert list to comma-separated string
                    normalized_filters[key] = ','.join(str(v) for v in value)
                else:
                    normalized_filters[key] = str(value)
            
            print(f"   Running Looker query:")
            print(f"   Model: {model_name}")
            print(f"   Explore: {explore}")
            print(f"   Dimensions: {dimensions}")
            print(f"   Measures: {measures}")
            print(f"   Filters: {normalized_filters}")
            
            # Create Looker query
            query = models.WriteQuery(
                model=model_name,
                view=explore,
                fields=dimensions + measures,
                filters=normalized_filters,
                sorts=sorts,
                limit=str(limit)
            )
            
            # Create and run query
            query_result = self.sdk.create_query(query)
            print(f"   Query ID: {query_result.id}")
            
            # Run query and get results
            results = self.sdk.run_query(
                query_id=query_result.id,
                result_format="json"
            )
            
            # Parse JSON string to Python objects
            import json
            if isinstance(results, str):
                results = json.loads(results)
            
            print(f"Query successful, returned {len(results) if isinstance(results, list) else 'N/A'} rows")
            return results
            
        except Exception as e:
            # Log the error details
            import traceback
            print(f"   Looker API Error: {str(e)}")
            print(f"   Error type: {type(e).__name__}")
            print(f"   Traceback:")
            traceback.print_exc()
            print("   Using mock data as fallback...")
            return self._get_mock_data(query_config)
    
    def _get_mock_data(self, query_config: Dict[str, Any]) -> List[Dict]:
        """
        Generate mock data for demo when Looker API is unavailable
        
        Args:
            query_config: Query configuration
            
        Returns:
            Mock data matching the query structure
        """
        
        explore = query_config.get('explore', 'sales_analysis')
        
        if explore == 'sales_analysis':
            return [
                {
                    'dim_product.category_name': 'Bikes',
                    'fct_sales.total_sales_amount': 28318144.65
                },
                {
                    'dim_product.category_name': 'Components',
                    'fct_sales.total_sales_amount': 11799076.83
                },
                {
                    'dim_product.category_name': 'Clothing',
                    'fct_sales.total_sales_amount': 2117613.45
                },
                {
                    'dim_product.category_name': 'Accessories',
                    'fct_sales.total_sales_amount': 928932.52
                }
            ]
        
        elif explore == 'product_reviews':
            return [
                {
                    'dim_product.product_name': 'Road-150 Red, 62',
                    'fct_product_reviews.average_rating': 5.0,
                    'fct_product_reviews.review_count': 1
                },
                {
                    'dim_product.product_name': 'Road-650 Black, 58',
                    'fct_product_reviews.average_rating': 4.0,
                    'fct_product_reviews.review_count': 2
                }
            ]
        
        elif explore == 'inventory_analysis':
            return [
                {
                    'dim_product.product_name': 'Mountain-100 Silver, 38',
                    'dim_location.location_name': 'Tool Crib',
                    'fct_product_inventory.total_inventory': 427
                },
                {
                    'dim_product.product_name': 'Mountain-100 Silver, 42',
                    'dim_location.location_name': 'Miscellaneous Storage',
                    'fct_product_inventory.total_inventory': 324
                }
            ]
        
        else:
            return [
                {'message': 'Mock data - Looker API not connected'},
                {'explore': explore}
            ]
    
    def test_connection(self) -> bool:
        """Test if Looker connection is working"""
        if self.sdk is None:
            return False
        try:
            self.sdk.me()
            return True
        except Exception as e:
            print(f"Connection test failed: {str(e)}")
            return False

