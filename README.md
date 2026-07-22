# 📊 Melbourne Housing Market Analysis — SQL Project
A SQL-based analysis of the Melbourne (Australia) real estate market, based on 34,857 property sale records from 2016–2018.
---

## 1. Project Goals
- Clean and standardize raw real estate data (multiple data-type issues, missing values, non-standard date formats).
- Write a comprehensive set of SQL queries covering: price by location, property type, property characteristics, time trends, sale method, agent performance, and more.
- Derive findings & recommendations applicable to buyers, investors, sellers, and urban policy planners.
---


## 2. Raw Data Description

| Column | Meaning | Issues to note |
|---|---|---|
| Suburb, Address, Postcode | Location | — |
| Rooms, Bedroom, Bathroom, Car | Room/facility counts | Contains NULLs (~24% for Bathroom) |
| Type | h = house, u = unit/apartment, t = townhouse | — |
| Method | Sale method (S, SP, PI, VB, SN, PN, SA, W, SS) | — |
| Date | Sale date | Text format D/M/YYYY, variable-length day/month (e.g. 3/9/2016, not 03/09/2016) |
| Distance | Distance to CBD (km) | — |
| Landsize, BuildingArea | Land/building area | BuildingArea contains the literal string "inf" mixed into a numeric column; ~61% NULL |
| YearBuilt | Year built | ~55% NULL |
| CouncilArea, Regionname | Administrative area | — |
| Price | Sale price (AUD) | NULL for unsold/undisclosed properties (~22%) |
| Propertycount | Total properties in the suburb | Used to calculate turnover ratio |

**Data time range:** January 2016 – March 2018.

---

## 3. How to Run the Project

### Option 1 — Use the pre-built database (fastest)
1. Open **DB Browser for SQLite**.
2. Open Database → select melbourne_housing.db.
3. Go to the **Execute SQL** tab, copy/open queries from melbourne_housing_analysis.sql (skip the SETUP section since the housing table already exists) → run directly.

### Option 2 — Rebuild from scratch (if you want to do the cleaning yourself)
1. Create a new database in DB Browser, name it whatever you like.
2. Import Melbourne_housing.csv as a raw database (File → Import → Table from CSV).
    **Important:** when importing, make sure the option to treat empty cells as NULL is checked, so they don't get auto-filled with 0.
3. Copy the full contents of melbourne_housing_analysis.sql, run **SECTION 0 — SETUP** first to create the cleaned housing table.
4. Then run the analytical queries in SECTIONS 1–10 as needed.

---

## 4. Data Cleaning Steps (SECTION 0 in the .sql file)

| Issue | How it's handled |
|---|---|
| BuildingArea contains the string "inf" | CASE WHEN BuildingArea = 'inf' THEN NULL ELSE CAST(BuildingArea AS REAL) END |
| Price stored as TEXT (causes incorrect MIN/MAX comparisons) | CAST(Price AS REAL) AS Price directly in the SELECT that creates the table |
| Date is text D/M/YYYY with variable-length day/month | Parsed using instr()/substr() split on / positions, not fixed offsets |
| Need derived metrics (price per sqm, price per room) | Added via ALTER TABLE + UPDATE after table creation: price_per_sqm, price_per_room |
| Queries frequently filter by suburb/region/type/year | Created `INDEX`es on these columns for speed |

### Common Pitfalls and How to Spot Them

1. **MIN(Price) comes out larger than MAX(Price)**
   → Cause: the Price column has TEXT type, so SQLite compares values as **strings** (`"999999.0" > "1000000.0"` because `'9' > '1'`) instead of comparing them numerically.
   → Check with: `SELECT typeof(Price) FROM housing LIMIT 5;`
   → Fix: cast with `CAST(Price AS REAL)` at the time the table is created.

2. **Bathroom = 0 appears even though the raw CSV shows no row explicitly set to 0**
   → Cause: empty cells in the original CSV got auto-filled with `0` by the **CSV import tool** instead of being kept as NULL — this happens at the import step into housing_raw, before the housing table is even created.
   → Check with:
     ```sql
     SELECT COUNT(*) FROM housing_raw WHERE Bathroom = 0;
     SELECT COUNT(*) FROM housing_raw WHERE Bathroom IS NULL;
     ```
   → Fix: re-import the CSV with the correct option to treat blank cells as NULL. If you're stuck with data that already has this issue, consider filtering WHERE Bathroom > 0 instead of just IS NOT NULL when analyzing this column specifically.

3. **Don't DELETE or impute fake values for NULL rows at the base table level**
   → NULL is genuine information ("unknown/not available"); deleting these rows loses data in all the other columns of that row too, and imputing fake values distorts the analysis.
   → Correct approach: keep NULLs in the base table, and only filter `WHERE column IS NOT NULL` inside each query that specifically needs that column.

4. **NULL result when using LAG()/LEAD() on the first/last row**
   → This is expected behavior, not a bug: the first row has no "previous row" to compare against (e.g., calculating year-over-year growth for the very first year in the dataset), so LAG() returns NULL, and any calculation involving NULL also returns NULL.

---

## 5. Analytical Query Structure (melbourne_housing_analysis.sql)

| Section | Content |
|---|---|
| 0 | Setup — creates the cleaned `housing` table, indexes, derived columns |
| 1 | Data quality overview — counts missing values per column |
| 2 | Market snapshot — average/median price, distribution by property type |
| 3 | Geographic analysis — price by region/suburb/council, most expensive/affordable suburbs, "value" suburbs |
| 4 | Distance from CBD vs. price |
| 5 | Property characteristics vs. price — rooms, bathrooms, parking, year built |
| 6 | Time trends — price by month/year, year-over-year growth |
| 7 | Sale method analysis — sold/passed-in rate by region |
| 8 | Agent (SellerG) performance — sales volume, average sale price |
| 9 | Supply/demand signals — highest-liquidity suburbs, turnover ratio |
| 10 | Price segmentation — top most expensive/cheapest transactions, market-wide price bands |

---

## 6. Key Findings Summary

- **Average price:** 1,050,173 AUD | **Median price:** 870,000 AUD.
- **Location is the #1 price driver** — price decreases almost linearly as distance from the CBD increases.
- **Southern Metropolitan & Boroondara City Council** are the most expensive areas; **Western Victoria** is the most affordable.
- The market shows signs of **mild cooling**: average price fell -1.14% (2017) and -3.2% (Q1 2018 vs. 2017).
- 59% of transactions fall within the 500K–1.2M AUD range — this is the market's dominant price segment.

→ Full details in `Findings_Recommendations.md`.

---

## 7. Data Limitations

- ~22% of transactions lack a sale price → average figures may be slightly skewed.
- >55% missing YearBuilt/BuildingArea → analyses involving these two fields should be treated as indicative only.
- Data only extends through March 2018 → does not reflect subsequent market movements (COVID-19, recent interest rate changes, etc.).
- Some numeric fields (Bathroom, Car, etc.) may have `0` values that are actually import errors rather than true NULLs — worth re-checking if this dataset is reused elsewhere.

---

## 8. Tools Used

- **SQLite** (via DB Browser for SQLite).
- Queries can be ported to PostgreSQL/MySQL with minor adjustments (e.g., date-splitting functions, `CREATE TABLE AS SELECT` syntax; window functions are already compatible with most modern engines).
