SELECT
    year,
    COUNT(*) AS total_ads,
    SUM(CASE WHEN municipality IS NULL THEN 1 ELSE 0 END) AS ads_no_location,
    ROUND(100.0 * SUM(CASE WHEN municipality IS NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_no_location
FROM fact_ads
GROUP BY year
ORDER BY year;