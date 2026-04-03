USE customer_behaviour;
DESCRIBE customer_shopping;
--  1) Select gender and calculate total purchase amount
SELECT gender,
    SUM(purchase_amount) AS total_revenue
FROM customer_shopping
-- Group results by gender to compare revenue
GROUP BY gender;
-- 2) Select customer ID and purchase amount
SELECT customer_id,
purchase_amount
FROM customer_shopping
-- Filter customers who used discount and spent above average purchase value
WHERE discount_applied = 'Yes'
  AND purchase_amount > (
      -- Calculate average purchase amount
      SELECT AVG(purchase_amount)
      FROM customer_shopping
  );
  -- 3) Calculate average review rating per product
SELECT item_purchased,ROUND(AVG(review_rating), 2) AS average_product_rating
FROM customer_shopping
-- Group by product name
GROUP BY item_purchased
-- Sort by highest rated products
ORDER BY average_product_rating DESC
-- Limit to top 5 products
LIMIT 5;
-- 4) Calculate average purchase amount by shipping type
SELECT shipping_type,ROUND(AVG(purchase_amount), 2) AS average_purchase_amount
FROM customer_shopping
-- Filter only Standard and Express shipping
WHERE shipping_type IN ('Standard', 'Express')
-- Group by shipping type for comparison
GROUP BY shipping_type;
--  5) Compare subscriber vs non-subscriber spending
SELECT 
    subscription_status,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS average_spend,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer_shopping
-- Group results by subscription status
GROUP BY subscription_status
-- Show highest revenue and spend first
ORDER BY total_revenue DESC, average_spend DESC;
--  6) Calculate discount usage percentage per product
SELECT 
    item_purchased,
    ROUND(
        100 * SUM(
            CASE 
                WHEN discount_applied = 'Yes' THEN 1 
                ELSE 0 
            END
        ) / COUNT(*),
        2
    ) AS discount_percentage
FROM customer_shopping
-- Group by product
GROUP BY item_purchased
-- Order by highest discount usage
ORDER BY discount_percentage DESC
-- Show top 5 products
LIMIT 5;

--  7) Create customer segments using CTE
WITH customer_segments AS (
    SELECT 
        customer_id,
        previous_purchases,
        CASE
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer_shopping
)
-- Count customers in each segment
SELECT 
    customer_segment,
    COUNT(*) AS number_of_customers
FROM customer_segments
-- Group by customer segment
GROUP BY customer_segment;

-- 8) Rank products by purchase count within each category
WITH product_ranking AS (
    SELECT 
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY COUNT(customer_id) DESC
        ) AS product_rank
    FROM customer_shopping
    GROUP BY category, item_purchased
)
-- Select top 3 products per category
SELECT 
    category,
    item_purchased,
    total_orders
FROM product_ranking
WHERE product_rank <= 3;

-- 9) Count repeat buyers by subscription status
SELECT 
    subscription_status,
    COUNT(customer_id) AS repeat_buyers
FROM customer_shopping
-- Filter repeat buyers
WHERE previous_purchases > 5
-- Group by subscription status
GROUP BY subscription_status;

-- 10) Calculate total revenue per age group
SELECT 
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer_shopping
-- Group by age group
GROUP BY age_group
-- Show highest revenue contributors first
ORDER BY total_revenue DESC;

