CREATE DATABASE Olist_ECommerce;   
USE Olist_ECommerce; 

DROP TABLE olist_customers_dataset;

-- 1. CUSTOMERS
CREATE TABLE customers (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32) NOT NULL,
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(100),
    customer_state VARCHAR(2),
    INDEX idx_unique_id (customer_unique_id),
    INDEX idx_zip (customer_zip_code_prefix)
);

-- 2. SELLERS
CREATE TABLE sellers (
    seller_id VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(100),
    seller_state VARCHAR(2),
    INDEX idx_zip (seller_zip_code_prefix)
);

-- 3. PRODUCT CATEGORY TRANSLATION
CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);

-- 4. PRODUCTS
CREATE TABLE products (
    product_id VARCHAR(32) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT,
    INDEX idx_category (product_category_name)
);

-- 5. ORDERS
CREATE TABLE orders (
    order_id VARCHAR(32) PRIMARY KEY,
    customer_id VARCHAR(32) NOT NULL,
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME NULL,
    order_delivered_carrier_date DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME,
    INDEX idx_customer (customer_id),
    INDEX idx_purchase_date (order_purchase_timestamp),
    INDEX idx_status (order_status)
);

-- 6. ORDER ITEMS
CREATE TABLE order_items (
    order_id VARCHAR(32),
    order_item_id INT,
    product_id VARCHAR(32),
    seller_id VARCHAR(32),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id),
    INDEX idx_product (product_id),
    INDEX idx_seller (seller_id)
);

-- 7. ORDER PAYMENTS
CREATE TABLE order_payments (
    order_id VARCHAR(32),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential),
    INDEX idx_order (order_id)
);

-- 8. ORDER REVIEWS
CREATE TABLE order_reviews (
    review_id VARCHAR(32),
    order_id VARCHAR(32),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message VARCHAR(1000),
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME,
    PRIMARY KEY (review_id, order_id),
    INDEX idx_order (order_id)
);

-- 9. GEOLOCATION (1M rows, many duplicate zip prefixes - kept raw here aggregate down to 1 row per zip)
CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat DECIMAL(10,7),
    geolocation_lng DECIMAL(10,7),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(2),
    INDEX idx_zip (geolocation_zip_code_prefix)
);
 
 
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'D:/SQL/Projects/Brazilian E-Commerce Public Dataset by Olist/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM customers;

LOAD DATA LOCAL INFILE 'D:/SQL/Projects/Brazilian E-Commerce Public Dataset by Olist/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM sellers;

LOAD DATA LOCAL INFILE 'D:/SQL/Projects/Brazilian E-Commerce Public Dataset by Olist/product_category_name_translation.csv'
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM product_category_name_translation;


LOAD DATA LOCAL INFILE 'D:/SQL/Projects/Brazilian E-Commerce Public Dataset by Olist/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_category_name, @pnl, @pdl, @ppq, @pwg, @plc, @phc, @pwc)
SET
  product_name_lenght = NULLIF(@pnl,''),
  product_description_lenght = NULLIF(@pdl,''),
  product_photos_qty = NULLIF(@ppq,''),
  product_weight_g = NULLIF(@pwg,''),
  product_length_cm = NULLIF(@plc,''),
  product_height_cm = NULLIF(@phc,''),
  product_width_cm = NULLIF(@pwc,'');

SELECT COUNT(*) FROM products;

LOAD DATA LOCAL INFILE 'D:/SQL/Projects/Brazilian E-Commerce Public Dataset by Olist/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_status, order_purchase_timestamp, @app, @carr, @cust, order_estimated_delivery_date)
SET
  order_approved_at = NULLIF(@app,''),
  order_delivered_carrier_date = NULLIF(@carr,''),
  order_delivered_customer_date = NULLIF(@cust,'');

SELECT COUNT(*) FROM orders;

LOAD DATA LOCAL INFILE 'D:/SQL/Projects/Brazilian E-Commerce Public Dataset by Olist/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM order_items;

LOAD DATA LOCAL INFILE 'D:/SQL/Projects/Brazilian E-Commerce Public Dataset by Olist/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM order_payments;

LOAD DATA LOCAL INFILE 'D:/SQL/Projects/Brazilian E-Commerce Public Dataset by Olist/olist_geolocation_dataset.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM geolocation;



