/* ================================================================
   PROJECT: Ebuka Logistics Order Data Cleaning
   AUTHOR : Data Professional
   PURPOSE: Clean, transform, and standardize customer order data
            imported from CSV into MySQL for reliable analysis.
================================================================ */

/* ---------------------------------------------------------------
   1. Database and Table Setup
---------------------------------------------------------------- */
CREATE DATABASE `Ebuka Logistics`;
USE `Ebuka Logistics`;

-- Create raw order table structure
CREATE TABLE order_table(
    order_id INT PRIMARY KEY,
    customer_name TEXT,
    email VARCHAR(250),
    order_date VARCHAR(25),
    product_name VARCHAR(250),
    quantity INT,
    price FLOAT,
    country TEXT,
    order_status TEXT,
    note TEXT
);

-- Adjust column datatypes for flexibility during cleaning
ALTER TABLE order_table
    MODIFY COLUMN price VARCHAR(10),
    MODIFY COLUMN quantity VARCHAR(10),
    MODIFY COLUMN note TEXT;

-- Load raw data from CSV file into order_table
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 9.3/Uploads/customer_orders - Sheet1.csv"
INTO TABLE order_table
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM order_table;


/* ---------------------------------------------------------------
   2. Create Working Copy (Data Engine)
   - Always work on a duplicate to preserve raw data integrity
---------------------------------------------------------------- */
CREATE TABLE data_engine LIKE order_table;

INSERT INTO data_engine 
SELECT *
FROM order_table;


/* ---------------------------------------------------------------
   3. Duplicate Check Procedure
   - Assess duplicate records and preview unique values
---------------------------------------------------------------- */
DELIMITER $$
CREATE PROCEDURE check_duplicates()
BEGIN
    -- Count all rows
    SELECT COUNT(*) `Total Count`
    FROM data_engine;

    -- Preview unique records
    SELECT *
    FROM (SELECT DISTINCT * FROM data_engine) unique_data;
END$$
DELIMITER ;

CALL check_duplicates();


/* ---------------------------------------------------------------
   4. Standardize Customer Names
   - Ensure consistent casing and split into first/last names
---------------------------------------------------------------- */
-- Step 1: Force uppercase (baseline standardization)
UPDATE data_engine
SET customer_name = UPPER(customer_name);

-- Step 2: Proper case transformation (First Last format)
UPDATE data_engine
SET customer_name = CONCAT(
    UPPER(LEFT(SUBSTRING_INDEX(customer_name, ' ', 1), 1)),        
    LOWER(SUBSTRING(SUBSTRING_INDEX(customer_name, ' ', 1), 2)),   
    ' ',
    UPPER(LEFT(SUBSTRING_INDEX(customer_name, ' ', -1), 1)),       
    LOWER(SUBSTRING(SUBSTRING_INDEX(customer_name, ' ', -1), 2))   
);

-- Step 3: Add separate first_name and last_name columns
ALTER TABLE data_engine
    ADD COLUMN first_name VARCHAR(100) AFTER customer_name,
    ADD COLUMN last_name VARCHAR(100) AFTER first_name;

-- Step 4: Populate first/last names
UPDATE data_engine
SET 
    first_name = SUBSTRING_INDEX(customer_name, ' ', 1),
    last_name  = CONCAT(
                   UPPER(LEFT(SUBSTRING_INDEX(customer_name, ' ', -1), 1)),
                   LOWER(SUBSTRING(SUBSTRING_INDEX(customer_name, ' ', -1), 2))
               );


/* ---------------------------------------------------------------
   5. Handle Missing / Invalid Values
---------------------------------------------------------------- */
-- Null/invalid order IDs
SELECT * FROM data_engine WHERE order_id IS NULL;
DELETE FROM data_engine WHERE order_id IS NULL;

-- Missing/invalid customer names
UPDATE data_engine
SET customer_name = "Unknown"
WHERE order_id = 1009;

-- Email cleaning
SELECT DISTINCT email FROM data_engine;
UPDATE data_engine
SET email = "Unknown"
WHERE email = "";


