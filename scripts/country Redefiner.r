# Load necessary libraries
library(readr)
library(dplyr)
library(stringr)
library(stringdist)

# Define the standard country list
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

# Create a mapping of non-standard country names to standard ones
country_mapping <- list(
  # Common variations and fixes
  "Bahamas, The" = "The Bahamas",
  "Korea, Rep." = "South Korea",
  "Korea, Republic of" = "South Korea",
  "Korea, Dem. People's Rep." = "South Korea",
  "Iran, Islamic Rep." = "Iran",
  "Lao PDR" = "Laos",
  "Lao P.D.R." = "Laos",
  "Slovak Republic" = "Slovakia",
  "Syrian Arab Republic" = "Syria",
  "Turkiye" = "Turkey",
  "Türkiye" = "Turkey",
  "Türkiye, Republic of" = "Turkey",
  "Venezuela, RB" = "Venezuela",
  "Gambia, The" = "Gambia",
  "Egypt, Arab Rep." = "Egypt",
  "Egypt" = "Egypt",
  "Micronesia, Fed. Sts." = "Micronesia",
  "Micronesia, Fed. States of" = "Micronesia",
  "Yemen, Rep." = "Yemen",
  "Virgin Islands (U.S.)" = "United States",
  "Puerto Rico" = "United States",
  "Hong Kong SAR, China" = "China",
  "Macao SAR, China" = "China",
  "China, People's Republic of" = "China",
  "Eswatini" = "Swaziland",
  "Czech Republic" = "Czechia",
  "Czechia" = "Czechia",
  "West Bank and Gaza" = "Palestine",
  "Republic of Kazakhstan" = "Kazakhstan",
  "Republic of Tajikistan" = "Tajikistan",
  "Republic of Turkmenistan" = "Turkmenistan",
  "Republic of Uzbekistan" = "Uzbekistan",
  "Congo, Dem. Rep." = "Congo Kinshasa",
  "Congo, Rep." = "Congo Brazzaville",
  # New additions
  "Aruba" = NA, # Not in our standard list, exclude
  "Bermuda" = NA, # Not in our standard list, exclude
  "Brunei" = "Brunei Darussalam",
  "Burma (Myanmar)" = "Myanmar",
  "Cape Verde" = "Cabo Verde",
  "Democratic Republic of the Congo" = "Congo Kinshasa",
  "Faroe Islands" = NA, # Not in our standard list, exclude
  "Honduras" = "Honduras", # Already in standard list
  "Hong Kong" = "China",
  "Ivory Coast" = "Cote d'Ivoire",
  "Kyrgyzstan" = "Kyrgyz Republic",
  "Palestine" = "Palestine", # Add to standard list
  "Republic of the Congo" = "Congo Brazzaville",
  "Russia" = "Russian Federation",
  "Saint Vincent and the Grenadines" = "St. Vincent and the Grenadines",
  "USA" = "United States"
)

