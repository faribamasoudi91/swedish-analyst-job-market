DROP VIEW IF EXISTS v_municipality_summary;

CREATE VIEW v_municipality_summary AS
SELECT
    d.municipality,
    d.municipality_name,
    d.region_name,
    ROUND(AVG(p.population)) AS avg_population,
    SUM(p.analyst_ads) AS ads_2020_2024,
    ROUND(SUM(p.analyst_ads) * 10000.0 / AVG(p.population) / 5, 2) AS ads_per_10k_per_year,
    MAX(CASE WHEN p.year = 2024 THEN p.unemployment_rate END) AS unemployment_2024,
    MAX(CASE WHEN p.year = 2024 THEN p.median_income_tkr END) AS income_2024_tkr,
    MAX(CASE WHEN p.year = 2024 THEN p.median_rent_sqm END) AS rent_sqm_2024,
    MAX(CASE WHEN p.year = 2024 THEN p.rent_moe END) AS rent_moe_2024,
    ROUND(100.0 * MAX(CASE WHEN p.year = 2024 THEN p.median_rent_sqm END) * 70
          / (MAX(CASE WHEN p.year = 2024 THEN p.median_income_tkr END) * 1000), 1) AS rent_pct_of_income_2024
FROM fact_panel AS p
JOIN dim_municipality AS d
    ON p.municipality = d.municipality
GROUP BY d.municipality, d.municipality_name, d.region_name;