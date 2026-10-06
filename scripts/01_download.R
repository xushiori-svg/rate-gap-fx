dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

series <- c(
  "IR3TIB01USM156N",# US 3-month interbank rate, monthly
  "IR3TIB01JPM156N",# Japan 3-month interbank rate, monthly
  "IR3TIB01CNM156N",# China 3-month interbank rate, monthly
  "EXJPUS",# yen per dollar, monthly average
  "EXCHUS",# yuan per dollar, monthly average
  "FPCPITOTLZGUSA",# US inflation, annual
  "FPCPITOTLZGJPN",# Japan inflation, annual
  "FPCPITOTLZGCHN"# China inflation, annual
)

for (id in series) {
  url <- paste0("https://fred.stlouisfed.org/graph/fredgraph.csv?id=", id)
  df <- read.csv(url, na.strings = c(".", ""))
  write.csv(df, paste0("data/raw/", id, ".csv"), row.names = FALSE)
  Sys.sleep(1)
}

