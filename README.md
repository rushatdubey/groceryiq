# GroceryIQ

**Irish Grocery Economics & Retail Intelligence Platform**

An enterprise-grade retail intelligence platform that explains how operational decisions shape grocery pricing, affordability, and competitiveness across Ireland's five major chains: Aldi, Lidl, Tesco, Dunnes Stores, and SuperValu. Operating-model comparison, consumer economics, inventory optimization, inflation intelligence, and supply-chain risk in one decision system.

---

## The Problem

Five chains compete for roughly the same Irish grocery euro, yet they run on opposite logic. A full-range grocer stocks 20,000 to 40,000 products and competes on choice; a hard discounter wins with around 1,800 and competes on operational efficiency. The 2 to 3% net margin that lets Aldi and Lidl undercut everyone is not a pricing trick, it is the output of a supply chain built for velocity: a narrow range, roughly 90% own-label control, longer production runs, fewer suppliers, and inventory that turns more than twice as fast.

The headline question most analysis stops at is "which supermarket is cheapest." The more valuable question, the one GroceryIQ is built to answer, is "how do operational decisions shape grocery pricing, affordability, and retail competitiveness in Ireland." It pairs a real, sourced operating-model comparison with a prescriptive analytics stack: a consumer tradeoff engine, an inventory optimizer with scenario simulation, an inflation intelligence module with price-shock pass-through, and a supply-chain risk heatmap.

---

## Live Demo

A single self-contained `index.html`, no build step and no dependencies. Open it in any browser, or deploy the folder to Vercel.

🔗 Live Platform: https://groceryiq.vercel.app

```bash
git clone https://github.com/rushatdubey/groceryiq
cd groceryiq
open index.html
```

Explore:
- Executive overview with animated KPI ribbon and live market pulse ticker
- Retail market intelligence: Kantar share trajectory, margins, market concentration (HHI)
- Basket analytics: which retailer is actually cheapest across five basket types
- Consumer Tradeoff Engine: a weighted Retailer Fit Score under selected priorities
- Grocery Inflation Intelligence: trajectory, category split, projection, and price-shock simulation
- Discount Economics: the cost waterfall explaining why discounters are structurally cheaper
- Inventory Optimizer and "What Happens If" scenario engine
- Supply Chain Risk Heatmap by operating model
- Consulting-grade Executive Brief
- Light and dark enterprise themes

---

## Platform Preview

### Executive Overview
![Overview](screenshots/overview.png)

### Basket Analytics
![Basket](screenshots/basket.png)

### Consumer Tradeoff Engine
![Tradeoff](screenshots/tradeoff.png)

### Inflation Intelligence
![Inflation](screenshots/inflation.png)

### Inventory Optimizer and Scenario Engine
![Inventory](screenshots/inventory.png)

### Supply Chain Risk Heatmap
![Risk](screenshots/risk.png)

---

## Key Findings

| Signal | Value | Detail |
|---|---|---|
| Market HHI | 1,736 | CCPC (May 2025), based on retail units, market is deconcentrating |
| Top-5 share | ~93% | of all Irish grocery spend (Kantar / CCPC 2025) |
| SKU range gap | ~22x | Tesco (~40,000) vs Aldi (~1,800) active SKUs |
| Inventory turns | 2.2x | discounter velocity advantage over full-range (modelled) |
| Private label | ~90% / ~48% | Aldi vs Tesco own-label share |
| Promo intensity | under 10% / ~33% | discounter vs market-average volume on promotion |
| Net margin | 2.6 to 3.0% | discounter EDLP model vs ~3.7 to 4.2% full-range |
| Family basket gap | €1,165 / yr | cheapest (Lidl) vs dearest (SuperValu) |
| Discounter price edge | 15.4% | decomposed into operational cost drivers |
| Grocery inflation | 6.0% | Kantar, December 2025 |

*Benchmarks calibrated to Kantar Worldpanel (Ireland), CCPC high-level grocery analysis (Aug 2025), CMA Aldi hearing, Which? UK basket studies, and published company accounts.*

---

## Platform Modules

### Retail Market Intelligence
Monthly Kantar market share for all five chains through 2025, net margin by chain (real where disclosed: Tesco IE 3.7% to Feb 2024, Aldi IE 2023 accounts), and market concentration. The HHI of 1,736 and falling shows a genuinely competitive market reshaped by discounter entry since 2014. Lidl posted the fastest growth of any chain in 2025; Dunnes leads on share through quality-plus-voucher positioning.

### Basket Analytics
Five basket profiles (student, family of four, healthy, high-protein, inflation survival) priced across all five chains, with weekly, monthly and annual cost both at shelf and with each chain's real loyalty mechanic applied. Includes cost-per-1,000-kcal and cost-per-100g-protein. Lidl is cheapest and SuperValu dearest; Dunnes' €10-off-€50 voucher pulls its effective basket below Tesco's.

