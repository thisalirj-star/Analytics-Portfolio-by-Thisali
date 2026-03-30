DITWA Flood Exposure Analysis – Colombo District

Overview
This project analyzes flood exposure in the Colombo district by identifying buildings located within flood-affected areas based on the DITWA flood exposure dataset. The analysis was conducted using GIS techniques to support disaster risk assessment and urban planning.



Objective
To identify buildings in Colombo that are exposed to DITWA-defined flood areas and assess spatial risk using geospatial analysis.



Dataset

The analysis was based on:

- DITWA Flood Exposure Data (flood-affected areas)
- OpenStreetMap data (via QuickOSM), including:
  - Building footprints  
  - Road network  
  - Waterways  
  - Administrative boundaries  



Methodology

The analysis followed these steps:

1. Data Collection
   - Extracted spatial data using QuickOSM
   - Integrated DITWA flood exposure dataset

2. Data Preprocessing
   - Reprojected all layers to a common coordinate system (EPSG:5234)
   - Clipped all datasets to the Colombo district boundary

3. Spatial Analysis
   - Used Select by Location to identify buildings intersecting DITWA flood zones
   - Extracted exposed buildings as a separate layer

4. Visualization
   - Applied thematic styling to distinguish exposed and non-exposed buildings
   - Designed a professional map layout using QGIS Print Layout



Output

- Flood exposure map of Colombo district  
- Identification of buildings exposed to DITWA flood zones  
- Final map exported as a high-quality PDF  



Full Project Files (Google Drive)

Due to file size limitations, the complete project files are hosted externally.

Access Full Project (Data, QGIS File, PDF, Layers):  
[Paste your Google Drive link here]



Project Structure (GitHub)
colombo-flood-analysis/
│
├── screenshots/ # Map previews and analysis visuals
├── report/ # Final map jpg
└── README.md


Key Insights

- Flood exposure is concentrated in low-lying and water-adjacent areas  
- Several buildings fall within DITWA-defined flood zones  
- GIS analysis helps identify vulnerable urban infrastructure  


Tools Used
- QGIS (for spatial analysis and visualization)

Limitations
- Based on DITWA dataset and open-source data  
- Does not account for real-time flood depth or severity  
- Analysis focuses on spatial overlap, not structural vulnerability  

Conclusion
This project demonstrates how GIS can be used to analyze flood exposure using DITWA data and support disaster management and urban planning decisions.

 Notes
This project was originally completed as an academic assignment and has been refined for portfolio presentation.
