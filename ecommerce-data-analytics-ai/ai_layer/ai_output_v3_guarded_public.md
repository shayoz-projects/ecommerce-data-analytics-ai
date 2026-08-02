# V3 Guarded AI Insight Report

Validated against the approved fact catalogue.

## Insight 1: Annual Order Volume Trajectory

**Approved evidence:**
- `ORDERS_2023` — 2023 recorded 471 orders. Source: `revenue_by_year[2023].orders`
- `ORDERS_2024` — 2024 recorded 367 orders. Source: `revenue_by_year[2024].orders`
- `ORDERS_2025` — 2025 recorded 332 orders. Source: `revenue_by_year[2025].orders`

**Interpretation:** The data suggests a downward pattern in annual order counts over the observed annual periods.

**Proposed experiment:** Review historical order logs and promotional schedules across the full years to investigate potential channel shifts.

**Confidence:** High

**Relevant limitations:**
- `LIM_TRAFFIC` — No website traffic or conversion data is available, so funnel performance cannot be assessed.

## Insight 2: Repeat Customer Engagement Trends

**Approved evidence:**
- `REPEAT_RATE_2023` — The repeat-customer rate in 2023 was 3.7%. Source: `repeat_rate_by_year[2023].repeat_customer_rate_pct`
- `REPEAT_RATE_2024` — The repeat-customer rate in 2024 was 6.1%. Source: `repeat_rate_by_year[2024].repeat_customer_rate_pct`
- `REPEAT_RATE_2025` — The repeat-customer rate in 2025 was 10.9%. Source: `repeat_rate_by_year[2025].repeat_customer_rate_pct`

**Interpretation:** The repeat-customer rate suggests an upward direction across the consecutive annual periods.

**Proposed experiment:** Review email tracking methods to assess whether identifier consistency influences the measured repeat rate.

**Confidence:** Medium

**Relevant limitations:**
- `LIM_EMAIL_ID` — Repeat-customer identity uses email, so customers using multiple emails may be undercounted.

## Insight 3: Product Co-Occurrence Observations

**Approved evidence:**
- `PAIR_1` — Baby bear towel and Exclusive Royal blanket appeared together in 79 orders. Source: `top_cross_sell_pairs[0]`
- `PAIR_2` — Exclusive Royal blanket and Pacifier holder appeared together in 62 orders. Source: `top_cross_sell_pairs[1]`
- `PAIR_3` — Exclusive Royal blanket and My new Bunny appeared together in 47 orders. Source: `top_cross_sell_pairs[2]`

**Interpretation:** Certain items frequently appear together within the same orders, which is consistent with common basket compositions.

**Proposed experiment:** Conduct a portfolio review of product placement on pages to evaluate cross-item visibility.

**Confidence:** High

**Relevant limitations:**
- `LIM_COPURCHASE` — Co-purchase counts show co-occurrence only; support, confidence and lift were not calculated.
- `LIM_AVAILABILITY` — Product availability and catalogue-status data are not included.

## Validation summary

- Every selected fact ID existed in the regenerated catalogue.
- Numerical evidence was inserted by Python, not copied by the model.
- No duplicate fact IDs were used across insights.
- Risky wording and unsupported numerical text passed the automated checks.
- Human review is still required for business interpretation.