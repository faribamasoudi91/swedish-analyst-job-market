SELECT
    d.municipality_name,
    d.region_name,
    SUM(p.analyst_ads) AS ads_2020_2024,
    ROUND(100.0 * SUM(p.analyst_ads)
          / (SELECT SUM(analyst_ads) FROM fact_panel), 1) AS pct_of_all_ads
FROM fact_panel AS p
JOIN dim_municipality AS d
    ON p.municipality = d.municipality
GROUP BY d.municipality_name, d.region_name
ORDER BY ads_2020_2024 DESC
LIMIT 10;