LOAD DATA LOCAL INFILE 'D:/SQL/Projects/Brazilian E-Commerce Public Dataset by Olist/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(review_id, order_id, review_score, @title, @msg, review_creation_date, review_answer_timestamp)
SET
  review_comment_title = NULLIF(@title,''),
  review_comment_message = NULLIF(@msg,'');

SELECT COUNT(*) FROM order_reviews;

-- Section 1: Revenue Health
-- 1.1 What is total revenue, and how much was lost to canceled/unavailable orders?
WITH tot_rev_delivered AS 
(
SELECT SUM(oi.price + oi.freight_value) AS total_revenue
FROM Orders AS o 
LEFT JOIN order_items AS oi 
ON o.order_id = oi.order_id
WHERE o.order_status IN ('delivered', 'invoiced', 'shipped', 'processing', 'created', 'approved')  
),
tot_rev_cancelled AS 
(
SELECT SUM(oi.price + oi.freight_value) AS total_revenue_lost
FROM Orders AS o 
LEFT JOIN order_items AS oi 
ON o.order_id = oi.order_id
WHERE o.order_status IN ('canceled' ,  'unavailable') 
)
SELECT total_revenue, total_revenue_lost
FROM  tot_rev_delivered
JOIN tot_rev_cancelled ; 

-- OR
SELECT
    SUM(CASE WHEN o.order_status IN ('delivered', 'invoiced', 'shipped', 'processing', 'created', 'approved')
    THEN (oi.price + oi.freight_value) ELSE 0 END) AS total_revenue,
    SUM(CASE WHEN o.order_status IN ('canceled','unavailable') THEN (oi.price + oi.freight_value) ELSE 0 END) AS lost_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;

-- ** ANALYSIS ** - Olist earned ₹15.74M in total revenue (delivered + pipeline orders), and only lost ₹108K to cancellations, 
-- which is just 0.7% of the total. 
-- This shows that cancellations are not really a problem for Olist at all, it's a very small leak, not something worth focusing on.


-- 1.2 Is monthly order count trending up, flat, or down?
SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS monthly_orders , COUNT(*) AS total_count
FROM  
orders 
WHERE order_status IN ('delivered', 'invoiced', 'shipped', 'processing', 'created', 'approved')  
GROUP BY monthly_orders
ORDER BY  monthly_orders; 
-- ** ANALYSIS ** - Order count grew steadily from early 2017, peaked in November 2017 at around 7,423 orders, 
-- and then plateaued and slightly dipped through 2018. Which shows Olist's growth phase basically stopped after November 2017, 
-- it didn't crash, but it clearly stopped climbing.

-- 1.3 Is average order value (AOV) trending up, flat, or down?
WITH tot_rev_delivered AS 
(
SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS monthly_revenue,  SUM(oi.price + oi.freight_value) AS total_revenue
FROM Orders AS o 
LEFT JOIN order_items AS oi 
ON o.order_id = oi.order_id
WHERE o.order_status IN ('delivered', 'invoiced', 'shipped', 'processing', 'created', 'approved')  
GROUP BY monthly_revenue
ORDER BY monthly_revenue
),
tot_no_of_orders AS 
(
SELECT  DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS monthly_count, COUNT(DISTINCT order_id)  AS cnt_order_id 
FROM 
Orders 
WHERE order_status IN ('delivered', 'invoiced', 'shipped', 'processing', 'created', 'approved')  
GROUP BY monthly_count
ORDER BY monthly_count
)
SELECT td.monthly_revenue AS month, ROUND((total_revenue / cnt_order_id),2) AS AOV  
FROM  tot_rev_delivered AS td
JOIN tot_no_of_orders AS tno
ON td.monthly_revenue = tno.monthly_count
ORDER BY  month; 
-- ** ANALYSIS ** - AOV stayed flat the whole time, mostly between ₹146 and ₹175, no real upward or downward trend at all. 
-- This shows that when order count stopped growing in 2018, there was nothing else, like customers spending more per order, to make up for it.


