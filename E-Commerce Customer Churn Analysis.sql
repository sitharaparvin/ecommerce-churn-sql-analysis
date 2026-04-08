USE ecomm;
SELECT * FROM customer_churn;

#Data Cleaning: Handling Missing Values and Outliers: 
#Impute mean  for the following columns, and round off to the nearest integer if required: WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear, DaySinceLastOrder. 
SET SQL_SAFE_UPDATES = 0;
SET @mean_WarehouseToHome = (SELECT ROUND(AVG(WarehouseToHome)) FROM customer_churn);
UPDATE customer_churn SET WarehouseToHome = @mean_WarehouseToHome WHERE WarehouseToHome IS NULL;

SET @mean_HourSpendOnApp = (SELECT ROUND(AVG(HourSpendOnApp)) FROM customer_churn);
UPDATE customer_churn SET HourSpendOnApp = @mean_HourSpendOnApp WHERE HourSpendOnApp IS NULL;

SET @mean_OrderAmountHikeFromlastYear = (SELECT ROUND(AVG(OrderAmountHikeFromlastYear)) FROM customer_churn);
UPDATE customer_churn SET OrderAmountHikeFromlastYear = @mean_OrderAmountHikeFromlastYear WHERE OrderAmountHikeFromlastYear IS NULL;

SET @mean_DaySinceLastOrder = (SELECT ROUND(AVG(DaySinceLastOrder)) FROM customer_churn);
UPDATE customer_churn SET DaySinceLastOrder = @mean_DaySinceLastOrder WHERE DaySinceLastOrder IS NULL;

# Impute mode for the following columns: Tenure, CouponUsed, OrderCount. 
SET @mode_Tenure = (SELECT Tenure FROM customer_churn GROUP BY Tenure ORDER BY COUNT(*) DESC LIMIT 1);
UPDATE customer_churn SET Tenure = @mode_Tenure WHERE Tenure IS NULL;

SET @mode_CouponUsed = (SELECT CouponUsed FROM customer_churn GROUP BY CouponUsed ORDER BY COUNT(*) DESC LIMIT 1);
UPDATE customer_churn SET CouponUsed = @mode_CouponUsed WHERE CouponUsed IS NULL;

SET @mode_OrderCount = (SELECT OrderCount FROM customer_churn GROUP BY OrderCount ORDER BY COUNT(*) DESC LIMIT 1);
UPDATE customer_churn SET OrderCount = @mode_OrderCount WHERE OrderCount IS NULL;

#Handle outliers in the 'WarehouseToHome' column by deleting rows where the values are greater than 100. 
DELETE FROM customer_churn WHERE WarehouseToHome > 100;

#Replace occurrences of “Phone” in the 'PreferredLoginDevice' column and “Mobile” in the 'PreferedOrderCat' column with “Mobile Phone” to ensure uniformity.
UPDATE customer_churn SET PreferredLoginDevice = 'Mobile Phone' WHERE PreferredLoginDevice = 'Phone';
UPDATE customer_churn SET PreferedOrderCat = REPLACE(preferedOrderCat, 'Mobile', 'Mobile Phone');

#Standardize payment mode values: Replace "COD" with "Cash on Delivery" and "CC" with "Credit Card" in the PreferredPaymentMode column.
UPDATE customer_churn SET PreferredPaymentMode = REPLACE(REPLACE(PreferredPaymentMode, 'COD', 'Cash on Delivery'), 'CC', 'Credit Card');

#Data Transformation:Column Renaming:Rename the column "PreferedOrderCat" to "PreferredOrderCat". 
ALTER TABLE customer_churn RENAME COLUMN PreferedOrderCat TO PreferredOrderCat; 
#Rename the column "HourSpendOnApp" to "HoursSpentOnApp".
ALTER TABLE customer_churn RENAME COLUMN HourSpendOnApp TO HoursSpentOnApp;

#Creating New Columns:Create a new column named ‘ComplaintReceived’ with values "Yes" if the corresponding value in the ‘Complain’ is 1, and "No" otherwise. 
ALTER TABLE customer_churn ADD COLUMN ComplaintReceived VARCHAR(3);
UPDATE customer_churn SET ComplaintReceived = IF(Complain = 1, 'Yes','No');

#Create a new column named 'ChurnStatus'. Set its value to “Churned” if the corresponding value in the 'Churn' column is 1, else assign “Active”. 
ALTER TABLE customer_churn ADD COLUMN ChurnStatus VARCHAR(10);
UPDATE customer_churn SET ChurnStatus = IF(Churn = 1, 'Churned', 'Active');

#Column Dropping: Drop the columns "Churn" and "Complain" from the table. 
ALTER TABLE customer_churn DROP COLUMN Churn;
ALTER TABLE customer_churn DROP COLUMN Complain;

#Data Exploration and Analysis:
#Retrieve the count of churned and active customers from the dataset. 
SELECT ChurnStatus, COUNT(*) AS CustomerCount FROM customer_churn GROUP BY ChurnStatus;

#Display the average tenure and total cashback amount of customers who churned.
SELECT AVG(Tenure) AS AverageTenure, SUM(CashbackAmount) AS TotalCashbackAmount FROM customer_churn WHERE ChurnStatus='Churned'; 

#Determine the percentage of churned customers who complained. 
SELECT (SUM(IF(ChurnStatus='Churned' AND ComplaintReceived = 'YES', 1, 0)) / SUM(IF(ChurnStatus='Churned', 1, 0))) * 100 
AS ChurnedComplaintPercentage FROM customer_churn;

