# Load necessary libraries
library(readr)
library(dplyr)
library(tidyr)
library(stringr)

# Define file paths (your actual file paths)
file_paths <- c(
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/Gov_Debt clean.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/inflation_rate_cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/Interest_rates cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/NPL_Ration cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/unemployment_rate_cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/Black_Market cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/CPI cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/cpi_index_cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/divorce_rate_cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/gdp_growth_cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Datasets/economic_index cleaned.csv"
)

# Initialize a list to store country names for each dataset
all_countries <- list()

# Read each file and extract unique country names
for (i in seq_along(file_paths)) {
  file_name <- file_paths[i]
  
  # Try to read the file
  tryCatch({
    # Read CSV file
    data <- read_csv(file_name)
    
    # Check column names and standardize to match our expected format
    if ("Country" %in% colnames(data) && !"country" %in% colnames(data)) {
      data <- data %>% rename(country = Country)
    }
    
    # Extract unique country names
    countries <- unique(data$country)
    
    # Store in list with dataset name as the name
    dataset_name <- tools::file_path_sans_ext(basename(file_name))
    all_countries[[dataset_name]] <- countries
    
    # Print number of unique countries
    cat(sprintf("Dataset: %s, Unique countries: %d\n", dataset_name, length(countries)))
    
  }, error = function(e) {
    cat(sprintf("Error reading file %s: %s\n", file_name, e$message))
  })
}

# Create a comprehensive list of all unique country names across all datasets
all_unique_countries <- unique(unlist(all_countries))
cat(sprintf("\nTotal unique country names across all datasets: %d\n\n", length(all_unique_countries)))

# Create a presence/absence matrix (country x dataset)
presence_matrix <- matrix(FALSE, 
                          nrow = length(all_unique_countries), 
                          ncol = length(all_countries),
                          dimnames = list(all_unique_countries, names(all_countries)))

# Fill the matrix
for (dataset_name in names(all_countries)) {
  presence_matrix[all_countries[[dataset_name]], dataset_name] <- TRUE
}

# Convert to data frame for easier analysis
presence_df <- as.data.frame(presence_matrix)
presence_df$country <- rownames(presence_df)
presence_df$present_in_count <- rowSums(presence_matrix)

# Find country names not present in all datasets
inconsistent_countries <- presence_df %>%
  filter(present_in_count < length(all_countries)) %>%
  arrange(present_in_count, country)

# Print the inconsistent countries
cat("Countries not present in all datasets:\n")
print(inconsistent_countries)

# Detailed analysis to identify potential matches
# Group similar country names (simplified approach)
potential_matches <- data.frame(
  country = all_unique_countries,
  simplified = tolower(str_replace_all(all_unique_countries, "[^a-zA-Z]", ""))
)

duplicate_simplified <- potential_matches %>%
  group_by(simplified) %>%
  filter(n() > 1) %>%
  arrange(simplified)

cat("\nPotential matching country names (simplified name matches):\n")
print(duplicate_simplified)

# Create a function to find countries with similar names
find_similar_countries <- function(countries, threshold = 0.8) {
  n <- length(countries)
  result <- data.frame(country1 = character(), 
                       country2 = character(), 
                       similarity = numeric(),
                       stringsAsFactors = FALSE)
  
  for (i in 1:(n-1)) {
    for (j in (i+1):n) {
      # Calculate string similarity (simple approach)
      similarity <- adist(countries[i], countries[j]) / 
        max(nchar(countries[i]), nchar(countries[j]))
      similarity <- 1 - similarity
      
      if (similarity > threshold) {
        result <- rbind(result, data.frame(
          country1 = countries[i],
          country2 = countries[j],
          similarity = similarity,
          stringsAsFactors = FALSE
        ))
      }
    }
  }
  
  return(result %>% arrange(desc(similarity)))
}

# Find similar country names
similar_countries <- find_similar_countries(all_unique_countries)
cat("\nCountries with similar names (may need standardization):\n")
print(head(similar_countries, 20))  # Show top 20 most similar pairs
