# Load necessary libraries
library(readr)
library(dplyr)
library(tidyr)
library(purrr)

# Define file paths for standardized data
file_paths <- c(
  "D:/Downloads/Files/DATA 467/project/Standardized Data/standardized_economic_index cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Standardized Data/standardized_gdp_growth_cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Standardized Data/standardized_Gov_Debt clean.csv",
  "D:/Downloads/Files/DATA 467/project/Standardized Data/standardized_inflation_rate_cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Standardized Data/standardized_Interest_rates cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Standardized Data/standardized_NPL_Ration cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Standardized Data/standardized_unemployment_rate_cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Standardized Data/standardized_Black_Market cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Standardized Data/standardized_CPI cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Standardized Data/standardized_divorce_rate_cleaned.csv"
)

# Define standard countries list
standard_countries <- c(
  "Afghanistan", "Angola", "Albania", "Andorra", "United Arab Emirates", "Argentina",
  "Armenia", "Antigua and Barbuda", "Australia", "Austria", "Azerbaijan", "Burundi",
  "Belgium", "Benin", "Burkina Faso", "Bangladesh", "Bulgaria", "Bahrain", "The Bahamas",
  "Bosnia and Herzegovina", "Belarus", "Belize", "Bolivia", "Brazil", "Barbados",
  "Brunei Darussalam", "Bhutan", "Botswana", "Central African Republic", "Canada",
  "Switzerland", "Chile", "China", "Cote d'Ivoire", "Cameroon", "Congo Kinshasa",
  "Congo Brazzaville", "Colombia", "Comoros", "Cabo Verde", "Costa Rica", "Cuba", "Cyprus",
  "Czechia", "Germany", "Djibouti", "Dominica", "Denmark", "Dominican Republic",
  "Algeria", "Ecuador", "Egypt", "Eritrea", "Spain", "Estonia", "Ethiopia",
  "Finland", "Fiji", "France", "Micronesia", "Gabon", "United Kingdom", "Georgia",
  "Ghana", "Guinea", "Gambia", "Guinea-Bissau", "Equatorial Guinea", "Greece",
  "Grenada", "Guatemala", "Guyana", "Croatia", "Haiti", "Hungary", "Indonesia",
  "India", "Ireland", "Iran", "Iraq", "Iceland", "Israel", "Italy", "Jamaica",
  "Jordan", "Japan", "Kazakhstan", "Kenya", "Kyrgyz Republic", "Cambodia", "Kiribati",
  "St. Kitts and Nevis", "South Korea", "Kuwait", "Laos", "Lebanon", "Liberia",
  "Libya", "St. Lucia", "Liechtenstein", "Sri Lanka", "Lesotho", "Lithuania",
  "Luxembourg", "Latvia", "Morocco", "Monaco", "Moldova", "Madagascar", "Maldives",
  "Mexico", "Marshall Islands", "North Macedonia", "Mali", "Malta", "Myanmar",
  "Montenegro", "Mongolia", "Mozambique", "Mauritania", "Mauritius", "Malawi",
  "Malaysia", "Namibia", "Niger", "Nigeria", "Nicaragua", "Netherlands", "Norway",
  "Nepal", "Nauru", "New Zealand", "Oman", "Pakistan", "Panama", "Peru", "Philippines",
  "Palau", "Papua New Guinea", "Poland", "Portugal", "Paraguay", "Qatar", "Romania",
  "Russian Federation", "Rwanda", "Saudi Arabia", "Sudan", "Senegal", "Singapore",
  "Solomon Islands", "Sierra Leone", "El Salvador", "San Marino", "Somalia", "Serbia",
  "South Sudan", "Sao Tome and Principe", "Suriname", "Slovakia", "Slovenia", "Sweden",
  "Eswatini", "Seychelles", "Syria", "Chad", "Togo", "Thailand", "Tajikistan",
  "Turkmenistan", "Timor-Leste", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey",
  "Tuvalu", "Tanzania", "Uganda", "Ukraine", "Uruguay", "United States", "Uzbekistan",
  "Venezuela", "Vietnam", "Vanuatu", "Samoa", "Kosovo", "Yemen", "South Africa",
  "Zambia", "Zimbabwe", "Honduras", "Palestine", "St. Vincent and the Grenadines"
)

