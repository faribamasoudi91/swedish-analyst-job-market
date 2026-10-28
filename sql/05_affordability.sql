SELECT
    d.municipality_name,
    d.region_name,
    p.population,
    ROUND(p.median_rent_sqm * 70 / 12.0) AS monthly_rent_70sqm,
    ROUND(p.median_income_tkr * 1000 / 12.0) AS monthly_income,
    ROUND(100.0 * p.median_rent_sqm * 70
          / (p.median_income_tkr * 1000), 1) AS rent_pct_of_income
FROM fact_panel AS p
JOIN dim_municipality AS d
    ON p.municipality = d.municipality
WHERE p.year = 2024
  AND p.population >= 50000
  AND p.median_rent_sqm IS NOT NULL
ORDER BY rent_pct_of_income;