-- ** OVERALL ANALYSIS ** 
-- Revenue in 2017 grew because order count kept increasing, not because each order was worth more, AOV stayed flat around ₹150-170 the whole time. 
-- Which shows that the growth was coming purely from more people ordering, not from people spending more per order. 
-- After November 2017, order count stopped growing and started plateauing, but AOV still didn't increase to make up for it. 
-- So the slowdown in 2018 is basically a demand problem, not a pricing problem, Olist just wasn't getting enough new orders anymore, 
-- and there was nothing else picking up the slack.

-- **Section 2: Customer Retention**
-- 2.1 What % of customers ordered only once vs. more than once?
WITH count_customer AS 
(
SELECT c.customer_unique_id , COUNT(o.order_id) AS cnt_order
FROM Customers AS c 
LEFT JOIN Orders AS o
ON c.customer_id = o.customer_id  
GROUP BY c.customer_unique_id  
)
SELECT 
CASE WHEN cnt_order = 1 THEN 'One_Time' ELSE 'Repeat' END AS cust_type , 
COUNT(*) AS total_cust, 
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*) ) OVER(), 2) AS percentage
FROM count_customer
GROUP BY cust_type; 

-- ** ANALYSIS ** - 96.88% of customers ordered only once and only 3.12% came back for a 2nd order, which shows that almost no one is returning to buy again. 
-- This is a big problem because in Section 1 we saw that revenue was growing only because more new orders kept coming in, not because AOV was increasing. 
-- So if hardly anyone repeats, that growth is not solid Olist is basically depending on new customers every single time instead of building customers 
-- who keep coming back, which is a risky way to grow.

-- 2.2 Did one-time customers face more delivery delay than repeat customers?
WITH count_customer AS 
(
SELECT c.customer_unique_id , 
                           COUNT(o.order_id) AS cnt_order, 
					       AVG(DATEDIFF(order_delivered_customer_date,  order_estimated_delivery_date)) AS avg_delivery_days
FROM Customers AS c 
LEFT JOIN Orders AS o
ON c.customer_id = o.customer_id  
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL 
GROUP BY c.customer_unique_id 
)
SELECT 
CASE WHEN cnt_order = 1 THEN 'One_Time' ELSE 'Repeat' END AS cust_type , 
AVG(avg_delivery_days)
FROM count_customer
GROUP BY cust_type; 

-- ** ANALYSIS ** - Average delivery delay is almost the same for one-time customers (-11.8 days) and repeat customers (-12.6 days), 
-- less than a 1 day difference. Which shows that delivery speed on the first order is not really a reason why customers come back or not. 
-- So this rules out one of the possible reasons for the low retention rate we found in 2.1.

-- 2.3 Did one-time customers leave lower review scores than repeat customers?
WITH count_customer AS 
(
SELECT c.customer_unique_id , 
                           COUNT(o.order_id) AS cnt_order, 
					       AVG(ors.review_score) AS avg_review_score 
FROM Customers AS c 
LEFT JOIN Orders AS o
ON c.customer_id = o.customer_id  
JOIN order_reviews AS ors 
ON o.order_id =  ors.order_id 
GROUP BY c.customer_unique_id 
)
SELECT 
CASE WHEN cnt_order = 1 THEN 'One_Time' ELSE 'Repeat' END AS cust_type , 
ROUND(AVG(avg_review_score),2) AS avg_score
FROM count_customer
GROUP BY cust_type; 

-- ** ANALYSIS ** - Just like 2.2, there's no real difference in review scores between one-time and repeat customers 
-- one-time customers average 4.08 and repeat customers average 4.11, barely a 0.03 gap. 
-- This is the second hypothesis that doesn't hold up. So it's now clear: neither delivery delay nor review score explains why customers aren't coming back 
-- both groups are having a similarly good experience by these two measures, yet 96.88% still don't return. 
-- That means the reason for low retention is something else entirely, not the delivery or satisfaction experience itself.


-- 2.4 Did one-time customers pay a different average price than repeat customers?
WITH sum_price AS 
(
SELECT order_id, SUM(price) AS total_price
FROM
order_items
GROUP BY  order_id
), 
count_customer AS 
(
SELECT c.customer_unique_id , 
                           COUNT(o.order_id) AS cnt_order, 
					       AVG(sp.total_price) AS avg_price_score 
FROM Customers AS c 
LEFT JOIN Orders AS o
ON c.customer_id = o.customer_id  
JOIN sum_price AS sp 
ON o.order_id =  sp.order_id 
GROUP BY c.customer_unique_id 
)
SELECT 
CASE WHEN cnt_order = 1 THEN 'One_Time' ELSE 'Repeat' END AS cust_type , 
ROUND(AVG(avg_price_score),2) AS avg_price
FROM count_customer
GROUP BY cust_type; 