/* ---------------------------------------------------------------
   6. Standardize Dates
---------------------------------------------------------------- */
-- Normalize delimiters to "-"
UPDATE data_engine
SET order_date = REPLACE(order_date, "/","-")
WHERE order_date LIKE "%/%";

-- Add new DATE column for proper formatting
ALTER TABLE data_engine
    ADD COLUMN new_date DATE;

-- Convert YYYY-MM-DD format
UPDATE data_engine
SET new_date = STR_TO_DATE(order_date, "%Y-%m-%d")
WHERE order_date LIKE "____-__-__";

-- Convert MM-DD-YYYY format
UPDATE data_engine
SET new_date = STR_TO_DATE(order_date, "%m-%d-%Y")
WHERE order_date LIKE "__-__-____";

-- Replace old order_date column
ALTER TABLE data_engine
    MODIFY COLUMN new_date DATE AFTER email;

ALTER TABLE data_engine
    DROP COLUMN order_date;

ALTER TABLE data_engine
    RENAME COLUMN new_date TO order_date;


/* ---------------------------------------------------------------
   7. Product Name Standardization
---------------------------------------------------------------- */
-- Replace NULL product names with "Unknown"
UPDATE data_engine
SET product_name = "Unknown"
WHERE product_name IS NULL;


/* ---------------------------------------------------------------
   8. Quantity Cleanup
---------------------------------------------------------------- */
-- Normalize text-based values (e.g., "two" → 2)
UPDATE data_engine
SET quantity = 2
WHERE quantity = "two";

-- Convert column type to INT
ALTER TABLE data_engine
    MODIFY COLUMN quantity INT;


/* ---------------------------------------------------------------
   9. Price Cleanup
---------------------------------------------------------------- */
-- Remove currency symbols and formatting
UPDATE data_engine
SET price = REPLACE(price, "$", "");

UPDATE data_engine
SET price = REPLACE(price, ",", "");

-- Replace blanks with 0
UPDATE data_engine
SET price = 0
WHERE price = "";

-- Convert to FLOAT
ALTER TABLE data_engine
    MODIFY COLUMN price FLOAT;


/* ---------------------------------------------------------------
   10. Derived Metrics
---------------------------------------------------------------- */
-- Add amount_due column
ALTER TABLE data_engine 
    ADD COLUMN amount_due FLOAT AFTER price;

-- Calculate amount_due = quantity × price
UPDATE data_engine 
SET amount_due = quantity * price;


/* ---------------------------------------------------------------
   11. Country Standardization
---------------------------------------------------------------- */
-- Normalize US entries
UPDATE data_engine
SET country = "US"
WHERE country IN ("usa", "United States", "US");

-- Normalize UK entries
UPDATE data_engine
SET country = "UK"
WHERE country IN ("United Kingdom", "UK");

-- Title-case other country names
UPDATE data_engine
SET country = CONCAT(
    UPPER(LEFT(country, 1)),
    LOWER(SUBSTRING(country,2))
);


/* ---------------------------------------------------------------
   12. Order Status Standardization
---------------------------------------------------------------- */
-- Proper case for order_status (e.g., "Shipped")
UPDATE data_engine
SET order_status = CONCAT(
    UPPER(LEFT(order_status, 1)), 
    LOWER(SUBSTRING(order_status, 2))
);


/* ---------------------------------------------------------------
   13. Notes Column Cleaning
---------------------------------------------------------------- */
-- Standardize casing
UPDATE data_engine
SET note = LOWER(note);

-- Trim whitespace and hidden characters
UPDATE data_engine
SET note = TRIM(note);

UPDATE data_engine
SET note = TRIM(REPLACE(REPLACE(REPLACE(note, CHAR(13), ''), CHAR(10), ''), CHAR(9), ''));

-- Handle special/placeholder values
UPDATE data_engine
SET note = "NA"
WHERE note = "-";

UPDATE data_engine
SET note = "na"
WHERE note = "";

-- Standardize duplicate references
UPDATE data_engine
SET note = "duplicate concern"
WHERE note LIKE "%duplicate%";


/* ---------------------------------------------------------------
   14. Final Verification
---------------------------------------------------------------- */
-- Inspect fully cleaned dataset
SELECT * FROM data_engine;

-- Verify schema
DESCRIBE data_engine;
