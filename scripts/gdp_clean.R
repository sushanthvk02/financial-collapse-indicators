# Load libraries
library(tidyverse)

# Read the raw data, remove unnecessary rows, clean up NAs
gdp_raw <- read.csv("data/raw/GDP_Growth - WBG.csv", skip = 4, na.strings = c("", "NA", "..", "n/a"))

# Keep only Country and years columns
gdp_clean <- gdp_raw[, c(1, 5:ncol(gdp_raw) - 1)]

# Rename first column
colnames(gdp_clean)[1] <- "Country"

# Clean year column names (remove "X")
colnames(gdp_clean)[2:ncol(gdp_clean)] <- gsub("^X", "", colnames(gdp_clean)[2:ncol(gdp_clean)])

# Keep only years 1990–2023
years_to_keep <- as.character(1990:2023)
gdp_trimmed <- gdp_clean[, c("Country", years_to_keep)]

# Converting to Long format
gdp_long <- gdp_trimmed %>%
  pivot_longer(-Country, names_to = "Year", values_to = "GDP_Growth_Rate") %>%
  mutate(
    Year = as.numeric(Year),
    GDP_Growth_Rate = as.numeric(GDP_Growth_Rate)
  )

# Save to cleaned folder
write.csv(gdp_long, "data/cleaned/GDP_Growth_Rate.csv", row.names = FALSE)