-- ** ANALYSIS ** - Here we can see a difference between the two types of customers. One-time customers pay a higher average price (₹138.67) 
-- compared to repeat customers (₹123.98), a gap of ₹14.69. Looking at 2.2 and 2.3, 
-- where delivery delay and review scores showed almost no difference between the two groups, 
-- this price gap is the first real difference we've found. It's not a huge gap, only about 9-10%, 
-- so it's too small to call it the main reason customers don't come back, but it's worth noting as a mild pattern. 
-- Possibly one-time customers are buying pricier, one-off items, like furniture or electronics, that people naturally don't repurchase often, 
-- rather than everyday products people buy again and again.


-- ** OVERALL ANALYSIS ** 
-- Only 3.12% of customers come back for a second order, which is an extremely low retention rate. We checked three possible reasons why: 
-- delivery delay, review scores, and price. Delivery delay showed almost no difference between one-time and repeat customers (about 1 day). 
-- Review scores also showed almost no difference (4.08 vs 4.11). Price showed a small difference, one-time customers pay about ₹14.69 more on average, 
-- but it's not a big enough gap to be the main reason either. So none of these three factors properly explain the low retention. 
-- This tells us the reason customers aren't coming back is probably not about their experience quality on the first order. 
-- It's more likely something structural, like the type of products people are buying on Olist being naturally 
-- one-time purchases (furniture, electronics, home items) rather than everyday repeat-purchase items. 
-- This is something we can look into more in Section 8, when we look at product and category performance.


-- **Section 3: Delivery Performance**
-- 3.1 What % of orders were delivered after the estimated delivery date?
SELECT 
  ROUND(SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_late
FROM orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL;

-- ** ANALYSIS ** - 8.11%(8%) of all delivered orders arrived after the estimated delivery date, 91.9% meaning close to (92%) of orders are delivered on time or early. 
-- This tells us that late delivery is not a widespread issue across the business, it's a relatively small slice of total order volume, 
-- so any delivery problem Olist has is concentrated, not systemic across every order.

-- 3.2 What's the average review score for on-time vs. late orders?
SELECT
  CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late' ELSE 'On-time' END AS delivery_status,
  ROUND(AVG(r.review_score),2) AS avg_review_score
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;

-- ** ANALYSIS ** - Average review score for on-time orders is 4.29, while late orders average only 2.57, a drop of 1.72 points. 
-- This is a strong signal that delivery timing has a direct and heavy impact on how customers rate their experience. 
-- Unlike what we found in 2.2, where delay didn't explain repeat purchase behavior, this shows delay does clearly explain review scores, 
-- so delay matters a lot for satisfaction, just not specifically for retention.

-- 3.3 On average, how many days late are late orders?
SELECT ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)),2) AS avg_days_late
FROM orders
WHERE order_status = 'delivered' 
  AND order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date > order_estimated_delivery_date;

-- ** ANALYSIS ** - For orders that are late, the average delay is 8.87 days, which is a substantial wait, not just a day or two slip. 
-- This helps explain why 3.2 showed such a sharp drop in review scores, an 8-9 day delay is long enough to frustrate most customers waiting on a delivery, 
-- so the severity of the delay, not just the fact that it happened, is likely driving the poor reviews.

-- ** OVERALL ANALYSIS ** 
-- Late deliveries only affect 8.11% of orders, so this isn't a large-scale operational failure, most orders arrive on time. 
-- But for the orders that are late,the damage is significant:review scores fall from 4.29 to 2.57 and the average delay is close to 9 days, not a minor slip.
-- So while delivery isn't broadly broken, it is a serious, concentrated problem, fixing delays for this smaller group of late orders could meaningfully lift
-- overall satisfaction scores, even though it wouldn't move the needle on the low retention rate we found in Section 2, 
-- since 2.2 already showed delay doesn't meaningfully separate one-time from repeat customers.


-- **Section 4: Seller Quality**
-- 4.1 Which 10 sellers have the highest average delivery delay?
-- AND
-- 4.2 Do those same sellers also have low average review scores?

