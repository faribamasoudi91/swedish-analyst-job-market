# Data Decisions Log

## 1. Keep only the 290 municipalities
Kolada returns three types of codes:
- `0000` = Sweden total, `0001`–`0025` = regions (län)
- Codes starting with `G` = municipality groups (3,344 groups); their values are unweighted averages of member municipalities
- Remaining 290 four-digit codes = municipalities

Regions, country total and groups are removed. They are aggregates of the municipality rows, so keeping them would cause double counting.

## 2. Analysis period: 2020–2024
The unemployment KPI (N02280) only covers 2020–2024, because it is based on SCB's BAS method, which started in 2020. Older unemployment series use a different method, and combining them would create an artificial break in the time series. All sources are therefore limited to 2020–2024.

Note: 2020–2021 were COVID years with an unusual labour market, so trends should be interpreted with caution.

## 3. Unemployment is a November snapshot
N02280 measures people registered as unemployed at Arbetsförmedlingen during November of each year, as a share of the labour force aged 20–64. It is not an annual average.
## 4. SCB missing values
SCB marks unpublished values with `..` (usually because the sample was too small). They are read as missing (NaN) using `na_values=[".."]`. Verified against the SCB website: 1, 2, 1, 0, 2 missing municipalities for 2020–2024 respectively.

## 5. Rent: median, not mean
Median annual rent per m² (SCB table TAB4590) is used instead of the mean, because the median is not pulled up by a few very expensive apartments. Rent includes heating and water; student and elderly housing are excluded.

## 6. Rent margin of error
The rent figures come from a sample survey, so each value has a margin of error (± kr). Small municipalities can have large margins (e.g. Vallentuna 2020: 1,413 ± 382). Some values show a margin of exactly 0 (e.g. Kungsbacka 2023), which is not realistic for a sample and is treated as "unknown", not "perfectly precise". Values with large or zero margins will be flagged in the analysis.
## 7. Income: register data, ages 20–64
Median "sammanräknad förvärvsinkomst" (SCB table TAB3554), in thousands of SEK per year, for ages 20–64, both sexes, all income classes. The 20–64 age group matches the unemployment KPI, so both measure the same population. Capital income is not included. Income comes from tax registers (full population), so unlike rent it has no margin of error and no missing values.

## 8. Merge
All five tables were reshaped to one row per municipality and year, then left-joined on `municipality` + `year`, with population as the base table (complete, no missing values). Every merge uses `validate="one_to_one"` to guarantee no duplicated keys. Result: 1,450 rows (290 municipalities × 5 years). Spot-checked Göteborg (1480) against Kolada and SCB websites.
## 9. Definition of an "analyst job ad"
Job ads come from Arbetsförmedlingen's Historical Ads API (JobTech). An analyst ad is any ad classified under one of these six official occupations:

| Occupation | Concept ID |
|---|---|
| Dataanalytiker | eTVL_hfE_Lyh |
| Verksamhetsanalytiker | X1FS_ZXE_DT2 |
| Data Warehouse specialist | YpXF_Mob_zM8 |
| Statistiker | 5bYa_vBF_REN |
| Matematisk statistiker | GhhA_SVR_Nsr |
| Marknadsanalytiker | Eh2z_fA6_4Ls |

Excluded: Systemanalytiker, Kravanalytiker (software/IT design roles) and Finansanalytiker (finance domain).

Free-text search was rejected: "dataanalytiker" matched only 83 ads in 2023, spread over unrelated occupations, and missed English-language ads.

The occupation "Dataanalytiker" did not exist in the taxonomy before 2023 (0 ads in 2020–2022, 8 in 2023, 49 in 2024). Ads are therefore always counted as the **sum of all six occupations**, so that ads moving between categories do not create artificial trends.
## 10. Job ad cleaning
All ad cleaning is done in `03_clean_merge.ipynb`, starting from the raw JSON file.

| Step | Rows | Removed | Reason |
|---|---|---|---|
| Raw | 6,938 | | Matches occupation counts from the API |
| Exact duplicates | 6,900 | 38 | Same headline, employer, municipality and timestamp, different ad ID |
| Abroad | 6,834 | 66 | Country not Sweden. Country appears as both "Sverige" and "SE" (both kept); 60 ads with no country kept |
| Workforce-management roles | 6,801 | 33 | Headlines "Real Time Manager" / "Workforce Specialist": operational call-centre scheduling roles, misclassified as Verksamhetsanalytiker. 31 of 33 from one employer, concentrated in Östersund |

The workforce rule was first tested as a broad keyword match ("Workforce", "WFM", "Real Time"), but that also caught genuine analyst roles (e.g. a BI developer at PostNord, "Workforce Management Analyst"), so it was narrowed to the two exact operational titles.

- Re-posts of the same ad in different months are kept, since they may represent new openings.
- Ads with no workplace municipality are excluded from municipality-level counts but kept in national totals.
- 12 ads have no occupation label even though they were returned by an occupation search. Kept.

## 11. Zero vs missing
After merging ad counts into the panel, municipality-years with no ads are filled with 0, because the ad data is complete: no ad means zero ads. Missing rent values are NOT filled, because there "missing" means "unknown" (not published by SCB).

## 12. Normalisation
Ads are normalised per 10,000 inhabitants (`ads_per_10k`). Small municipalities produce unstable rates (e.g. Oxelösund 2022: 6 ads, 12k inhabitants). Rankings will use a minimum population threshold and/or 5-year totals.
## 13. Employer type (Power BI)
A calculated column `Employer Type` labels each ad as "Recruitment agency" or "Direct employer", based on a list of known Swedish recruitment agencies seen in the data (e.g. Academic Work, Talent & Partner, Bravura, Randstad) plus keywords in the employer name ("Rekrytering", "Recruit", "Bemanning", "Staffing"). The list is not exhaustive: agencies not on the list and without a keyword are counted as direct employers. Result: 3 of the top 10 employers are recruitment agencies, including the largest one.

Employer names are shortened for display (`Employer Short`) by removing the suffixes " Sweden AB", " Sverige AB" and " AB".