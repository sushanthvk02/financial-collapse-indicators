# Load libraries
library(tidyverse)

# Read the raw inflation data
inflation_raw <- read.csv("data/raw/Inflation_Rates - WBG.csv", skip = 4, na.strings = c("", "..", "NA", "n/a"))


# Keep Country and Year columns
inflation_clean <- inflation_raw[, c(1, 5:ncol(inflation_raw))]
colnames(inflation_clean)[1] <- "Country"

# Remove X from year columns
colnames(inflation_clean)[2:ncol(inflation_clean)] <- gsub("^X", "", colnames(inflation_clean)[2:ncol(inflation_clean)])

# Only keep years 1990–2023
years_to_keep <- as.character(1990:2023)
inflation_trimmed <- inflation_clean[, c("Country", intersect(colnames(inflation_clean), years_to_keep))]

# Change to long format
inflation_long <- inflation_trimmed %>%
  pivot_longer(-Country, names_to = "Year", values_to = "Inflation_CPI") %>%
  mutate(
    Year = as.numeric(Year),
    Inflation_CPI = as.numeric(Inflation_CPI)
  )

# Save the cleaned output
write.csv(inflation_long, "data/cleaned/Inflation_CPI.csv", row.names = FALSE)
