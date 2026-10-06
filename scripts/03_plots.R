library(dplyr)
library(tidyr)
library(ggplot2)

dir.create("output", showWarnings = FALSE)

monthly <- read.csv("data/clean/monthly.csv")
monthly$date <- as.Date(monthly$date)
annual <- read.csv("data/clean/annual.csv")

colors <- c("United States" = "#2a78d6", "Japan" = "#eb6834", "China" = "#1baf7a",
            "Yen" = "#eb6834", "Yuan" = "#1baf7a")

# Figure 1
rates_long <- monthly %>%
  select(date, us_rate, jp_rate, cn_rate) %>%
  pivot_longer(-date, names_to = "country", values_to = "rate") %>%
  mutate(country = recode(country, us_rate = "United States",
                          jp_rate = "Japan", cn_rate = "China"))
rates_long$country <- factor(rates_long$country, levels = c("United States", "Japan", "China"))

fig1 <- ggplot(rates_long, aes(date, rate, color = country)) +
  geom_hline(yintercept = 0, color = "grey70") +
  geom_line(linewidth = 0.8) +
  scale_color_manual(values = colors) +
  labs(title = "3-month interest rates in the US, Japan and China",
       x = NULL, y = "Percent", color = NULL,
       caption = "Source: OECD via FRED") +
  theme_minimal() +
  theme(legend.position = "top")

ggsave("output/fig1_rates.png", fig1, width = 8, height = 4.5, dpi = 300)

# Figure 2
base <- monthly %>% filter(date == as.Date("2021-01-01"))

fx_index <- monthly %>%
  filter(date >= as.Date("2021-01-01")) %>%
  mutate(Yen = usdjpy / base$usdjpy * 100,
         Yuan = usdcny / base$usdcny * 100) %>%
  select(date, Yen, Yuan) %>%
  pivot_longer(-date, names_to = "currency", values_to = "index")

fig2 <- ggplot(fx_index, aes(date, index, color = currency)) +
  geom_hline(yintercept = 100, color = "grey70") +
  geom_line(linewidth = 0.8) +
  scale_color_manual(values = colors) +
  labs(title = "Yen and yuan per US dollar since 2021",
       subtitle = "Index, Jan 2021 = 100. Higher means the currency is weaker against the dollar",
       x = NULL, y = "Index", color = NULL,
       caption = "Source: Federal Reserve via FRED (EXJPUS, EXCHUS)") +
  theme_minimal() +
  theme(legend.position = "top")

ggsave("output/fig2_fx_index.png", fig2, width = 8, height = 4.5, dpi = 300)

# Figure 3
annual <- annual %>%
  mutate(gap_change_jp = real_gap_jp - lag(real_gap_jp),
         gap_change_cn = real_gap_cn - lag(real_gap_cn))

annual_long <- bind_rows(
  annual %>% transmute(year, currency = "Yen", gap_change = gap_change_jp, change = jpy_change),
  annual %>% transmute(year, currency = "Yuan", gap_change = gap_change_cn, change = cny_change)
) %>%
  filter(!is.na(gap_change))

fig3 <- ggplot(annual_long, aes(gap_change, change, color = currency)) +
  geom_hline(yintercept = 0, color = "grey70") +
  geom_vline(xintercept = 0, color = "grey70") +
  geom_point(size = 2.5) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.8) +
  geom_text(data = filter(annual_long, year %in% c(2022, 2023)), aes(label = year),
            vjust = -1, size = 3, show.legend = FALSE) +
  scale_color_manual(values = colors) +
  labs(title = "Change in the real interest rate gap with the US and currency change, 2004-2024",
       x = "Change in real rate gap from previous year (percentage points)",
       y = "Change in currency per dollar from previous year (%)",
       color = NULL,
       caption = "Real rate = 3-month rate minus CPI inflation. Source: OECD, World Bank, Federal Reserve via FRED") +
  theme_minimal() +
  theme(legend.position = "top")

ggsave("output/fig3_gap_vs_change.png", fig3, width = 8, height = 5, dpi = 300)

# numbers for the blog text
annual %>%
  summarise(cor_yen = cor(gap_change_jp, jpy_change, use = "complete.obs"),
            cor_yuan = cor(gap_change_cn, cny_change, use = "complete.obs"))