#Identify the city tier with the highest number of churned customers whose preferred order category is Laptop & Accessory.
SELECT CityTier, COUNT(*) AS ChurnedLaptopAccessoryCustomer FROM customer_churn 
WHERE ChurnStatus = 'Churned' AND PreferredOrderCat = 'Laptop & Accessory' 
GROUP BY CityTier ORDER BY ChurnedLaptopAccessoryCustomer DESC LIMIT 1;

#Identify the most preferred payment mode among active customers.
SELECT PreferredPaymentMode, COUNT(*) AS PaymentCount FROM customer_churn WHERE ChurnStatus = 'Active' GROUP BY PreferredPaymentMode 
ORDER BY PreferredPaymentMode DESC LIMIT 1;

#Calculate the total order amount hike from last year for customers who are single and prefer mobile phones for ordering. 
SELECT SUM(OrderAmountHikeFromlastYear) AS TotalOrderAmountHike FROM customer_churn 
WHERE MaritalStatus = 'Single' AND PreferredOrderCat = 'Mobile Phone';

#Find the average number of devices registered among customers who used UPI as their preferred payment mode. 
SELECT AVG(NumberOfDeviceRegistered) AS AverageDeviceRegistered FROM customer_churn WHERE PreferredPaymentMode = 'UPI';

#Determine the city tier with the highest number of customers. 
SELECT CityTier, COUNT(*) AS NumberOfCustomers FROM customer_churn GROUP BY CityTier ORDER BY NumberOfCustomers DESC LIMIT 1;

#Identify the gender that utilized the highest number of coupons.
SELECT Gender, SUM(CouponUsed) AS TotalCouponUsed FROM customer_churn GROUP BY Gender ORDER BY  TotalCouponUsed DESC LIMIT 1;

#List the number of customers and the maximum hours spent on the app in each preferred order category.
SELECT PreferredOrderCat, COUNT(*) AS CustomerCount, MAX(HoursSpentOnApp) AS MaxHoursSpent FROM customer_churn GROUP BY PreferredOrderCat;

#Calculate the total order count for customers who prefer using credit cards and have the maximum satisfaction score.
SELECT SUM(OrderCount) AS TotalOrderCount FROM customer_churn WHERE PreferredPaymentMode = 'Credit Card' AND 
SatisfactionScore = (SELECT MAX(SatisfactionScore) FROM customer_churn);

#What is the average satisfaction score of customers who have complained?
SELECT AVG(SatisfactionScore) AS AverageSatisfactionScore FROM customer_churn WHERE ComplaintReceived = 'Yes';

#List the preferred order category among customers who used more than 5 coupons. 
SELECT PreferredOrderCat, COUNT(*) AS CustomerCount FROM customer_churn WHERE CouponUsed > 5 
GROUP BY PreferredOrderCat ORDER BY CustomerCount DESC;

#List the top 3 preferred order categories with the highest average cashback amount.
SELECT PreferredOrderCat, AVG(CashbackAmount) AS AverageCashback FROM customer_churn 
GROUP BY PreferredOrderCat ORDER BY AverageCashback DESC LIMIT 3;

#Find the preferred payment modes of customers whose average tenure is 10 months and have placed more than 500 orders. 
SELECT PreferredPaymentMode FROM customer_churn GROUP BY PreferredPaymentMode 
HAVING ROUND(AVG(Tenure),0) = 10 AND SUM(OrderCount) > 500; 

#Categorize customers based on their distance from the warehouse to home such  as 'Very Close Distance' for distances <=5km, 'Close Distance' for <=10km,  'Moderate Distance' for <=15km, and 'Far Distance' for >15km. Then, display the churn status breakdown for each distance category.
SELECT 
    IF(WarehouseToHome <= 5, 'Very Close Distance', IF(WarehouseToHome <= 10, 'Close Distance', 
    IF(WarehouseToHome <= 15, 'Moderate Distance', 'Far Distance'))) AS DistanceCategory,
    ChurnStatus, COUNT(*) as CustomerCount FROM customer_churn GROUP BY IF(WarehouseToHome <= 5, 'Very Close Distance',
	IF(WarehouseToHome <= 10, 'Close Distance', IF(WarehouseToHome <= 15, 'Moderate Distance', 'Far Distance'))), ChurnStatus;
    
#List the customer’s order details who are married, live in City Tier-1, and their order counts are more than the average number of orders placed by all customers.
SELECT * FROM customer_churn WHERE MaritalStatus = 'Married' AND CityTier = 1 AND OrderCount > (SELECT AVG(OrderCount) FROM customer_churn);

CREATE TABLE customer_returns(
ReturnID INT PRIMARY KEY,
CustomerID INT,
ReturnDate DATE,
RefundAmount INT,
FOREIGN KEY (CustomerID) REFERENCES customer_churn(CustomerID) 
);

INSERT INTO customer_returns (ReturnID, CustomerID, ReturnDate, RefundAmount) VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);

#Display the return details along with the customer details of those who have churned and have made complaints.
SELECT r.ReturnID, r.CustomerID, r.ReturnDate, r.RefundAmount, c.ChurnStatus, c.ComplaintReceived FROM customer_returns r 
INNER JOIN customer_churn c ON r.CustomerID = c.CustomerID WHERE c.ChurnStatus = 'Churned' AND c.ComplaintReceived = 'Yes';