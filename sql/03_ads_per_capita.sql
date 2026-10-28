SELECT
    d.municipality_name,
    d.region_name,
    ROUND(AVG(p.population)) AS avg_population,
    SUM(p.analyst_ads) AS ads_2020_2024,
    ROUND(SUM(p.analyst_ads) * 10000.0 / AVG(p.population) / 5, 2) AS ads_per_10k_per_year
FROM fact_panel AS p
JOIN dim_municipality AS d
    ON p.municipality = d.municipality
GROUP BY d.municipality_name, d.region_name
HAVING AVG(p.population) >= 50000
ORDER BY ads_per_10k DESC
LIMIT 15;