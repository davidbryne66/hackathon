import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime
import os
from dotenv import load_dotenv

# Import custom modules
from gemini_client import GeminiClient
from looker_client import LookerClient

# Load environment variables
load_dotenv()

# Page configuration
st.set_page_config(
    page_title="Adventure Works AI Assistant",
    page_icon="🚴",
    layout="wide"
)

# Initialize clients
@st.cache_resource
def init_clients():
    gemini = GeminiClient()
    looker = LookerClient()
    return gemini, looker

# Custom CSS - Enterprise Theme
st.markdown("""
<style>
    /* Main Theme Colors */
    :root {
        --primary-blue: #0066CC;
        --secondary-blue: #4A90E2;
        --success-green: #28A745;
        --warning-orange: #FFA500;
        --error-red: #DC3545;
        --bg-light: #F8F9FA;
        --text-dark: #212529;
        --border-color: #DEE2E6;
    }
    
    /* Header Styling */
    .main-header {
        font-size: 2.8rem;
        font-weight: 700;
        color: var(--primary-blue);
        text-align: center;
        margin-bottom: 0.5rem;
        letter-spacing: -0.5px;
    }
    
    .sub-header {
        font-size: 1.1rem;
        color: #6c757d;
        text-align: center;
        margin-bottom: 2rem;
        font-weight: 400;
    }
    
    /* Metric Cards */
    .metric-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 1.5rem;
        border-radius: 12px;
        color: white;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        transition: transform 0.2s;
    }
    
    .metric-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 12px rgba(0,0,0,0.15);
    }
    
    /* Chat Messages */
    [data-testid="stChatMessage"] {
        background-color: transparent !important;
        padding: 0.5rem 0 !important;
    }
    
    [data-testid="stChatMessageContent"] {
        background-color: transparent !important;
    }
    
    /* Professional Badges */
    .status-badge {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 12px;
        font-size: 0.85rem;
        font-weight: 600;
        margin: 4px;
    }
    
    .badge-success { background-color: #d4edda; color: #155724; }
    .badge-info { background-color: #d1ecf1; color: #0c5460; }
    .badge-warning { background-color: #fff3cd; color: #856404; }
    
    /* Loading Animation */
    @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.5; }
    }
    
    .loading-pulse {
        animation: pulse 2s ease-in-out infinite;
    }
    
    /* Improved Buttons */
    .stButton > button {
        border-radius: 8px;
        font-weight: 500;
        transition: all 0.3s ease;
    }
    
    .stButton > button:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    }
    
    /* Data Table Styling */
    .dataframe {
        border-radius: 8px;
        overflow: hidden;
    }
    
    /* Conversation Cards */
    .conv-card {
        border-left: 4px solid var(--primary-blue);
        padding-left: 12px;
    }
</style>
""", unsafe_allow_html=True)

# Header
st.markdown('<h1 class="main-header">Adventure Works AI Assistant</h1>', unsafe_allow_html=True)
st.markdown('<p class="sub-header">Natural language analytics powered by AI</p>', unsafe_allow_html=True)

# Initialize session state
if 'conversations' not in st.session_state:
    st.session_state.conversations = {}
if 'active_conversation_id' not in st.session_state:
    st.session_state.active_conversation_id = 'default'
    st.session_state.conversations['default'] = {
        'name': 'Chat 1',
        'messages': [],
        'created_at': datetime.now(),
        'total_queries': 0,
        'avg_response_time': 0
    }
if 'message_counter' not in st.session_state:
    st.session_state.message_counter = 0
if 'query_cache' not in st.session_state:
    st.session_state.query_cache = {}
if 'show_query_details' not in st.session_state:
    st.session_state.show_query_details = False

# Initialize clients
try:
    gemini_client, looker_client = init_clients()
except Exception as e:
    st.error(f"Error initializing clients: {str(e)}")
    st.stop()

# Get active conversation early for sidebar
active_conv = st.session_state.conversations[st.session_state.active_conversation_id]

