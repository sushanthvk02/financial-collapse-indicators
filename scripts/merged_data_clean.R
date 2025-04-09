# Load necessary libraries
library(tidyverse)  

# Load the merged dataset
df <- read.csv("data/cleaned/merged_dataset.csv")

# Preview the first few rows
head(df)

# Standardize column names for consistency and easier referencing in code
new_col_names <- c(
  "country", "year", "economic_index", "gdp_growth", "gov_debt",
  "inflation_rate", "interest_rates", "npl_ratio", "unemployment_rate",
  "black_market", "cpi", "divorce_rate"
)
colnames(df) <- new_col_names


# Calculate overall missing data statistics for all columns
missing_data <- df %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "missing_count") %>%
  mutate(
    total = nrow(df),
    missing_percentage = (missing_count / total) * 100
  )
print(missing_data)

# Drop columns with extremely high missingness or that are hard to impute reliably
# - 'divorce_rate' and 'npl_ratio' are missing in over 60% of the rows
# - 'unemployment_rate' is dropped because missing data of around 50%
df_clean <- df %>%
  select(-divorce_rate, -npl_ratio, -unemployment_rate)

# Recalculate missing data statistics after dropping above columns
missing_data1 <- df_clean %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "missing_count") %>%
  mutate(
    total = nrow(df_clean),
    missing_percentage = (missing_count / total) * 100
  )
print(missing_data1)

# Check for countries with high missingness across all their records
# Here we calculate:
# - total missing values across the 7 predictors
# - average missing per row
# - percent missing (normalized by total predictors * rows)
country_missing_summary <- df_clean %>%
  group_by(country) %>%
  summarise(
    missing_total = sum(is.na(economic_index)) +
      sum(is.na(gdp_growth)) +
      sum(is.na(gov_debt)) +
      sum(is.na(inflation_rate)) +
      sum(is.na(interest_rates)) +
      sum(is.na(black_market)) +
      sum(is.na(cpi)),
    total_rows = n(),
    avg_missing_per_row = missing_total / total_rows,
    percent_missing = (missing_total / (total_rows * 7)) * 100  # normalized to 7 predictors
  ) %>%
  arrange(desc(percent_missing))
print(country_missing_summary)

# Identify countries with more than 50% missing data across all 7 predictor variables
# These countries are dropped entirely as the quality is too poor for reliable modeling
high_missing_countries <- country_missing_summary %>%
  filter(percent_missing > 50)
print(high_missing_countries)

# Explicit list of countries to drop (more than 50% missing data across predictors)
countries_to_drop <- c(
  "Liechtenstein", "Cuba", "Somalia", "Marshall Islands", "Nauru", 
  "South Sudan", "Monaco", "Andorra", "Tuvalu", "Kosovo", "Timor-Leste", 
  "Palau", "Congo Kinshasa", "Afghanistan", "Congo Brazzaville", 
  "Turkmenistan", "Eritrea", "San Marino", "Djibouti"
)

# Drop all rows corresponding to those countries
df_filtered <- df_clean %>%
  filter(!country %in% countries_to_drop)

# Final missing data overview after dropping columns and countries
missing_data2 <- df_filtered %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "missing_count") %>%
  mutate(
    total = nrow(df_filtered),
    missing_percentage = (missing_count / total) * 100
  )
print(missing_data2)

# Save the cleaned dataset to a new CSV for future modeling and imputation
write_csv(df_filtered, "data/cleaned/final_data.csv")



