# Load libraries
library(tidyverse)

# Read the raw CSV
homicide_raw <- read.csv("data/raw/Homicides_per_100k - WBG.csv", skip = 4, na.strings = c("", "..", "NA", "n/a"))

# Keep Country and year columns
homicide_clean <- homicide_raw[, c(1, 5:ncol(homicide_raw))]
colnames(homicide_clean)[1] <- "Country"

# Clean year column names
colnames(homicide_clean)[2:ncol(homicide_clean)] <- gsub("^X", "", colnames(homicide_clean)[2:ncol(homicide_clean)])

# Keep only years 1990–2023
years_to_keep <- as.character(1990:2023)
homicide_trimmed <- homicide_clean[, c("Country", intersect(colnames(homicide_clean), years_to_keep))]

# Change to long format
homicide_long <- homicide_trimmed %>%
  pivot_longer(-Country, names_to = "Year", values_to = "Homicide_Rate") %>%
  mutate(
    Year = as.numeric(Year),
    Homicide_Rate = as.numeric(Homicide_Rate)
  )

# Save cleaned output
write.csv(homicide_long, "data/cleaned/Homicide_Rate.csv", row.names = FALSE)