# Sidebar - Conversation Management
with st.sidebar:
    st.markdown("### Conversations")
    
    # New conversation button
    col1, col2 = st.columns([3, 1])
    with col1:
        if st.button("+ New Chat", use_container_width=True, type="primary"):
            new_id = f"chat_{len(st.session_state.conversations) + 1}"
            st.session_state.conversations[new_id] = {
                'name': f"Chat {len(st.session_state.conversations) + 1}",
                'messages': [],
                'created_at': datetime.now(),
                'total_queries': 0,
                'avg_response_time': 0
            }
            st.session_state.active_conversation_id = new_id
            st.rerun()
    with col2:
        # Settings toggle
        if st.button("⚙", use_container_width=True):
            st.session_state.show_query_details = not st.session_state.show_query_details
            st.rerun()
    
    st.divider()
    
    # List conversations
    for conv_id, conv in st.session_state.conversations.items():
        col1, col2 = st.columns([4, 1])
        with col1:
            is_active = conv_id == st.session_state.active_conversation_id
            if st.button(
                f"{'●' if is_active else '○'} {conv['name']} ({len(conv['messages'])})",
                key=f"conv_{conv_id}",
                use_container_width=True,
                type="primary" if is_active else "secondary"
            ):
                st.session_state.active_conversation_id = conv_id
                st.rerun()
        with col2:
            if len(st.session_state.conversations) > 1:
                if st.button("×", key=f"delete_{conv_id}"):
                    del st.session_state.conversations[conv_id]
                    if conv_id == st.session_state.active_conversation_id:
                        st.session_state.active_conversation_id = list(st.session_state.conversations.keys())[0]
                    st.rerun()
    
    st.divider()
    
    # Analytics for active conversation
    if active_conv['total_queries'] > 0:
        st.markdown("**Chat Stats**")
        cols = st.columns(2)
        with cols[0]:
            st.metric("Queries", active_conv['total_queries'])
        with cols[1]:
            st.metric("Avg Time", f"{active_conv.get('avg_response_time', 0):.1f}s")
        st.divider()
    
    st.markdown("### Quick Start")
    
    example_questions = [
        "What were total sales for road bikes last year?",
        "Show me top 5 products by revenue",
        "Which salesperson has the highest sales?",
        "What's the average product rating?",
        "Show me sales by product category",
        "What's our current inventory level?"
    ]
    
    for i, question in enumerate(example_questions):
        if st.button(question, key=f"example_{i}", use_container_width=True):
            st.session_state.pending_question = question
            st.rerun()
    
    st.divider()
    
    st.caption("Data: 2011-2014 | 5 Explores")

# Display conversation history
if active_conv['messages']:
    st.header(f"{active_conv['name']}")
    
    for msg in active_conv['messages']:
        # User question
        with st.chat_message("user"):
            st.write(msg['question'])
        
        # Assistant response
        with st.chat_message("assistant"):
            if 'error' in msg:
                st.error(msg['error'])
                st.info("**Tip:** Try rephrasing your question or use one of the examples from the sidebar.")
            else:
                # Display results
                df = msg['results']
                
                # Response metadata
                response_time = msg.get('response_time', 0)
                row_count = msg.get('row_count', len(df))
                
                # Show insights if available
                if msg.get('insight'):
                    st.markdown(f"**Insight:** {msg['insight']}")
                    st.divider()
                
                # Metadata badges
                col1, col2 = st.columns([1, 1])
                with col1:
                    st.markdown(f'<span class="status-badge badge-success">{row_count} rows</span>', unsafe_allow_html=True)
                with col2:
                    st.markdown(f'<span class="status-badge badge-info">{response_time:.2f}s</span>', unsafe_allow_html=True)
                
                # Key metrics with better formatting
                if not df.empty:
                    metric_cols = st.columns(min(4, len(df.columns)))
                    for idx, col in enumerate(df.columns[:4]):
                        with metric_cols[idx]:
                            if pd.api.types.is_numeric_dtype(df[col]):
                                value = df[col].sum() if len(df) > 1 else df[col].iloc[0]
                                # Format based on size
                                if value > 1000000:
                                    formatted = f"${value/1000000:.1f}M" if 'amount' in col.lower() or 'sales' in col.lower() or 'revenue' in col.lower() else f"{value/1000000:.1f}M"
                                elif value > 1000:
                                    formatted = f"${value/1000:.1f}K" if 'amount' in col.lower() or 'sales' in col.lower() or 'revenue' in col.lower() else f"{value/1000:.1f}K"
                                else:
                                    formatted = f"${value:,.0f}" if 'amount' in col.lower() or 'sales' in col.lower() or 'revenue' in col.lower() else f"{value:,.0f}"
                                
                                st.metric(
                                    label=col.replace('_', ' ').replace('.', ' ').title(),
                                    value=formatted
                                )
                
                st.divider()
                
                # Smart Visualization Selection
                if len(df) > 0:
                    numeric_cols = df.select_dtypes(include=['number']).columns.tolist()
                    categorical_cols = df.select_dtypes(include=['object']).columns.tolist()
                    
                    viz_col1, viz_col2 = st.columns([2, 1])
                    
                    with viz_col1:
                        if len(categorical_cols) > 0 and len(numeric_cols) > 0:
                            # Smart chart selection
                            if len(df) <= 10:
                                # Bar chart for small datasets
                                fig = px.bar(
                                    df,
                                    x=categorical_cols[0],
                                    y=numeric_cols[0],
                                    title=f"{numeric_cols[0].replace('_', ' ').replace('.', ' - ').title()}",
                                    template="plotly_white",
                                    color=numeric_cols[0],
                                    color_continuous_scale="Blues"
                                )
                                fig.update_layout(
                                    xaxis_tickangle=-45,
                                    showlegend=False,
                                    height=350
                                )
                            else:
                                # Line chart for larger datasets
                                fig = px.line(
                                    df.head(20),
                                    x=categorical_cols[0],
                                    y=numeric_cols[0],
                                    title=f"{numeric_cols[0].replace('_', ' ').replace('.', ' - ').title()} Trend",
                                    template="plotly_white",
                                    markers=True
                                )
                                fig.update_layout(height=350)
                            
                            st.plotly_chart(fig, use_container_width=True, key=f"chart_{msg['timestamp']}")
                    
                    with viz_col2:
                        # Additional viz or stats
                        if len(numeric_cols) > 0:
                            st.markdown("**Statistics**")
                            for col in numeric_cols[:2]:
                                st.markdown(f"**{col.replace('_', ' ').replace('.', ' ').title()}**")
                                st.markdown(f"Max: {df[col].max():,.0f}")
                                st.markdown(f"Min: {df[col].min():,.0f}")
                                st.markdown(f"Avg: {df[col].mean():,.0f}")
                    
                    # Data table (collapsed)
                    with st.expander("View Data Table", expanded=False):
                        st.dataframe(df, use_container_width=True, hide_index=True)
                        
                        # Download button
                        csv = df.to_csv(index=False)
                        st.download_button(
                            label="Download CSV",
                            data=csv,
                            file_name=f"results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
                            mime="text/csv",
                            key=f"download_{msg['timestamp']}"
                        )
                
                # Show query details if enabled
                if st.session_state.show_query_details and 'query' in msg:
                    with st.expander("Query Details", expanded=False):
                        st.json(msg['query'])