### Consumer Tradeoff Engine
A transparent multi-criteria decision model. The user assigns weights to lowest cost, product variety, quality and fresh, and convenience, sets household scale and loyalty usage, and the engine computes a Retailer Fit Score for each chain. It never claims a chain is objectively best, it reports which scores highest under the selected priorities, with a breakdown of the drivers. This is how real decision-intelligence systems work.

### Grocery Inflation Intelligence
Real 2025 Kantar grocery inflation trajectory, category decomposition (dairy and meat lead), a 12-month projection with a widening confidence band, and a retailer resilience ranking. The price-shock simulator applies an input cost shock and shows the shelf-price pass-through by operating model: own-label-heavy, everyday-low-price discounters absorb a larger share before it reaches the shelf.

### Discount Economics
A cost waterfall decomposing the roughly 15% discounter price advantage into its operational drivers: private label, narrow SKU range, simplified logistics, lower labour per euro of sales, minimal promotion, and faster inventory turns. The thesis: the discounters won on the supply chain, not on price.

### Inventory Optimizer and Scenario Engine
The prescriptive core. A (Q,R) policy across each chain's SKU book: EOQ, safety stock, reorder point, ABC classification and the service-level cost trade-off. The "What Happens If" simulator stresses the chain with supplier delay, inflation shock, fuel cost, SKU expansion or forecast-error shocks, and shows cost, stockout risk and working-capital impact live, differentiated by operating model.

### Supply Chain Risk Heatmap
Exposure scored across five operational risk dimensions (supplier dependency, lead-time volatility, spoilage exposure, logistics fragility, SKU complexity burden) for each chain, with a comparison radar. Discounters trade lower complexity and volatility for higher supplier concentration; full-range grocers carry the opposite signature.

---

## Data Architecture

The platform separates real, cited parameters from a transparently modelled analytics layer.

**Real (sourced):** market share and HHI (Kantar via CCPC high-level grocery analysis, Aug 2025; Kantar monthly releases 2025), SKU range (CMA Aldi hearing 2018; IGD and retail press 2024 to 25), private-label share (Aldi CEO via WSJ; Brand Nudge 2025), promo intensity (CMA Aldi hearing), operating margins (Tesco IE, Aldi IE and Musgrave accounts), basket-price ordering (2025 Irish price studies and Which? UK basket ratios), loyalty mechanics (Clubcard, Dunnes voucher, Real Rewards), and grocery inflation (Kantar 2025).

**Modelled (calibrated, reproducible):** a per-chain SKU book generated with a fixed random seed, where demand level, demand variability, lead-time mean and variance, unit cost and private-label flag are calibrated to each chain's published operating profile. Inventory metrics, basket cost indices, inflation projection, pass-through and risk scores are then computed, not assumed, so the discounter-vs-full-range contrast is an output of the model rather than an input.

| Dataset | Records | Description |
|---|---|---|
| Real parameters | 5 chains x 9+ metrics | Sourced market, structural and margin figures |
| Share time series | 6 readings x 4 chains | Kantar 2025 monthly market share |
| Modelled SKU book | up to 40,000 SKUs/chain | Demand, lead time, cost, perishability, PL flag |
| Service-level curves | 9 points x 4 chains | Inventory value and annual cost vs service level |
| Basket costs | 5 baskets x 5 chains | Weekly, annual, per-calorie, per-protein |
| Inflation | history + 12-month projection | Trajectory, category split, resilience, pass-through |
| Risk scores | 5 chains x 5 dimensions | Operational exposure matrix |

> Note: Full raw SKU books are generated programmatically. The Python pipeline (`python/analytics.py`, `python/groceryiq.py`) reproduces every figure deterministically from a fixed seed.

---

## Analytics & Optimization Engine

Standard inventory theory applied per SKU across each chain's book:

- **EOQ** equals the square root of (2 x D x S / H), with D annual demand, S order cost, H annual holding cost
- **Safety stock** equals z x sigma over lead time, combining demand and lead-time variance
- **Reorder point** equals mean daily demand x mean lead time plus safety stock
- **Holding cost** carries an added spoilage penalty for perishable categories (shelf life under 10 days)
- **ABC classification** by revenue contribution (Class A is the top 80% of revenue)
- **Service-level trade-off** recomputed across 80% to 99.5%
- **Inflation pass-through** modelled by operating model (own-label share and pricing strategy)
- **Risk exposure** scored from range breadth, supplier base, perishable share and DC footprint

Everything recomputes in-browser as the user moves the sliders.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Data & analytics | Python, Pandas, NumPy, SciPy |
| Inventory modelling | EOQ, (Q,R) policy, safety stock, ABC analysis |
| SQL layer | PostgreSQL-compatible SQL, window functions, CTEs |
| Frontend | HTML5, CSS3, Vanilla JavaScript |
| Charts | Chart.js 4.4 |
| Design | Enterprise dark and light themes, glassmorphism, Sora + Inter Tight + JetBrains Mono |

No frameworks, no bundler, no build step. The entire platform runs from a single HTML file with embedded CSS and JavaScript.

---

## Business Insights

