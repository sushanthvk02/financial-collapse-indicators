# Load libraries
library(tidyverse)

# Read in raw CSV
unemp_raw <- read.csv("data/raw/Unemployment_Rate - WBG.csv", skip = 4, na.strings = c("", "..", "NA", "n/a"))

# Keep only Country + Year columns
unemp_clean <- unemp_raw[, c(1, 5:ncol(unemp_raw))]
colnames(unemp_clean)[1] <- "Country"

# Clean year names
colnames(unemp_clean)[2:ncol(unemp_clean)] <- gsub("^X", "", colnames(unemp_clean)[2:ncol(unemp_clean)])

# Select years 1990–2023
years_to_keep <- as.character(1990:2023)
unemp_trimmed <- unemp_clean[, c("Country", intersect(colnames(unemp_clean), years_to_keep))]

# Change to long format
unemp_long <- unemp_trimmed %>%
  pivot_longer(-Country, names_to = "Year", values_to = "Unemployment_Rate") %>%
  mutate(
    Year = as.numeric(Year),
    Unemployment_Rate = as.numeric(Unemployment_Rate)
  )

# Save cleaned output
write.csv(unemp_long, "data/cleaned/Unemployment_Rate.csv", row.names = FALSE)