# Input area at bottom
st.divider()

# Check for pending question from example
default_question = st.session_state.get('pending_question', '')
if 'pending_question' in st.session_state:
    del st.session_state.pending_question

# Chat input
question = st.chat_input(
    "Ask a question about your data...",
    key="chat_input"
)

# If there's a default question, use it
if default_question and not question:
    question = default_question

# Alternative text area for longer questions
with st.expander("Type a longer question"):
    long_question = st.text_area(
        "Detailed question:",
        height=100,
        placeholder="e.g., Show me total sales for road bikes in North America for 2014, broken down by month"
    )
    if st.button("Ask Question", type="primary"):
        question = long_question

# Process question
if question and question.strip():
    start_time = datetime.now()
    
    # Progressive loading states
    status_placeholder = st.empty()
    progress_bar = st.progress(0)
    
    try:
        # Step 1: Generate Looker query using Gemini
        status_placeholder.info("**Analyzing question...**")
        progress_bar.progress(25)
        
        looker_query = gemini_client.translate_to_looker_query(question)
        
        # Step 2: Validate query
        status_placeholder.info("**Fetching data from BigQuery...**")
        progress_bar.progress(50)
        
        # Step 3: Execute query via Looker API
        results = looker_client.run_query(looker_query)
        progress_bar.progress(75)
        
        # Step 4: Process results
        status_placeholder.info("**Processing results...**")
        
        if results:
            # Ensure results is a list
            if not isinstance(results, list):
                results = [results]
            
            # Handle empty results
            if len(results) == 0:
                raise ValueError("No data returned from query")
            
            df = pd.DataFrame(results)
            
            # Verify DataFrame has data
            if df.empty:
                raise ValueError("Query returned empty dataset")
            
            # Calculate response time
            response_time = (datetime.now() - start_time).total_seconds()
            
            # Update conversation stats
            active_conv['total_queries'] += 1
            total_time = active_conv.get('avg_response_time', 0) * (active_conv['total_queries'] - 1)
            active_conv['avg_response_time'] = (total_time + response_time) / active_conv['total_queries']
            
            # Generate AI insight (optional)
            insight = None
            if st.session_state.show_query_details:
                insight = gemini_client.generate_insight(question, df)
            
            progress_bar.progress(100)
            status_placeholder.success(f"**Results retrieved in {response_time:.2f}s**")
            
            # Add to conversation
            active_conv['messages'].append({
                'timestamp': datetime.now(),
                'question': question,
                'results': df,
                'query': looker_query,
                'response_time': response_time,
                'insight': insight,
                'row_count': len(df)
            })
            
            # Clear status
            import time
            time.sleep(1)
            status_placeholder.empty()
            progress_bar.empty()
            
            st.rerun()
        else:
            progress_bar.empty()
            # Add error message to conversation
            active_conv['messages'].append({
                'timestamp': datetime.now(),
                'question': question,
                'error': "No results found for your query."
            })
            status_placeholder.empty()
            st.rerun()
    
    except Exception as e:
        # Add detailed error to conversation
        import traceback
        error_details = f"Error: {str(e)}\n\nDetails: {traceback.format_exc()}"
        
        active_conv['messages'].append({
            'timestamp': datetime.now(),
            'question': question,
            'error': str(e)
        })
        
        # Show error in UI temporarily
        st.error(f"Error processing question: {str(e)}")
        st.code(error_details, language="text")
        
        progress_bar.empty()
        status_placeholder.empty()
        
        import time
        time.sleep(2)
        st.rerun()

