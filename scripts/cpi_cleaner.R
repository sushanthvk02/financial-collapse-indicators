library(dplyr)
library(tidyr)
library(readr)

# Read the CPI index data directly from the specified file path
cpi_raw <- read_csv(
  "D:/Downloads/Files/DATA 467/project/Datasets/CPI index.csv",
  skip = 4,  # Skip the first 4 rows (metadata and empty rows)
  na = c("", "NA"),
  trim_ws = TRUE
)

# Examine the raw data
cat("Dimensions of raw data:", dim(cpi_raw)[1], "rows,", dim(cpi_raw)[2], "columns\n")
cat("Column names:\n")
print(names(cpi_raw)[1:10])  # Print first 10 column names

# Rename columns for clarity
names(cpi_raw)[1:4] <- c("Country", "Country_Code", "Indicator_Name", "Indicator_Code")

# Check the data
cat("\nFirst few rows of raw data:\n")
print(head(cpi_raw[, 1:10], 3))  # Show just the first 10 columns

# Filter to keep only CPI index data
cpi_data <- cpi_raw

cat("\nNumber of countries with CPI data:", nrow(cpi_data), "\n")

# Convert to long format
cpi_long <- cpi_data %>%
  pivot_longer(
    cols = -c(Country, Country_Code, Indicator_Name, Indicator_Code),
    names_to = "Year",
    values_to = "CPI_Index"
  ) %>%
  mutate(
    Year = as.numeric(Year),
    CPI_Index = as.numeric(CPI_Index)
  ) %>%
  filter(!is.na(Year), !is.na(CPI_Index), Year >= 1990, Year <= 2023) %>%
  select(Country, Year, CPI_Index)  # Keep only the essential columns

# Examine the processed data
cat("\nFirst few rows of processed data:\n")
print(head(cpi_long, 10))

# Summarize the cleaned data
cat("\nSummary of cleaned CPI index data:\n")
cat("Rows:", nrow(cpi_long), "\n")
cat("Countries:", length(unique(cpi_long$Country)), "\n")
cat("Year range:", min(cpi_long$Year, na.rm = TRUE), "to", max(cpi_long$Year, na.rm = TRUE), "\n")

# Write to file
write_csv(cpi_long, "D:/Downloads/Files/DATA 467/project/Datasets/cpi_index_cleaned.csv")
cat("\nCleaned data saved to: D:/Downloads/Files/DATA 467/project/Datasets/cpi_index_cleaned.csv\n")

cat("\nData cleaning complete!\n")
