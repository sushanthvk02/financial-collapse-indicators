library(tidyverse)

# Load the raw CSV
stability_raw <- read.csv("data/raw/Political_Stability_index - WGB.csv", na.strings = c("", "..", "NA", "n/a"))

# Filter for just the indicator 
stability_filtered <- stability_raw %>%
  filter(Series.Name == "Political Stability and Absence of Violence/Terrorism: Estimate")

# Keep only Country column + year data columns
stability_clean <- stability_filtered[, c(1, 5:ncol(stability_filtered))]
colnames(stability_clean)[1] <- "Country"

# Extract numeric years from weird column names
cleaned_names <- gsub(".*?(\\d{4}).*", "\\1", colnames(stability_clean)[-1])
colnames(stability_clean)[2:ncol(stability_clean)] <- cleaned_names

# Change to long format
stability_long <- stability_clean %>%
  pivot_longer(-Country, names_to = "Year", values_to = "Political_Stability") %>%
  mutate(
    Year = as.numeric(Year),
    Political_Stability = as.numeric(Political_Stability)
  ) %>%
  filter(Year >= 1990 & Year <= 2023)

# Save the result
write.csv(stability_long, "data/cleaned/Political_Stability.csv", row.names = FALSE)

