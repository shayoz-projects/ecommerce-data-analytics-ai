-- E-commerce Data Analytics & AI Project - Core KPI Queries
-- Database: DataP.db (tables: orders, products, contacts, orders_summary)
-- orders          = one row per line-item (use for product-level analysis)
-- orders_summary  = one row per order (use for order/customer-level analysis)
-- Convention: revenue queries always exclude is_canceled = 1

-- 1. Overall headline metrics
SELECT
    COUNT(*)                              AS total_orders,
    ROUND(SUM(order_revenue), 0)          AS total_revenue,
    ROUND(AVG(order_revenue), 0)          AS avg_order_value
FROM orders_summary
WHERE is_canceled = 0;

-- 2. Revenue, orders, and AOV by year
SELECT
    strftime('%Y', order_date)            AS year,
    COUNT(*)                              AS orders,
    ROUND(SUM(order_revenue), 0)          AS revenue,
    ROUND(AVG(order_revenue), 0)          AS aov
FROM orders_summary
WHERE is_canceled = 0
GROUP BY year
ORDER BY year;


-- 3. Revenue and orders by month

SELECT
    strftime('%Y-%m', order_date)         AS month,
    COUNT(*)                              AS orders,
    ROUND(SUM(order_revenue), 0)          AS revenue
FROM orders_summary
WHERE is_canceled = 0
GROUP BY month
ORDER BY month;


-- 4. Top products by revenue (item-level table needed-not "order_summary")

SELECT
    canonical_name,
    ROUND(SUM(line_revenue), 0)           AS revenue,
    SUM(Qty)                              AS units_sold,
    COUNT(DISTINCT "Order number")        AS orders_containing_it
FROM orders
WHERE is_canceled = 0 AND is_gift_voucher = 0
GROUP BY canonical_name
ORDER BY revenue DESC
LIMIT 20;


-- 5. Declining products: 2024 vs 2025 ** not so usefull - theres no real tracking for sold out procuts. 

SELECT
    canonical_name,
    SUM(CASE WHEN strftime('%Y', "Date created") = '2024' THEN line_revenue ELSE 0 END) AS revenue_2024,
    SUM(CASE WHEN strftime('%Y', "Date created") = '2025' THEN line_revenue ELSE 0 END) AS revenue_2025,
    CASE
        WHEN SUM(CASE WHEN strftime('%Y', "Date created") = '2025' THEN line_revenue ELSE 0 END) = 0
            THEN 'Likely discontinued'
        ELSE 'Declining, still active'
    END AS status
FROM orders
WHERE is_canceled = 0 AND is_gift_voucher = 0
GROUP BY canonical_name
HAVING revenue_2024 > 0
ORDER BY (revenue_2025 - revenue_2024) ASC
LIMIT 15;