# Export conversation button
if active_conv['messages']:
    st.divider()
    
    col1, col2, col3 = st.columns([1, 1, 4])
    
    with col1:
        if st.button("Export", use_container_width=True):
            # Create comprehensive markdown export
            export_text = f"""# 🚴 {active_conv['name']}
**Adventure Works AI Assistant**

---

## 📊 Session Summary
- **Created:** {active_conv['created_at'].strftime('%Y-%m-%d %H:%M')}
- **Total Queries:** {active_conv['total_queries']}
- **Avg Response Time:** {active_conv.get('avg_response_time', 0):.2f}s

---

"""
            
            for idx, msg in enumerate(active_conv['messages'], 1):
                export_text += f"## Query {idx}\n\n"
                export_text += f"**Question:** {msg['question']}\n\n"
                
                if 'error' in msg:
                    export_text += f"**Status:** ❌ Error\n\n"
                    export_text += f"**Message:** {msg['error']}\n\n"
                else:
                    export_text += f"**Status:** ✅ Success\n\n"
                    export_text += f"**Rows Returned:** {len(msg['results'])}\n\n"
                    export_text += f"**Response Time:** {msg.get('response_time', 0):.2f}s\n\n"
                    
                    if msg.get('insight'):
                        export_text += f"**AI Insight:** {msg['insight']}\n\n"
                    
                    export_text += "**Data:**\n\n"
                    export_text += msg['results'].to_markdown(index=False) + "\n\n"
                
                export_text += "---\n\n"
            
            export_text += f"\n*Exported: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n"
            
            st.download_button(
                label="Download Report",
                data=export_text,
                file_name=f"adventure_works_analysis_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md",
                mime="text/markdown",
                use_container_width=True
            )
    
    with col2:
        # Help button
        if st.button("Help", use_container_width=True):
            st.session_state.show_help = not st.session_state.get('show_help', False)
            st.rerun()

# Help modal
if st.session_state.get('show_help', False):
    with st.expander("User Guide", expanded=True):
        st.markdown("""
        ### How to Use
        
        **Ask Questions in Plain English:**
        - "What were total sales for road bikes last year?"
        - "Show me top 5 products by revenue"
        - "Which salesperson has the highest sales?"
        
        **Features:**
        - **Multiple Chats:** Create separate conversations for different analyses
        - **Settings:** Toggle query details view to see underlying LookML queries
        - **Auto Viz:** Charts automatically generated based on your data
        - **Export:** Download conversations as markdown reports
        - **Stats:** Track query performance and response times
        
        **Available Data:**
        - **Sales** (2011-2014): Orders, revenue, customers, products
        - **Inventory:** Stock levels by location
        - **Reviews:** Customer product ratings
        - **Purchasing:** Vendor orders and procurement
        - **Manufacturing:** Work orders and scrap rates
        
        **Tips:**
        - Be specific about time periods ("last year", "2014", "Q1")
        - Mention product categories ("road bikes", "helmets")
        - Ask for rankings ("top 5", "highest", "lowest")
        - Request breakdowns ("by month", "by category", "by region")
        """)
        
        if st.button("Close Help", type="primary"):
            st.session_state.show_help = False
            st.rerun()

# Footer
st.divider()
st.caption("Powered by Looker, BigQuery, and Gemini AI | Adventure Works Analytics")