SELECT oi.seller_id, 
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)),2) AS avg_delay_days,
  ROUND(AVG(r.review_score),2) AS avg_review_score
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id
ORDER BY avg_delay_days DESC
LIMIT 10;

-- ** ANALYSIS for 4.1 ** - The worst-delay seller averages 167 days late, far beyond the rest of the top 10, which range between 19 and 35 days. 
-- This tells us that while most poorly-performing sellers are consistently a few weeks late, there's at least one extreme outlier dragging the average up, 
-- worth flagging separately since a seller averaging 167 days is likely a serious operational failure, not just slow shipping.

-- AND 

-- ** ANALYSIS for 4.2 ** - Nearly every seller with high delay also has a very low review score, mostly 1.00, with a couple in the 3.00-3.67 range. 
-- This confirms that delivery delay and poor ratings are tied together at the seller level, not just randomly correlated at the order level. 
-- Only one seller breaks the pattern, 33 days delay but a 4.00 score, an anomaly worth a one-line mention but not something to build a conclusion on.

-- 4.3 Do a few sellers account for most late orders, or is it spread across many?
SELECT oi.seller_id, COUNT(*) AS late_order_count
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered' 
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_delivered_customer_date > o.order_estimated_delivery_date
GROUP BY oi.seller_id
ORDER BY late_order_count DESC
LIMIT 20;

-- -- ** ANALYSIS ** - The top 20 worst sellers by late order count account for roughly 2,769 late orders combined 
-- and Olist has around 7,800 late orders total, meaning just 20 sellers (out of over 3,000 total sellers) are responsible for about 35% of all late deliveries. 
-- This is a strong sign that delivery delay is not spread evenly across the platform, it's concentrated in a small group of underperforming sellers, 
-- which means Olist could fix a large chunk of its delay problem by focusing on a small, 
-- specific list of sellers rather than a platform-wide logistics overhaul.


-- ** OVERALL ANALYSIS ** 
-- Delivery delay at Olist is not a platform-wide problem, it's concentrated in a small group of sellers. 
-- The worst offender averages 167 days late, and just 20 sellers account for about 35% of all late orders across the entire platform. 
-- These same high-delay sellers also tend to have poor review scores, mostly 1.00, confirming that seller performance directly drives customer dissatisfaction. 
-- This is actually good news from a business fix perspective: rather than needing a company-wide logistics overhaul, 
-- Olist could meaningfully reduce its delay problem, and by extension improve review scores, 
-- by identifying and addressing this small group of consistently underperforming sellers.

-- **Section 5: Regional Performance**
-- 5.1 What's total revenue and order count by state?
SELECT c.customer_state, 
  ROUND(SUM(oi.price + oi.freight_value),2) AS total_revenue,
  COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- ** ANALYSIS ** - SP (São Paulo) dominates the business by a wide margin, ₹57.7 lakh in revenue and 40,501 orders, 
-- more than double the next closest state, RJ. 
-- The top 3 states (SP, RJ, MG) together account for the vast majority of total revenue, 
-- while states further down the list like RR, AP, and AM contribute only a few thousand rupees each. 
-- This shows Olist's business is heavily concentrated in a small number of states, mainly the more populated, economically developed regions of Brazil, 
-- rather than being evenly spread across the country.

-- 5.2 Which states have the worst average delivery delay?
SELECT c.customer_state, ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)),2) AS avg_delay_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delay_days DESC;

-- ** ANALYSIS ** - Every state shows a negative average, meaning Olist delivers early almost everywhere, 
-- but the size of that early buffer varies a lot by state. AL has the smallest buffer at -8.71 days, 
-- making it the "worst" performing state relative to its own estimate, closest to actually running late. 
-- On the other end, remote states like AC (-20.73), RO (-20.10), and AP (-19.69) are delivered extremely early, over 20 days ahead of estimate in some cases. 
-- This is interesting because it suggests Olist may be setting overly generous delivery estimates for harder-to-reach states, 
-- padding the promise heavily to avoid ever appearing late there, while closer, high-volume states like AL and SP sit with a much tighter buffer.

