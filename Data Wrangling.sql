CREATE DATABASE dicoding_colection;
USE dicoding_colection;

-- A. Data Wrangling 

-- Customers 
SELECT * FROM customers;

-- 1. Checking Missing Values  
SELECT * FROM customers
WHERE gender ='';

SELECT 

UPDATE customers
SET gender  = 'Prefer not to say'
WHERE gender = '';


SELECT * FROM sales 
WHERE total_price IS NULL;

-- Orders 
SELECT * FROM orders;

-- Product
SELECT * FROM product;

-- Sales
SELECT * FROM sales;

