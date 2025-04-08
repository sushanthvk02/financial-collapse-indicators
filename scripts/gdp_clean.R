# Load libraries
library(tidyverse)
library(zoo)

# Read the raw data, skip unnecessary rows, recognize all forms of empty as NA
gdp_raw <- read.csv("data/raw/GDP_Growth - WBG.csv", skip = 4, na.strings = c("", "NA", "..", "n/a"))
head(gdp_raw)

# Keep only Country and year columns
gdp_clean <- gdp_raw[, c(1, 5:ncol(gdp_raw) - 1)]

# Rename Country column
colnames(gdp_clean)[1] <- "Country"

# Clean year column names: X1990 → 1990
colnames(gdp_clean)[2:ncol(gdp_clean)] <- gsub("^X", "", colnames(gdp_clean)[2:ncol(gdp_clean)])
head(gdp_clean)

# Keep only years 1990 to 2023
years_to_keep <- as.character(1990:2023)
gdp_trimmed <- gdp_clean[, c("Country", years_to_keep)]

# Convert all year columns to numeric
gdp_trimmed[ , 2:ncol(gdp_trimmed)] <- lapply(gdp_trimmed[ , 2:ncol(gdp_trimmed)], function(x) as.numeric(as.character(x)))


# Save to cleaned folder
write.csv(gdp_trimmed, "data/cleaned/GDP_Growth_rate.csv", row.names = FALSE)


