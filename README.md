# Explore-Ecommerce-Dataset
Use SQL in BigQuery to improve channel quality, cohort funnel and cross-sell

## I. PROJECT OVERVIEW
This project contains an eCommerce dataset that I will explore using SQL on Google BigQuery. 
**Business goals:** 
This project analyzes Google Analytics 360 e-commerce sessions to find practical levers for **growing monthly revenue**. I compares baseline performance and seasonality (visits, pageviews, transactions), with focus on July, and evaluate **channel quality** and **onsite funnel efficiency** using bounce rate, revenue per session, and the view → add-to-cart → purchase path. The analysis identifies which traffic sources to scale or fix, where users drop off, the expected AOV/upsell potential, and **cross-sell pairs** for “frequently bought together,” turning raw GA data into concrete actions for acquisition, conversion, and merchandising.

## II. DATASET
**Dataset access:**
This eCommerce dataset is stored in a public Google BigQuery dataset. To access the dataset, follow these steps:
- Log in to your Google Cloud Platform account
- Get data through:
  - this link https://console.cloud.google.com/bigquery?ws=!1m5!1m4!4m3!1sbigquery-public-data!2sgoogle_analytics_sample!3sga_sessions_20170801
  - Or create a new project in BigQuery -> select "Add Data" -> "Search a project" -> Enter the project ID "bigquery-public-data.google_analytics_sample.ga_sessions" -> "Enter" -> Click on the "ga_sessions_" table to open it

**Dataset description:** 
The dataset is based on the Google Analytics public dataset and contains data from an eCommerce website. (`bigquery-public-data.google_analytics_sample.ga_sessions_20170801` )
The sample dataset contains obfuscated Google Analytics 360 data from the [Google Merchandise Store](https://www.googlemerchandisestore.com/shop.axd/Home?utm_source=Partners&utm_medium=affiliate&utm_campaign=Data%20Share%20Promo), a real ecommerce store. The Google Merchandise Store sells Google branded merchandise. The data is typical of what you would see for an ecommerce website. 

**Data description table:**
Below are the fields, data type, description of the fields I used in this SQL project

| Field Name | Data Type | Description |
|----------|----------|----------|
| fullVisitorId   | String   | The unique visitor ID     |
| date      | String     | The date of the session in YYYYMMDD format      |
| totals      | Record     | This section contains aggregate values across the session      |
| totals.bounces      | Integer     | Total bounces (for convenience). For a bounced session, the value is 1, otherwise it is null      |
| totals.hits      | Integer     | Total number of hits within the session      |
| totals.pageviews      | Integer     | Total number of pageviews within the session      |
| totals.visits     | Integer     | The number of sessions (for convenience). This value is 1 for sessions with interaction events. The value is null if there are no interaction events in the session      |
| totals.transactions      | Integer     | Total number of ecommerce transactions within the session      |
| trafficSource.source      | String     | The source of the traffic source. Could be the name of the search engine, the referring hostname, or a value of the utm_source URL parameter      |
| hits      | Record     | This row and nested fields are populated for any and all types of hits      |
| hits.eCommerceAction      | Record     | This section contains all of the ecommerce hits that occurred during the session. This is a repeated field and has an entry for each hit that was collected      |
| hits.eCommerceAction.action_type      | String     | The action type. Click through of product lists = 1, Product detail views = 2, Add product(s) to cart = 3, Remove product(s) from cart = 4, Check out = 5, Completed purchase = 6, Refund of purchase = 7, Checkout options = 8, Unknown = 0. Usually this action type applies to all the products in a hit, with the following exception: when hits.product.isImpression = TRUE, the corresponding product is a product impression that is seen while the product action is taking place (i.e., a "product in list view")      |
| hits.product      | Record     | This row and nested fields will be populated for each hit that contains Enhanced Ecommerce PRODUCT data      |
| hits.product.productQuantity      | Integer     | The quantity of the product purchased      |
| hits.product.productRevenue      | Integer     | The revenue of the product, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000)      |
| hits.product.productSKU      | String     | Product SKU      |
| hits.product.v2ProductName      | String     | Product Name     |

## III. EXPLORE DATASET
This project includes 8 queries

### Query 1. Calculate total visit, pageview, transaction for January - August 2017 (order by month).
**SQL code**
```
SELECT 
  FORMAT_DATE('%Y%m', parse_date('%Y%m%d', date)) AS month
  ,SUM(totals.visits) AS visits
  ,SUM(totals.pageviews) AS pageview
  ,SUM(totals.transactions) AS transactions
  ,ROUND(100 * SAFE_DIVIDE(SUM(totals.transactions), SUM(totals.visits)), 2) AS conversion_rate_pct

FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*` 
GROUP BY month
ORDER BY month;
```

**Query result**

<img width="911" height="305" alt="image" src="https://github.com/user-attachments/assets/c93ba95c-696d-49ca-97ce-3aeb22f21db3" />




  

