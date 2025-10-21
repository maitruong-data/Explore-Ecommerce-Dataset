# Explore-Ecommerce-Dataset
Use SQL in BigQuery to improve channel quality, cohort funnel and cross-sell
## I. PROJECT OVERVIEW
This project contains an eCommerce dataset that I will explore using SQL on Google BigQuery. 
**Business goals:** 
This project analyzes Google Analytics 360 e-commerce sessions to find practical levers for **growing monthly revenue**. I compares baseline performance and seasonality (visits, pageviews, transactions), with focus on July, and evaluate **channel quality** and **onsite funnel efficiency** using bounce rate, revenue per session, and the view → add-to-cart → purchase path. The analysis identifies which traffic sources to scale or fix, where users drop off, the expected AOV/upsell potential, and **cross-sell pairs** for “frequently bought together,” turning raw GA data into concrete actions for acquisition, conversion, and merchandising.

**Dataset description:** 
The dataset is based on the Google Analytics public dataset and contains data from an eCommerce website. (`bigquery-public-data.google_analytics_sample.ga_sessions_20170801` )
The sample dataset contains obfuscated Google Analytics 360 data from the [Google Merchandise Store](https://www.googlemerchandisestore.com/shop.axd/Home?utm_source=Partners&utm_medium=affiliate&utm_campaign=Data%20Share%20Promo), a real ecommerce store. The Google Merchandise Store sells Google branded merchandise. The data is typical of what you would see for an ecommerce website. 

**Dataset access:**
This eCommerce dataset is stored in a public Google BigQuery dataset. To access the dataset, follow these steps:
- Log in to your Google Cloud Platform account
- Get data through:
  - this link https://console.cloud.google.com/bigquery?ws=!1m5!1m4!4m3!1sbigquery-public-data!2sgoogle_analytics_sample!3sga_sessions_20170801
  - Or create a new project in BigQuery -> select "Add Data" -> "Search a project" -> Enter the project ID "bigquery-public-data.google_analytics_sample.ga_sessions" -> "Enter" -> Click on the "ga_sessions_" table to open it

  
| STT | Cột 1 | Cột 2 |

| 1 | Dòng 11 | Dòng 21 |
| 2 | Dòng 12 | Dòng 22 |
| 3 | Dòng 13 | Dòng 23 |
| 4 | Dòng 14 | Dòng 24 |
