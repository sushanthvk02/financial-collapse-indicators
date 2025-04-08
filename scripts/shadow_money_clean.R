# Load required libraries
library(tidyverse)

# Load the raw dataset
shadow_raw <- read.csv("data/raw/Shadow_Economy.csv", na.strings = c("", "..", "NA", "n/a"))

# Drop the first column
shadow_data <- shadow_raw[, -1]

# Change to long format
shadow_long <- shadow_data %>%
  pivot_longer(
    cols = -Country,
    names_to = "Year",
    values_to = "Shadow_Economy"
  ) %>%
  mutate(
    Year = as.numeric(gsub("^Y", "", Year)),
    Shadow_Economy = as.numeric(Shadow_Economy)
  ) %>%
  filter(Year >= 1990 & Year <= 2023)

# Save the cleaned tidy file
write.csv(shadow_long, "data/cleaned/Shadow_Economy.csv", row.names = FALSE)

