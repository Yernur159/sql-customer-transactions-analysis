# Customer Transactions Analysis (SQL)

Analysis of one year of customer transactions (June 2015 – June 2016) in MySQL.

## Tasks
1. **Loyal customers** — clients who made purchases every month of the period: average check, average monthly spend and number of operations
2. **Monthly metrics** — average check, operations per client, active clients, each month's share of yearly operations and revenue, and the split by gender (M / F / unknown) in operations and spend
3. **Age groups by quarter** — revenue, operations and clients for 10-year age groups, average per client and share of each quarter

## Techniques
Subqueries in `FROM` and `WHERE`, `CROSS JOIN` for totals, `LEFT JOIN` with customer data, `CASE` for age groups and quarters, `COALESCE` for missing values, date functions (`DATE_FORMAT`, `TIMESTAMPDIFF`).

## Files
- `финал SQL.sql` — all queries

**Stack:** MySQL
