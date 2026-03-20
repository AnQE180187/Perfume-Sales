# AI Chat System Design

**Project:** AI-Powered Perfume Sales & Personalized Consultation System

This document describes the design of the **AI Chat subsystem**, which includes two specialized AI agents:

1. **Customer AI – Perfume Consultant**
2. **Admin AI – Marketing Assistant**

Although both use the same chat infrastructure, they serve **different users, data sources, and objectives**.

---

# 1. AI Chat Overview

The system integrates AI into the chat module to support two key functions:

| AI Agent    | Target User | Purpose                                                 |
| ----------- | ----------- | ------------------------------------------------------- |
| Customer AI | Customer    | Recommend perfumes and answer fragrance questions       |
| Admin AI    | Admin       | Provide marketing insights and business recommendations |

Both AI agents operate within the same **conversation framework** but use different prompts, data contexts, and tools.

---

# 2. Customer AI – Perfume Consultant

## 2.1 Purpose

The Customer AI acts as a **virtual perfume consultant**, similar to a salesperson in a perfume store.

Its primary goals are:

* Help customers choose suitable perfumes
* Reduce decision fatigue
* Provide fragrance knowledge
* Increase product conversion

---

# 2.2 Data Sources

Customer AI should only use **customer-facing data**.

### Product Catalog

Key product attributes:

```
name
brand
price
gender
scentFamily
topNotes
middleNotes
baseNotes
longevity
description
```

---

### Customer Profile

Customer preferences can improve recommendations.

```
gender
age
budget
favorite scent family
purchase history
quiz results
```

---

### Context Data

Optional contextual information:

```
season
weather
occasion
```

---

# 2.3 Supported Customer Intents

Customer AI must detect and respond to several main intent types.

---

## Intent 1 — Perfume Recommendation

Customers ask the AI to suggest perfumes.

Examples:

```
recommend a perfume for summer
perfume under 1.5 million
sweet perfume for women
```

AI tasks:

1. Understand customer preferences
2. Filter product catalog
3. Select 3–5 suitable perfumes
4. Explain why they match

---

## Intent 2 — Fragrance Education

Customers want to learn about perfume concepts.

Examples:

```
what is a woody scent
difference between EDT and EDP
which perfumes last the longest
```

AI should explain the concept and optionally recommend example perfumes.

---

## Intent 3 — Product Comparison

Customers compare perfumes.

Examples:

```
Dior Sauvage vs Bleu de Chanel
which one is better for office
```

AI compares:

```
scent profile
longevity
strength
occasion suitability
```

---

## Intent 4 — Personal Advisor

Customers may describe vague preferences.

Examples:

```
I want a perfume for a date
I like sweet smells but not too strong
```

AI should infer preferences and recommend suitable perfumes.

---

# 2.4 Processing Flow

Customer AI processing pipeline:

```
Customer Message
      │
Intent Detection
      │
Query Product Database
      │
Send Context to AI
      │
AI Reasoning
      │
Structured Response
```

Important rule:

**AI must only recommend perfumes that exist in the database.**

---

# 2.5 Response Format

The AI should return structured responses instead of free text.

Example response:

```
{
  "intent": "recommendation",
  "products": [
    {
      "productId": "p123",
      "reason": "Fresh citrus scent perfect for hot weather"
    },
    {
      "productId": "p456",
      "reason": "Light floral fragrance ideal for daily wear"
    }
  ]
}
```

Frontend converts this into **product cards inside the chat UI**.

---

# 2.6 Conversation Memory

Customer AI should maintain short-term conversation memory.

Possible stored preferences:

```
preferred scent family
budget range
gender preference
occasion preference
```

Example:

Customer says:

```
I like sweet perfumes
```

Later asks:

```
recommend something for daily use
```

AI should prioritize **sweet perfumes**.

---

# 3. Admin AI – Marketing Assistant

## 3.1 Purpose

Admin AI acts as a **business intelligence assistant** for the perfume store.

It helps administrators analyze business data and make better decisions.

Primary goals:

* Analyze sales trends
* Provide marketing recommendations
* Suggest promotions
* Support business strategy

---

# 3.2 Data Sources

Admin AI requires **business and analytics data**.

---

### Sales Data

```
productId
quantitySold
revenue
date
```

---

### Customer Behavior

```
popular scent families
customer age groups
repeat purchase rate
```

---

### Review Data

```
rating
review text
sentiment
```

---

### Inventory Data

```
stock level
expiry date
restock threshold
```

---

# 3.3 Supported Admin Tasks

---

## Task 1 — Sales Analysis

Example question:

```
Top selling perfumes this month
```

AI returns ranked products based on sales data.

---

## Task 2 — Trend Analysis

Example question:

```
Which scent family is trending?
```

AI analyzes customer purchase patterns.

Example result:

```
Floral: 42%
Woody: 30%
Fresh: 18%
```

---

## Task 3 — Promotion Suggestions

Example question:

```
Which perfumes should we promote for summer?
```

AI suggests products based on:

* seasonal suitability
* sales performance
* customer preferences

---

## Task 4 — Marketing Campaign Ideas

Example:

```
Give me a marketing campaign idea for summer
```

AI output:

```
Summer Fresh Campaign

Promote citrus fragrances
Offer bundle discounts
Provide free travel-size samples
```

---

## Task 5 — Inventory Insights

Example question:

```
Which perfumes may run out soon?
```

AI checks inventory levels and warns about low stock.

---

# 3.4 Admin AI Processing Flow

```
Admin Message
      │
Intent Detection
      │
Retrieve Analytics Data
      │
Build Context
      │
Send Context to AI
      │
AI Generates Insights
```

---

# 3.5 Admin AI Response Format

Admin AI responses typically include:

* analysis
* recommendation
* strategy suggestion

Example:

```
Top perfume trends for summer:

1. Citrus fragrances
2. Aquatic scents
3. Light floral perfumes

Recommendation:
Promote fresh fragrances during hot weather campaigns.
```

---

# 4. Differences Between the Two AI Agents

| Feature      | Customer AI               | Admin AI                    |
| ------------ | ------------------------- | --------------------------- |
| Primary Role | Perfume consultant        | Marketing strategist        |
| Target User  | Customer                  | Admin                       |
| Main Data    | Product catalog           | Sales + analytics           |
| Output       | Product recommendations   | Business insights           |
| Goal         | Increase sales conversion | Improve marketing decisions |

---

# 5. AI Agent Architecture

The system should use **two specialized AI agents** instead of a single generic AI.

Recommended agents:

```
PerfumeConsultantAgent
MarketingAnalystAgent
```

Each agent uses:

* different prompts
* different context data
* different tools

---

# 6. AI Tool Integration (Advanced)

AI agents can use internal tools to query system data.

Example tools:

```
searchPerfume
filterByBudget
filterByScent
getTopSellingPerfumes
getInventoryStatus
```

Example flow:

```
User: recommend perfume under 1 million

AI → tool: filterByBudget(1000000)
AI → tool: searchPerfume("fresh scent")

AI generates recommendations
```

This approach enables the AI to produce **accurate results based on real system data**.

---

# 7. Future Improvements

Possible enhancements for the AI chat system:

* AI conversation summarization
* AI sentiment analysis on reviews
* AI upselling recommendations
* AI personalized promotions
* AI demand forecasting
* multilingual AI support

---

# 8. Summary

The AI Chat System consists of two specialized agents:

Customer AI focuses on **personalized perfume consultation**, while Admin AI focuses on **data-driven marketing insights**.

Separating these agents ensures:

* better response quality
* clearer system design
* easier future expansion
* more realistic AI behavior for different user roles.
