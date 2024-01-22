USE Dicoding_Colection;

-- EXPLORATORY DATA ANALYSIS 

-- 1. Explore data customer and orders
-- Distribution each gender VS total customer VS age
SELECT 
	gender, 
	COUNT(customer_id) AS total_customer, 
	MIN(age) AS min_age, 
	MAX(age) AS max_age, 
	AVG(age) AS average_age, 
	STDEV(age) AS deviation_age
FROM dbo.customers
GROUP BY gender;

-- Number of Orders based on age group 
-- If age > 64 THEN age_group = Seniors, age < 24 THEN age_group = Youth, ELSE Adult
SELECT
	order_id,
	customer_name, 
	gender, 
	age, 
	home_address, 
	city, 
	[state], 
	CASE 
		WHEN age > 64 THEN 'Seniors'
		WHEN age < 24 THEN 'Youth'
		ELSE 'Adult'
	END AS age_group
FROM dbo.customers a
INNER JOIN dbo.orders b
ON a.customer_id = b.customer_id
GROUP BY order_id, customer_name, gender, age, home_address, city, [state]

-- Add column : age group
ALTER TABLE dbo.customers
ADD age_group VARCHAR(100)

UPDATE dbo.customers
SET age_group = CASE
			WHEN age > 64 THEN 'Seniors'
			WHEN age < 24 THEN 'Youth'
			ELSE 'Adult'
			END

-- Calculate number of orders 
SELECT 
	age_group,
	COUNT(order_id) AS total_order
FROM dbo.customers a
INNER JOIN dbo.orders b
ON a.customer_id = b.customer_id
GROUP BY age_group;


-- Distribution each city VS total order 
SELECT 
	city, 
	COUNT(order_id) AS total_order
FROM dbo.customers a
INNER JOIN dbo.orders b
ON a.customer_id = b.customer_id
GROUP BY city
ORDER BY total_order DESC;

-- Distribution each state VS total order
SELECT 
	[state], 
	COUNT(order_id) AS total_order
FROM dbo.customers a
INNER JOIN dbo.orders b
ON a.customer_id = b.customer_id
GROUP BY [state]
ORDER BY total_order DESC;


-- Relation between customer_id VS order_id 
-- IF customer place an orders then customer status = Active, ELSE Not Active
WITH cte_customer_status AS (
	SELECT 
		a.customer_id,
		customer_name, 
		CASE 
		WHEN b.customer_id IS NOT NULL THEN 'Active' 
		Else 'Not Active' 
		END AS customer_status
	FROM dbo.customers a
	LEFT OUTER JOIN dbo.orders b
	ON a.customer_id = b.customer_id
	GROUP BY a.customer_id, b.customer_id, customer_name
)
SELECT 
	customer_status,
	COUNT(customer_id) AS total_customer
FROM cte_customer_status
GROUP BY customer_status;

-- Distribution total day delivery each order 

-- First, add a column is contain total day delivery. 
-- Total day delivery = Delivery Date - Order Date

ALTER TABLE dbo.orders
ADD total_day_delivery INT

UPDATE dbo.orders
SET total_day_delivery = ABS(DATEDIFF(day, delivery_date, order_date))

SELECT  * 
FROM dbo.orders
ORDER BY total_day_delivery DESC
;

-- 2. Explore data product and sales
SELECT * 
FROM dbo.product
SELECT * 
FROM dbo.sales

-- Number of sales based on product type
SELECT 
	product_type, 
	COUNT(sales_id) AS total_sales,
	SUM(b.quantity) AS total_products_sold,
	SUM(total_price) AS total_price
FROM dbo.product a
INNER JOIN dbo.sales b
ON a.product_id = b.product_id
GROUP BY product_type;

-- Number of sales based on product name
SELECT 
	product_name, 
	COUNT(sales_id) AS total_sales,
	SUM(b.quantity) AS total_products_sold,
	SUM(total_price) AS total_price
FROM dbo.product a
INNER JOIN dbo.sales b
ON a.product_id = b.product_id
GROUP BY product_name
ORDER BY total_sales DESC; 

-- The top 5 highest-grossing products name within each product type
WITH ranking_product AS (
	SELECT 
		product_type,
		product_name, 
		SUM(total_price) AS total_price,
		ROW_NUMBER() OVER(
		PARTITION BY product_type
		ORDER BY SUM(total_price) DESC
		) AS ranking
	FROM dbo.product a
	INNER JOIN dbo.sales b
	ON a.product_id = b.product_id
	GROUP BY product_type, product_name
	)
SELECT 
	product_type, 
	product_name,
	total_price
FROM ranking_product
WHERE ranking < 6

-- 3. Explore all data 

-- Relation between gender VS product type VS total product sold

SELECT 
	gender,
	product_type, 
	SUM(dbo.sales.quantity) AS total_product_sold,
	SUM(total_price) AS total_price,
	ROW_NUMBER() OVER(
	PARTITION BY gender 
	ORDER BY SUM(total_price) DESC
	) AS ranking
FROM dbo.customers
INNER JOIN dbo.orders
ON dbo.customers.customer_id = dbo.orders.customer_id
INNER JOIN dbo.sales
ON dbo.orders.order_id = dbo.sales.order_id
INNER JOIN dbo.product
ON dbo.sales.product_id = dbo.product.product_id
GROUP BY gender, product_type


-- Relation between state VS product type VS total product sold
SELECT 
	[state],
	product_type, 
	SUM(dbo.sales.quantity) AS total_product_sold,
	SUM(total_price) AS total_price, 
	ROW_NUMBER() OVER(
	PARTITION BY [state]
	ORDER BY SUM(total_price) DESC
	) AS ranking
