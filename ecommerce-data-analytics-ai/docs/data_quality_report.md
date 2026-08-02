## Public Data Quality Report

## Scope

The private analysis covered a multi-year Wix export containing more than one thousand orders, several thousand order line items and more than one hundred products.

Exact order counts and absolute financial values are not included in this public version.

## Key Findings

## Order-Level and Line-Item Data

Each row in the Wix export represents one product line within an order, not a complete order.

An order containing several products therefore appears across several rows. Orders must be counted using distinct order identifiers rather than the total number of rows.

This structure also affects the calculation of average order value, customer purchase frequency and product combinations.

### Unit Price and Line Revenue

The exported ״Price״ field represents the price of one unit rather than the total value of the row.

Line revenue is therefore calculated as:

line_revenue = Price × Qty


## Duplicate-Looking Rows

Some rows appeared identical but represented legitimate repeated items within an order.

Removing these rows automatically with `drop_duplicates()` could incorrectly reduce the calculated quantity and revenue.

Rows were therefore not removed based only on identical visible values. Validation included comparing the total line-item quantities with the order-level quantity provided in the export.

## Cancelled Orders

Cancelled orders remain in the Wix exports.

They are retained in the analytical database for cancellation analysis but excluded from:

- completed-order counts
- revenue calculations
- average order value
- customer purchase-frequency calculations
- completed product-sales analysis

## Product-Name Fragmentation

The same product sometimes appeared under different labels because of spelling differences, naming changes and personalisation text.

 A manually reviewed mapping was therefore created to connect historical product labels to one standardised product name.

## Missing Cost and SKU Values

Cost and SKU fields were not complete enough to support reliable margin analysis or SKU-based joins.

Product-level analysis therefore uses standardised product names and focuses on revenue rather than profit.

## Gift Vouchers

Gift vouchers represent valid sales and remain included in overall revenue.

They are excluded from physical-product analysis and gift-box vs. individual-product comparisons because they do not represent the sale of a physical product.


## Public Data Transformation (last step)

Before publication:

- customer and order identifiers will be hashed
- customer names, email addresses, phone numbers and physical addresses will be removed
- absolute revenue and order-value figures will be replaced with indices or percentages
- raw Wix exports will not be included in the repository
- the private SQLite database will not be included in the repository
- only aggregated analytical results will be published
- real product names will be published only after receiving the business owner’s approval; otherwise, product aliases will be used