**The discounters won on the supply chain, not on price.** The 2 to 3% net margin that enables permanent undercutting survives only because of 2.2x faster inventory turns, a roughly 22x narrower range, and around 90% own-label control. Price is the visible output; the operating model is the cause. Lidl posted the fastest growth of any Irish chain through 2025, a supply-chain story rather than a marketing one.

**Range is the most expensive decision a grocer makes.** Every additional SKU adds a supplier, a forecast, a safety-stock buffer and a slice of working capital. The optimizer quantifies how much inventory value a 40,000-line range demands versus a tight discounter book, and the scenario engine shows full-range chains are more exposed to supplier and demand shocks.

**Operational efficiency is an inflation hedge.** During inflationary cycles the operationally simplest model passes through the least. Own-label-heavy, everyday-low-price discounters absorb a larger share of input cost rises before they reach the shelf, turning supply-chain design into a pricing advantage.

**Dunnes' voucher economics offset premium shelf pricing.** On raw shelf price Dunnes sits above the discounters, but the €10-off-€50 voucher on a qualifying family shop pulls its effective annual basket below Tesco's, a real, measurable loyalty-economics effect.

**Full-range chains should compete with data, not imitation.** Tesco and Dunnes cannot shrink to 1,800 SKUs without abandoning their proposition. Their realistic lever is sharper inventory policy: service-level segmentation by ABC class, tighter safety stock on slow movers, and own-label expansion to reclaim supply-chain control.

---

## Repository Structure

```
groceryiq/
├── index.html                  # Full platform: landing, dashboard, all modules (single file)
├── screenshots/                # Platform preview images
├── sql/
│   └── groceryiq_queries.sql   # 11 analytical SQL queries (operating model, basket, inventory, ABC, risk)
├── python/
│   ├── analytics.py            # Inventory optimization pipeline (EOQ, safety stock, ABC, service curves)
│   └── groceryiq.py            # Basket economics, discount waterfall, inflation, risk, scenario params
├── data/
│   ├── analysis_output.json    # Inventory / operating-model outputs
│   └── groceryiq_data.json     # Basket, inflation, risk, consumer-attribute outputs
├── vercel.json
├── README.md
└── LICENSE
```

---

## Running the Analytics

```bash
pip install pandas numpy scipy
python python/analytics.py      # regenerates data/analysis_output.json
python python/groceryiq.py      # regenerates data/groceryiq_data.json
```

Both scripts are deterministic (fixed seed), so the dashboard figures reproduce exactly.

---

## Deploying to Vercel

This is a static site, so deployment is immediate.

1. Push the repository to GitHub.
2. In Vercel, import the repository.
3. Framework preset: **Other**. Build command: none. Output directory: project root.
4. Deploy. The included `vercel.json` serves `index.html` directly.

```bash
# or from the CLI
npm i -g vercel
vercel --prod
```

---

## Skills Demonstrated

**Operations analytics:** EOQ, safety stock, (Q,R) reorder policy, ABC classification, service-level cost trade-off, scenario sensitivity, perishability-adjusted holding cost.

**Consumer and pricing analytics:** basket modelling, loyalty economics, cost-per-calorie and cost-per-protein, a transparent multi-criteria decision (tradeoff) engine.

**Inflation analytics:** trajectory tracking, category decomposition, projection with confidence bands, price-shock pass-through by operating model.

**BI and KPI engineering:** market concentration (HHI), margin, share, executive KPI ribbon, risk heatmap.

**SQL:** window functions, CTEs, conditional aggregation, Pareto/ABC classification, HHI computation, EOQ and safety-stock expression in SQL.

**Data sourcing:** real Kantar, CCPC, CMA, Which? and company-accounts figures, cited and reconciled, with a clear split between sourced and modelled values.

**Frontend engineering:** single-file dashboard, dual light/dark theme, live in-browser optimizer and simulators with recomputing charts, glassmorphism design system, zero dependencies.

---

## About the Project

GroceryIQ was built to answer a specific question: can a single analyst, working from regulator and market data, build the analytics infrastructure that a retail strategy, operations or category team would need to understand the Irish grocery market and its competitive dynamics?

The business context is grounded in published Irish and UK market data. Market share, concentration, SKU range, private-label share, margins, basket-price ordering and inflation are real, cited figures. The modelled layer (inventory, basket indices, inflation projection, risk) is calibrated to those anchors and generated deterministically, with sourced and modelled values clearly separated throughout the platform.

---

## Author

**Rushat Dubey**
Dublin, Ireland

[linkedin.com/in/rushat](https://linkedin.com/in/rushat) &nbsp; [rushatdubey16@gmail.com](mailto:rushatdubey16@gmail.com) &nbsp; [github.com/rushatdubey](https://github.com/rushatdubey)

---

*Data: Kantar Worldpanel (Ireland), CCPC high-level grocery analysis (Aug 2025), CMA Aldi hearing, Which? UK basket studies, and published company accounts (Tesco IE, Aldi IE, Musgrave). Inventory, basket, inflation and risk metrics modelled with standard analytics, calibrated to published parameters. Built with Python, SQL, and a browser.*