# Define years range
years <- 1990:2023

# Create a complete grid of all country-year combinations
complete_grid <- expand.grid(
  country = standard_countries,
  year = years,
  stringsAsFactors = FALSE
) %>% as_tibble()

# Read all datasets with informative error handling
datasets <- list()
dataset_names <- c()

for (i in seq_along(file_paths)) {
  file_path <- file_paths[i]
  file_name <- basename(file_path)
  
  # Extract a short name for the dataset from the file name
  dataset_name <- gsub("standardized_|_cleaned|clean|\\.csv", "", file_name)
  dataset_name <- trimws(dataset_name)
  dataset_names <- c(dataset_names, dataset_name)
  
  cat(sprintf("Reading %s...\n", file_name))
  
  tryCatch({
    # Read CSV file
    data <- read_csv(file_path)
    
    # Standardize column names
    if ("Year" %in% colnames(data) && !"year" %in% colnames(data)) {
      data <- data %>% rename(year = Year)
    }
    
    # Select relevant columns only - assuming third column is the data column
    # Extract the data column name (third column)
    data_col_name <- colnames(data)[3]
    
    # Select only necessary columns and rename the data column to match the dataset name
    data <- data %>% 
      select(country, year, all_of(data_col_name)) %>%
      rename(!!dataset_name := all_of(data_col_name))
    
    # Store in list
    datasets[[dataset_name]] <- data
    
    # Print info
    cat(sprintf("Successfully read %s with %d rows\n", dataset_name, nrow(data)))
    
  }, error = function(e) {
    cat(sprintf("Error reading file %s: %s\n", file_name, e$message))
  })
}

# Merge all datasets with the complete grid
result <- complete_grid

# Loop through all datasets and merge them with the result
for (dataset_name in names(datasets)) {
  cat(sprintf("Merging %s...\n", dataset_name))
  
  # Ensure there are no duplicates in the dataset before merging
  datasets[[dataset_name]] <- datasets[[dataset_name]] %>%
    distinct(country, year, .keep_all = TRUE)
  
  # Use left join to merge, but maintain only one row per country-year
  result <- result %>%
    left_join(datasets[[dataset_name]], by = c("country", "year")) %>%
    # In case the join caused duplicates, use distinct again
    distinct(country, year, .keep_all = TRUE)
  
  # Check for duplicates after merge
  dup_count <- result %>% 
    group_by(country, year) %>% 
    filter(n() > 1) %>% 
    nrow()
  
  if(dup_count > 0) {
    cat(sprintf("WARNING: %d duplicate country-year combinations found after merging %s\n", 
                dup_count, dataset_name))
  }
}

# Check the result
cat(sprintf("\nFinal dataset has %d rows and %d columns\n", 
            nrow(result), ncol(result)))

# Check for any remaining duplicates in the final dataset
final_dup_count <- result %>% 
  group_by(country, year) %>% 
  filter(n() > 1) %>% 
  nrow()

if(final_dup_count > 0) {
  cat(sprintf("WARNING: Final dataset still has %d duplicate country-year combinations\n", 
              final_dup_count))
  
  # Force remove any remaining duplicates before saving
  result <- result %>% distinct(country, year, .keep_all = TRUE)
  cat("Duplicates have been removed.\n")
} else {
  cat("No duplicate country-year combinations in final dataset.\n")
}

# Count missing values per column
missing_counts <- result %>%
  summarise(across(everything(), ~sum(is.na(.x)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "missing_count") %>%
  mutate(missing_percent = round(missing_count / nrow(result) * 100, 2)) %>%
  arrange(desc(missing_count))

cat("\nMissing values summary:\n")
print(missing_counts)

# Write the combined dataset to CSV
output_file <- "D:/Downloads/Files/DATA 467/project/combined_dataset.csv"
write_csv(result, output_file)
cat(sprintf("\nCombined dataset written to %s\n", output_file))

# Output a sample of the data
cat("\nSample of combined dataset (first 10 rows):\n")
print(head(result, 10))
