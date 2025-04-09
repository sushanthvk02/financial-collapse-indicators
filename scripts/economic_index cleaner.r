library(dplyr)
library(readr)

# Write to a file for processing

# Read the economic indicators data
eco_raw <- read_csv(
  "D:/Downloads/Files/DATA 467/project/Datasets/economy_index.csv",
  na = c("", "NA"),
  trim_ws = TRUE
)

# Filter to years between 1990 and 2023 and keep only the relevant columns
eco_cleaned <- eco_raw %>%
  filter(Year >= 1990, Year <= 2023) %>%
  select(
    Country,
    Year,
    `Economic globalization index (0-100)`
  ) %>%
  rename(
    Economic_Globalization_Index = `Economic globalization index (0-100)`
  ) %>%
  filter(!is.na(Economic_Globalization_Index))  # Remove rows with missing globalization index

# Check the cleaned data
cat("Dimensions of cleaned data:", dim(eco_cleaned)[1], "rows,", dim(eco_cleaned)[2], "columns\n")
cat("First few rows of cleaned data:\n")
print(head(eco_cleaned, 7))

# Summarize the cleaned data
cat("\nSummary of cleaned economic globalization index data:\n")
cat("Rows:", nrow(eco_cleaned), "\n")
cat("Countries:", length(unique(eco_cleaned$Country)), "\n")
cat("Year range:", min(eco_cleaned$Year, na.rm = TRUE), "to", max(eco_cleaned$Year, na.rm = TRUE), "\n")

# Write to file
write_csv(eco_cleaned, "D:/Downloads/Files/DATA 467/project/Datasets/economic_index cleaned.csv")
cat("\nCleaned data saved to: D:/Downloads/Files/DATA 467/project/Datasets/economic_index cleaned.csv\n")

# Clean up the temporary file
file.remove("D:/Downloads/Files/DATA 467/project/Datasets/economic_index.csv")

cat("\nData cleaning complete!\n")