-- 5.3 Is delay worse for cross-state orders (customer state ≠ seller state) vs. same-state?
SELECT 
  CASE WHEN c.customer_state = s.seller_state THEN 'Same State' ELSE 'Cross State' END AS shipping_type,
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)),2) AS avg_delay_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN sellers s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY shipping_type;

-- ** ANALYSIS ** - Cross-state orders are delivered about 2.4 days earlier on average (-12.91) than same-state orders (-10.47). 
-- This is a bit counterintuitive, you'd expect shipping across state lines to take longer, not shorter, but it lines up with what we saw in 5.2, 
-- Olist appears to set more generous delivery estimates for farther/cross-state deliveries, 
-- so even though the actual shipping likely takes longer in absolute terms, the gap between promised and actual delivery ends up wider (more "early") 
-- because the promise itself was padded more. So distance isn't creating a delay problem, it's actually being pre-compensated for in the estimate itself.


-- ** OVERALL ANALYSIS ** 
-- Olist's business is heavily concentrated in a handful of states, led by SP, RJ, and MG, both in revenue and order volume. 
-- Despite this concentration, delivery performance is strong nationwide, every state is delivered early on average, 
-- though the size of that early buffer varies, smaller in high-volume states like SP and AL, much larger in distant states like AC and RO. 
-- This pattern also holds for cross-state vs same-state shipping, cross-state orders actually look "more early" than same-state ones, 
-- which suggests Olist compensates for distance by setting longer delivery estimates upfront, rather than distance genuinely causing more delays. 
-- Overall, geography doesn't appear to be a real delivery problem for Olist, it's already being managed well through estimate padding, 
-- so any delay issues found earlier (Section 3 and 4) are more likely driven by specific sellers than by regional/geographic factors.


