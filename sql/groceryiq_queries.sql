-- ============================================================================
-- GroceryIQ : Irish Grocery Retail Intelligence
-- Analytical SQL layer (PostgreSQL-compatible)
-- ----------------------------------------------------------------------------
-- These queries express the platform's core analytics in SQL: operating-model
-- comparison, basket economics, inventory (Q,R) policy, ABC classification,
-- inflation pass-through and supply-chain risk scoring. They are written to run
-- against the modelled SKU book and the chain/parameter tables produced by the
-- Python pipeline (python/analytics.py, python/groceryiq.py).
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. SCHEMA
-- ----------------------------------------------------------------------------
CREATE TABLE chains (
    chain           TEXT PRIMARY KEY,
    operating_model TEXT,            -- 'Discounter' | 'Full-range'
    market_share    NUMERIC,         -- % (Kantar)
    sku_count       INTEGER,
    private_label   NUMERIC,         -- %
    promo_intensity NUMERIC,         -- %
    net_margin      NUMERIC,         -- %
    stores          INTEGER,
    dcs             INTEGER
);

CREATE TABLE sku_book (
    sku_id          BIGINT PRIMARY KEY,
    chain           TEXT REFERENCES chains(chain),
    category        TEXT,
    shelf_life_days INTEGER,
    daily_demand    NUMERIC,
    demand_cv       NUMERIC,         -- coefficient of variation
    unit_cost       NUMERIC,
    private_label   BOOLEAN,
    lead_time_mean  NUMERIC,
    lead_time_std   NUMERIC
);

CREATE TABLE basket_costs (
    basket          TEXT,
    chain           TEXT REFERENCES chains(chain),
    weekly_shelf    NUMERIC,
    weekly_loyalty  NUMERIC,
    annual_loyalty  NUMERIC,
    cost_per_1000kcal   NUMERIC,
    cost_per_100g_protein NUMERIC,
    PRIMARY KEY (basket, chain)
);

CREATE TABLE inflation_category (
    category        TEXT PRIMARY KEY,
    annual_inflation NUMERIC          -- %
);

CREATE TABLE risk_scores (
    chain           TEXT REFERENCES chains(chain),
    dimension       TEXT,
    exposure        INTEGER,          -- 0..100
    PRIMARY KEY (chain, dimension)
);


-- ----------------------------------------------------------------------------
-- 2. OPERATING-MODEL SCORECARD
--    Discounter vs full-range, with the headline structural contrasts.
-- ----------------------------------------------------------------------------
SELECT
    operating_model,
    COUNT(*)                                   AS chains,
    ROUND(AVG(sku_count))                      AS avg_sku_count,
    ROUND(AVG(private_label), 1)               AS avg_private_label_pct,
    ROUND(AVG(promo_intensity), 1)             AS avg_promo_pct,
    ROUND(AVG(net_margin), 2)                  AS avg_net_margin_pct
FROM chains
GROUP BY operating_model
ORDER BY avg_sku_count;


-- ----------------------------------------------------------------------------
-- 3. THE RANGE GAP  (SKU spread between models)
-- ----------------------------------------------------------------------------
WITH model_range AS (
    SELECT operating_model, AVG(sku_count) AS avg_skus
    FROM chains GROUP BY operating_model
)
SELECT
    MAX(CASE WHEN operating_model = 'Full-range' THEN avg_skus END) AS full_range_skus,
    MAX(CASE WHEN operating_model = 'Discounter' THEN avg_skus END) AS discounter_skus,
    ROUND(
        MAX(CASE WHEN operating_model = 'Full-range' THEN avg_skus END) /
        NULLIF(MAX(CASE WHEN operating_model = 'Discounter' THEN avg_skus END), 0)
    , 1) AS range_multiple
FROM model_range;


-- ----------------------------------------------------------------------------
-- 4. MARKET CONCENTRATION  (Herfindahl-Hirschman Index)
--    HHI = sum of squared market shares.
-- ----------------------------------------------------------------------------
SELECT ROUND(SUM(POWER(market_share, 2))) AS hhi
FROM chains;


-- ----------------------------------------------------------------------------
-- 5. BASKET ECONOMICS  : cheapest chain per basket, with saving vs dearest
-- ----------------------------------------------------------------------------
WITH ranked AS (
    SELECT
        basket, chain, annual_loyalty,
        RANK()  OVER (PARTITION BY basket ORDER BY annual_loyalty ASC)  AS cheapest_rank,
        MAX(annual_loyalty) OVER (PARTITION BY basket)                  AS dearest
    FROM basket_costs
)
SELECT
    basket, chain AS cheapest_chain,
    annual_loyalty                              AS cheapest_annual_eur,
    ROUND(dearest - annual_loyalty)             AS annual_saving_vs_dearest
FROM ranked
WHERE cheapest_rank = 1
ORDER BY annual_saving_vs_dearest DESC;


