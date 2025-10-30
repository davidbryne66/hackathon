# **Adventure Works AI Hackathon - Presentation Structure**

### **1. Introduction: The Hackathon Premise**

**The Challenge:**

- Hackathon focused on integrating Generative AI into data & analytics workflows
- Transform Adventure Works OLTP data (38 tables) into a conversational analytics interface
- Build end-to-end solution: Raw data → Star schema → Semantic layer → AI chat interface

**The Goal:**

- Enable business users to ask questions in plain English
- Get instant insights with visualizations
- Demonstrate how AI can accelerate data project development

---

### **2. Phase-by-Phase Walkthrough**

**Initial Context Building**

- **Goal:** Establish preliminary knowledge and build context
- **Approach:** Had Cursor AI read the hackathon documentation first, then walked through it together
- **Generated:** Shared understanding of requirements and constraints

**Phase 1: Dimensional Data Modeling (25-30 mins)**

- **Goal:** Transform 38 OLTP tables into analytics-optimized star schema
- **Approach:** Used Cursor AI with the raw schema from BigQuery and incremental prompts
- **Generated:** Star schema design, BigQuery DDL scripts, ER diagrams, prompt file

**Phase 2: Source-to-Target Mapping (10-15 mins)**

- **Goal:** Document how each OLTP field maps to the star schema
- **Approach:** Cursor AI generated field-level mappings using Phase 1 output and raw schema
- **Generated:** Complete mapping document, business rules, data quality notes, prompt file

**Phase 3: Data Transformation (3 hours)**

- **Goal:** Build ETL pipeline to populate the star schema in BigQuery
- **Approach:** Educated Cursor on Dataform first, then used incremental prompting for SQLX files
- **Generated:** Dataform project with 19 SQLX files, 19 BigQuery tables, prompt file

**Phase 4: Looker LookML Semantic Layer (30 mins)**

- **Goal:** Create business-friendly interface to the data
- **Approach:** Educated Cursor on LookML first, then generated views and explores
- **Generated:** LookML project with 5 explores and 19 views, prompt file

**Phase 5: Conversational Interface (1 hour)**

- **Goal:** Build natural language interface for business users
- **Approach:** Cursor AI generated Streamlit app with Gemini integration
- **Generated:** Web application with chat interface, auto-visualizations, prompt file

---

### **3. Key Learnings & Limitations**

**Two Key Learnings:**

**1. Educate the Agent First**

- **Dataform Pain Point:** Cursor struggled with SQLX formatting initially
- **Solution:** We educated Cursor on Dataform syntax before asking it to generate code
- **Validation:** Same approach with LookML - much faster results
- **Takeaway:** Invest time upfront to teach the agent domain-specific requirements

**2. Incremental Prompting with Human-in-the-Loop**

- **Approach:** Break complex tasks into smaller, manageable prompts
- **HITL:** Human reviews, validates, and iterates on each step
- **Result:** Higher quality output and faster iteration cycles
- **Example:** Instead of "build the entire Dataform project," we prompted for sources first, then dimensions, then facts

**Limitations (With More Time, I Would Focus On):**

- **Agent accuracy:** The agent got about 75-85% there in most cases, with some obvious blunders that needed human correction. I would spend time identifying these edge cases and tuning the prompts.
- **Code quality:** I would have put more guardrails and informed it on Python and AI standards - no placeholders, no silent failures, no mismatched package dependencies
- **Production readiness:** The generated code works for a demo/POC but needs refinement (fine-tooth comb) for real-world use

**The Result:**
A working end-to-end analytics solution where users can ask "What were total sales for road bikes last year?" and get instant visualizations - all built in 5 hours using AI-assisted development, with clear areas for improvement given more time.
