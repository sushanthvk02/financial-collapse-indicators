# Load libraries
library(tidyverse)

# Read the raw CSV, remove necessary rows, fix NA strings
interest_raw <- read.csv("data/raw/Real_Interest_Rates - WBG.csv", skip = 4, na.strings = c("", "..", "NA", "n/a"))

# Keep only Country and columns 5 onward (the years)
interest_clean <- interest_raw[, c(1, 5:ncol(interest_raw) - 1)]

# Rename first column
colnames(interest_clean)[1] <- "Country"

# Clean year names: "X1990" -> "1990"
colnames(interest_clean)[2:ncol(interest_clean)] <- gsub("^X", "", colnames(interest_clean)[2:ncol(interest_clean)])

# Filter to keep only years 1990–2023
years_to_keep <- as.character(1990:2023)
interest_trimmed <- interest_clean[, c("Country", years_to_keep)]

# Convert to long format
interest_long <- interest_trimmed %>%
  pivot_longer(-Country, names_to = "Year", values_to = "Real_Interest_Rate") %>%
  mutate(
    Year = as.numeric(Year),
    Real_Interest_Rate = as.numeric(Real_Interest_Rate)
  )

# Save it to cleaned folder
write.csv(interest_long, "data/cleaned/Real_Interest_Rates.csv", row.names = FALSE)
