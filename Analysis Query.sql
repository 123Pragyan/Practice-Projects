Create Table city
( city_id INT Primary Key, 
  city_name Varchar(15),
  population Bigint,
  estimated_rent Float,
  city_rank INT);
  
  Create Table cutomers
  (customer_id INT Primary Key,
  customer_name Varchar(25),
  city_id INT,
  Constraint fk_city Foreign Key (city_id) References city(city_id));
  
  Create Table products
  (product_id INT Primary Key,
  product_name Varchar(35),
  Price Float);
  
  Rename Table cutomers to customers;
  
  Create Table sales
  (sale_id INT Primary Key,
  sale_date date,
  product_id INT,
  customer_id INT,
  total FLOAT,
  rating INT,
  Constraint fk_products Foreign Key (product_id) References products(product_id),
  constraint fk_customers Foreign Key (customer_id) References customers(customer_id));
  
  Select * From city;
  Select * From customers;
  Select * From products;
  Select * From sales;
  
  
-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?
  Select city_name, Round((population * 0.25/1000000),2) as coffee_consumers_in_millions
  From city
  Order By 2 DESC;
  
 
 -- -- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
Select SUM(sales.total) as Total_revenue, city.city_name
From city
Join customers
On city.city_id = Customers.city_id
Join sales
On customers.customer_id = sales.customer_id
Where year(sales.sale_date) = 2023 AND quarter(sales.sale_date) = 4
Group By city.city_name
Order By SUM(sales.total) DESC;



-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?
Select Count(sales.product_id) as Units_sold, products.product_name
From sales
Join products
On products.product_id = sales.product_id
Group By products.product_id
ORDER BY Units_sold DESC;


-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?
-- city and total sale
-- no cx in each these city
Select Round(Avg(sales.Total)/(COUNT(DISTINCT(customers.customer_id))),2) as Sales_count, city.city_name
From city
Join customers
On city.city_id = Customers.city_id
Join sales
On customers.customer_id = sales.customer_id
Group By city.city_name;


-- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)
With city_table as 
(SELECT city_name, Round((population*0.25)/1000000,2) as coffee_consumers
From city), 
customers_table as
(Select city.city_name, Count(Distinct customers.customer_id) as unique_customers
FROM sales 
Join customers
ON customers.customer_id = sales.customer_id
Join city
ON city.city_id = customers.city_id
Group By city.city_name)
Select customers_table.city_name, city_table.coffee_consumers as coffee_consumer_in_millions, customers_table.unique_customers
From city_table
Join customers_table
ON city_table.city_name = customers_table.city_name;


-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
Select *
From 
(select city.city_name, products.product_name,COUNT(sales.sale_id) as total_orders,
Dense_Rank() OVER(Partition By city.city_name Order By Count(sales.sale_id) DESC) as serial_no
From sales 
Join products 
On sales.product_id = products.product_id
Join customers
ON customers.customer_id = sales.customer_id
Join city 
ON city.city_id = customers.city_id
Group BY city.city_name, products.product_name
Order BY city.city_name, total_orders DESC ) as T1
Where serial_no >=3;


-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?
Select city.city_name, COUNT(DISTINCT customers.customer_id) as unique_customers
From city
Left Join Customers
ON customers.city_id = city.city_id
Join sales
ON sales.customer_id = customers.customer_id
WHERE sales.product_id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
Group By city.city_name;


-- -- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and average rent per customer
WITH city_table as
(select city.city_name,
Sum(sales.total) as total_revenue,
COUNT(DISTINCT sales.customer_id) as total_customers,
ROUND(SUM(sales.total)/COUNT(DISTINCT sales.customer_id),2) as avg_sale_pr_cx
FROM sales
JOIN customers
ON sales.customer_id = customers.customer_id
JOIN city
ON city.city_id = customers.city_id
GROUP BY city.city_name
ORDER BY total_revenue	
),
city_rent
AS
(SELECT 
	city_name, 
	estimated_rent
FROM city
)
SELECT 
	city_rent.city_name,
	city_rent.estimated_rent,
	city_table.total_customers,
	city_table.avg_sale_pr_cx,
	ROUND(
		city_rent.estimated_rent/city_table.total_customers
		, 2) as avg_rent_per_cx
FROM city_rent 
JOIN city_table 
ON city_rent.city_name = city_table.city_name
ORDER BY 4 DESC;


-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city
With monthly_sales as
(Select city.city_name, Month(sale_date) as sales_pr_month, Year(sale_date) as sales_pr_year, SUM(sales.total) as total_sale
FROM sales
Join customers
ON customers.customer_id = sales.customer_id
Join city
ON city.city_id = customers.city_id
Group BY city.city_name, sales_pr_month, sales_pr_year
ORDER BY city.city_name, sales_pr_month, sales_pr_year),
growth_ratio AS
(Select city_name, sales_pr_month, sales_pr_year, total_sale,
LAG(total_sale , 1) OVER (PARTITION BY city_name ORDER BY sales_pr_month, sales_pr_year) as last_month_sale
FROM monthly_sales)
SELECT city_name, sales_pr_month, sales_pr_year, total_sale, last_month_sale,
ROUND((total_sale - last_month_sale) / last_month_sale * 100, 2) as growth_ratio
FROM growth_ratio
WHERE last_month_sale IS NOT NULL;


-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer


WITH city_table AS
(Select city.city_name, SUM(sales.total) as total_revenue, COUNT(DISTINCT sales.customer_id) as total_customers,
ROUND(SUM(sales.total)/COUNT(DISTINCT sales.customer_id),2) as avg_sales_pr_customer
FROM sales
Join customers 
ON sales.customer_id = customers.customer_id
JOIN city
ON city.city_id = customers.city_id
Group BY 1
Order By total_revenue DESC),
city_rent as 
(Select city_name, estimated_rent, ROUND((population*0.25)/1000000, 3) as estimated_coffee_consumer
FROM city)
SELECT city_rent.city_name, total_revenue, city_rent.estimated_coffee_consumer, city_rent.estimated_rent as total_rent, city_table.total_customers, city_table.avg_sales_pr_customer, ROUND((city_rent.estimated_rent/city_table.total_customers),2) as avg_rent_pr_customer
FROM city_rent
Join city_table 
ON city_rent.city_name = city_table.city_name
ORDER BY 2 DESC;