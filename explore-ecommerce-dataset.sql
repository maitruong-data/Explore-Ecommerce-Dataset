--Query 1. Visits, pageviews, transactions by month (Jan 2017 to Aug 2017)
SELECT 
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
  ,SUM(totals.visits) AS visits
  ,SUM(totals.pageviews) AS pageview
  ,SUM(totals.transactions) AS transactions
  ,ROUND(100 * SAFE_DIVIDE(SUM(totals.transactions), SUM(totals.visits)), 2) AS conversion_rate_pct

FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*` 
GROUP BY month
ORDER BY month;


--Query 2. Calculate cohort map from product view to addtocart to purchase in 2017 (Jan 2017 to Aug 2017)

WITH 
product_view AS(
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
    ,COUNT(product.productSKU) AS num_product_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE hits.eCommerceAction.action_type = '2'
  GROUP BY month
),

add_to_cart AS(
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
    ,count(product.productSKU) as num_addtocart
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE hits.eCommerceAction.action_type = '3'
  GROUP BY month
),

purchase AS(
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
    ,COUNT(product.productSKU) AS num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) AS product
  WHERE hits.eCommerceAction.action_type = '6'
  AND product.productRevenue IS NOT NULL
  GROUP BY month
)

SELECT
    pv.month
    ,pv.num_product_view
    ,a.num_addtocart
    ,p.num_purchase
    ,ROUND(a.num_addtocart * 100/pv.num_product_view,2) AS add_to_cart_rate
    ,ROUND(p.num_purchase * 100/pv.num_product_view,2) AS purchase_rate
FROM product_view AS pv
LEFT JOIN add_to_cart AS a ON pv.month = a.month
LEFT JOIN purchase AS p ON pv.month = p.month
ORDER BY pv.month;


--Query 03: Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC)

SELECT 
  trafficSource.source AS source
  ,SUM(totals.visits) AS total_visits
  ,SUM(totals.bounces) AS total_no_of_bounces
  ,ROUND(100.0*SUM(totals.bounces)/SUM(totals.visits), 3) AS bounce_rate --Bounce_rate = num_bounce/total_visit
  
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*` --July 2017

GROUP BY source
ORDER BY total_visits DESC;


--Query 04: Revenue by traffic source in July 2017

WITH 
base AS ( --Check date string, calculate revenue by traffic source and by date
  SELECT
    PARSE_DATE('%Y%m%d', date) AS parsed
    ,trafficSource.source AS source
    ,SUM(product.productRevenue)/1000000 AS revenue --productRevenue is divided by 1000000 to shorten the result
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*` --July 2017
    ,UNNEST (hits) hits
    ,UNNEST(hits.product) product
  WHERE product.productRevenue IS NOT NULL 
  GROUP BY parsed, source
)

--Format and round the Revenue
SELECT 
  FORMAT_DATE('%Y%m', parsed) AS month
  ,source
  ,ROUND(SUM(revenue), 4) AS revenue
FROM base
GROUP BY month, source
ORDER BY month, revenue DESC;


--Query 5. Average number of pageviews by purchaser type (purchasers vs non-purchasers) in July 2017.
--Avg pageview = total pageview / number unique user.

WITH 
purchaser AS (--Average number of pageviews by purchaser
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
    ,ROUND(SUM(totals.pageviews) / COUNT(DISTINCT fullVisitorId), 7) AS avg_pageviews_purchase 
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*` 
    ,UNNEST (hits) hits
    ,UNNEST(hits.product) product
  WHERE totals.transactions >=1
  AND productRevenue IS NOT NULL
  GROUP BY month
)

,non_purchaser AS (--Average number of pageviews by non-purchaser
  SELECT
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
    ,ROUND(SUM(totals.pageviews) / COUNT(DISTINCT fullVisitorId), 7) AS avg_pageviews_non_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*` 
    ,UNNEST (hits) hits
    ,UNNEST(hits.product) product
  WHERE totals.transactions IS NULL
  AND productRevenue IS NULL
  GROUP BY month
)

SELECT p.month, p.avg_pageviews_purchase, n.avg_pageviews_non_purchase
FROM purchaser p
FULL JOIN non_purchaser n
ON p.month = n.month
ORDER BY p.month;


--Query 6: Average number of transactions per user in July 2017

SELECT
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
  --avg transaction per user = total transaction / total visitor
  ,ROUND(SUM(totals.transactions) / COUNT(DISTINCT fullVisitorId), 7) AS Avg_total_transactions_per_user 

FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*` --July 2017
  ,UNNEST (hits) hits
  ,UNNEST(hits.product) product
WHERE totals.transactions >=1
AND productRevenue IS NOT NULL
GROUP BY month;


--Query 7: Average amount of money spent per session in July 2017

SELECT  
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month
  -- avg_revenue_per_session = total revenue/ total visit
  ,ROUND((SUM(productRevenue) / SUM(totals.visits)) / 1000000, 2) AS avg_revenue_by_user_per_visit
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*` --July 2017
    ,UNNEST (hits) hits
    ,UNNEST(hits.product) product
WHERE totals.transactions >=1
AND productRevenue IS NOT NULL
GROUP BY month;


--Query 8. Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered.

WITH buyer_list AS(
  SELECT
    DISTINCT fullVisitorId  
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) AS product
  WHERE product.v2ProductName = "YouTube Men's Vintage Henley"
  AND totals.transactions>=1
  AND product.productRevenue IS NOT NULL 
)

SELECT
  product.v2ProductName AS other_purchased_products,
  SUM(product.productQuantity) AS quantity
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
, UNNEST(hits) AS hits
, UNNEST(hits.product) AS product
JOIN buyer_list USING(fullVisitorId)
WHERE product.v2ProductName != "YouTube Men's Vintage Henley"
 AND product.productRevenue IS NOT NULL 
 AND totals.transactions>=1
GROUP BY other_purchased_products
ORDER BY quantity DESC;
