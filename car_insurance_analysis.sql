/* =========================================================================
   CAR INSURANCE RISK SEGMENTATION — SQL
   ========================================================================= */
CREATE TABLE Insurance_Policies (
    ID               VARCHAR(20),         
    birthdate        DATE,
    marital_status   VARCHAR(20),
    car_use          VARCHAR(20),     
    gender           VARCHAR(10),
    kids_driving     INT,
    parent           VARCHAR(5),
    education        VARCHAR(30),
    car_make         VARCHAR(30),
    car_model        VARCHAR(30),
    car_color        VARCHAR(20),
    car_year         INT,
    claim_freq       INT,
    coverage_zone    VARCHAR(30),
    claim_amt        DECIMAL(12,2),
    household_income DECIMAL(12,2)
);


/* =========================================================================
   Q1 — Claims by coverage zone, marital status, education, gender.
   ========================================================================= */
SELECT coverage_zone,
       ROUND(AVG(claim_freq), 3)  AS avg_claim_freq,
       ROUND(AVG(claim_amt), 2)   AS avg_claim_amt,
       COUNT(*)                   AS n
FROM Insurance_Policies
GROUP BY coverage_zone
ORDER BY avg_claim_amt DESC;

SELECT marital_status,
       ROUND(AVG(claim_freq), 3) AS avg_claim_freq,
       ROUND(AVG(claim_amt), 2)  AS avg_claim_amt,
       COUNT(*)                  AS n
FROM Insurance_Policies
GROUP BY marital_status
ORDER BY avg_claim_amt DESC;

SELECT education,
       ROUND(AVG(claim_freq), 3) AS avg_claim_freq,
       ROUND(AVG(claim_amt), 2)  AS avg_claim_amt,
       COUNT(*)                  AS n
FROM Insurance_Policies
GROUP BY education
ORDER BY avg_claim_amt DESC;

SELECT gender,
       ROUND(AVG(claim_freq), 3) AS avg_claim_freq,
       ROUND(AVG(claim_amt), 2)  AS avg_claim_amt,
       COUNT(*)                  AS n
FROM Insurance_Policies
GROUP BY gender;


/* =========================================================================
   Q2 — Car usage distribution by gender and kids_driving presence
   ========================================================================= */
SELECT gender,
       (kids_driving > 0)                                    
	   AS has_kids_driving,
       car_use,
       COUNT(*)                                                
	   AS n,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) 
	   OVER (PARTITION BY gender, kids_driving > 0), 1) AS pct_within_group
FROM Insurance_Policies
GROUP BY gender, kids_driving > 0, car_use
ORDER BY gender, has_kids_driving, car_use;


/* =========================================================================
   Q3 — Which car_make/model are most frequently in claims
   ========================================================================= */
SELECT car_make,
       COUNT(*)                  AS n_policies,
       ROUND(AVG(claim_freq), 3) AS avg_claim_freq,
       ROUND(AVG(claim_amt), 2)  AS avg_claim_amt
FROM Insurance_Policies
GROUP BY car_make
HAVING COUNT(*) >= 30          
ORDER BY avg_claim_amt DESC;


/* =========================================================================
   Q4 — Car color vs. claims
   ========================================================================= */
SELECT car_color,
       ROUND(AVG(claim_freq), 3) AS avg_claim_freq,
       ROUND(AVG(claim_amt), 2)  AS avg_claim_amt,
       COUNT(*)                  AS n
FROM Insurance_Policies
GROUP BY car_color
ORDER BY avg_claim_amt DESC;


/* =========================================================================
   Q5 — Household income vs. claims 
   ========================================================================= */
SELECT
    CASE
        WHEN household_income < 40000  THEN '<40k'
        WHEN household_income < 70000  THEN '40k-70k'
        WHEN household_income < 100000 THEN '70k-100k'
        ELSE '100k+'
    END AS income_band,
    ROUND(AVG(claim_freq), 3) AS avg_claim_freq,
    ROUND(AVG(claim_amt), 2)  AS avg_claim_amt,
    COUNT(*)                  AS n
FROM Insurance_Policies
GROUP BY income_band
ORDER BY income_band;


/* =========================================================================
   Q6 — Full summary table used for the "flat distribution" chart
   (every variable side-by-side, min/max/spread as % of overall average)
   ========================================================================= */
SELECT 'coverage_zone' AS variable, MIN(avg_claim_amt) AS min_amt, MAX(avg_claim_amt) AS max_amt
FROM (SELECT coverage_zone, ROUND(AVG(claim_amt),2) AS avg_claim_amt FROM Insurance_Policies GROUP BY coverage_zone) t
UNION ALL
SELECT 'marital_status', MIN(avg_claim_amt), MAX(avg_claim_amt)
FROM (SELECT marital_status, ROUND(AVG(claim_amt),2) AS avg_claim_amt FROM Insurance_Policies GROUP BY marital_status) t
UNION ALL
SELECT 'education', MIN(avg_claim_amt), MAX(avg_claim_amt)
FROM (SELECT education, ROUND(AVG(claim_amt),2) AS avg_claim_amt FROM Insurance_Policies GROUP BY education) t
UNION ALL
SELECT 'car_color', MIN(avg_claim_amt), MAX(avg_claim_amt)
FROM (SELECT car_color, ROUND(AVG(claim_amt),2) AS avg_claim_amt FROM Insurance_Policies GROUP BY car_color) t;