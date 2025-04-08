# Load libraries
library(tidyverse)

# Read the raw CSV file, skip unnecessary rows
npl_raw <- read.csv("data/raw/NPL_Ratio - WBG.csv", skip = 4, na.strings = c("", "..", "NA", "n/a"))

# Select only Country and year columns
npl_clean <- npl_raw[, c(1, 5:ncol(npl_raw) - 1)]

# Rename Country column
colnames(npl_clean)[1] <- "Country"

# Fix year column names: remove 'X' prefix
colnames(npl_clean)[2:ncol(npl_clean)] <- gsub("^X", "", colnames(npl_clean)[2:ncol(npl_clean)])

# Keep only years 1990–2023
years_to_keep <- as.character(1990:2023)
npl_trimmed <- npl_clean[, c("Country", intersect(colnames(npl_clean), years_to_keep))]

# Change to long format
npl_long <- npl_trimmed %>%
  pivot_longer(
    cols = -Country,
    names_to = "Year",
    values_to = "NPL_Ratio"
  ) %>%
  mutate(
    Year = as.numeric(Year),
    NPL_Ratio = as.numeric(NPL_Ratio)
  )

# Save to cleaned folder
write.csv(npl_long, "data/cleaned/NPL_Ratio.csv", row.names = FALSE)