-- **Section 6: Customer Satisfaction**
-- 6.1 What % of reviews are 1-star or 2-star?
SELECT 
  ROUND(SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_low_reviews
FROM order_reviews;

-- -- ** ANALYSIS ** - 14.69% of all reviews are 1-star or 2-star, meaning roughly 1 in 7 customers who leave a review are unhappy with their experience. 
-- This is a meaningful chunk of dissatisfaction, not tiny, but also not the majority, so most customers are having a fine or good experience, 
-- while a real minority is having a genuinely bad one. This number gives us a baseline to compare against later questions, 
-- like whether these negative reviews cluster around specific categories or late deliveries, to understand what's actually driving that unhappy 14.69%.

-- 6.2 Which product categories have the lowest average review score?
SELECT pt.product_category_name_english, ROUND(AVG(r.review_score),2) AS avg_review_score, COUNT(*) AS review_count
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation pt ON p.product_category_name = pt.product_category_name
GROUP BY pt.product_category_name_english
ORDER BY avg_review_score ASC
LIMIT 10;

-- ** ANALYSIS ** - Looking at this list, sample size matters a lot here, security_and_services has the worst score (2.50) but only 2 reviews total, 
-- too small to draw any real conclusion from, same with diapers_and_hygiene (39 reviews) and a few others in single or double digits. 
-- The one category worth actually paying attention to is office_furniture, a 3.49 average score across 1,687 reviews, 
-- that's a large enough sample to be a real, reliable finding, not noise. This suggests office furniture is a genuinely underperforming category for Olist, 
-- worth investigating further in Section 8 when we look at product/category performance in more depth, 
-- while the other categories on this list are likely just small-sample flukes, not real patterns.


-- ** OVERALL ANALYSIS ** 
-- About 14.69% of all reviews are negative (1-2 star), a real but minority slice of customer sentiment. 
-- Looking at which categories drive the worst scores, most of the lowest-rated categories have very small review counts and aren't reliable, 
-- except office_furniture, which has a low score (3.49) backed by a large sample (1,687 reviews), making it a genuine weak spot worth investigating further. 
-- As already established in 3.2, late delivery is a major driver of poor reviews (4.29 on-time vs 2.57 late), 
-- so between category-specific issues (like office_furniture) and delivery timing, we now have two concrete, 
-- evidence-backed levers Olist could pull to reduce the 14.69% dissatisfaction rate.

-- 6.3 Are low reviews more common for late orders than on-time orders?
-- same as 3.2  


-- **Section 7: Payments**
-- 7.1 What % of revenue comes from each payment type?
SELECT payment_type, 
  ROUND(SUM(payment_value),2) AS total_revenue,
  ROUND(SUM(payment_value) * 100.0 / SUM(SUM(payment_value)) OVER(), 2) AS pct_of_revenue
FROM order_payments
GROUP BY payment_type
ORDER BY total_revenue DESC;

-- ** ANALYSIS ** - Credit card dominates as the payment method, making up 78.34% of total revenue, 
-- followed by boleto (a Brazilian bank-slip payment method) at 17.92%. Voucher and debit card together contribute less than 4% combined, 
-- essentially a rounding error in the bigger picture. This tells us Olist's revenue is heavily dependent on customers having and using credit cards, 
-- which is worth noting since credit card access and usage habits can vary a lot by region or income level in Brazil, 
-- so this concentration could either reflect customer preference or be limiting adoption among customers who prefer boleto or don't have credit access, 
-- worth keeping in mind if Olist wanted to grow order volume in underserved segments.

-- 7.2 Is AOV different for orders paid in more installments vs. fewer?
SELECT payment_installments, ROUND(AVG(payment_value),2) AS avg_payment_value, COUNT(*) AS order_count
FROM order_payments
GROUP BY payment_installments
ORDER BY payment_installments;

-- ** ANALYSIS ** - There's a clear pattern here, average payment value generally increases as installment count goes up, 
-- 1 installment averages ₹112.42, while 10 installments jumps to ₹415.09, and higher installment counts (18, 20, 24) push even further, 
-- up to ₹610.05. This makes sense practically, customers are more likely to split a bigger purchase into more installments rather than pay it all at once, 
-- so installment count is really acting as a proxy for order size. Worth noting, the highest installment counts (13 and above) have very small order counts, 
-- some under 30, so those specific averages are less reliable individually, but the overall upward trend from 1 to 10 installments, where most of the volume sits, is a real and consistent pattern.

-- ** OVERALL ANALYSIS ** 
-- Credit card is by far Olist's dominant payment method at 78.34% of revenue, with boleto a distant second at 17.92%
-- and voucher/debit card barely registering. Within credit card usage specifically, higher installment counts consistently correlate with higher order value,
-- customers splitting payments into more installments tend to be making larger purchases, which is a normal and expected pattern, not a red flag. 
-- Together, this tells us Olist's revenue engine is built almost entirely around credit card flexibility, especially the ability to pay in installments, 
-- which likely makes higher-value purchases more accessible to customers 
-- and any strategy to grow AOV further could reasonably lean into promoting installment options even more.


-- **Section 8: Product Performance**
-- 8.1 What are the top 10 products by revenue?
SELECT 
    oi.product_id, ROUND(SUM(oi.price), 2) AS total_revenue
FROM
    order_items oi
        JOIN
    orders o ON oi.order_id = o.order_id
WHERE
    o.order_status = 'delivered'
GROUP BY oi.product_id
ORDER BY total_revenue DESC
LIMIT 10;

-- ** ANALYSIS ** - The top product alone generated ₹63,560, with the rest of the top 10 ranging from roughly ₹37,000 to ₹56,000. 
-- There's a fairly steady, gradual drop-off from the top product to the tenth, no single item is wildly dominating the way SP dominated states in Section 5, 
-- so revenue at the product level is more evenly spread across a handful of strong performers rather than concentrated in one or two hits. 
-- Since these are raw product IDs, not category names, this table alone doesn't tell us much about what type of products are winning, 
-- that's what 8.2 will help us understand, once we bring category names into the picture.

-- 8.2 Which categories are high-revenue but also low-review-score?
SELECT pt.product_category_name_english, 
  ROUND(SUM(oi.price),2) AS total_revenue,
  ROUND(AVG(r.review_score),2) AS avg_review_score
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation pt ON p.product_category_name = pt.product_category_name
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY pt.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 15;

-- ** ANALYSIS ** - Looking at this list, nearly every high-revenue category has a solid review score, mostly between 3.9 and 4.2, 
-- so high revenue and good satisfaction generally go together at Olist. 
-- The one clear exception is office_furniture, ₹2,66,533 in revenue but only a 3.52 average score, noticeably lower than every other category on this list. 
-- This matches exactly what we found back in 6.2, office_furniture was already flagged there as a genuinely weak category with a large, 
-- reliable sample size (1,687 reviews). 
-- Now seeing it here again, generating real revenue but underperforming on satisfaction, confirms it's a legitimate problem area, not a coincidence, 
-- this is a category where Olist is making solid money but quietly losing customer trust, exactly the kind of "watch this" signal we were looking for.

-- ** OVERALL ANALYSIS ** 
-- Revenue at the product level is spread fairly evenly across top performers, no single item dominates the way certain states did in Section 5. 
-- At the category level, most high-revenue categories also have strong review scores, showing that revenue and satisfaction are generally aligned across Olist's catalog. 
-- The clear exception is office_furniture, which appears here as a real revenue contributor but with the lowest review score on the list (3.52),
-- and this isn't a fluke, it was already flagged independently in Section 6 with a large sample size backing it up. 
-- This makes office_furniture the strongest, most evidence-backed "problem category" found so far in the entire project, 
-- a category worth specific investigation, possibly around product quality, delivery handling for bulky furniture items, 
-- or seller performance within that category specifically.

-- **Section 9: Customer Value**
-- 9.1 If customers are split into High/Medium/Low spend tiers, how much revenue does each tier bring in?
-- 9.1 spend tier revenue breakdown
WITH customer_spend AS (
  SELECT c.customer_unique_id, SUM(oi.price + oi.freight_value) AS total_spend
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
)
SELECT 
  CASE 
    WHEN total_spend >= 1000 THEN 'High'
    WHEN total_spend >= 300 THEN 'Medium'
    ELSE 'Low'
  END AS spend_tier,
  COUNT(*) AS customer_count,
  ROUND(SUM(total_spend),2) AS tier_revenue
FROM customer_spend
GROUP BY spend_tier;

-- ** ANALYSIS ** - 88.93% of customers fall into the Low spend tier, yet they still account for 59.74% of total revenue, 
-- simply because they're such a large group. Medium spenders are just 9.84% of customers but contribute 28.46% of revenue, 
-- and High spenders are a tiny 1.23% of customers but still bring in 11.8% of revenue, averaging ₹1,584 per customer, 
-- more than 14x what a Low tier customer spends on average (₹110.95). 
-- This shows Olist's revenue isn't purely mass-market volume-driven, 
-- there's a small but valuable High-spend segment worth protecting and potentially targeting specifically, 
-- even though the bulk of the business still comes from the much larger Low-spend base.

-- 9.2 Do High spenders tend to be repeat customers, or mostly one-time big purchases?
WITH customer_data AS (
  SELECT c.customer_unique_id, 
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(oi.price + oi.freight_value) AS total_spend
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
)
SELECT 
  CASE WHEN total_spend >= 1000 THEN 'High' WHEN total_spend >= 300 THEN 'Medium' ELSE 'Low' END AS spend_tier,
  ROUND(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_repeat
FROM customer_data
GROUP BY spend_tier;

-- ** ANALYSIS ** - Repeat purchase rate is low across every spend tier, but it's clearly not flat, Medium spenders repeat the most at 9.45%, 
-- followed by High spenders at 7.31%, while Low spenders repeat the least at just 2.23%. 
-- This is a useful nuance on top of Section 2's overall 3.12% retention rate, retention isn't uniform, 
-- customers who spend more (Medium and High tiers) are meaningfully more likely to come back than low-value customers. 
-- It's a bit surprising that Medium beats High here, one possible explanation is that High spenders may be making a single large one-off purchase, 
-- like an expensive furniture or electronics item, rather than returning repeatedly, 
-- while Medium spenders may be buying moderately-priced items more suited to repeat purchasing.

-- -- ** OVERALL ANALYSIS ** 
-- While 88.93% of customers are Low spenders, they contribute just under 60% of revenue, 
-- while a small High-spend segment (1.23% of customers) contributes nearly 12% of revenue at a much higher per-customer value. 
-- Retention also varies meaningfully by tier, Medium and High spenders repeat purchase noticeably more often than Low spenders, 
-- though even the best-performing tier (Medium, at 9.45%) is still low in absolute terms. 
-- This suggests Olist's most valuable customers aren't just defined by how much they spend, but also by tier-specific retention behavior, 
-- and any retention strategy going forward should probably prioritize Medium and High spenders first, 
-- since they show the clearest existing tendency to return, rather than trying to fix retention uniformly across the entire customer base.