-- ----------------------------------------------------------------------------
-- 6. INVENTORY (Q,R) POLICY  per SKU
--    EOQ = sqrt(2 * D_annual * S / H);  ROP = d_bar*L_bar + z*sigma_LT
--    z (95% service) ~ 1.645. Perishables (shelf life < 10d) get a spoilage
--    penalty on the holding rate.
-- ----------------------------------------------------------------------------
WITH params AS (SELECT 60.0 AS order_cost, 0.25 AS holding_rate, 1.645 AS z),
calc AS (
    SELECT
        s.sku_id, s.chain, s.category,
        s.daily_demand * 365                                   AS d_annual,
        s.unit_cost * (p.holding_rate +
            CASE WHEN s.shelf_life_days < 10 THEN 0.20
                 WHEN s.shelf_life_days < 30 THEN 0.08 ELSE 0 END) AS h,
        SQRT( s.lead_time_mean * POWER(s.daily_demand * s.demand_cv, 2)
            + POWER(s.daily_demand, 2) * POWER(s.lead_time_std, 2) ) AS sigma_lt,
        s.daily_demand * s.lead_time_mean                      AS lt_demand,
        p.order_cost, p.z
    FROM sku_book s CROSS JOIN params p
)
SELECT
    chain,
    ROUND(SUM(SQRT(2 * d_annual * order_cost / NULLIF(h,0))))      AS total_eoq_units,
    ROUND(SUM(z * sigma_lt))                                       AS total_safety_stock,
    ROUND(SUM(lt_demand + z * sigma_lt))                           AS total_reorder_units,
    ROUND(SUM( (SQRT(2 * d_annual * order_cost / NULLIF(h,0)) / 2 + z * sigma_lt) * h ))
                                                                   AS annual_holding_cost
FROM calc
GROUP BY chain
ORDER BY annual_holding_cost DESC;


-- ----------------------------------------------------------------------------
-- 7. ABC CLASSIFICATION  (Pareto by revenue contribution)
--    Class A = top 80% of revenue, B = next 15%, C = remaining 5%.
-- ----------------------------------------------------------------------------
WITH rev AS (
    SELECT chain, sku_id,
           daily_demand * 365 * unit_cost AS annual_revenue
    FROM sku_book
),
cum AS (
    SELECT chain, sku_id, annual_revenue,
        SUM(annual_revenue) OVER (PARTITION BY chain ORDER BY annual_revenue DESC)
          / SUM(annual_revenue) OVER (PARTITION BY chain) AS cum_share
    FROM rev
)
SELECT
    chain,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cum_share <= 0.80) / COUNT(*), 1) AS pct_class_a,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cum_share > 0.80 AND cum_share <= 0.95) / COUNT(*), 1) AS pct_class_b,
    ROUND(100.0 * COUNT(*) FILTER (WHERE cum_share > 0.95) / COUNT(*), 1) AS pct_class_c
FROM cum
GROUP BY chain
ORDER BY chain;


-- ----------------------------------------------------------------------------
-- 8. INVENTORY TURNS by chain  (velocity advantage)
-- ----------------------------------------------------------------------------
WITH inv AS (
    SELECT chain,
        SUM(daily_demand * 365 * unit_cost)                       AS cogs,
        SUM( (daily_demand * lead_time_mean + daily_demand * 0.5) * unit_cost ) AS avg_inv_value
    FROM sku_book GROUP BY chain
)
SELECT chain, ROUND(cogs / NULLIF(avg_inv_value, 0), 1) AS inventory_turns
FROM inv ORDER BY inventory_turns DESC;


-- ----------------------------------------------------------------------------
-- 9. INFLATION PASS-THROUGH  : shelf impact of an input shock by model
--    Discounters (own-label heavy, EDLP) absorb a larger share.
-- ----------------------------------------------------------------------------
WITH shock AS (SELECT 8.0 AS input_pct)  -- e.g. +8% input cost
SELECT
    c.chain, c.operating_model,
    s.input_pct                                                   AS input_shock_pct,
    ROUND(s.input_pct *
        (1 - CASE WHEN c.operating_model = 'Discounter' THEN 0.48 ELSE 0.36 END)
    , 2)                                                          AS est_shelf_passthrough_pct
FROM chains c CROSS JOIN shock s
ORDER BY est_shelf_passthrough_pct ASC;


-- ----------------------------------------------------------------------------
-- 10. SUPPLY-CHAIN RISK  : mean exposure and worst dimension per chain
-- ----------------------------------------------------------------------------
SELECT
    r.chain, c.operating_model,
    ROUND(AVG(r.exposure))                                        AS avg_exposure,
    (ARRAY_AGG(r.dimension ORDER BY r.exposure DESC))[1]          AS top_risk_dimension,
    MAX(r.exposure)                                               AS top_risk_score
FROM risk_scores r JOIN chains c USING (chain)
GROUP BY r.chain, c.operating_model
ORDER BY avg_exposure DESC;


-- ----------------------------------------------------------------------------
-- 11. CATEGORY INFLATION  ranked, flagging perishable-led pressure
-- ----------------------------------------------------------------------------
SELECT
    category, annual_inflation,
    RANK() OVER (ORDER BY annual_inflation DESC) AS inflation_rank,
    CASE WHEN annual_inflation >= 6.5 THEN 'Acute'
         WHEN annual_inflation >= 5.0 THEN 'Elevated'
         ELSE 'Moderate' END                     AS pressure_band
FROM inflation_category
ORDER BY annual_inflation DESC;
