Terrorism Data Analysis Dashboard (R Shiny)

Overview
This project presents an interactive dashboard built using R Shiny to analyze global terrorism data. The dashboard provides insights into incident patterns, casualties, perpetrator behavior, and temporal trends through dynamic visualizations and user-driven filters.



Objective
To explore and analyze terrorism-related data by:
- Identifying patterns in incidents across regions and countries
- Understanding casualty distributions and impact levels
- Analyzing perpetrator groups and target types
- Observing trends over time

Dataset
- Dataset provided for academic purposes
- Contains information on:
  - Incident details (date, location)
  - Attack types
  - Casualties (kills, wounded)
  - Perpetrator groups
  - Target types
  - Geographic coordinates

 Data Preprocessing

Data cleaning and transformation were performed using R:

Key Steps:
- Removed irrelevant and redundant columns
- Renamed variables for clarity and consistency
- Converted data types (numeric, categorical, date)
- Handled missing values (replaced with defaults or "Unknown")
- Created new features:
  - total_casualties
  - casualty_rate
  - impact_level (Low / Medium / High)
  - fatality_severity
- Combined date fields into a proper Date format

View Dashbaord:
https://thisali-rj.shinyapps.io/Terrorist_Dashboard/

Dashboard Features

The dashboard is divided into four main sections:

Incident Analysis
- Total incidents, average casualties, high-impact percentage (KPIs)
- Top countries by incident count
- Attack type distribution (pie chart)
- Drill-down analysis by country
- Interactive map showing incident locations



Casualties & Human Impact
- Killed vs wounded trends over time
- Casualties by attack type
- Heatmap of casualties by region and year
- Boxplot analysis by weapon type
- Regional comparison of total vs average casualties


Perpetrator & Target Analysis
- Top perpetrator groups
- Target type distribution
- Interactive map showing group-target relationships
- Detailed summary table of group activity


Trend & Comparative Analysis
- Monthly incident trends
- Stacked regional trends over time
- Country-level comparison of incidents vs casualties



Interactivity

- Multi-select filters:
  - Region, Country, Attack Type
- Range filters:
  - Year range
  - Casualty range
- Impact level selection
- Dynamic filtering across all visualizations
- Drill-down functionality (click-based country analysis)

Tools & Technologies
- R (Data processing and analysis)
- Shiny & Shinydashboard (Dashboard development)
- Plotly (Interactive charts)
- Leaflet (Geospatial visualization)
- Dplyr, Tidyr (Data manipulation)



AI Usage

This project was developed using AI-assisted coding to support data preprocessing and dashboard development.

AI was used to:
- Assist in writing and refining data cleaning scripts
- Support dashboard structure and visualization logic
- Improve development efficiency

All outputs were reviewed, tested, and adjusted to ensure correctness and meaningful insights.

Key Insights

- Terrorism incidents are concentrated in specific regions and countries
- Certain attack types result in significantly higher casualties
- A small number of perpetrator groups are responsible for a large portion of incidents
- Trends show variation over time across regions

Limitations

- Dataset is limited to provided academic data
- Some missing values required assumptions during cleaning
- Analysis focuses on historical data, not predictive modeling

Conclusion

This project demonstrates the application of data cleaning, transformation, and interactive visualization techniques using R. It highlights the ability to build end-to-end analytical dashboards and extract meaningful insights from complex datasets.

Notes

This project was developed as part of academic coursework and enhanced for portfolio presentation.
