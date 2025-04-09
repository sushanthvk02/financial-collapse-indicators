# Load libraries
library(tidyverse)

# Read the raw CSV
health_raw <- read.csv("data/raw/Health_Expenditure_Percent - WBG.csv", skip = 4, na.strings = c("", "..", "NA", "n/a"))


# Keep Country and year columns
health_clean <- health_raw[, c(1, 5:ncol(health_raw))]
colnames(health_clean)[1] <- "Country"

# Clean year names: remove "X" prefix
colnames(health_clean)[2:ncol(health_clean)] <- gsub("^X", "", colnames(health_clean)[2:ncol(health_clean)])

# Only keep years 1990–2023
years_to_keep <- as.character(1990:2023)
health_trimmed <- health_clean[, c("Country", intersect(colnames(health_clean), years_to_keep))]

# Change to long format
health_long <- health_trimmed %>%
  pivot_longer(-Country, names_to = "Year", values_to = "Health_Expenditure_Percent") %>%
  mutate(
    Year = as.numeric(Year),
    Health_Expenditure_Percent = as.numeric(Health_Expenditure_Percent)
  )

# Save cleaned output
write.csv(health_long, "data/cleaned/Healthcare_Expenditure.csv", row.names = FALSE)
