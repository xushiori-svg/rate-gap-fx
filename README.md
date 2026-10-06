# Interest rate gaps and the yen vs. the yuan

Question: why did the yen weaken much more than the yuan against the US dollar after 2021, and how much of this can the interest rate gap with the US explain?

## Folder structure

```
rate-gap-fx/
  scripts/
    01_download.R     download data from FRED
    02_clean.R        merge data, compute rate gaps and real rates
    03_plots.R        make figures and key numbers
  data/
    raw/              raw csv files from FRED
    clean/            monthly.csv, annual.csv
  output/             figures (png) and key_numbers.csv
  README.md
```

## How to replicate

1. Open the R project (or set the working directory to this folder).
2. Install packages if needed:
   ```r
   install.packages(c("dplyr", "tidyr", "ggplot2"))
   ```
3. Run the scripts in order:
   ```r
   source("scripts/01_download.R")
   source("scripts/02_clean.R")
   source("scripts/03_plots.R")
   ```

No API key is needed. `01_download.R` reads the csv files directly from FRED, so results may change slightly if FRED updates the data.

## Data

All series come from FRED (Federal Reserve Bank of St. Louis): https://fred.stlouisfed.org

| Series ID | Description | Original source | Frequency |
|---|---|---|---|
| IR3TIB01USM156N | US 3-month interbank rate | OECD | Monthly |
| IR3TIB01JPM156N | Japan 3-month interbank rate | OECD | Monthly |
| IR3TIB01CNM156N | China 3-month interbank rate | OECD | Monthly |
| EXJPUS | Japanese yen per US dollar | Federal Reserve | Monthly |
| EXCHUS | Chinese yuan per US dollar | Federal Reserve | Monthly |
| FPCPITOTLZGUSA | US CPI inflation | World Bank | Annual |
| FPCPITOTLZGJPN | Japan CPI inflation | World Bank | Annual |
| FPCPITOTLZGCHN | China CPI inflation | World Bank | Annual |

## Outputs

- `fig1_rates.png`: 3-month interest rates in the US, Japan and China, 2002-2026
- `fig2_fx_index.png`: yen and yuan per US dollar, index Jan 2021 = 100
- `fig3_gap_vs_change.png`: yearly change in the real rate gap vs. yearly currency change, 2004-2024
- `key_numbers.csv`: numbers used in the blog post (latest index values, slopes, correlations, standard deviations)

## Notes

- 3-month rates are used instead of 10-year yields because FRED does not have a 10-year yield for China.
- Real rate = 3-month rate minus CPI inflation in the same year. Monthly CPI for Japan stops in 2021 on FRED, so annual inflation is used.
- Rate gap = US rate minus Japan (or China) rate.
- The annual sample is 2003-2024 because 2025 US inflation is not yet available. Figure 3 starts in 2004 because it uses the change from the previous year.
