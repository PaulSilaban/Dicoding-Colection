use Dicoding_Colection

-- DATA CLEANING

-- Customers 
SELECT * FROM dbo.customers;

-- 1. Checking Missing Values  
SELECT * FROM dbo.customers
WHERE gender ='';
-- There are 6 missing values 

-- checking count of gender 
SELECT gender, COUNT(gender)
FROM dbo.customers 
GROUP BY gender;

-- prefer not to say about gender is higher count, so missing values will be filled in with it 
UPDATE dbo.customers
SET gender  = 'Prefer not to say'
WHERE gender = '';

-- 2. Checking Duplicate Value 
WITH duplicate_row AS (
SELECT *, 
	ROW_NUMBER() OVER(
    PARTITION BY customer_id,
				 customer_name, 
				 age, 
                 home_address, 
                 zip_code
    ORDER BY customer_id
	) row_num
FROM dbo.customers)

SELECT * FROM duplicate_row
-- Deleting Duplicates Value
-- DELETE FROM duplicate_row
WHERE row_num > 1;
-- There are 7 Duplicates values

-- 3. Checking inaccurated value 
SELECT MAX(age) FROM dbo.customers;
-- Value : 700 
UPDATE dbo.customers
SET age = 70
WHERE age = 700;

SELECT MAX(age) FROM dbo.customers;
-- Value : 500 
UPDATE dbo.customers
SET age = 50
WHERE age = 500;

-- Orders 
SELECT * FROM dbo.orders;
-- 1. Checking Missing Values
SELECT * FROM dbo.orders
WHERE order_id = 0 OR customer_id = 0 OR payment = 0 OR order_date = '' OR delivery_date = '' ;
-- No missing values 

-- 2. Checking Duplicate Values
WITH duplicate_row AS (
SELECT *, 
	ROW_NUMBER() OVER(
    PARTITION BY order_id, customer_id
    ORDER BY order_id
	) row_num
FROM dbo.orders)

SELECT * FROM duplicate_row
WHERE row_num > 1;
-- No Duplicates values 

-- 3. Checking inaccurated values
EXEC sp_help orders
-- order_date and delivery_date is varchar, so data type must change to date 

ALTER TABLE dbo.orders
ALTER COLUMN delivery_date DATE

ALTER TABLE dbo.orders
ALTER COLUMN order_date DATE

-- Product 
SELECT * FROM dbo.product;
-- 1. Checking Missing Values
SELECT * FROM dbo.product
WHERE product_type = '' OR product_name = '' OR size = '' OR colour = '';
-- No missing values 

-- 2. Checking Duplicate Values
WITH duplicate_row AS (
SELECT *, 
	ROW_NUMBER() OVER(
    PARTITION BY product_id
    ORDER BY product_id
	) row_num
FROM dbo.product)

-- SELECT * FROM duplicate_row
-- Deleting Duplicates Value
DELETE FROM duplicate_row
WHERE row_num > 1;
-- There are 6 Duplicates values 

-- 3. Drop column description because it is not needed
ALTER TABLE dbo.product
DROP COLUMN [description];

SELECT * FROM dbo.product;

-- Sales 
SELECT * FROM dbo.sales;
-- 1. Checking Missing Values
SELECT * FROM dbo.sales
WHERE order_id = 0 OR product_id = 0 OR price_per_unit = 0 OR quantity = 0 ;
-- No missing values 


-- 2. Checking Duplicate Values
WITH duplicate_row AS (
SELECT *, 
	ROW_NUMBER() OVER(
    PARTITION BY sales_id, product_id
    ORDER BY sales_id
	) row_num
FROM dbo.sales)

SELECT * FROM duplicate_row
-- Deleting Duplicates Value
-- DELETE FROM duplicate_row
WHERE row_num > 1;
-- No duplicates value

-- 3. Checking inaccurated values
SELECT price_per_unit, quantity, total_price 
FROM dbo.sales
ORDER BY total_price DESC;

UPDATE dbo.sales
SET total_price = price_per_unit*quantity;