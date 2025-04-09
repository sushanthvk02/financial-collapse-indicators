# Load required libraries
library(tidyverse)

# Fit the full linear model with all predictors
full_model <- lm(economic_index ~ gdp_growth + gov_debt + inflation_rate + interest_rates + black_market + cpi, data = df)
summary(full_model)  # View summary of the full model

# Plot residuals vs fitted and Q-Q plot to check model assumptions
par(mfrow = c(1, 2))

plot(full_model$fitted.values, full_model$residuals,
     xlab = "Fitted Values", ylab = "Residuals",
     main = "Residuals vs Fitted", pch = 19, col = "steelblue")
abline(h = 0, col = "red", lty = 2)

qqnorm(full_model$residuals, main = "Normal Q-Q Plot", pch = 19, col = "steelblue")
qqline(full_model$residuals, col = "red", lty = 2)

par(mfrow = c(1, 1))  # Reset plot layout

# Fit the reduced model without gdp_growth and interest_rates
reduced_model <- lm(economic_index ~ gov_debt + inflation_rate + black_market + cpi, data = df)
summary(reduced_model)  # View summary of the reduced model

# Compare full and reduced models using an F-test
anova(reduced_model, full_model)

# Create a new observation with average values (typical country-year)
new_data <- data.frame(
  gdp_growth = mean(df$gdp_growth),
  gov_debt = mean(df$gov_debt),
  inflation_rate = mean(df$inflation_rate),
  interest_rates = mean(df$interest_rates),
  black_market = mean(df$black_market),
  cpi = mean(df$cpi)
)

# Predict economic_index for the new observation using the full model
predict(full_model, newdata = new_data, interval = "confidence")

# Predict using the reduced model (only the needed variables)
new_data_reduced <- new_data %>%
  select(gov_debt, inflation_rate, black_market, cpi)

predict(reduced_model, newdata = new_data_reduced, interval = "confidence")


