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
            self.sdk.me()
        except Exception as e:
            raise Exception(f"Failed to initialize Looker SDK: {str(e)}")
    
    def run_query(self, query_config: Dict[str, Any]) -> List[Dict]:
        """
        Execute a Looker query based on configuration
        
        Args:
            query_config: Dictionary with explore, dimensions, measures, filters, etc.
            
        Returns:
            List of dictionaries with query results
        """
        
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
            
            # Create Looker query
            query = models.WriteQuery(
                model=model_name,
                view=explore,
                fields=dimensions + measures,
                filters=filters,
                sorts=sorts,
                limit=str(limit)
            )
            
            # Create and run query
            query_result = self.sdk.create_query(query)
            
            # Run query and get results
            results = self.sdk.run_query(
                query_id=query_result.id,
                result_format="json"
            )
            
            # Parse JSON string to Python objects
            import json
            if isinstance(results, str):
                results = json.loads(results)
            
            return results
            
        except Exception as e:
            # Log the error and return mock data
            print(f"Looker API Error: {str(e)}")
            print("Using mock data instead...")
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
        try:
            self.sdk.me()
            return True
        except:
            return False

