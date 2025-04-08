library(dplyr)
library(tidyr)
library(readr)

# Read the data directly from your file path
unemployment_raw <- read_csv(
  "D:/Downloads/Files/DATA 467/project/Datasets/unemployment.csv",
  na = c("", "NA", "no data"),
  trim_ws = TRUE
)

# Check the raw data
cat("Column names after reading:\n")
print(names(unemployment_raw))
cat("\nFirst 5 rows of raw data:\n")
print(head(unemployment_raw, 5))
cat("\nDimensions of raw data:", dim(unemployment_raw)[1], "rows,", dim(unemployment_raw)[2], "columns\n")

# Debugging: Check if the first column is correctly identified
cat("\nFirst column name:", names(unemployment_raw)[1], "\n")

# Rename the first column if it's not already "Country"
if (names(unemployment_raw)[1] != "Country") {
  names(unemployment_raw)[1] <- "Country"
  cat("Renamed first column to 'Country'\n")
}

# Check if there is a second row that's empty (all NAs)
if (all(is.na(unemployment_raw[1, -1]))) {
  cat("Found empty second row, removing it\n")
  unemployment_raw <- unemployment_raw[-1, ]
}

# Convert to long format with more explicit debugging
cat("\nAttempting to convert to long format...\n")

unemployment_long <- unemployment_raw %>%
  pivot_longer(
    cols = -Country,
    names_to = "Year",
    values_to = "Unemployment_Rate"
  )

cat("Pivot complete. Checking long format data structure:\n")
print(head(unemployment_long, 5))
cat("Dimensions after pivot:", dim(unemployment_long)[1], "rows,", dim(unemployment_long)[2], "columns\n")

# Convert Year and Unemployment_Rate to numeric with careful handling
unemployment_long <- unemployment_long %>%
  mutate(
    # Try to convert Year to numeric, but preserve the original if it fails
    Year_orig = Year,
    Year = suppressWarnings(as.numeric(Year)),
    # Only proceed with rows where Year converted successfully
    Unemployment_Rate = as.numeric(Unemployment_Rate)
  )

# Check for any failed Year conversions
if (any(is.na(unemployment_long$Year) & !is.na(unemployment_long$Year_orig))) {
  cat("\nWARNING: Some year values couldn't be converted to numbers:\n")
  problem_years <- unique(unemployment_long$Year_orig[is.na(unemployment_long$Year)])
  print(head(problem_years, 10))
}

# Filter for valid years between 1990-2023
unemployment_clean <- unemployment_long %>%
  filter(!is.na(Year), Year >= 1990, Year <= 2023) %>%
  select(Country, Year, Unemployment_Rate)  # Drop the Year_orig column

# Check the final cleaned data
cat("\nFinal cleaned data structure:\n")
print(head(unemployment_clean, 5))
cat("Dimensions of cleaned data:", dim(unemployment_clean)[1], "rows,", dim(unemployment_clean)[2], "columns\n")

# Summarize the cleaned data
cat("\nSummary of cleaned unemployment data:\n")
cat("Rows:", nrow(unemployment_clean), "\n")
cat("Countries:", length(unique(unemployment_clean$Country)), "\n")
if (nrow(unemployment_clean) > 0) {
  cat("Year range:", min(unemployment_clean$Year, na.rm = TRUE), "to", max(unemployment_clean$Year, na.rm = TRUE), "\n")
} else {
  cat("Year range: No data after filtering\n")
}

# Write the cleaned data to a CSV file
write_csv(unemployment_clean, "D:/Downloads/Files/DATA 467/project/Datasets/unemployment_rate_cleaned.csv")
cat("\nCleaned data saved to: D:/Downloads/Files/DATA 467/project/Datasets/unemployment_rate_cleaned.csv\n")

cat("\nData cleaning complete!\n")
