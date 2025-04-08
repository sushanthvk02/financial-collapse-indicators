# Load libraries
library(tidyverse)
library(readxl)

# Read the Excel file
debt_raw <- read_excel("data/raw/Central_Govt_Debt - IMF.xls", skip = 0, na = c("", "..", "NA", "n/a"))

# Rename first column to Country
colnames(debt_raw)[1] <- "Country"

# Keep only Country + 1990–2023 columns 
years_to_keep <- as.character(1990:2023)
cols_to_keep <- c("Country", intersect(colnames(debt_raw), years_to_keep))
debt_trimmed <- debt_raw[2:(nrow(debt_raw) - 2), cols_to_keep]

# Convert to long format
debt_long <- debt_trimmed %>%
  pivot_longer(-Country, names_to = "Year", values_to = "Govt_Debt_Percent_GDP") %>%
  mutate(
    Year = as.numeric(Year),
    Govt_Debt_Percent_GDP = as.numeric(Govt_Debt_Percent_GDP)
  )

# Save to cleaned folder
write.csv(debt_long, "data/cleaned/Govt_Debt_percent_GDP.csv", row.names = FALSE)
