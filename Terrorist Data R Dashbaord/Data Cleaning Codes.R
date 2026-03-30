# Load Libraries

library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)



# 1. Read Data

data <- read.csv("selected_terroristdataset.csv", stringsAsFactors = FALSE)


# 2. Remove Clearly Unwanted Columns

unwanted_cols <- c(
  "resolution", "weaptype4", "weaptype4_txt", "weapsubtype4", "weapsubtype4_txt",
  
  "gsubname", "gsubname2", "gsubname3", "related",
  
  
  "INT_LOG", "INT_IDEO", "INT_MISC", "INT_ANY",
  
  "country", "region",
  "attacktype1", "attacktype2", "attacktype3",
  "targtype1", "targtype2", "targtype3",
  "targsubtype1", "targsubtype2", "targsubtype3",
  "natlty1", "natlty2", "natlty3",
  "weaptype1", "weaptype2", "weaptype3",
  "weapsubtype1", "weapsubtype2", "weapsubtype3",
  "location","motive",
  "attacktype2_txt", "attacktype3_txt"
)

data <- data %>% select(-all_of(unwanted_cols))


# 3. Optional Column Splits


if ("approxdate" %in% names(data)) {
  data <- data %>%
    mutate(
      approxdate_clean = ifelse(str_detect(approxdate, "^\\d{4}-\\d{2}-\\d{2}$"),
                                approxdate, NA),
      approx_year  = as.numeric(str_sub(approxdate_clean, 1, 4)),
      approx_month = as.numeric(str_sub(approxdate_clean, 6, 7)),
      approx_day   = as.numeric(str_sub(approxdate_clean, 9, 10))
    ) %>%
    select(-approxdate_clean)  # remove helper column
}

# 3.2 If location contains comma-separated values, split into parts
if("location" %in% names(data)){
  data <- data %>%
    separate(location, into = c("location_main", "location_detail"), sep = ",", fill = "right", remove = FALSE)
}


# 3.3 Extract base domain from scite columns
extract_domain <- function(x) {
  ifelse(!is.na(x) & str_detect(x, "http"), str_extract(x, "(?<=//)[^/]+"), NA)
}
for(col in c("scite1", "scite2", "scite3")){
  if(col %in% names(data)){
    data[[paste0(col, "_domain")]] <- extract_domain(data[[col]])
  }
}


# 4. Drop Rows Missing Key Columns

key_columns <- c("eventid", "iyear", "imonth", "iday", "country_txt", "region_txt",
                 "city", "latitude", "longitude", "attacktype1_txt",
                 "targtype1_txt", "gname", "nkill")

data <- data %>%
  filter(if_all(all_of(key_columns), ~ !is.na(.)))



# 5. Keep Recommended Final Structure

data <- data %>% select(
  eventid, iyear, imonth, iday,
  country_txt, region_txt, provstate, city,
  latitude, longitude,
  attacktype1_txt,
  weaptype1_txt, weaptype2_txt, weaptype3_txt,
  targtype1_txt, targsubtype1_txt, natlty1_txt,
  corp1, target1,
  nkill, nkillus, nkillter, nwound,
  property, propextent_txt, propvalue,
  gname, 
  summary, 
  scite1, scite2, scite3,
  
)


# 6. Rename Columns (Shorter & More Readable)

data <- data %>%
  rename(
    year = iyear,
    month = imonth,
    day = iday,
    country = country_txt,
    region = region_txt,
    prov_state = provstate,
    weapon1 = weaptype1_txt,
    weapon2 = weaptype2_txt,
    weapon3 = weaptype3_txt,
    target_type = targtype1_txt,
    target_subtype = targsubtype1_txt,
    target_nationality = natlty1_txt,
    kills = nkill,
    kills_us = nkillus,
    kills_terrorists = nkillter,
    wounded = nwound,
    property_extent = propextent_txt,
    property_value = propvalue,
    perpetrator_group = gname
  )


# 7. Adjust Data Types

data <- data %>%
  mutate(
    year = as.integer(year),
    month = as.integer(month),
    day = as.integer(day),
    latitude = as.numeric(latitude),
    longitude = as.numeric(longitude),
    kills = as.integer(kills),
    kills_us = as.integer(kills_us),
    kills_terrorists = as.integer(kills_terrorists),
    wounded = as.integer(wounded),
    property_value = as.numeric(property_value),
    eventid = as.character(eventid)
  )

# Ensure categorical columns are factors
data$country <- as.factor(data$country)
data$region <- as.factor(data$region)
data$prov_state <- as.factor(data$prov_state)
data$city <- as.factor(data$city)
data$attacktype1_txt <- as.factor(data$attacktype1_txt)
data$weapon1 <- as.factor(data$weapon1)
data$target_type <- as.factor(data$target_type)


# 8. Create New Calculated Columns

data <- data %>%
  mutate(
    total_casualties = kills + wounded,
    casualty_rate = ifelse(kills + wounded > 0, kills / (kills + wounded), 0),
    impact_level = case_when(
      total_casualties >= 50 ~ "High",
      total_casualties >= 10 ~ "Medium",
      TRUE ~ "Low"
    )
  )
data <- data %>%
  mutate(date = as.Date(paste(year, month, day, sep = "-"), "%Y-%m-%d"),
         fatality_severity = case_when(
           kills == 0 ~ "No Fatalities",
           kills <= 5 ~ "Low",
           kills <= 20 ~ "Moderate",
           kills > 20 ~ "Severe"
         ))
# Replace blanks with "Unknown" in categorical variables
categorical_cols <- c("weapon2", "weapon3", "target_subtype", 
                      "target_nationality", "perpetrator_group")

for (col in categorical_cols) {
  data[[col]][is.na(data[[col]]) | data[[col]] == ""] <- "Unknown"
}
# Replace NA or "Unknown" with 0 in numeric variables
numeric_cols <- c("kills", "kills_us", "kills_terrorists", 
                  "wounded", "property_value", 
                  "total_casualties", "casualty_rate")

for (col in numeric_cols) {
  data[[col]][is.na(data[[col]]) | data[[col]] == "Unknown"] <- 0
  data[[col]] <- as.numeric(data[[col]])  # ensure numeric type
}

# 9. Save Cleaned Dataset

write.csv(data, "236055B-cleaned_terroristdataset.csv", row.names = FALSE)



