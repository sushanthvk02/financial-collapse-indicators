# Load libraries
library(tidyverse)
library(skimr)

# Load the dataset
df <- read_csv("data/final/financial_collapse_data.csv")

# Drop non-numeric variables
numeric_df <- df %>%
  select(-country, -year)

# Check for missing values
colSums(is.na(numeric_df))

# Basic summary statistics
summary(numeric_df)


# Plot histograms for all numeric variables
numeric_df %>%
  pivot_longer(cols = everything()) %>%
  ggplot(aes(x = value)) +
  geom_histogram(bins = 30, fill = "#3182bd", color = "white") +
  facet_wrap(~name, scales = "free", ncol = 3) +
  labs(title = "Distributions of Numeric Variables", x = "", y = "Count") +
  theme_minimal()


# Pivot data for boxplots
numeric_df %>%
  pivot_longer(cols = everything()) %>%
  ggplot(aes(x = name, y = value)) +
  geom_boxplot(fill = "#9ecae1", outlier.color = "red") +
  labs(title = "Boxplots of Numeric Variables", x = "Variable", y = "Value") +
  theme_minimal()


# Scatterplots of each predictor vs economic_index
numeric_df %>%
  pivot_longer(cols = -economic_index) %>%
  ggplot(aes(x = value, y = economic_index)) +
  geom_point(alpha = 0.4, color = "#2c7fb8") +
  facet_wrap(~name, scales = "free_x", ncol = 2) +
  labs(title = "Scatterplots: Predictors vs Economic Index", x = "Predictor Value", y = "Economic Index") +
  theme_minimal()


# Compute correlation matrix
cor_matrix <- cor(numeric_df)

# Load visualization package
library(ggcorrplot)


# Plot correlation heatmap
ggcorrplot(cor_matrix,
           lab = TRUE,
           lab_size = 3,
           type = "lower",
           colors = c("#d73027", "white", "#1a9850"),
           title = "Correlation Matrix of Numeric Variables",
           ggtheme = theme_minimal())



