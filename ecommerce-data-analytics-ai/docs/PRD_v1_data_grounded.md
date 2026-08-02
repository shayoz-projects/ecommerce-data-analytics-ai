
## Data-Grounded Requirements 

This document was created after reviewing the available Wix data. It defines which business questions can be answered reliably, which analyses are currently limited by missing data, and how the AI layer will use the calculated results.

## Confirmed Data Scope

The private dataset contains multiple years of Wix order, product, and customer exports.

The public repository includes approved product names, aggregated percentages, and indexed financial values. Customer details, order identifiers, and absolute financial values are not published.

## Key Data Findings and Calculation Rules

During the initial data review, two important data-structure findings were identified:

- Each row in the Wix export represents an order line item rather than a complete order. A single order may therefore appear across several rows, with one row for each purchased product.
- Orders include a status indicating whether they were completed or cancelled. Cancelled orders are retained for cancellation analysis but are excluded from revenue and completed-order calculations.

Based on these findings:

- Orders are counted using distinct order identifiers rather than the number of rows.
- Revenue is calculated only from non-cancelled order items.
- Average order value is calculated after grouping valid line items at the order level.
- Product combinations are identified by grouping products that belong to the same order.
- Customer purchase frequency is based on distinct completed orders.
  
## Questions Supported by the Current Data

- How did full-year revenue, order volume, and average order value change over time?
- How did the repeat-customer rate change?
- Which products rank highest by revenue index?
- How did gift-box performance compare with individual-product performance?
- Which product pairs appeared together most frequently?

## Questions Not Supported by the Current Data

- Profitability and margin, because complete cost data is unavailable
- Discount effectiveness, because no usable discount field is available
- Website conversion, because traffic and funnel data are missing
- Marketing attribution
- Reliable sales forecasting
  
## Analytical Workflow

1. Export the available Wix data.
2. Validate the structure, fields, and level of detail in each export.
3. Identify cancelled orders and exclude them from revenue-related calculations.
4. Aggregate item-level rows into validated order-level tables.
5. Clean and standardise product names.
6. Build privacy-safe analytical tables.
7. Calculate KPIs using SQL and Python.
8. Present indexed results and percentages in Power BI.
9. Send only validated and sanitised metrics to the LLM.
10. Validate the AI output against an approved fact catalogue.

## Privacy Requirements

- Raw Wix exports and the SQLite database will not be published
- Customer and order identifiers will be hashed
- Names, phone numbers, addresses, and raw email addresses will be removed
- The business name will not be included in the public repository
- Product names will be included only with the business owner’s approval
- Absolute financial values will be replaced with indices
