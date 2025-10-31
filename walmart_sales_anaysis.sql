CREATE TABLE walmart(
  invoice_id	INT PRIMARY KEY,
  Branch VARCHAR(25)	,
  City	VARCHAR(25),
  category	VARCHAR(25),
  unit_price	FLOAT,
  quantity	INT,
  date	DATE,
  time	TIME,
  payment_method	VARCHAR(25),
  rating	FLOAT,
  profit_margin FLOAT

)

SELECT * FROM walmart

-- Walmart Business Problems

-- 1. What are the different payment methods, and how many transactions and items were sold with each method?
-- 2. Which category received the highest average rating in each branch?
-- 3. What is the busiest day of the week for each branch based on transaction volume?
-- 4. How many items were sold through each payment method?
-- 5.  What are the average, minimum, and maximum ratings for each category in each city?
-- 6.  What is the total profit for each category, ranked from highest to lowest?
-- 7.  What is the most frequently used payment method in each branch?
-- 8. How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
-- 9. Which branches experienced the largest decrease in revenue compared to the previous year?

-- Walmart Business Problems Analysis & Solutions

-- 1. What are the different payment methods, and how many transactions and items were sold with each method?

SELECT 
     payment_method , 
	 COUNT(invoice_id) as no_of_transactions, 
	 SUM(quantity) as no_quantity_sold 
FROM walmart
GROUP BY 1 ;


-- 2. Which category received the highest average rating in each branch?
SELECT * FROM 
(
SELECT 
     DISTINCT branch ,
     category, 
	 AVG(rating) as  avg_rating ,
	 RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
FROM walmart
GROUP BY 1 ,2
)
WHERE rank = 1

-- 3. What is the busiest day of the week for each branch based on transaction volume?
SELECT * FROM walmart

SELECT * FROM (
SELECT 
     branch ,
	 TO_CHAR(date , 'Day') as Day ,
	 COUNT(*) as no_of_transaction ,
	 RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart
GROUP BY 1 ,2
)
WHERE rank = 1;
 
-- 4. How many items were sold through each payment method?
SELECT 
     payment_method , 
	 SUM(quantity) as no_quantity_sold 
FROM walmart
GROUP BY 1 ;

-- 5.  What are the average, minimum, and maximum ratings for each category in each city?

SELECT 
      city ,
      category, 
	 AVG(rating) as  avg_rating ,
	 MIN(rating) as  min_rating ,
	 MAX(rating) as  max_rating 
FROM walmart
GROUP BY 1 ,2
ORDER BY 1 , 2

-- 6.  What is the total profit for each category, ranked from highest to lowest?

SELECT 
     category, 
	 ROUND (SUM( unit_price * quantity) ::numeric,2) AS total_profit
FROM walmart
GROUP BY 1 
ORDER BY 2 DESC

-- 7.  What is the most frequently used payment method in each branch?
SELECT * FROM 
(
SELECT 
     branch, 
	 payment_method ,
	 COUNT(*) as total_transactions,
	 RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart
GROUP BY 1 , 2
) 
WHERE rank = 1;

-- 8. How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

SELECT branch ,
      CASE
      WHEN EXTRACT(HOUR FROM time )  < 12 THEN 'Morning '
	  WHEN EXTRACT(HOUR FROM time )  BETWEEN 12 AND 18  THEN 'Afternoon' 
	  ELSE 'Evening'
	  END as shift ,
	  COUNT(*) as total_transactions
FROM walmart
GROUP BY 1 , 2
ORDER BY  1 , 3 DESC


-- 9. Which branches experienced the largest decrease in revenue compared to the previous year?

WITH revenue_2022 AS (
  SELECT 
    branch, 
    EXTRACT(YEAR FROM date) AS year, 
    ROUND(SUM(unit_price * quantity)::numeric, 2) AS total_profit
  FROM walmart
  WHERE EXTRACT(YEAR FROM date) = 2022
  GROUP BY branch, year
),
revenue_2023 AS (
  SELECT 
    branch, 
    EXTRACT(YEAR FROM date) AS year, 
    ROUND(SUM(unit_price * quantity)::numeric, 2) AS total_profit
  FROM walmart
  WHERE EXTRACT(YEAR FROM date) = 2023
  GROUP BY branch, year
)
SELECT 
  ly.branch,
  ly.total_profit AS last_year,
  cy.total_profit AS current_year,
  ROUND(((cy.total_profit - ly.total_profit) / ly.total_profit) * 100, 2) AS percent_change
FROM revenue_2022 ly
JOIN revenue_2023 cy ON ly.branch = cy.branch
ORDER BY percent_change DESC
LIMIT 5;


