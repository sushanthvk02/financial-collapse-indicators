# Load libraries
library(tidyverse)
library(zoo)

# Load cleaned dataset
df <- read_csv("data/cleaned/final_data.csv")

# Interpolate missing values within each country by year
# This uses values from previous and next year (rule = 2 handles edge cases)
df_imputed <- df %>%
  group_by(country) %>%
  arrange(year) %>%
  mutate(
    gdp_growth = na.approx(gdp_growth, year, na.rm = FALSE, rule = 2),
    gov_debt = na.approx(gov_debt, year, na.rm = FALSE, rule = 2),
    inflation_rate = na.approx(inflation_rate, year, na.rm = FALSE, rule = 2),
    economic_index = na.approx(economic_index, year, na.rm = FALSE, rule = 2),
    cpi = na.approx(cpi, year, na.rm = FALSE, rule = 2),
    interest_rates = na.approx(interest_rates, year, na.rm = FALSE, rule = 2),
    black_market = na.approx(black_market, year, na.rm = FALSE, rule = 2)
  ) %>%
  ungroup()

# Check how much missing data is left after interpolation
missing_after_impute <- df_imputed %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "missing_count") %>%
  mutate(total = nrow(df_imputed), missing_percentage = (missing_count / total) * 100)
print(missing_after_impute)

# Fill remaining NAs with country-level means
df_filled <- df_imputed %>%
  group_by(country) %>%
  mutate(
    economic_index = ifelse(is.na(economic_index), mean(economic_index, na.rm = TRUE), economic_index),
    gov_debt = ifelse(is.na(gov_debt), mean(gov_debt, na.rm = TRUE), gov_debt),
    cpi = ifelse(is.na(cpi), mean(cpi, na.rm = TRUE), cpi)
  ) %>%
  ungroup()

# Build model to impute interest_rates
interest_model <- lm(interest_rates ~ gdp_growth + inflation_rate + gov_debt + economic_index, data = df_filled, na.action = na.omit)
df_filled$interest_rates[is.na(df_filled$interest_rates)] <- predict(interest_model, newdata = df_filled[is.na(df_filled$interest_rates), ])

# Build model to impute black_market
black_market_model <- lm(black_market ~ gdp_growth + inflation_rate + cpi + economic_index, data = df_filled, na.action = na.omit)
df_filled$black_market[is.na(df_filled$black_market)] <- predict(black_market_model, newdata = df_filled[is.na(df_filled$black_market), ])

# Final check for missing data
missing_final <- df_filled %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "missing_count") %>%
  mutate(total = nrow(df_filled), missing_percentage = (missing_count / total) * 100)
print(missing_final)

# Check which countries still have any NA rows 
countries_with_na <- df_filled %>%
  filter(if_any(everything(), is.na)) %>%
  group_by(country) %>%
  summarise(rows_with_na = n())
print(countries_with_na)

# Save NA details if needed 
write_csv(countries_with_na, "data/cleaned/missing.csv")

# recheck the most problematic countries from before
problem_countries <- c(
  "Argentina", "Cambodia", "China", "Egypt", "Eswatini", "Ethiopia",
  "Georgia", "Mauritius", "Micronesia", "Netherlands", "Panama",
  "Philippines", "St. Kitts and Nevis", "Tajikistan", "Tanzania",
  "United Arab Emirates", "Uzbekistan"
)

# Split dataset into complete and incomplete country groups
complete_data <- df_filled %>% filter(!country %in% problem_countries)
incomplete_data <- df_filled %>% filter(country %in% problem_countries)

# Function to impute missing values using a linear model
impute_with_model <- function(target_var, predictors) {
  formula <- as.formula(paste(target_var, "~", paste(predictors, collapse = " + ")))
  model <- lm(formula, data = complete_data)
  missing_rows <- is.na(incomplete_data[[target_var]])
  incomplete_data[[target_var]][missing_rows] <<- predict(model, newdata = incomplete_data[missing_rows, ])
}

# Apply model-based imputation to each remaining variable
impute_with_model("economic_index", c("gdp_growth", "inflation_rate", "gov_debt", "cpi"))
impute_with_model("gov_debt", c("gdp_growth", "inflation_rate", "economic_index", "cpi"))
impute_with_model("cpi", c("gdp_growth", "inflation_rate", "economic_index", "gov_debt"))
impute_with_model("interest_rates", c("gdp_growth", "inflation_rate", "gov_debt", "economic_index"))
impute_with_model("black_market", c("gdp_growth", "inflation_rate", "cpi", "economic_index"))

# Combine complete and imputed data
df_final_model_ready <- bind_rows(complete_data, incomplete_data)

# Final check to make sure everything is imputed
missing_final_check <- df_final_model_ready %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "missing_count") %>%
  mutate(total = nrow(df_final_model_ready), missing_percentage = (missing_count / total) * 100)
print(missing_final_check)

# Save the fully imputed dataset
write_csv(df_final_model_ready, "data/final/financial_collapse_data.csv")

