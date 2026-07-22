/* ============================================================
   MELBOURNE / AUSTRALIAN HOUSING MARKET ANALYSIS
   Dataset: Melbourne_housing.csv (34,857 property sale records)
   Engine : SQLite 
   Author : Bao Chau Tran 
   ============================================================ */


/* ------------------------------------------------------------
   0. SETUP — CLEAN STAGING TABLE
   ------------------------------------------------------------ */
DROP TABLE IF EXISTS housing;

CREATE TABLE housing AS
SELECT
    ROW_NUMBER() OVER ()                                   AS property_id,
    Suburb,
    Address,
    Rooms,
    Type,                                    
    Method,                               
    SellerG                                  AS Agent,
    Date                                     AS SaleDate_raw,
    -- Date column is text in D/M/YYYY format with variable-length day/month (e.g. "3/9/2016"),
    CAST(substr(Date, instr(Date,'/') + instr(substr(Date, instr(Date,'/')+1), '/') + 1) AS INT) AS SaleYear,
    CAST(substr(substr(Date, instr(Date,'/')+1), 1, instr(substr(Date, instr(Date,'/')+1), '/') - 1) AS INT) AS SaleMonth,
    Distance,                                -- distance to Melbourne CBD, km
    Postcode,
    Bedroom,
    Bathroom,
    Car,
    Landsize,
    CASE WHEN BuildingArea = 'inf' THEN NULL ELSE CAST(BuildingArea AS REAL) END AS BuildingArea,
    YearBuilt,
    CouncilArea,
    Latitude,
    Longtitude                               AS Longitude,
    Regionname                               AS Region,
    Propertycount,
    ParkingArea,
    CAST(Price AS REAL)                      AS Price

FROM Melbourne_housing;

CREATE INDEX idx_h_suburb ON housing(Suburb);
CREATE INDEX idx_h_region ON housing(Region);
CREATE INDEX idx_h_type   ON housing(Type);
CREATE INDEX idx_h_year   ON housing(SaleYear);

/* Add derived value metrics used throughout the analysis */
ALTER TABLE housing ADD COLUMN price_per_sqm REAL;
ALTER TABLE housing ADD COLUMN price_per_room REAL;

UPDATE housing SET price_per_sqm  = ROUND(Price * 1.0 / NULLIF(BuildingArea,0), 0);
UPDATE housing SET price_per_room = ROUND(Price * 1.0 / NULLIF(Rooms,0), 0);


/* ============================================================
   SECTION 1 — DATA QUALITY OVERVIEW
   ============================================================ */

-- 1.1 Row counts & completeness of key fields
SELECT
    COUNT(*)                                            AS total_records,
    SUM(CASE WHEN Price IS NULL THEN 1 ELSE 0 END)      AS missing_price,
    SUM(CASE WHEN BuildingArea IS NULL THEN 1 ELSE 0 END) AS missing_building_area,
    SUM(CASE WHEN Landsize IS NULL THEN 1 ELSE 0 END)   AS missing_landsize,
    SUM(CASE WHEN YearBuilt IS NULL THEN 1 ELSE 0 END)  AS missing_year_built
FROM housing;

-- 1.2 Sales record date range
SELECT MIN(SaleYear||'-'||printf('%02d',SaleMonth)) AS earliest_sale,
       MAX(SaleYear||'-'||printf('%02d',SaleMonth)) AS latest_sale
FROM housing;


/* ============================================================
   SECTION 2 — OVERALL MARKET SNAPSHOT
   ============================================================ */

-- 2.1 Headline price statistics (sold properties only)
SELECT
    COUNT(*)                          AS sold_count,
    ROUND(AVG(Price),0)               AS avg_price,
    ROUND(MIN(Price),0)               AS min_price,
    ROUND(MAX(Price),0)               AS max_price
FROM housing
WHERE Price IS NOT NULL;

-- 2.2 Median price (SQLite has no native MEDIAN — window-based calc)
WITH ranked AS (
    SELECT Price,
           ROW_NUMBER() OVER (ORDER BY Price) AS rn,
           COUNT(*) OVER () AS cnt
    FROM housing WHERE Price IS NOT NULL
)
SELECT ROUND(AVG(Price),0) AS median_price
FROM ranked
WHERE rn IN ((cnt+1)/2, (cnt+2)/2);

-- 2.3 Price distribution by property type (house / unit / townhouse)
SELECT
    Type,
    COUNT(*)                AS n_sales,
    ROUND(AVG(Price),0)     AS avg_price,
    ROUND(AVG(price_per_sqm),0) AS avg_price_per_sqm
FROM housing
WHERE Price IS NOT NULL
GROUP BY Type
ORDER BY avg_price DESC;


/* ============================================================
   SECTION 3 — GEOGRAPHIC ANALYSIS (REGION / SUBURB / COUNCIL)
   ============================================================ */

