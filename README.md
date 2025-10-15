# Adventure Works AI Hackathon

> **End-to-End Analytics Solution with GenAI Integration**

A complete data analytics pipeline from raw OLTP data to conversational AI interface, demonstrating modern data engineering and AI integration techniques.

---

## 📋 Table of Contents

- [Problem Statement](#problem-statement)
- [Solution Overview](#solution-overview)
- [Project Deliverables](#project-deliverables)
- [Technology Stack](#technology-stack)
- [Phase Overview](#phase-overview)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Success Metrics](#success-metrics)

---

## Problem Statement

### Business Challenge

Adventure Works, a bicycle manufacturer, has comprehensive transactional data in an OLTP database, but faces several analytics challenges:

1. **Complex Data Structure:** 38+ normalized tables designed for transactional efficiency, not analytical queries
2. **Technical Barrier:** Business users need SQL expertise to answer simple questions
3. **Scattered Business Logic:** Calculations and metrics inconsistent across different tools
4. **Self-Service Gap:** Analysts can't explore data independently without engineering support
5. **Insight Delay:** Time from question to answer takes days due to manual query writing

### Project Goal

Build an **end-to-end analytics solution** that transforms raw OLTP data into an AI-powered conversational interface where anyone can ask questions in plain English and get instant insights with visualizations.

---

## Solution Overview

### The Journey: OLTP → Star Schema → Semantic Layer → AI Interface

```
Adventure Works OLTP Database (38 tables)
    ↓
Phase 1: Dimensional Data Modeling (Star Schema Design)
    ↓
Phase 2: Source-to-Target Mapping (Transformation Logic)
    ↓
Phase 3: Data Transformation (Dataform on BigQuery)
    ├── 5 Fact Tables
    └── 14 Dimension Tables
    ↓
Phase 4: Looker LookML Semantic Layer
    ├── 19 Views
    └── 5 Explores
    ↓
Phase 5: Conversational Analytics Interface
    ├── Gemini AI (Natural Language Understanding)
    ├── Looker API (Data Access)
    └── Streamlit UI (Interactive Chat)
    ↓
Business Users Ask Questions in Plain English
```

### Key Innovation: GenAI Integration

Throughout the pipeline, Generative AI assists with:

- **Phase 1:** Schema understanding and star schema design
- **Phase 2:** Transformation logic documentation
- **Phase 3:** SQL transformation generation and debugging
- **Phase 4:** LookML code generation and field descriptions
- **Phase 5:** Natural language to query translation

---

## Project Deliverables

### Phase 1: Dimensional Data Modeling

**Deliverables:**

- ✅ Star schema design (5 facts, 14 dimensions)
- ✅ BigQuery DDL for all tables
- ✅ Entity-relationship diagrams
- ✅ Grain definitions for each fact table

**Output Files:** `schema.txt`, `ddl.sql`, `diagram.md`

### Phase 2: Source-to-Target Mapping

**Deliverables:**

- ✅ Comprehensive field-level mappings
- ✅ Transformation logic documentation
- ✅ Business rules and data quality notes
- ✅ Expected row counts

**Output Files:** `stt.md`

### Phase 3: Data Transformation with Dataform

**Deliverables:**

- ✅ Dataform project (19 SQLX files)
- ✅ 5 fact tables in BigQuery
- ✅ 14 dimension tables in BigQuery
- ✅ Source declarations and dependencies
- ✅ Automated build pipeline

**Key Tables:**

- fct_sales (~121K rows)
- fct_product_reviews (4 rows)
- fct_product_inventory (~1K rows)
- fct_purchases (~8K rows)
- fct_work_orders (~72K rows)

### Phase 4: Looker LookML Semantic Layer

**Deliverables:**

- ✅ LookML model with 5 explores
- ✅ 19 view files (facts + dimensions)
- ✅ Field definitions with descriptions
- ✅ Join logic and relationships
- ✅ Measures and dimension hierarchies

**Explores:**

- sales_analysis
- product_reviews
- inventory_analysis
- purchasing_analysis
- manufacturing_analysis

### Phase 5: Conversational Analytics Interface

**Deliverables:**

- ✅ Streamlit web application
- ✅ Gemini AI integration for NL→Query
- ✅ Looker API integration
- ✅ Multi-conversation management
- ✅ Smart visualizations (Plotly)
- ✅ Professional export reports

**Features:**

- Natural language querying
- Auto-generated visualizations
- Performance tracking
- Conversation history
- In-app help system

---

## Technology Stack

### Data Engineering

| Layer                    | Technology            | Purpose                  |
| ------------------------ | --------------------- | ------------------------ |
| **Source**         | BigQuery              | OLTP database storage    |
| **Transformation** | Google Cloud Dataform | SQL-based ETL            |
| **Warehouse**      | BigQuery              | Star schema storage      |
| **Semantic Layer** | Looker LookML         | Business logic & metrics |

### AI & Application

| Layer                   | Technology              | Purpose                        |
| ----------------------- | ----------------------- | ------------------------------ |
| **AI Engine**     | Google Gemini 2.0 Flash | Natural language understanding |
| **API**           | Looker API 4.0          | Data access                    |
| **Frontend**      | Streamlit               | Web interface                  |
| **Visualization** | Plotly Express          | Interactive charts             |
| **Processing**    | Pandas                  | Data manipulation              |

### Development

| Tool        | Purpose                  |
| ----------- | ------------------------ |
| Python 3.8+ | Application development  |
| Git         | Version control          |
| Markdown    | Documentation            |
| SQLX        | Dataform transformations |
| LookML      | Semantic definitions     |

---

## Phase Overview

### Phase 1: Dimensional Data Modeling (2-3 hours)

**What:** Design star schema for analytical queries
**Input:** OLTP schema (CSV)
**Output:** Star schema design, DDL, diagrams
**GenAI Use:** Schema understanding, dimension/fact identification, DDL generation

**Key Concepts:** Star schema, fact tables, dimension tables, grain, surrogate keys

**Documentation:** `phase_1/prompt.txt`

---

### Phase 2: Source-to-Target Mapping (1-2 hours)

**What:** Document transformation logic from OLTP to star schema
**Input:** OLTP schema + Phase 1 star schema
**Output:** Comprehensive field mappings
**GenAI Use:** Mapping generation, transformation logic, business rules

**Key Concepts:** Field mappings, join logic, data types, business rules

**Documentation:** `phase_2/prompt.txt`

---

### Phase 3: Data Transformation with Dataform (3-4 hours)

**What:** Build and execute ETL pipeline in BigQuery
**Input:** Phase 2 mappings
**Output:** 19 tables in BigQuery (star schema)
**GenAI Use:** SQLX generation, debugging, optimization

**Key Concepts:** Dataform, SQLX, dependencies, incremental builds

**Documentation:** `phase_3/README.md`, `phase_3/prompt.txt`

---

### Phase 4: Looker LookML Semantic Layer (2-3 hours)

**What:** Create business-friendly semantic layer
**Input:** Phase 3 BigQuery tables
**Output:** LookML project with 5 explores
**GenAI Use:** View file generation, measure definitions, field descriptions

**Key Concepts:** LookML, views, explores, joins, measures, dimensions

**Documentation:** `phase_4/README.md`, `phase_4/prompt.txt`

---

### Phase 5: Conversational Analytics Interface (3-4 hours)

**What:** Build AI-powered chat interface for data queries
**Input:** Phase 4 LookML semantic layer
**Output:** Streamlit web application
**GenAI Use:** Natural language to query translation, insight generation

**Key Concepts:** Gemini API, Looker API, Streamlit, prompt engineering

**Documentation:** `phase_5/README.md`, `phase_5/prompt.txt`

---

## Getting Started

### Prerequisites

**Accounts & Access:**

- Google Cloud Platform account
- BigQuery access
- Looker instance access
- Gemini API key

**Technical Requirements:**

- Python 3.8+
- Git
- Text editor or IDE

### Quick Start by Phase

#### For Phases 1-2 (Design):

```bash
# Phase 1: Read prompt.txt and generate artifacts
cd phase_1
cat prompt.txt
# Follow incremental prompts with AI assistant

# Phase 2: Create source-to-target mapping
cd ../phase_2
cat prompt.txt
# Follow incremental prompts with AI assistant
```

#### For Phases 3-5 (Implementation):

```bash
# Phase 3: Deploy Dataform
cd phase_3
cat README.md     # Overview
cat prompt.txt    # Build instructions
# Upload dataform/ to Google Cloud Dataform

# Phase 4: Deploy LookML
cd ../phase_4
cat README.md     # Overview
cat prompt.txt    # Build instructions
# Upload lookml/ to Looker

# Phase 5: Run Application
cd ../phase_5
cat README.md     # Overview
cp .env.example .env
# Add your API keys to .env
pip install -r requirements.txt
streamlit run app.py
```

### Recommended Workflow

1. **Understand the Problem:** Read this README completely
2. **Study Each Phase:** Review phase-specific documentation
3. **Follow Incrementally:** Build phase by phase, don't skip
4. **Use AI Assistant:** Leverage prompt.txt files with AI tools
5. **Validate Thoroughly:** Test each phase before moving forward
6. **Document Learnings:** Note challenges and solutions

---

## Project Structure

```
hackathon/
├── README.md                               ← This file (start here)
├── raw_schema.csv    ← OLTP schema reference
├── info.txt                                ← Original hackathon details
│
├── phase_1/                                ← Dimensional Modeling
│   ├── prompt.txt                          (build instructions)
│   ├── schema.txt                          (star schema design)
│   ├── ddl.sql                             (BigQuery DDL)
│   └── diagram.md                          (ER diagrams)
│
├── phase_2/                                ← Source-to-Target Mapping
│   ├── prompt.txt                          (build instructions)
│   └── stt.md                              (field mappings)
│
├── phase_3/                                ← Data Transformation
│   ├── README.md                           (overview & deployment)
│   ├── prompt.txt                          (build instructions)
│   └── dataform/                           (Dataform project)
│       ├── workflow_settings.yaml
│       └── definitions/
│           ├── staging/sources.js
│           ├── dimensions/*.sqlx           (14 files)
│           └── facts/*.sqlx                (5 files)
│
├── phase_4/                                ← Semantic Layer
│   ├── README.md                           (overview & deployment)
│   ├── prompt.txt                          (build instructions)
│   └── lookml/                             (LookML project)
│       ├── adventure_works.model.lkml
│       └── views/*.view.lkml               (19 files)
│
└── phase_5/                                ← Conversational Interface
    ├── README.md                           (overview & usage)
    ├── prompt.txt                          (build instructions)
    ├── app.py                              (Streamlit app)
    ├── gemini_client.py                    (AI integration)
    ├── looker_client.py                    (Data access)
    ├── requirements.txt                    (dependencies)
    └── .env.example                        (configuration template)
```

---

## Success Metrics

### Technical Milestones

**Phase 1:** ✅ Star schema designed with clear grain definitions
**Phase 2:** ✅ Complete field mappings for 19 tables
**Phase 3:** ✅ 19 tables created in BigQuery with expected row counts
**Phase 4:** ✅ 5 explores working in Looker, all joins functional
**Phase 5:** ✅ Natural language queries returning correct results with visualizations

### Business Value

**Before:**

- Days to answer analytical questions
- Required SQL expertise
- Inconsistent business logic
- Limited self-service capability
- Static reports only

**After:**

- Seconds to get insights
- Plain English questions
- Consistent semantic layer
- Full self-service analytics
- Interactive visualizations + conversation history

### Learning Outcomes

By completing this hackathon, you will have hands-on experience with:

- ✅ Dimensional data modeling (Kimball methodology)
- ✅ Modern ETL with Dataform
- ✅ Semantic layer design with LookML
- ✅ AI/LLM integration for analytics
- ✅ Full-stack data application development
- ✅ Google Cloud Platform (BigQuery, Dataform)
- ✅ Prompt engineering and GenAI workflows

---

## Data Coverage

**Business Domains:**

- Sales & Revenue (~121K transactions)
- Customer Feedback (4 reviews)
- Inventory Management (~1K records)
- Procurement (~8K purchase orders)
- Manufacturing (~72K work orders)

**Time Period:** 2011-2014 (4 years)
**Geographic Scope:** North America (primary), Europe, Pacific
**Product Categories:** Bikes, Components, Clothing, Accessories

---

## Key Features Demonstrated

### Data Engineering

- Star schema design and implementation
- Source-to-target transformation logic
- Surrogate key generation
- Slowly changing dimensions (Type 1)
- Date dimension generation
- BigQuery optimization

### Semantic Modeling

- Business-friendly field definitions
- Measure calculations
- Dimension hierarchies
- Conformed dimensions
- Reusable explores

### AI/ML Integration

- Natural language understanding
- Query structure generation
- Prompt engineering
- LLM context management
- Insight generation

### Application Development

- Interactive web interfaces
- Real-time data visualization
- Session state management
- Multi-conversation handling
- Error handling and fallbacks

---

## Support & Resources

### Documentation

- Each phase has dedicated README.md and/or prompt.txt
- Code includes inline comments
- Schema designs include descriptions

### External Resources

- **BigQuery:** https://cloud.google.com/bigquery/docs
- **Dataform:** https://cloud.google.com/dataform/docs
- **Looker:** https://cloud.google.com/looker/docs
- **Gemini AI:** https://ai.google.dev/docs
- **Streamlit:** https://docs.streamlit.io

### GenAI Integration

All phases include prompt.txt files designed for use with AI assistants (like this one!) to:

- Generate code and configurations
- Debug issues
- Explain concepts
- Optimize solutions

---

## Acknowledgments

**Dataset:** Adventure Works sample database (Microsoft)
**Inspiration:** Kimball dimensional modeling methodology
**Technologies:** Google Cloud Platform, Looker, Gemini AI, Streamlit

---

## License

Educational project for hackathon purposes.

---

**Built to demonstrate modern data analytics with GenAI integration**
