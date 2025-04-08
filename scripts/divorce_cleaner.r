library(dplyr)
library(tidyr)
library(readr)

# Read the divorce data directly from the file path
divorce_raw <- read_csv(
  "D:/Downloads/Files/DATA 467/project/Datasets/Divorce Rates.csv",
  skip = 2,  # Skip the first two rows
  col_names = FALSE,  # No column names in the file
  na = c("", "NA", "no data"),
  trim_ws = TRUE
)

# Check the structure
cat("Dimensions of raw data:", dim(divorce_raw)[1], "rows,", dim(divorce_raw)[2], "columns\n")
cat("First few rows:\n")
print(head(divorce_raw, 3))

# The structure should be:
# X1 = ID, X2 = Country, X3-X47 = Years (1980-2024)

# Assign proper column names
year_cols <- 1980:2024
all_cols <- c("ID", "Country", as.character(year_cols))
names(divorce_raw) <- all_cols[1:ncol(divorce_raw)]

# Check with proper column names
cat("\nWith proper column names:\n")
print(head(divorce_raw, 3))

# Convert to long format
divorce_long <- divorce_raw %>%
  pivot_longer(
    cols = as.character(year_cols),
    names_to = "Year",
    values_to = "Divorce_Rate"
  ) %>%
  mutate(
    Year = as.numeric(Year),
    Divorce_Rate = as.numeric(Divorce_Rate)
  ) %>%
  filter(!is.na(Year), Year >= 1990, Year <= 2023)  # Filter to years between 1990 and 2023

# Check the long format data
cat("\nFirst few rows of the long format data:\n")
print(head(divorce_long, 10))

# Summarize the cleaned data
cat("\nSummary of cleaned divorce data:\n")
cat("Rows:", nrow(divorce_long), "\n")
cat("Countries:", length(unique(divorce_long$Country)), "\n")
cat("Year range:", min(divorce_long$Year, na.rm = TRUE), "to", max(divorce_long$Year, na.rm = TRUE), "\n")

# Drop the ID column if not needed for joining
divorce_final <- divorce_long %>%
  select(Country, Year, Divorce_Rate)

# Write to file
write_csv(divorce_final, "D:/Downloads/Files/DATA 467/project/Datasets/divorce_rate_cleaned.csv")
cat("\nCleaned data saved to: D:/Downloads/Files/DATA 467/project/Datasets/divorce_rate_cleaned.csv\n")

cat("\nData cleaning complete!\n")
