# Melbourne Real Estate Market Analysis
### Findings & Recommendations — based on 34,857 transaction records (2016–2018)

---

## 1. Data Overview

- **Total records:** 34,857 | **Records with a sale price:** 27,247 (78%)
- **Time range:** January 2016 – March 2018
- **Notable missing data:** BuildingArea (61%), YearBuilt (55%), Landsize (34%) — worth keeping in mind for any analysis involving area-based metrics.
- **Average price:** 1,050,173 AUD | **Median price:** 870,000 AUD (median well below the mean → right-skewed distribution, driven by a small number of ultra-high-end properties).

---

## 2. Key Findings

### 2.1 Property type drives price segment
| Type | # Sales | Avg Price | Avg Price/sqm |
|---|---|---|---|
| House (h) | 18,472 | 1,203,718 | 9,718 |
| Townhouse (t) | 2,866 | 931,077 | **18,408** |
| Unit/Apartment (u) | 5,909 | 627,943 | 10,756 |

**Insight:** Townhouses have a lower total price than houses but the highest price per sqm — reflecting the land + construction cost concentrated into a smaller footprint, typically in denser, closer-to-CBD locations.

### 2.2 Location is the #1 pricing factor
- **Southern Metropolitan** leads: avg. price 1,395,928 AUD, averaging only 9km from the CBD.
- **Western Victoria** (far outer suburbs) is the cheapest: 432,607 AUD.
- Price vs. CBD-distance relationship is close to linear (inverse): 0–5km (1,152,389) → 5–10km (1,175,359, peak) → declining steadily → 30+km drops to just 632,256 AUD.
- **Most expensive council:** Boroondara City Council (1,667,326 AUD); **cheapest in the ranked list:** Maribyrnong (829,902 AUD).

### 2.3 Top most expensive / most affordable suburbs (≥30 sales)
- **Most expensive:** Canterbury (2.39M), Middle Park (2.23M), Malvern (2.09M), Brighton (1.98M), Albert Park (1.93M).
- **Most affordable:** Melton South (424K), Melton (435K), Meadow Heights (484K) — all in the western/north-western outer suburbs, more than 25km from the CBD.
- **"Value" suburbs** (within 10km of CBD but low price/sqm): Altona North (5,657/sqm), Pascoe Vale (6,084/sqm), Essendon West (6,324/sqm) — worth noting for buyers who want proximity to the centre on a tighter budget.

### 2.4 Rooms and amenities have a strong impact on price
- Price rises almost linearly with room count: 1 room (433K) → 3 rooms (1.03M) → 5 rooms (1.82M).
- Each additional bathroom adds significant value: 1 bathroom (882K) → 2 (1.19M) → 3 (1.75M) → 4 (2.58M).
- Parking spaces: 0 spaces (1.08M, skewed upward by many expensive inner-city properties without garages) → 2 spaces (1.19M) → 5 spaces (1.40M), a generally rising trend with more parking.

### 2.5 Building age has a non-linear effect
- Homes built before 1900 (period/Victorian-era homes in older central suburbs) command very high average prices (1900s decade: 1.47M).
- Prices bottom out around the 1970s decade (775K) — coinciding with the wave of budget outer-suburb housing built during that era.
- Homes built 2000–2010+ recover slightly (943K–966K) thanks to modern building standards, but still trail well behind older inner-city homes — suggesting **location matters more than the age of the building**.

### 2.6 Time trend: the market is cooling
- Average price by year: 2016 (1.06M) → 2017 (1.05M, -1.1%) → Q1 2018 (1.02M, -3.2% vs. 2017).
- This lines up with the period when Melbourne's market began cooling after the hot 2014–2016 cycle, coinciding with tighter credit conditions introduced by APRA (Australian Prudential Regulation Authority).

### 2.7 Sale method and clearance rates
- 56.6% of listings sold outright via a successful auction/private treaty (Method = S); 13.9% were "passed in" (failed to meet reserve).
- Highest success rate by region: Northern/Western Victoria (~78%); lowest: Eastern Metropolitan (66.7%) — higher-priced areas tend to be more selective for buyers, leading to a higher passed-in rate.

### 2.8 Agents & market liquidity
- Highest-volume agents: Nelson (2,735 sales), Jellis (2,532) — but Jellis' average price (1.35M) is notably higher than Nelson's (1.02M), suggesting Jellis is more concentrated in the premium segment.
- Highest average sale price agents (≥20 sales): Abercromby's (2.04M), Kay (2.01M), Marshall (1.96M) — these agencies specialize in the luxury segment.
- Highest-liquidity suburbs: Reservoir (844 sales), Bentleigh East (583), Richmond (552).
- Highest turnover ratio (sales / total property stock): Essendon West (7.8%), Jacana (6.5%) — a sign of an active market or a suburb undergoing demographic transition.

### 2.9 Market-wide price segmentation
| Price band | % of market |
|---|---|
| Under $500K | 10.9% |
| $500K–$800K | 31.8% (largest) |
| $800K–$1.2M | 27.3% |
| $1.2M–$2M | 22.9% |
| $2M+ | 7.2% |
→ The majority of transactions (59%) fall in the 500K–1.2M range — this is the dominant middle-market segment of the Melbourne housing market.

---

## 3. Recommendations

**For first-time buyers / limited budgets:**
- Prioritize "value" suburbs close to the CBD such as Altona North, Pascoe Vale, and Essendon West/North — price per sqm 30–40% lower than comparably-located premium suburbs.
- Consider units/apartments or townhouses in the 10–15km band instead of houses in the inner core.

**For investors:**
- High-turnover areas (Essendon West, Jacana, Niddrie) suggest strong liquidity, suited to shorter/medium-term buy-sell strategies.
- The slight price decline in 2017–2018 suggests a market correction phase — potentially a good entry point ahead of a recovery cycle, though this should be checked against more recent data beyond March 2018 (outside this dataset's scope).
- Southern Metropolitan and the Boroondara/Stonnington/Bayside councils remain the safest value-holding areas (steady price growth, stable demand).

**For sellers:**
- Consider listing during higher-volume months (May, September, November — Australian spring/early-summer) to maximize buyer competition.
- Match the agent to the segment: agencies like Jellis/Marshall/Kay suit premium properties; Nelson/Barry/Ray suit the mainstream segment with higher transaction volume.

**For policymakers / urban planning:**
- Distance from the CBD is the strongest single price driver — investing in public transport links to suburbs in the 15–30km band (where prices remain lower) could help relieve price pressure in the inner core.
- The higher passed-in rate in Eastern Metropolitan suggests the premium market segment is more sensitive to interest-rate movements — worth monitoring when adjusting credit policy.

**Limitations of this analysis:**
- ~22% of transactions lack a sale price (unsold or undisclosed), so average figures may be slightly skewed.
- Over 55% missing YearBuilt/BuildingArea — analyses involving these two fields are indicative only, not fully representative of the whole market.
- The dataset only runs through March 2018 — it does not capture market developments since then (e.g., COVID-19 impact, recent interest rate changes).

---

## 4. Attached Files
- melbourne_housing_analysis.sql — the full set of 25+ SQL queries, organized into 10 sections (data quality, market overview, geography, CBD distance, property characteristics, time trends, sale method, agents, supply-demand, price segmentation).
- melbourne_housing.db — the cleaned SQLite database (housing table with derived columns: price_per_sqm, SaleYear, SaleMonth, etc.), ready to open in DB Browser for SQLite or query directly using the .sql file above.
