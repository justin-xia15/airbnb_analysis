# Airbnb Listings Dashboard
This project aims to analyze <a href="https://www.kaggle.com/datasets/arianazmoudeh/airbnbopendata">Airbnb listings</a> in New York City. Findings are visualized in an 
interactive Excel dashboard (PivotTables, PivotCharts, slicers). <br>
<img width="1497" height="646" alt="image" src="https://github.com/user-attachments/assets/34a47812-1c1a-4469-a676-cbb7732f7b7e" />

### Data Preparation
- Data was extracted from a CSV file into SQL Server (<code>sql/init.sql</code>), with data prepartion in the file <code>sql/data_wrangling.sql</code>
- Removed duplicate rows
- Removed license column as only two rows had a value
- Removed country and country code columns as all listings are in New York City
- Confirmed that data was correctly formatted (data types, checking for typos or incorrect values)
- Filled in missing values if it made sense (e.g. null values for price was replaced with the average price)
- Otherwise missing values were left blank (e.g. if a listing had no name provided or no house rules)

### Usage
The provided Excel file <code>analysis.xlsx</code> contains a dashboard with slicers which can be used to filter room type visualizations by
neighbourhood group (Bronx, Brooklyn, Manhattan, Queens, and Staten Island). Neighbourhood visualizations can be filtered by room type.
The data folder contains the original data (<code>Airbnb_Data.csv</code>), the prepared data (<code>Airbnb_Data_Final.csv</code>), and a description 
of columns in the dataset (<code>Airbnb Open Data Dictionary.xlsx</code>).