-- 3.1 Average price & volume by metro region
SELECT
    Region,
    COUNT(*)             AS n_sales,
    ROUND(AVG(Price),0)  AS avg_price,
    ROUND(AVG(Distance),1) AS avg_distance_to_cbd_km
FROM housing
WHERE Price IS NOT NULL
GROUP BY Region
ORDER BY avg_price DESC;

-- 3.2 Top 10 most expensive suburbs (min 30 sales to avoid small-sample noise)
SELECT
    Suburb,
    COUNT(*)             AS n_sales,
    ROUND(AVG(Price),0)  AS avg_price,
    ROUND(AVG(Distance),1) AS avg_distance_km
FROM housing
WHERE Price IS NOT NULL
GROUP BY Suburb
HAVING COUNT(*) >= 30
ORDER BY avg_price DESC
LIMIT 10;

-- 3.3 Top 10 most affordable suburbs (min 30 sales)
SELECT
    Suburb,
    COUNT(*)             AS n_sales,
    ROUND(AVG(Price),0)  AS avg_price,
    ROUND(AVG(Distance),1) AS avg_distance_km
FROM housing
WHERE Price IS NOT NULL
GROUP BY Suburb
HAVING COUNT(*) >= 30
ORDER BY avg_price ASC
LIMIT 10;

-- 3.4 Best "value" suburbs: lowest price per sqm among suburbs close to CBD (<=10km)
SELECT
    Suburb,
    COUNT(*)                    AS n_sales,
    ROUND(AVG(Distance),1)      AS avg_distance_km,
    ROUND(AVG(price_per_sqm),0) AS avg_price_per_sqm
FROM housing
WHERE Price IS NOT NULL AND Distance <= 10 AND price_per_sqm IS NOT NULL
GROUP BY Suburb
HAVING COUNT(*) >= 15
ORDER BY avg_price_per_sqm ASC
LIMIT 10;

-- 3.5 Council areas ranked by average price
SELECT
    CouncilArea,
    COUNT(*)             AS n_sales,
    ROUND(AVG(Price),0)  AS avg_price
FROM housing
WHERE Price IS NOT NULL AND CouncilArea IS NOT NULL AND CouncilArea <> ''
GROUP BY CouncilArea
ORDER BY avg_price DESC;


/* ============================================================
   SECTION 4 — DISTANCE FROM CBD vs PRICE
   ============================================================ */

-- 4.1 Price by distance band
SELECT
    CASE
        WHEN Distance < 5  THEN '0-5 km'
        WHEN Distance < 10 THEN '5-10 km'
        WHEN Distance < 15 THEN '10-15 km'
        WHEN Distance < 20 THEN '15-20 km'
        WHEN Distance < 30 THEN '20-30 km'
        ELSE '30+ km'
    END AS distance_band,
    COUNT(*)             AS n_sales,
    ROUND(AVG(Price),0)  AS avg_price
FROM housing
WHERE Price IS NOT NULL AND Distance IS NOT NULL
GROUP BY distance_band
ORDER BY MIN(Distance);


/* ============================================================
   SECTION 5 — PROPERTY CHARACTERISTICS vs PRICE
   ============================================================ */

-- 5.1 Price by number of rooms
SELECT
    Rooms,
    COUNT(*)             AS n_sales,
    ROUND(AVG(Price),0)  AS avg_price
FROM housing
WHERE Price IS NOT NULL
GROUP BY Rooms
ORDER BY Rooms;

-- 5.2 Price by number of bathrooms
SELECT
    Bathroom,
    COUNT(*)             AS n_sales,
    ROUND(AVG(Price),0)  AS avg_price
FROM housing
WHERE Price IS NOT NULL AND Bathroom IS NOT NULL
GROUP BY Bathroom
ORDER BY Bathroom;

-- 5.3 Impact of car spaces on price
SELECT
    Car AS car_spaces,
    COUNT(*)             AS n_sales,
    ROUND(AVG(Price),0)  AS avg_price
FROM housing
WHERE Price IS NOT NULL AND Car IS NOT NULL
GROUP BY Car
ORDER BY Car;

-- 5.4 Price by decade built
SELECT
    (CAST(YearBuilt AS INT) / 10) * 10 AS decade_built,
    COUNT(*)             AS n_sales,
    ROUND(AVG(Price),0)  AS avg_price
FROM housing
WHERE Price IS NOT NULL AND YearBuilt IS NOT NULL AND YearBuilt BETWEEN 1850 AND 2020
GROUP BY decade_built
ORDER BY decade_built;


/* ============================================================
   SECTION 6 — TIME TRENDS
   ============================================================ */

-- 6.1 Average price and sales volume by year-month
SELECT
    SaleYear,
    SaleMonth,
    COUNT(*)             AS n_sales,
    ROUND(AVG(Price),0)  AS avg_price
FROM housing
WHERE Price IS NOT NULL
GROUP BY SaleYear, SaleMonth
ORDER BY SaleYear, SaleMonth;

