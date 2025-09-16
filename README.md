# Advanced-Data-Cleaning-in-SQL-

## 📌 Project Overview  
This project focuses on **cleaning and transforming customer order data** for **Ebuka Logistics** using **MySQL**.  
The raw dataset was imported from a CSV file and had several issues, including:  

- Duplicates  
- Inconsistent customer names  
- Invalid or inconsistent dates  
- Malformed price and quantity values  
- Missing and null entries  
- Messy notes with unnecessary characters  

As a **Data Professional**, my goal was to create a structured **SQL workflow** that mirrors a real-world **ETL (Extract, Transform, Load)** process.  
The end result is a **standardized, reliable, and clean dataset** that is ready for **analysis or reporting**.  

---

## 📂 Dataset  
- **Source:** CSV file `customer_orders - Sheet1.csv`  
- **Imported into:** MySQL database (`Ebuka Logistics`)  
- **Raw Table:** `order_table`  
- **Working Copy:** `data_engine`  

---

## ⚙️ SQL Workflow  

### 1. Database & Table Setup  
- Created a database called `Ebuka Logistics`  
- Defined the schema for the `order_table`  
- Imported raw customer order data from the CSV file into MySQL  

### 2. Working Copy Creation  
- Duplicated the data into a `data_engine` table to work with  
- Preserved the integrity of the original dataset while working on the duplicate  

### 3. Duplicate Handling  
- Created a stored procedure `check_duplicates()` to identify duplicate records  
- Counted the total number of rows and previewed unique records  

### 4. Customer Name Standardization  
- Converted customer names to **proper case**  
- Split the full name into `first_name` and `last_name` columns for better analysis  

### 5. Missing / Invalid Values  
- Replaced missing values for order IDs, customer names, and emails with `"Unknown"`  
- Removed invalid rows or those with critical missing information  

### 6. Date Standardization  
- Standardized date formats (e.g., `YYYY-MM-DD`, `MM-DD-YYYY`)  
- Converted dates into the proper **DATE** datatype for consistency  

### 7. Product Name Standardization  
- Replaced missing product names with `"Unknown"`  

### 8. Quantity Cleanup  
- Converted text-based quantity values (e.g., `"two" → 2`)  
- Ensured that the `quantity` column is of type **INT**  

### 9. Price Cleanup  
- Removed currency symbols and commas from price values  
- Replaced empty or invalid price entries with `0`  
- Converted the `price` column to **FLOAT** for accuracy  

### 10. Derived Metrics  
- Added an `amount_due` column, calculated as `quantity × price` for each order  

### 11. Country Standardization  
- Unified entries for `"US"` and `"UK"`  
- Converted all other country names to **Title Case** for consistency  

### 12. Order Status Standardization  
- Standardized the `order_status` to proper case (e.g., `"Shipped"`)  

### 13. Notes Column Cleaning  
- Converted the `note` field to lowercase  
- Trimmed leading/trailing whitespace and removed hidden characters  
- Standardized placeholders like `"-"` and empty strings (`""`) to `"NA"`  
- Unified all entries related to duplicates or concerns  

### 14. Final Verification  
- Reviewed the fully cleaned dataset to ensure data integrity  
- Validated the schema with `DESCRIBE data_engine` to confirm the structure  

---

## ✅ Final Output  
The **`data_engine`** table is now:  
- Duplicate-free  
- Standardized in format  
- Free from invalid entries  
- Enriched with derived metrics  
- Ready for **reporting, dashboards, or further analysis**  

---

## 🛠️ Tools & Technologies  
- **SQL (MySQL 9.3)**  
- **CSV (raw data import)**  
- **ETL Workflow Simulation**  

---

## 📜 Author  
👤 **Oluwatosin Adekoya (Data Professional)**  
   