FROM dbo.customers
INNER JOIN dbo.orders
ON dbo.customers.customer_id = dbo.orders.customer_id
INNER JOIN dbo.sales
ON dbo.orders.order_id = dbo.sales.order_id
INNER JOIN dbo.product
ON dbo.sales.product_id = dbo.product.product_id
GROUP BY [state], product_type


-- The customers with the highest purchases 
SELECT 
	dbo.orders.customer_id,
	customer_name, 
	age,
	COUNT(dbo.orders.order_id) AS total_order,
	SUM(total_price) AS total_purchases
FROM dbo.customers
INNER JOIN dbo.orders
ON dbo.customers.customer_id = dbo.orders.customer_id
INNER JOIN dbo.sales
ON dbo.orders.order_id = dbo.sales.order_id
GROUP BY dbo.orders.customer_id, customer_name, age
ORDER BY total_purchases DESC


-- ANSWER THE BUSINESS CASE 
-- 1. Bagaimana performa penjualan dan revenue penjualan dalam beberapa bulan terakhir?
WITH cte_monthly_perform AS(
	SELECT 
		DATENAME(MONTH, order_date) AS [month],
		dbo.orders.order_id AS total_order,
		SUM(total_price) AS total_revenue
	FROM dbo.customers
	INNER JOIN dbo.orders
	ON dbo.customers.customer_id = dbo.orders.customer_id
	INNER JOIN dbo.sales
	ON dbo.orders.order_id = dbo.sales.order_id
	GROUP BY DATENAME(MONTH, order_date), dbo.orders.order_id 
	)
SELECT 
	[month], 
	COUNT(total_order) AS total_order,
	SUM(total_revenue) AS total_revenue
FROM cte_monthly_perform
GROUP BY [month]

-- 2. Produk apa yang paling banyak terjual dan paling sedikit terjual?
SELECT 
	product_name, 
	SUM(dbo.sales.quantity) AS total_product_sold
FROM dbo.product
INNER JOIN dbo.sales
ON dbo.product.product_id = dbo.sales.product_id
GROUP BY product_name
ORDER BY total_product_sold DESC;

-- 3. Bagaimana demografi pelanggan yang kita miliki? 
-- By Age
SELECT 
	age_group,
	COUNT(customer_id) AS total_customer
FROM dbo.customers
GROUP BY age_group
ORDER BY COUNT(customer_id);
-- By Gender
SELECT 
	gender, 
	COUNT(customer_id) AS total_customer
FROM dbo.customers
GROUP BY gender
ORDER BY COUNT(customer_id);
-- By State
SELECT 
	[state],
	COUNT(customer_id) AS total_customer
FROM dbo.customers
GROUP BY [state]
ORDER BY COUNT(customer_id);


-- 4. RFM Analysis
-- Kapan terakhir pelanggan melakukan transaksi?
-- Seberapa sering seorang pelanggan melakukan pembelian dalam beberapa bulan terakhir?
-- Berapa banyak uang yang dihabiskan pelanggan dalam beberapa bulan terakhir?

SELECT MAX(order_date)
FROM dbo.orders;


DECLARE @today_date AS DATE = '2021-10-24';

WITH rfm_base AS (
	SELECT 
		customer_id,
		MAX(order_date) AS most_recently_purchase_date,
		DATEDIFF(day, MAX(order_date), @today_date) AS recency_value,
		COUNT(dbo.orders.order_id) AS frequency_value,
		SUM(total_price) AS monetary_value
	FROM dbo.orders 
	INNER JOIN dbo.sales
	ON dbo.orders.order_id = dbo.sales.order_id
	GROUP BY customer_id
),
rfm_score AS (
	SELECT 
		customer_id,
		recency_value, 
		frequency_value, 
		monetary_value, 
		NTILE(5) OVER(ORDER BY recency_value DESC) AS recency_score, 
		NTILE(5) OVER(ORDER BY frequency_value ASC) AS frequency_score, 
		NTILE(5) OVER(ORDER BY monetary_value ASC) AS monetary_score
	FROM rfm_base
),

user_segmentation AS(
	SELECT *,
		CASE 
			WHEN recency_score=5 AND frequency_score>=4 THEN '01-Champion'
			WHEN recency_score BETWEEN 3 AND 4 AND frequency_score>=4 THEN '02-Loyal Customers'
			WHEN recency_score>=4 AND frequency_score BETWEEN 2 AND 3 THEN '03-Potential Loyalists'
			WHEN recency_score<=2 AND frequency_score=5 THEN '04-Cant Lose Them'
			WHEN recency_score=3 AND frequency_score=3 THEN '05-Need Attention'
			WHEN recency_score=5 AND frequency_score=1 THEN  '06-New Customers'
			WHEN recency_score=4 AND frequency_score=1 THEN '07-Promising'
			WHEN recency_score<=2 AND frequency_score BETWEEN 3 AND 4 THEN '08-At Risk'
			WHEN recency_score=3 AND frequency_score<=2 THEN '09-About to Sleep'
			WHEN recency_score<=2 AND frequency_score<=2 THEN '10-Hibernating'
			END AS user_segment
	FROM rfm_score
)

SELECT 
	user_segment, 
	COUNT(customer_id) AS customer_count, 
	AVG(recency_value) AS mean_day_since_last_order,
	AVG(frequency_value) AS mean_order_count,
	SUM(monetary_value) AS total_revenue, 
	CAST(SUM(monetary_value)/COUNT(customer_id) AS DECIMAL(12,2)) AS avg_revenue_per_customer
FROM user_segmentation 
GROUP BY user_segment
ORDER BY user_segment

