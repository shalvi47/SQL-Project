use health1;
select * from org_data;

#--- 1. Total number of discharges from the hospital-------
SELECT 
  CONCAT(ROUND(SUM(DIS_TOT) / 1000000, 1), 'M') AS total_discharges
FROM 
  org_data;
  
#-------- 2. Average Patient Stays per Hospital ---------
SELECT 
  IFNULL(FAC_NAME, 'Total') AS FAC_NAME, 
  ROUND(AVG(`Patient Stay(days)`), 0) AS avg_patient_stay
FROM org_data
GROUP BY FAC_NAME WITH ROLLUP;

#----- 3. State-wise Revenue and Hospital Count -------
SELECT 
  IFNULL(COUNTY_NAME, 'Total') AS STATE, 
  COUNT(DISTINCT FAC_NAME) AS hospital_count,
  CONCAT(ROUND(SUM(CAST(REPLACE(REPLACE(NET_PAT_REV_CC, '$', ''), ',', '') AS UNSIGNED)) / 1000000, 1), 'M') AS total_revenue
FROM org_data
WHERE NET_PAT_REV_CC IS NOT NULL AND NET_PAT_REV_CC != ''
GROUP BY COUNTY_NAME WITH ROLLUP;

#--------- 4. Net patient revenue by year and month ----------
SELECT 
  IFNULL(YEAR, 'Total') AS YEAR, 
  IFNULL(MONTH, 'Total') AS MONTH, 
  CONCAT(ROUND(SUM(CAST(REPLACE(REPLACE(NET_PAT_REV_CC, '$', ''), ',', '') AS FLOAT)) / 1000000, 1), 'M') AS net_patient_revenue_in_million
FROM 
  org_data
GROUP BY 
  YEAR, MONTH WITH ROLLUP
ORDER BY 
  YEAR, MONTH;

#----- 5. Number of hospitals and their total revenue, grouped by state ----
SELECT 
  IFNULL(COUNTY_NAME, 'Total') AS COUNTY_NAME, 
  COUNT(DISTINCT FAC_NAME) AS num_hospitals,
  CONCAT(ROUND(SUM(CAST(REPLACE(REPLACE(NET_PAT_REV_CC, '$', ''), ',', '') AS FLOAT)) / 1000000), 'M') AS total_revenue_in_million
FROM org_data
GROUP BY COUNTY_NAME WITH ROLLUP;

#----- 6. Summarize revenue based on hospital type---------
SELECT 
  IFNULL(TYPE_CNTRL, 'Total') AS hospital_type,
  CONCAT(ROUND(SUM(CAST(REPLACE(REPLACE(NET_PAT_REV_CC, '$', ''), ',', '') AS FLOAT)) / 1000000), 'M') AS total_revenue_in_million
FROM org_data
GROUP BY TYPE_CNTRL WITH ROLLUP;

#------ 7. YOY GROWTH ------
SELECT  
  IFNULL(YEAR, 'Total') AS YEAR, 
  IFNULL(CONCAT(ROUND(SUM(CAST(REPLACE(REPLACE(NET_PAT_REV_CC, '$', ''), ',', '') AS FLOAT)) / 1000000, 2), 'M'), 'NA') AS NET_TOT_in_M
FROM 
  org_data
GROUP BY  
  YEAR WITH ROLLUP
ORDER BY 
  CASE WHEN YEAR = 'Total' THEN 9999 ELSE YEAR END DESC;

#---- 8. QOQ GROWTH --------
WITH quarterly_data AS (
  SELECT 
    YEAR, 
    QUARTER, 
    SUM(CAST(REPLACE(REPLACE(NET_PAT_REV_CC, '$', ''), ',', '') AS FLOAT)) AS REVENUE
  FROM 
    org_data
  GROUP BY 
    YEAR, QUARTER WITH ROLLUP
),

lagged_quarters AS (
  SELECT 
    IFNULL(YEAR, 'Total') AS YEAR, 
    IFNULL(QUARTER, 'Total') AS QUARTER, 
    REVENUE,
    LAG(REVENUE) OVER (PARTITION BY QUARTER ORDER BY YEAR) AS PREV_QUARTER_REVENUE
  FROM 
    quarterly_data
)

SELECT 
  YEAR, 
  QUARTER, 
  CONCAT(ROUND(REVENUE / 1000000, 2), 'M') AS REVENUE_IN_MILLION,
  CONCAT(
    ROUND(
      (REVENUE - PREV_QUARTER_REVENUE) / PREV_QUARTER_REVENUE * 100, 2
    ), '%'
  ) AS QOQ_GROWTH
FROM 
  lagged_quarters
WHERE 
  PREV_QUARTER_REVENUE IS NOT NULL 
ORDER BY 
  CASE WHEN YEAR = 'Total' THEN 9999 ELSE YEAR END DESC, 
  CASE WHEN QUARTER = 'Total' THEN 5 ELSE QUARTER END DESC;

#----9. MOM GROWTH--------
WITH monthly_data AS (
  SELECT 
    YEAR, 
    MONTH, 
    SUM(CAST(REPLACE(REPLACE(NET_PAT_REV_CC, '$', ''), ',', '') AS FLOAT)) AS REVENUE
  FROM 
    org_data
  GROUP BY 
    YEAR, MONTH WITH ROLLUP
),

lagged_months AS (
  SELECT 
    IFNULL(YEAR, 'Total') AS YEAR, 
    IFNULL(MONTH, 'Total') AS MONTH, 
    REVENUE,
    LAG(REVENUE) OVER (PARTITION BY YEAR ORDER BY MONTH) AS PREV_MONTH_REVENUE
  FROM 
    monthly_data
)

SELECT 
  YEAR, 
  MONTH, 
  IFNULL(CONCAT(ROUND(REVENUE / 1000000, 2), 'M'), '-') AS REVENUE_M,
  IFNULL(CONCAT(ROUND(PREV_MONTH_REVENUE / 1000000, 2), 'M'), '-') AS PREV_MONTH_REVENUE_M,
  IFNULL(
    CONCAT(
      ROUND(
        (REVENUE - PREV_MONTH_REVENUE) / PREV_MONTH_REVENUE * 100, 2
      ), '%'
    ), 
    '-'
  ) AS MOM_GROWTH_PERCENT
FROM 
  lagged_months
ORDER BY 
  CASE WHEN YEAR = 'Total' THEN 9999 ELSE YEAR END DESC, 
  CASE WHEN MONTH = 'Total' THEN 13 ELSE MONTH END DESC;
