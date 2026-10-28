# Where should a data analyst look for work in Sweden?

An end-to-end analysis of **6,801 analyst job ads (2020–2024)** combined with population, unemployment, rent and income for all **290 Swedish municipalities**. The data comes from four public APIs and is cleaned in Python, modelled in SQL and presented in Power BI.

![Labour market](reports/screenshots/01_labour_market.png)

## Key findings

- **Demand peaked in 2022 and has fallen since.** Analyst ads rose from about 800 (2020) to about 1,800 (2022), then dropped to about 1,000 in 2024 (−22% vs 2023).
- **The market is highly concentrated.** Stockholm alone has 3,039 of 6,501 located ads (47%); Stockholm, Göteborg and Solna together hold about two thirds.
- **Per resident, Solna and Sundbyberg lead**, and both have a rent burden below the median, making them the best mix of jobs and affordability.
- **Göteborg** is the second-largest market with a rent burden close to the median. **Malmö and Uppsala** have solid demand but the highest rent relative to local income.
- **Recruitment agencies matter.** 3 of the top 10 employers are agencies, including the largest (Academic Work). Government agencies (Försäkringskassan, SCB) are also major hirers.

![Jobs vs cost of living](reports/screenshots/02_jobs_vs_cost.png)

## Data sources

| Source | Data | Access |
|---|---|---|
| [Arbetsförmedlingen – JobTech Historical Ads](https://jobtechdev.se/en/components/historical-ads) | Job ads with occupation, employer, workplace | REST API, CC0 |
| [Kolada (RKA)](https://www.kolada.se) | Population (`N01951`), unemployment 20–64 (`N02280`) | REST API |
| [Statistics Sweden (SCB)](https://www.scb.se/en/services/open-data-api/pxwebapi/) | Median rent per m² (`TAB4590`), median income 20–64 (`TAB3554`) | PxWebApi 2 |

**"Analyst"** = ads classified under six official occupations: Dataanalytiker, Verksamhetsanalytiker, Data Warehouse specialist, Statistiker, Matematisk statistiker, Marknadsanalytiker.

## Method

| Step | Tool | What happens |
|---|---|---|
| 1 · Collect | Python (`requests`) | Three APIs, pagination (`next_url` and `offset`), raw responses saved unchanged |
| 2 · Clean | Python (`pandas`) | Remove aggregate rows, reshape wide → long, handle SCB missing markers (`..`), deduplicate ads, standardise country values, remove misclassified roles |
| 3 · Merge | Python | Municipality × year panel (1,450 rows), joined on municipality code with `validate="one_to_one"` |
| 4 · Analyse | SQL (SQLite) | Six business questions: trends, rankings, regions, affordability, summary view |
| 5 · Present | Power BI | Star schema with shared municipality and year dimensions, DAX measures |

![Data and method](reports/screenshots/03_data_method.png)

### Data quality issues found and handled

- **Aggregates mixed with municipalities:** Kolada returned 3,656 codes (country, regions, 3,344 municipality groups); only the 290 municipalities were kept to avoid double counting.
- **Taxonomy break:** the occupation *Dataanalytiker* did not exist before 2023 (0 ads 2020–2022). All analysis uses the sum of all six occupations so ads moving between categories do not create fake trends.
- **Misclassified ads:** 33 call-centre scheduling roles were classified as business analysts and concentrated in one city. A broad keyword rule was tested first and rejected because it also removed real BI roles.
- **Inconsistent values:** Sweden appeared as both `Sverige` and `SE`.
- **Zero vs missing:** municipalities with no ads are set to 0; unpublished rent values stay missing.

Every decision is documented in [`decisions.md`](decisions.md).

## Limitations

- Ads are counted by **workplace**, rent and income by **residence**, so commuter municipalities look weaker than they are.
- SCB rent is the median of **existing contracts**; newcomers often pay more on the second-hand market.
- Income is the median of **all residents** aged 20–64, not analyst salaries.
- Some ads are posted by **recruitment agencies**, so the real employer is unknown.
- Rates for **small municipalities** are unstable; charts default to municipalities above 50,000 residents.

## Repository structure

```
├── notebooks/
│   ├── 01_kolada_fetch.ipynb       # population, unemployment, municipality names
│   ├── 02_scb_fetch.ipynb          # rent, income
│   ├── 03_clean_merge.ipynb        # cleaning + panel (no API calls)
│   ├── 04_jobtech_fetch.ipynb      # job ads
│   └── 05_build_database.ipynb     # SQLite database + summary view
├── sql/                            # six analysis queries
├── data_raw/                       # API responses (see note below)
├── data_clean/                     # panel, ads, dimension, SQLite database
├── reports/                        # Power BI report, theme, screenshots
└── decisions.md                    # data decisions log
```

## How to reproduce

Requires Python 3 with `pandas` and `requests`. Run the notebooks in this order:

1. `01_kolada_fetch` and `02_scb_fetch`
2. `04_jobtech_fetch` downloads the job ads (~40 MB). **This file is not included in the repository** because of its size; the notebook recreates it.
3. `03_clean_merge`
4. `05_build_database`

The cleaned data is already in `data_clean/`, so the Power BI report and SQL queries work without running any code.

---

**Fariba Masoudi** · MSc Applied Economics and Data Analysis, Jönköping University
