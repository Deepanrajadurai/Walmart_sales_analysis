#  Walmart Sales Data Analysis — SQL Project

##  Project Overview
This project explores Walmart’s retail sales dataset using **PostgreSQL** to answer key business questions.  
The dataset includes transaction-level details such as branches, cities, product categories, prices, quantities, ratings, and payment methods.  

The main goal is to generate insights into sales performance, customer preferences, and profitability across different branches and time periods.

---

## 🧱 Table Structure

```sql
CREATE TABLE walmart (
  invoice_id       INT PRIMARY KEY,
  branch           VARCHAR(25),
  city             VARCHAR(25),
  category         VARCHAR(25),
  unit_price       FLOAT,
  quantity         INT,
  date             DATE,
  time             TIME,
  payment_method   VARCHAR(25),
  rating           FLOAT,
  profit_margin    FLOAT
);
```

### Sample Query
```sql
SELECT * FROM walmart;
```

---

## 🧠 Business Problems & SQL Solutions

### 1️⃣ Payment Method Analysis
**Question:** What are the different payment methods, and how many transactions and items were sold with each method?  
```sql
SELECT 
  payment_method, 
  COUNT(invoice_id) AS no_of_transactions, 
  SUM(quantity) AS no_quantity_sold 
FROM walmart
GROUP BY 1;
```

---

### 2️⃣ Category with Highest Average Rating per Branch
```sql
SELECT * FROM (
  SELECT 
    DISTINCT branch,
    category,
    AVG(rating) AS avg_rating,
    RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
  FROM walmart
  GROUP BY 1, 2
)
WHERE rank = 1;
```

---

### 3️⃣ Busiest Day of the Week per Branch
```sql
SELECT * FROM (
  SELECT 
    branch,
    TO_CHAR(date, 'Day') AS day,
    COUNT(*) AS no_of_transaction,
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
  FROM walmart
  GROUP BY 1, 2
)
WHERE rank = 1;
```

---

### 4️⃣ Items Sold per Payment Method
```sql
SELECT 
  payment_method, 
  SUM(quantity) AS no_quantity_sold 
FROM walmart
GROUP BY 1;
```

---

### 5️⃣ Ratings Summary by Category & City
```sql
SELECT 
  city,
  category, 
  AVG(rating) AS avg_rating,
  MIN(rating) AS min_rating,
  MAX(rating) AS max_rating 
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 2;
```

---

### 6️⃣ Total Profit by Category (Ranked)
```sql
SELECT 
  category, 
  ROUND(SUM(unit_price * quantity)::numeric, 2) AS total_profit
FROM walmart
GROUP BY 1
ORDER BY 2 DESC;
```

---

### 7️⃣ Most Frequent Payment Method per Branch
```sql
SELECT * FROM (
  SELECT 
    branch, 
    payment_method,
    COUNT(*) AS total_transactions,
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
  FROM walmart
  GROUP BY 1, 2
)
WHERE rank = 1;
```

---

### 8️⃣ Transactions per Shift
```sql
SELECT 
  branch,
  CASE
    WHEN EXTRACT(HOUR FROM time) < 12 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM time) BETWEEN 12 AND 18 THEN 'Afternoon'
    ELSE 'Evening'
  END AS shift,
  COUNT(*) AS total_transactions
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC;
```

---

### 9️⃣ Year-over-Year Revenue Comparison
**Question:** Which branches experienced the largest decrease in revenue compared to the previous year?  
```sql
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
```

---

## 📊 Key Insights You Can Expect
- **Customer behavior patterns** by payment method and time of day.  
- **Top-performing categories** by rating and profit.  
- **Revenue trends** across years and branches.  
- **Branch performance insights** for strategic decision-making.

---

## 🧰 Tools & Technologies
- **Database:** PostgreSQL  
- **Language:** SQL  
- **Environment:** pgAdmin / DB

---

## 📁 How to Use
1. Create the `walmart` table using the provided schema.  
2. Import your dataset (CSV or SQL dump).  
3. Run the queries sequentially to explore insights.  
4. Modify or extend queries for deeper analysis.

---

## 📈 Future Enhancements
- Integrate with **Power BI** for visual dashboards.  
- Include **stored procedures** for automated analysis.  
- Add **time-series trend analysis** for forecasting sales.

---

## 👨‍💻 Author
**Deepan R**  
_Data Analyst | SQL | Power BI | Excel | Python
