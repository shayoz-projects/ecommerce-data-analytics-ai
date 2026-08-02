## E-commerce Data Analytics & AI Project

An end-to-end analytics project based on real Wix order data from a small e-commerce business selling newborn gift boxes and individual baby products.

The project combines Python, SQL, Power BI and an LLM-based insight layer to analyse sales, product performance and customer behaviour.

Privacy note: The business name is not included in this public repository. Product names are published with the owner's approval. Absolute revenue and order-value figures are replaced with indices or percentages.

## Business Background

The business is independently managed by its owner, who handles product management, order processing, customer service and marketing.

Wix provides useful built-in analytics, including AI-generated insights and benchmarking focused on traffic, conversion, and site performance, but these offer only a partial view of the business.The historical data had also not previously been organised and validated for deeper analysis, so additional preparation was required before reliable and consistent metrics could be calculated.

The purpose of this project was to create a structured analytical process that goes beyond the existing reports and provides a clearer understanding of sales, product performance and customer behaviour.

The main questions were:

What contributed to changes in revenue and order volume?
How did new and returning customers behave over time?
How did gift boxes perform compared with individual products?
Which products were frequently purchased together?
Did an increase in average order value also mean that customers purchased more items?

## Data Preparation

The Wix exports required several decisions before reliable KPIs could be calculated.

* Each row represents one product line within an order, not a complete order. Therefore Orders had to be counted using distinct order identifiers, not row counts.
* Cancelled orders remain in the export. They were retained for cancellation analysis but excluded from completed-order, revenue and average-order-value calculations.
* Product names changed over time because of spelling and naming differences. Automated matching created incorrect groupings, so a manually reviewed product-name mapping was created.
* Customer and financial data had to be anonymised before any files could be published.

Order-level metrics were calculated only after valid product lines were grouped by order.

## Project Workflow

Wix exports -> Python: Cleaning and validation -> SQLite: Analytical tables, views and SQL queries ->Power BI dashboard + AI insight layer- 
Validated metrics → Gemini → validation checks → final output

 ### Tools : Python, pandas, openpyxl, SQLite, Power BI and Gemini API.

The analytical database includes four tables, seven views and eighteen documented SQL queries.

## Main Analysis Areas

Sales: 

- Revenue and completed orders over time
- Average order value
- Average items per order
- Revenue and order growth
- New versus returning-customer orders

Customers:

- Repeat-customer rate vs. new customers
- Purchase frequency
- Time between purchases
- Revenue concentration

Products:

- Revenue and units sold by product
- Product performance over time
- Gift boxes compared with individual products
- Frequently purchased product combinations
  
## Key Findings

### The decline in completed orders from 2024 to 2025 was concentrated among new customers

The number of completed orders declined between 2024 and 2025. Most of this decrease came from orders placed by new customers, while returning-customer order activity remained relatively stable.

During the same period, the repeat-customer rate increased from 6.1% to 10.9%.

The available data does not explain why fewer new customers purchased, because website-traffic and campaign data were unavailable. 

### Average order value increased while items per order declined

Average order value increased between 2023 and 2025, but the average number of items per order decreased.

This suggests that the increase in average order value was driven at least partly by higher product prices or changes in the product mix, rather than by customers purchasing more items. Looking only at average order value would therefore provide an incomplete picture.

### Individual products generated a larger revenue share than gift boxes

Gift boxes represented:

2023- 38.6%
2024- 38.7%
2025- 33.7%

The gift-box share remained almost unchanged between 2023 and 2024 and then declined in 2025.

This raised a question worth testing: whether a smaller or lower-priced gift-box option could provide a more accessible entry point without reducing sales of individual products.

### One product contributed strongly to both revenue and product combinations

The Exclusive Royal Blanket ranked first by revenue index and appeared in several of the most frequent product combinations.

Examples included:

Exclusive Royal Blanket with Baby Bear Towel
Exclusive Royal Blanket with Pacifier Holder

This makes the blanket a relevant product for testing product-page placement, cross-sell recommendations or bundle offers.

The full findings and proposed experiments are documented in [`recommendations_summary.md`](recommendations_summary.md).

## Power BI Dashboard

The dashboard contains two pages:

* Sales Overview: revenue, completed orders, average order value, monthly performance and new-versus-returning customer trends
* Product Performance: top products, box versus individual product performance and frequent product pairs

Only indexed financial values and percentages are included in the public screenshots.

## AI Insight Layer

The AI layer receives aggregated and validated metrics rather than raw customer or order-level data.

For the public evaluation, three prompt versions were rerun using the same privacy-safe metrics package:

V1- Naive prompt: A broad instruction without a fixed structure or validation requirements
V2- Structured prompt: Each insight included a finding, evidence, interpretation, recommended action and data limitation
V3- Guarded pipeline: Confidence scoring, an approved fact catalogue and Python validation were added

During development, a stale fact-catalogue issue was identified. The product-classification logic had been corrected, but the catalogue used by the AI layer had not been regenerated.

The model used the supplied values correctly, but those values were no longer current. This showed that grounding can reduce unsupported model output, but it cannot protect against outdated upstream data.

The corrected metrics package and fact catalogue were used for the final public reruns.

The full evaluation is documented in [`docs/prompt_evaluation.md`](docs/prompt_evaluation.md).

## Known Limitations

- Product-cost data was unavailable, so the analysis focuses on revenuen, not profit.
- No usable discount field was available.
- Website-traffic, conversion and campaign-attribution data were not included.
- The 2022 and 2026 exports contain partial-year data and were not directly compared with complete years.
- Customer matching uses email as the main identity key, so customers using different email addresses may be counted separately.
- Gift-box classification is based on reviewed product-name rules and a manual override.
- Forecasting was excluded because the available data was not sufficient for a reliable model.

## Future Work

The next stage is to implement selected recommendations and measure their impact using future sales data. Results will be compared with the current baseline by calculating percentage changes in KPIs such as order volume, average order value, repeat-customer rate, product performance, and co-purchase activity.

Where possible, controlled tests will be used to determine whether observed improvements are linked to the implemented actions rather than normal business variation.

## Privacy and Anonymisation

The raw Wix exports and private SQLite database are not included in this repository.

Before publication:

- customer and order identifiers were hashed
- names, email addresses, phone numbers and physical addresses were removed
- absolute revenue and order-value figures were replaced with indices
- only aggregated results were published
- product names were included with the business owner's approval

## Running the Project

The full pipeline requires he original Wix exports, which are not included in the public repository.

1. Place the private exports in the local input directory.
2. Run the cleaning and database-build script: python [`clean_and_build_db.py`](src/clean_and_build_db.py). 
3. Review the SQL analysis in: [`kpi_queries.sql`](sql/kpi_queries.sql).
4. Connect Power BI to the generated analytical tables.
5. Configure the Gemini API key and run the AI insight layer using the validated metrics package.

## AI-Assisted Development

Claude was used to support parts of the Python, SQL and documentation process. Gemini is used as the insight-generation model in the final AI layer.

AI-generated code and analytical outputs were reviewed against the source data and corrected when required. The prompt evaluation documents examples of errors that were identified during this process. go [`docs/prompt_evaluation.md`](docs/prompt_evaluation.md). for specific example. 
