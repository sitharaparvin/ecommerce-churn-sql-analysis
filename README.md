# 🛍️ E-Commerce Customer Churn Analysis (SQL Project)

## 📌 Overview
This project analyzes customer churn data for an e-commerce platform using SQL. It includes data cleaning, transformation, and exploratory analysis to extract meaningful business insights.

---

## 🎯 Objectives
- Clean and preprocess raw customer data  
- Handle missing values and outliers  
- Transform and standardize data  
- Analyze customer churn behavior  
- Generate insights using SQL queries  

---

## 🗂️ Dataset
The dataset contains customer information such as:
- Tenure  
- Order history  
- Payment methods  
- Customer complaints  
- Satisfaction score  
- Churn status  

---

## 🛠️ Key Operations Performed

### 🔹 Data Cleaning
- Imputed missing values using mean and mode  
- Removed outliers (e.g., extreme distance values)  
- Standardized inconsistent text values  

### 🔹 Data Transformation
- Renamed columns for consistency  
- Created new columns:
  - `ChurnStatus` (Churned / Active)  
  - `ComplaintReceived` (Yes / No)  
- Dropped unnecessary columns  

### 🔹 Data Analysis
- Customer churn distribution  
- Customer behavior analysis  
- Payment method preferences  
- Product/category insights  
- Customer segmentation  

---

## 📊 Key Insights
- Identified 16.84% overall churn rate with 948 churned customers; churned users averaged only 3 months tenure, signaling critical early lifecycle risk
- Quantified revenue and service impact: $152,030 in cashback tied to churned customers; 53.6% of churned users had lodged complaints with avg satisfaction score of 3.0/5
- Last-mile analysis using SQL CASE WHEN: Customers >15km from warehouse showed 21.0% churn vs 13.5% for <=10km — 1.6x higher attrition for far-distance segments
- Payment behavior insight: Debit Card was most preferred mode among 1,956 active users, indicating lower-risk transaction profile for retention targeting

---

## 🚀 How to Use

1. Open MySQL or any SQL environment  
2. Create a database (e.g., `ecomm`)  
3. Import the dataset  
4. Run the SQL script file  
5. Execute queries to view insights  

---

## 📁 File Included

- E-Commerce Customer Churn Analysis.sql  

---

## 📬 Notes
- This project is for learning and portfolio purposes  
- Queries are written in MySQL syntax  
- Can be extended with visualization tools like Power BI or Tableau  

---

## ⭐ Support
If you found this project useful, feel free to star ⭐ the repository!
