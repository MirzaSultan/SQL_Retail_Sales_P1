Create Database sql_project_p1;

-- Create Table
Create Table retail_sales
(
	transactions_id	int PRIMARY KEY,
	sale_date	date,
	sale_time	time,
	customer_id	int,
	gender	varchar(15),
	age	int,
	category	varchar(15),
	quantiy	int,
	price_per_unit float,	
	cogs	float,
	total_sale float
)

select * from retail_sales;

/*
Inserting data from a file into a table
BULK INSERT retail_sales
FROM 'C:\Users\ADMIN\Desktop\Learning\SQL\SQL - Retail Sales Analysis_utf .csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);*/

-- selecting top 10 rows from data
select top 10 * from retail_sales;

-- counting total number of rows in table
select COUNT(*) from retail_sales;

					--  !!!  Data Cleaning  !!!
		
-- selecting rows where there is a null value in any column
/*
select * from retail_sales
where 
transactions_id is null OR
sale_date is null OR
sale_time is null OR
customer_id is null OR
gender is null OR
age is null OR
category is null OR
quantiy is null OR
price_per_unit is null OR
cogs is null OR
total_sale is null;
*/

-- deleting rows where there is a null value in a row
/*
Delete from retail_sales
where 
transactions_id is null OR
sale_date is null OR
sale_time is null OR
customer_id is null OR
gender is null OR
category is null OR
quantiy is null OR
price_per_unit is null OR
cogs is null OR
total_sale is null;
*/

-- Data Exploration

-- How many sales we have?
select COUNT(*) as Total_Sales from retail_sales;

-- How many customers we have?
select COUNT(DISTINCT customer_id) as Total_Customers from retail_sales;

-- Which categories we have?
select Distinct category from retail_sales;

-- Data Analysis & Business Key Problems

-- Q1: Write a SQLquery to retrieve all columns for sales made on "2022-11-05"?
select * from retail_sales
where sale_date = '2022-11-05';


-- Q2: Write a SQLquery to retrieve all records where category is 'Clothing' and the quantity sold is more than 2 in the month of Nov-2022?
select * from retail_sales
where category = 'Clothing' and Format(sale_date, 'yyyy-MM') = '2022-11' and quantiy>2;

-- Q3: Calculate the total sales for each category?
select 
category, 
SUM(total_sale) as net_sale,
COUNT(*) as total_orders
from retail_sales
Group By category;

-- Q4: Find the average age of customers who purchased items from 'Beauty' Category?
Select 
AVG(age) as Average_Age
from retail_sales
where category='Beauty';

-- Q5: Find all transactions where the total_sale is greater than 1000?
select * from retail_sales where total_sale>1000;

-- Q6: Find the total number of transactions(transaction_id) made by each gender in each category?
select 
	category,
	gender,
	Count(*) as total_transactions 
	from retail_sales
	group by category,gender;


-- Q7: Calculate the average sale for each month. Find out best selling month in each Year?

--Example:1
select
	Year,
	Month,
	Avg_Sale
	From(
select 
	YEAR(sale_date) as Year,
	MONTH(sale_date) as Month,
	AVG(total_sale) as Avg_Sale,
	RANK() Over(Partition By YEAR(sale_date) order by AVG(total_sale) DESC) as rank
	from retail_sales
	Group By YEAR(sale_date),MONTH(sale_date)
	) as t1
	where rank =1;


--Example:2
WITH MonthlyAverages AS (
    SELECT 
        YEAR(sale_date) AS Year,
        MONTH(sale_date) AS Month,
        AVG(total_sale) AS Avg_Sale
    FROM 
        retail_sales
    GROUP BY 
        YEAR(sale_date), MONTH(sale_date)
)
SELECT 
    Year,
    Month,
    Avg_Sale
FROM 
    MonthlyAverages AS ma
WHERE 
    Avg_Sale = (SELECT MAX(Avg_Sale) 
                FROM MonthlyAverages 
                WHERE Year = ma.Year);

-- Q8: Find the top 5 customers based on highest total sales?

Select 
	Top 5
	customer_id,
	SUM(total_sale) as total_sales
	from retail_sales
	group by customer_id
	order by SUM(total_sale) DESC

-- Q9: Find the number of unique customers who purchased items from each category?

Select
	category,
	Count(DISTINCT customer_id) as Unique_Customers
	from retail_sales
	group by category

-- Q10: Create each shift and number of orders ( Example Morning, Afternoon & Evening)
With sale_shift AS
(
Select *,
	CASE 
	When DATEPART(HOUR, sale_time) < 12 Then 'Morning'
	When DATEPART(HOUR, sale_time) Between 12 and 17 Then 'Afternoon'
	Else 'Evening'
	END as shift
	From retail_sales
)
Select 
	shift,
	COUNT(*) as Orders
	From sale_shift
	Group By shift

-- Q11: What is the total revenue by category (Clothing, Beauty, Electronics)?

Select 
	category,
	SUM(total_sale) as Revenue
	From retail_sales
	Group by category

-- Q12: Which month or day has the highest number of sales?
--For Month
SELECT Top 1
    MONTH(sale_date) AS Sale_Month,
    COUNT(*) AS Number_of_Sales
FROM 
    retail_sales
GROUP BY 
    MONTH(sale_date)
ORDER BY 
    Number_of_Sales DESC

--For Day
SELECT Top 1
    Day(sale_date),
    COUNT(*) AS Number_of_Sales
FROM 
    retail_sales
GROUP BY 
    Day(sale_date)
ORDER BY 
    Number_of_Sales DESC

-- Q13:Which product category has the highest average revenue per transaction?
SELECT Top 1
    category,
    AVG(total_sale) AS Avg_Revenue_Per_Transaction
FROM 
    retail_sales
GROUP BY 
    category
ORDER BY 
    Avg_Revenue_Per_Transaction DESC

-- Q14: What are the purchasing patterns based on gender or age groups?
-- By Gender
SELECT 
    gender,
    COUNT(*) AS Number_of_Purchases,
    SUM(total_sale) AS Total_Revenue,
    AVG(total_sale) AS Avg_Revenue_Per_Transaction
FROM 
    retail_sales
GROUP BY 
    gender;

-- By Age
SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age >= 55 THEN '55+'
    END AS Age_Group,
    COUNT(*) AS Number_of_Purchases,
    SUM(total_sale) AS Total_Revenue,
    AVG(total_sale) AS Avg_Revenue_Per_Transaction
FROM 
    retail_sales
GROUP BY 
    CASE 
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age >= 55 THEN '55+'
    END;

-- Q15: Are certain categories more popular among a specific gender?
SELECT 
    category,
    gender,
    COUNT(*) AS Number_of_Purchases,
    SUM(total_sale) AS Total_Revenue
FROM 
    retail_sales
GROUP BY 
    category, gender
ORDER BY 
    category, gender;

-- End of Project!