# Create a function to find the best match for a country name
find_best_match <- function(country, standard_list, threshold = 0.8) {
  if (country %in% standard_list) {
    return(country)  # Already standard
  }
  
  if (country %in% names(country_mapping)) {
    return(country_mapping[[country]])  # Direct mapping exists
  }
  
  # Exclude regions, aggregates, and non-country entities
  regions_and_aggregates <- c(
    "Africa Eastern and Southern", "Africa Western and Central",
    "Arab World", "Caribbean small states", "Central Europe and the Baltics",
    "Channel Islands", "Curacao", "East Asia & Pacific", "East Asia & Pacific (excluding high income)",
    "Early-demographic dividend", "Euro area", "Europe & Central Asia", 
    "Europe & Central Asia (excluding high income)", "European Union",
    "Fragile and conflict affected situations", "High income", "IBRD only",
    "IDA & IBRD total", "IDA total", "IDA blend", "IDA only", "Isle of Man",
    "Latin America & Caribbean", "Latin America & Caribbean (excluding high income)",
    "Least developed countries: UN classification", "Low income", "Lower middle income",
    "Low & middle income", "Late-demographic dividend", "Middle East & North Africa",
    "Middle income", "Middle East & North Africa (excluding high income)",
    "North America", "OECD members", "Other small states", "Pre-demographic dividend",
    "Post-demographic dividend", "Pacific island small states", "Small states",
    "Sub-Saharan Africa", "Sub-Saharan Africa (excluding high income)",
    "East Asia & Pacific (IDA & IBRD countries)", "Europe & Central Asia (IDA & IBRD countries)",
    "Latin America & the Caribbean (IDA & IBRD countries)", 
    "Middle East & North Africa (IDA & IBRD countries)", "South Asia (IDA & IBRD)",
    "Sub-Saharan Africa (IDA & IBRD countries)", "World", "Heavily indebted poor countries (HIPC)",
    "South Asia"
  )
  
  if (country %in% regions_and_aggregates) {
    return(NA)  # Not a country, exclude
  }
  
  # Calculate string distance for remaining cases
  distances <- stringdistmatrix(country, standard_list, method = "jw")
  best_match_idx <- which.min(distances)
  best_match <- standard_list[best_match_idx]
  best_score <- 1 - distances[best_match_idx]
  
  if (best_score >= threshold) {
    return(best_match)
  } else {
    cat(sprintf("No good match found for '%s', best candidate: '%s' (score: %.2f)\n", 
                country, best_match, best_score))
    return(NA)  # No good match found
  }
}

# Function to process a single CSV file
process_file <- function(file_path, output_dir = NULL) {
  # Extract file name for logging
  file_name <- basename(file_path)
  cat(sprintf("Processing %s...\n", file_name))
  
  # Try to read the file
  tryCatch({
    # Read CSV file
    data <- read_csv(file_path)
    
    # Check column names and standardize to match our expected format
    if ("Country" %in% colnames(data) && !"country" %in% colnames(data)) {
      data <- data %>% rename(country = Country)
    }
    
    # Save original countries for comparison
    original_countries <- unique(data$country)
    cat(sprintf("Found %d unique countries\n", length(original_countries)))
    
    # Create a lookup table for this specific dataset
    country_lookup <- sapply(original_countries, function(c) find_best_match(c, standard_countries))
    
    # Print the mappings for this dataset
    cat("Country mappings for this dataset:\n")
    for (i in seq_along(original_countries)) {
      if (!is.na(country_lookup[i]) && original_countries[i] != country_lookup[i]) {
        cat(sprintf("  '%s' => '%s'\n", original_countries[i], country_lookup[i]))
      }
    }
    
    # Count excluded countries
    excluded <- sum(is.na(country_lookup))
    cat(sprintf("Excluding %d non-country entities\n", excluded))
    
    # Apply the mapping to the dataset
    data <- data %>%
      mutate(standard_country = sapply(country, function(c) country_lookup[c == original_countries])) %>%
      filter(!is.na(standard_country)) %>%
      # Clean any quotation marks that might appear in country names
      mutate(standard_country = str_replace_all(standard_country, '"', '')) %>%
      rename(original_country = country) %>%
      rename(country = standard_country)
    
    # Write the standardized dataset
    if (!is.null(output_dir)) {
      output_file <- file.path(output_dir, paste0("standardized_", file_name))
      write_csv(data, output_file)
      cat(sprintf("Wrote standardized data to %s\n", output_file))
    }
    
    return(data)
    
  }, error = function(e) {
    cat(sprintf("Error processing file %s: %s\n", file_name, e$message))
    return(NULL)
  })
}

# Define file paths
file_paths <- c(
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/Gov_Debt clean.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/inflation_rate_cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/Interest_rates cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/NPL_Ration cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/unemployment_rate_cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/Black_Market cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/CPI cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Datasets/economic_index cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/divorce_rate_cleaned.csv",
  "D:/Downloads/Files/DATA 467/project/Cleaned Data/gdp_growth_cleaned.csv"
)

# Create output directory
output_dir <- "D:/Downloads/Files/DATA 467/project/Standardized Data"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# Process all files
for (file_path in file_paths) {
  process_file(file_path, output_dir)
  cat("\n")  # Add blank line between files for readability
}

cat("Country standardization complete. Standardized files are in:", output_dir, "\n")