-- 6. Repeat-customer rate
WITH customer_orders AS (
    SELECT customer_id, COUNT(*) AS n_orders
    FROM orders_summary
    WHERE is_canceled = 0
    GROUP BY customer_id
)
SELECT
    COUNT(*)                                                       AS total_customers,
    SUM(CASE WHEN n_orders > 1 THEN 1 ELSE 0 END)                 AS repeat_customers,
    ROUND(100.0 * SUM(CASE WHEN n_orders > 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS repeat_rate_pct
FROM customer_orders;


-- 7. Average time between purchases (repeat customers only)

WITH gaps AS (
    SELECT
        customer_id,
        julianday(order_date) - julianday(LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS days_between
    FROM orders_summary
    WHERE is_canceled = 0
)
SELECT ROUND(AVG(days_between), 0) AS avg_days_between_purchases
FROM gaps
WHERE days_between IS NOT NULL;

-- 8. Product combinations (cross-sell pairs, item-level table needed) ** should use in the follow up! 

SELECT
    a.canonical_name AS product_a,
    b.canonical_name AS product_b,
    COUNT(*)          AS times_bought_together
FROM orders a
JOIN orders b
    ON a."Order number" = b."Order number"
    AND a.canonical_name < b.canonical_name
WHERE a.is_canceled = 0 AND a.is_gift_voucher = 0 AND b.is_gift_voucher = 0
GROUP BY product_a, product_b
ORDER BY times_bought_together DESC
LIMIT 15;

-- 9. Refund rate (item-level table needed)
SELECT
    ROUND(100.0 * SUM("Quantity refunded") / SUM(Qty), 2) AS refund_rate_pct,
    SUM("Quantity refunded")                                AS units_refunded,
    SUM(Qty)                                                AS units_sold
FROM orders
WHERE is_canceled = 0;


-- 10. Cancellation rate (full table, not filtered) 

SELECT
    COUNT(*)                                                        AS total_orders_incl_canceled,
    SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END)               AS canceled_orders,
    ROUND(100.0 * SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancellation_rate_pct
FROM orders_summary;


-- 11. Revenue driver decomposition: AOV alone is misleading
--     here, unit prices grow ~52% from 2022-2026, so AOV growth
--     can look positive while real basket size actually shrinks.
--     This query shows both, side by side, on purpose.

WITH yearly AS (
    SELECT strftime('%Y', order_date) AS year, COUNT(*) AS orders,
           ROUND(AVG(order_revenue),0) AS aov,
           ROUND(AVG(total_items),2) AS avg_items_per_order
    FROM orders_summary WHERE is_canceled = 0 AND strftime('%Y', order_date) IN ('2023','2024','2025')
    GROUP BY year
)
SELECT year, orders, aov, avg_items_per_order,
       ROUND(100.0*(orders - LAG(orders) OVER (ORDER BY year))/LAG(orders) OVER (ORDER BY year),1) AS orders_pct_change,
       ROUND(100.0*(aov - LAG(aov) OVER (ORDER BY year))/LAG(aov) OVER (ORDER BY year),1) AS nominal_aov_pct_change,
       ROUND(100.0*(avg_items_per_order - LAG(avg_items_per_order) OVER (ORDER BY year))/LAG(avg_items_per_order) OVER (ORDER BY year),1) AS real_basket_size_pct_change
FROM yearly;

-- 12. New vs. returning customer revenue by year

WITH first_order AS (
    SELECT customer_id, MIN(order_date) AS first_date
    FROM orders_summary WHERE is_canceled = 0 GROUP BY customer_id
)
SELECT
    strftime('%Y', o.order_date) AS year,
    CASE WHEN o.order_date = f.first_date THEN 'New' ELSE 'Returning' END AS customer_type,
    COUNT(*) AS orders,
    ROUND(SUM(o.order_revenue),0) AS revenue
FROM orders_summary o
JOIN first_order f ON o.customer_id = f.customer_id
WHERE o.is_canceled = 0
GROUP BY year, customer_type
ORDER BY year, customer_type;

-- 13. Customer concentration (Pareto) - revenue share by quintile (5)

WITH ranked AS (
    SELECT customer_id, SUM(order_revenue) AS cust_revenue,
           NTILE(5) OVER (ORDER BY SUM(order_revenue) DESC) AS quintile
    FROM orders_summary WHERE is_canceled = 0 GROUP BY customer_id
)
SELECT quintile, COUNT(*) AS customers, ROUND(SUM(cust_revenue),0) AS revenue,
       ROUND(100.0*SUM(cust_revenue)/(SELECT SUM(order_revenue) FROM orders_summary WHERE is_canceled=0),1) AS pct_of_total_revenue
FROM ranked GROUP BY quintile ORDER BY quintile;

-- 14. Seasonality average order value by calendar month (full years only: 2023-2025)

SELECT strftime('%m', order_date) AS month,
       ROUND(AVG(order_revenue),0) AS avg_order_value,
       COUNT(*) AS orders
FROM orders_summary
WHERE is_canceled = 0 AND strftime('%Y', order_date) IN ('2023','2024','2025')
GROUP BY month ORDER BY month;

-- 15. Basket size (items per order) by year - a price-inflation-
--     proof measure of real purchasing behavior. 
--     NOTE: overlaps with query 11's raw values, but this one covers
--     ALL years (including partial 2022/2026) for charting in Power BI,
--     while query 11 is restricted to full years (2023-2025) for a
--     valid year-over-year % change calculation. 

SELECT strftime('%Y', order_date) AS year,
       COUNT(*) AS orders,
       ROUND(AVG(total_items),2) AS avg_items_per_order,
       ROUND(AVG(order_revenue),0) AS nominal_aov
FROM orders_summary
WHERE is_canceled = 0
GROUP BY year ORDER BY year;

-- 16. Bundle (box) vs. individual item split
--  product name contains "box" = Bundle, else = Individual. 
--   NOTE: Bundle + Individual will not sum to total annual revenue.
--     gift vouchers (is_gift_voucher=1) are excluded from both
--     categories, makes a small gap (~1% of revenue most years), not a calculation error.

WITH classified AS (
    SELECT *,
        CASE
            WHEN bundle_override = 1 THEN 'Bundle'
            WHEN LOWER(canonical_name) LIKE '%box%'
                THEN 'Bundle'
            ELSE 'Individual'
        END AS category
    FROM orders
    WHERE is_canceled = 0 AND is_gift_voucher = 0
)
SELECT category,
       ROUND(SUM(line_revenue),0) AS revenue,
       COUNT(DISTINCT "Order number") AS orders,
       SUM(Qty) AS units
FROM classified
GROUP BY category;


-- 17. Bundle vs. individual revenue share, by year (the trend)

WITH classified AS (
    SELECT *,
        strftime('%Y', "Date created") AS year,
        CASE
            WHEN bundle_override = 1 THEN 'Bundle'
            WHEN LOWER(canonical_name) LIKE '%box%'
                THEN 'Bundle'
            ELSE 'Individual'
        END AS category
    FROM orders
    WHERE is_canceled = 0 AND is_gift_voucher = 0
)
SELECT year,
       ROUND(SUM(CASE WHEN category='Bundle' THEN line_revenue ELSE 0 END),0) AS bundle_revenue,
       ROUND(SUM(CASE WHEN category='Individual' THEN line_revenue ELSE 0 END),0) AS individual_revenue,
       ROUND(100.0 * SUM(CASE WHEN category='Bundle' THEN line_revenue ELSE 0 END)
             / SUM(line_revenue), 1) AS bundle_share_pct
FROM classified
GROUP BY year
ORDER BY year;

-- 18. Average unit price by year - used to separate nominal AOV
--     movement from changes in real basket size.
--     This was previously calculated ad-hoc and never persisted
--     as a query added here so it's traceable and included in
--     the AI layer's metrics package.

SELECT strftime('%Y', "Date created") AS year,
       ROUND(AVG(Price),1) AS avg_unit_price
FROM orders
WHERE is_canceled = 0 AND is_gift_voucher = 0
GROUP BY year
ORDER BY year;
