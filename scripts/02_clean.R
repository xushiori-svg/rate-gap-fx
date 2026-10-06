library(dplyr)

dir.create("data/clean", recursive = TRUE, showWarnings = FALSE)

read_fred <- function(id, new_name) {
  df <- read.csv(paste0("data/raw/", id, ".csv"))
  names(df) <- c("date", new_name)
  df$date <- as.Date(df$date)
  df
}

us_rate <- read_fred("IR3TIB01USM156N", "us_rate")
jp_rate <- read_fred("IR3TIB01JPM156N", "jp_rate")
cn_rate <- read_fred("IR3TIB01CNM156N", "cn_rate")
usdjpy  <- read_fred("EXJPUS", "usdjpy")
usdcny  <- read_fred("EXCHUS", "usdcny")

us_infl <- read_fred("FPCPITOTLZGUSA", "us_infl")
jp_infl <- read_fred("FPCPITOTLZGJPN", "jp_infl")
cn_infl <- read_fred("FPCPITOTLZGCHN", "cn_infl")

monthly <- us_rate %>%
  inner_join(jp_rate, by = "date") %>%
  inner_join(cn_rate, by = "date") %>%
  inner_join(usdjpy, by = "date") %>%
  inner_join(usdcny, by = "date") %>%
  na.omit() %>%
  mutate(gap_jp = us_rate - jp_rate,
         gap_cn = us_rate - cn_rate)

annual_rates <- monthly %>%
  mutate(year = as.integer(format(date, "%Y"))) %>%
  filter(year >= 2003, year <= 2025) %>%
  group_by(year) %>%
  summarise(us_rate = mean(us_rate),
            jp_rate = mean(jp_rate),
            cn_rate = mean(cn_rate))

annual_fx <- usdjpy %>%
  inner_join(usdcny, by = "date") %>%
  mutate(year = as.integer(format(date, "%Y"))) %>%
  group_by(year) %>%
  summarise(usdjpy = mean(usdjpy, na.rm = TRUE),
            usdcny = mean(usdcny, na.rm = TRUE)) %>%
  mutate(jpy_change = (usdjpy / lag(usdjpy) - 1) * 100,
         cny_change = (usdcny / lag(usdcny) - 1) * 100)

infl <- us_infl %>%
  inner_join(jp_infl, by = "date") %>%
  inner_join(cn_infl, by = "date") %>%
  mutate(year = as.integer(format(date, "%Y"))) %>%
  select(-date)

annual <- annual_rates %>%
  inner_join(infl, by = "year") %>%
  inner_join(annual_fx, by = "year") %>%
  mutate(us_real = us_rate - us_infl,
         jp_real = jp_rate - jp_infl,
         cn_real = cn_rate - cn_infl,
         real_gap_jp = us_real - jp_real,
         real_gap_cn = us_real - cn_real)

write.csv(monthly, "data/clean/monthly.csv", row.names = FALSE)
write.csv(annual, "data/clean/annual.csv", row.names = FALSE)
