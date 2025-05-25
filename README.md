# Customer Behavior Analysis - SQL Solutions

## Overview

This project contains SQL-based solutions to analyze customer behavior on a financial platform. It covers 4 key business scenarios:

1. **High-Value Customers with Multiple Products**
2. **Transaction Frequency Analysis**
3. **Inactive accounts (>/ 1 year)**
4. **Estimated Customer Lifetime Value (CLV)**

These insights help the business with strategic decisions in **cross-selling**, **user segmentation**, and **customer engagement**.

---

## Problem 1: High-Value Customers with Multiple Products

**Objective**: Identify customers who have both at least one *funded savings plan* and one *funded investment plan*, sorted by their total deposits (converted from kobo to naira).

### ✅ Final Output Includes:
- `owner_id`
- `name`
- `savings_count`
- `investment_count`
- `total_deposits`

### 🧠 Logic Summary:
- Extract only funded savings and investment plans.
- Link deposit amounts to the respective plans.
- Ensure users have **at least one** of each product type.
- Aggregate deposits and sort descending by total.

### ⚠️ Challenges:
- **Multiple columns for plan types** (`is_regular_savings`, `is_a_fund`) had to be handled carefully.
- **Null name values** were returned in early queries due to unmatched joins or user data issues.
- **Overcounting** plans without deposits was resolved by applying filters at the CTE level.
- **Inconsistent row counts** (192 vs. 179) occurred when comparing two approaches; the final version merges their strengths to produce accurate results.

---

## Problem 2: Transaction Frequency Analysis

**Objective**: Segment users into frequency categories based on their **average number of transactions per month**.

### ✅ Final Output Includes:
- `frequency_category` ("High Frequency", "Medium Frequency", "Low Frequency")
- `customer_count`
- `avg_transactions_per_month`

### 🧠 Logic Summary:
- Count daily transactions per user.
- Aggregate to get monthly average transactions per user.
- Categorize:
  - **High Frequency**: ≥10 txns/month
  - **Medium Frequency**: 3–9 txns/month
  - **Low Frequency**: ≤2 txns/month
- Summarize the total customers and average per category.

### ⚠️ Challenges:
- Original attempts referenced a non-existent `created_at` column.
- Correct timestamp field was identified as `transaction_date` from `savings_savingsaccount`.
- Filtering out zero-amount or null-date transactions was essential for accurate counts.
- Needed to multiply average **daily** transactions by 30 to approximate monthly frequency.

---
## Problem 3  – Inactive Accounts (≥1 Year)**
✅ Problem
Identify all plans with no inflow transactions for over 365 days.

⚙️ Approach
Created type column: Savings or Investment
Calculated last_transaction_date per plan
Calculated inactivity_days using DATEDIFF()
Filtered for inactivity_days >= 365

## ❓ Problem 4 Estimated Customer Lifetime Value (CLV)**
✅ Problem
Estimate CLV for all users using:

CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction
⚙️ Approach
Calculated tenure in months from date_joined
Combined inflow + withdrawal transactions
Converted amounts from Kobo to Naira
Estimated CLV and sorted by highest to lowest
📊 Result
Final result is a table of 1867 users with:

id
full name
date_joined
tenure (months)
estimated CLV (Naira)

## Technologies Used

- MySQL 8.x
- SQL CTEs and Aggregate Functions
- Joins and Conditional Aggregations

---

## Author

**Analyst**: [Yazid Ohiare]  
**Date**: May 2025  
**Organization**: Internal Analytics Team / Adashi Staging Environment

---


