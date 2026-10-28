SELECT
    d.region_name,
    SUM(p.analyst_ads) AS ads_2020_2024,
    ROUND(100.0 * SUM(p.analyst_ads)
          / (SELECT SUM(analyst_ads) FROM fact_panel), 1) AS pct_of_all_ads,
    ROUND(SUM(p.analyst_ads) * 10000.0 / (SUM(p.population) / 5.0) / 5, 2) AS ads_per_10k_per_year
FROM fact_panel AS p
JOIN dim_municipality AS d
    ON p.municipality = d.municipality
GROUP BY d.region_name
ORDER BY ads_2020_2024 DESC;