-- 6.2 Year-over-year average price growth
WITH yearly AS (
    SELECT SaleYear, ROUND(AVG(Price),0) AS avg_price
    FROM housing
    WHERE Price IS NOT NULL
    GROUP BY SaleYear
)
SELECT
    SaleYear,
    avg_price,
    ROUND(100.0 * (avg_price - LAG(avg_price) OVER (ORDER BY SaleYear))
          / LAG(avg_price) OVER (ORDER BY SaleYear), 2) AS yoy_growth_pct
FROM yearly
ORDER BY SaleYear;


/* ============================================================
   SECTION 7 — AUCTION / SALE METHOD ANALYSIS
   ============================================================ */

-- 7.1 Sale method mix and resulting average prices
SELECT
    Method,
    COUNT(*)                                   AS n_sales,
    ROUND(100.0*COUNT(*) / (SELECT COUNT(*) FROM housing),1) AS pct_of_market,
    ROUND(AVG(Price),0)                        AS avg_price
FROM housing
GROUP BY Method
ORDER BY n_sales DESC;

-- 7.2 Clearance-style indicator: share of listings that sold vs passed in / withdrawn, by region
SELECT
    Region,
    COUNT(*) AS n_listings,
    ROUND(100.0 * SUM(CASE WHEN Method IN ('S','SP','SA') THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_sold,
    ROUND(100.0 * SUM(CASE WHEN Method IN ('PI','PN') THEN 1 ELSE 0 END) / COUNT(*), 1)      AS pct_passed_in
FROM housing
GROUP BY Region
ORDER BY pct_sold DESC;


/* ============================================================
   SECTION 8 — AGENTS (SellerG) PERFORMANCE
   ============================================================ */

-- 8.1 Top 10 agents by sales volume, with average price handled
SELECT
    Agent,
    COUNT(*)             AS n_sales,
    ROUND(AVG(Price),0)  AS avg_price
FROM housing
WHERE Price IS NOT NULL
GROUP BY Agent
HAVING COUNT(*) >= 50
ORDER BY n_sales DESC
LIMIT 10;

-- 8.2 Top 10 agents by average sale price (min. 20 sales, excludes tiny/luxury-only outliers)
SELECT
    Agent,
    COUNT(*)             AS n_sales,
    ROUND(AVG(Price),0)  AS avg_price
FROM housing
WHERE Price IS NOT NULL
GROUP BY Agent
HAVING COUNT(*) >= 20
ORDER BY avg_price DESC
LIMIT 10;


/* ============================================================
   SECTION 9 — SUPPLY / DEMAND SIGNALS
   ============================================================ */

-- 9.1 Suburbs with the highest sales volume 
SELECT
    Suburb,
    COUNT(*)             AS n_sales,
    ROUND(AVG(Price),0)  AS avg_price,
    MAX(Propertycount)   AS total_properties_in_suburb
FROM housing
GROUP BY Suburb
ORDER BY n_sales DESC
LIMIT 10;

-- 9.2 Sales turnover ratio (sales in dataset / total property stock) — proxy for market churn
SELECT
    Suburb,
    COUNT(*)                                          AS n_sales,
    MAX(Propertycount)                                AS total_properties,
    ROUND(100.0 * COUNT(*) / NULLIF(MAX(Propertycount),0), 2) AS turnover_pct
FROM housing
GROUP BY Suburb
HAVING MAX(Propertycount) > 0
ORDER BY turnover_pct DESC
LIMIT 10;


/* ============================================================
   SECTION 10 — OUTLIER / LUXURY & ENTRY-LEVEL SEGMENTS
   ============================================================ */

-- 10.1 Top 15 highest-priced transactions
SELECT Suburb, Address, Type, Rooms, Price, SaleYear, SaleMonth
FROM housing
WHERE Price IS NOT NULL
ORDER BY Price DESC
LIMIT 15;

-- 10.2 Entry-level segment: cheapest 15 transactions (data-quality sanity check included)
SELECT Suburb, Address, Type, Rooms, Landsize, BuildingArea, Price, SaleYear, SaleMonth
FROM housing
WHERE Price IS NOT NULL
ORDER BY Price ASC
LIMIT 15;

-- 10.3 Price segmentation buckets across the whole market
SELECT
    CASE
        WHEN Price < 500000  THEN '1. Under $500K'
        WHEN Price < 800000  THEN '2. $500K-$800K'
        WHEN Price < 1200000 THEN '3. $800K-$1.2M'
        WHEN Price < 2000000 THEN '4. $1.2M-$2M'
        ELSE '5. $2M+'
    END AS price_band,
    COUNT(*) AS n_sales,
    ROUND(100.0*COUNT(*) / (SELECT COUNT(*) FROM housing WHERE Price IS NOT NULL),1) AS pct_market
FROM housing
WHERE Price IS NOT NULL
GROUP BY price_band
ORDER BY price_band;
