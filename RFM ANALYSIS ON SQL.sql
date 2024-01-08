--==============================================================================
-- SQL PROJECT: E-COMMERCE RFM ANALYSIS
--==============================================================================

--==============================================================================
-- DATA CLEANING
--==============================================================================

-- Viewing the structure of the Online_Retail table
SELECT *
FROM Online_Retail

EXEC sp_help 'Online_Retail';

-- Create a duplicate table with the same structure and data
SELECT *
INTO Shopping
FROM Online_Retail;

--Compare Both Tables
SELECT * 
FROM Shopping

SELECT * 
FROM Online_Retail

--==============================================================================
-- ADD TOTALSALES COLUMN AND UPDATE ITS VALUES
--==============================================================================

-- Add the TotalSales column
ALTER TABLE Online_Retail
ADD TotalSales DECIMAL(10, 2);

-- Update TotalSales with Quantity multiplied by UnitPrice
UPDATE Online_Retail
SET TotalSales = Quantity*UnitPrice

-- View the updated Online_Retail table
SELECT * FROM Online_Retail;

--Checking StockCode For Any Errors
select * from Online_Retail
order by StockCode Desc

select distinct StockCode from Online_Retail
order by StockCOde desc

--Check For Null Values in CustomerID
SELECT *
FROM 
	"Online_Retail"
WHERE 
	CustomerID IS NULL

SELECT *
FROM 
	Online_Retail
WHERE
	InvoiceNo IS NULL

SELECT * 
FROM Online_Retail
WHERE UnitPrice < 0

SELECT * 
FROM Online_Retail
WHERE Quantity < 0

--From Investigations Above, it can be seen that StockCode with 'S-SAMPLE, POST-POSTAGE, D-DISCOUNT, M-MANUAL, 
--%gift%-GIFTCARD, DOT-DOTCOM POSTAGE, CRUK- CommissionUK, C2-CARRIAGE, BANK CHARGES, AMAZON FEE,B-ADJUSTED BAD DEBT 
--and Descriptions with ?, ??, mising and check either have Blank InvoiceID, CustomerID or have Negative Unit Price and Quantity
--which may affect our analysis so will be deleted. Lets check each of them before deletion

SELECT *
FROM Online_Retail
WHERE StockCode = 'S'

SELECT *
FROM Online_Retail
WHERE StockCode = 'POST'

SELECT *
FROM Online_Retail
WHERE StockCode = 'D'

SELECT *
FROM Online_Retail
WHERE StockCode = 'M'

SELECT *
FROM Online_Retail
WHERE StockCode LIKE '%gift_%'

SELECT *
FROM Online_Retail
WHERE StockCode = 'DOT'

SELECT *
FROM Online_Retail
WHERE StockCode = 'CRUK'

SELECT *
FROM Online_Retail
WHERE StockCode = 'C2'

SELECT *
FROM Online_Retail
WHERE StockCode = 'BANK CHARGES'

SELECT *
FROM Online_Retail
WHERE StockCode = 'B'

SELECT *
FROM Online_Retail
WHERE StockCode = 'AMAZONFEE'

SELECT *
FROM Online_Retail
WHERE Description = '?'

SELECT *
FROM Online_Retail
WHERE Description = 'missing'

SELECT *
FROM Online_Retail
WHERE Description = 'check'

SELECT *
FROM Online_Retail
WHERE Description = '??'

--DELETION OF ERRORS

DELETE FROM Online_Retail
WHERE CustomerID IS NULL;

DELETE FROM Online_Retail
WHERE StockCode IN ('S','POST','PADS','M','DOT','D','CRUK','C2','BANK CHARGES')

DELETE FROM Online_Retail
WHERE InvoiceNo IS NULL;

DELETE FROM Online_Retail
WHERE UnitPrice <= 0

DELETE FROM Online_Retail
WHERE Quantity <= 0

--CONFIRMATION
SELECT * 
FROM Online_Retail
ORDER BY StockCode

--INVESTIGATION OF QUANTITIES
SELECT *
FROM Online_Retail
ORDER BY Quantity desc

--Outliers Can be seen of 80995 and 74215 Quantities compared to the next one of 4800 quantities.
--Should Outlier be deleted

--Checking The StockCode to find out if other customers bought the product
SELECT *
FROM Online_Retail
where StockCode IN ('23843', '23166')
--It has more than one transactions

--Checking The CustomerID to find out if the customers bought other products
SELECT *
FROM Online_Retail
WHERE CustomerID IN ('12346', '16446')

--Let's Do some sensitivity Analysis to find out if it will hugely affect our final resul

SELECT
	AVG(Quantity),
	SUM(Quantity), 
	SUM(TotalSales)
FROM
	Online_Retail

SELECT
	AVG(Quantity),
	SUM(Quantity), 
	SUM(TotalSales)
FROM
	Online_Retail
WHERE 
	Quantity < 10000

--=============================================================================
--EXPLORATORY DATA ANALYSIS
--==============================================================================
-- COUNTRY ANALYSIS
--==============================================================================
SELECT 
	Country,
	COUNT(DISTINCT InvoiceNo) AS "Countries Trasactions",
	COUNT(DISTINCT CustomerID) AS "Customers PER COUNTRY",
	SUM(QUANTITY) AS QuantitySold,
	SUM(TotalSales) AS TotalSales, 
	SUM(TotalSales)/COUNT(DISTINCT InvoiceNo) as AvgSalesPerTransaction
FROM 
	Online_Retail
GROUP BY 
	Country
ORDER BY
	TotalSales DESC

-- Calculate average purchase amount per country
SELECT Country, AVG(TotalSales) AS AvgPurchaseAmount
FROM Online_Retail
GROUP BY Country
ORDER BY Country

--==============================================================================
-- CUSTOMER ANALYSIS
--==============================================================================
SELECT 
	CustomerID, 
	SUM(TotalSales) as Sales, 
	count(DISTINCT InvoiceNo) as Transactions, 
	SUM(QUANTITY) AS QuantitySold,
	SUM(TotalSales)/count(DISTINCT InvoiceNo) as AverageSalesPerTransaction
FROM
	Online_Retail
GROUP BY
	CustomerID
ORDER BY
	Sales DESC

-- Determining the number of unique products purchased by each customer
SELECT
    CustomerID,
    COUNT(DISTINCT StockCode) AS UniqueProductCount
FROM
    Online_Retail
GROUP BY
    CustomerID
ORDER BY
    UniqueProductCount DESC;

---- Identifying customers who have made only a single purchase from the company
SELECT
    CustomerID
FROM
    Online_Retail
GROUP BY
    CustomerID
HAVING
    COUNT(DISTINCT InvoiceNo) = 1;

--==============================================================================
-- PRODUCTS ANALYSIS
--==============================================================================
-- List of Products, Unit Price, Quantity Sold and Total Sales
SELECT 
	StockCode, 
	Description, 
	MAX(UnitPrice) AS UnitPrice, 
	SUM(Quantity) as ProductQtySold, 
	SUM(TotalSales) as ProductRevenue
FROM
    Online_Retail
GROUP BY 
	StockCode,
	Description
ORDER BY 
	ProductRevenue DESC

-- Identify products commonly purchased together

SELECT
    A.StockCode AS Product1,
	A.Description AS ProductDescription1,
    B.StockCode AS Product2,
	B.Description AS ProductDescription2,
    COUNT(*) AS PurchaseCount
FROM
    Online_Retail A
JOIN
    Online_Retail B ON A.InvoiceNo = B.InvoiceNo AND A.StockCode < B.StockCode
GROUP BY
    A.StockCode,A.Description, B.StockCode, B.Description
HAVING
    COUNT(*) > 100
ORDER BY
    PurchaseCount DESC;
--Green Regency Teacuo and Saucer and Pink Teacup and saucer are the most bought items together

--==============================================================================
-- PEAK TRANSACTION ANALYSIS
--==============================================================================
--MONTHLY TRANSACTION COUNT
--==============================================================================
SELECT
    DATEPART(YEAR, InvoiceDate) AS Year,
    DATEPART(MONTH, InvoiceDate) AS Month,
    COUNT(DISTINCT InvoiceNo) AS TransactionCount
FROM
    Online_Retail
GROUP BY
    DATEPART(YEAR, InvoiceDate),
    DATEPART(MONTH, InvoiceDate)
ORDER BY
    Year, Month;
--November 2011 has the highest transactions made

-- WEEKLY TRANSACTION COUNT
SELECT
	DATEPART(YEAR, InvoiceDate) AS Year,
    DATEPART(MONTH, InvoiceDate) AS Month,
    DATEPART(WEEK, InvoiceDate) AS WEEK,
    COUNT(DISTINCT InvoiceNo) AS TransactionCount
FROM
    Online_Retail
GROUP BY
	DATEPART(YEAR, InvoiceDate),
    DATEPART(MONTH, InvoiceDate),
    DATEPART(WEEK, InvoiceDate)
ORDER BY
    Year,Month,WEEK
--The highest transaction count is the third week of November 2011

-- HOURLY TRANSACTION COUNT
SELECT
    DATEPART(HOUR, InvoiceDate) AS HourOfDay,
    COUNT(DISTINCT InvoiceNo) AS TransactionCount
FROM
    Online_Retail
GROUP BY
    DATEPART(HOUR, InvoiceDate)
ORDER BY
    HourOfDay;
--Transaction Peaked at 12Noon. It rises slowly from 6am to 12noon before going down in trend.

-- WEEKDAY TRANSACTION COUNT
SELECT
    DATEPART(WEEKDAY, InvoiceDate) AS WEEKDAY,
    COUNT(DISTINCT InvoiceNo) AS TransactionCount
FROM
    Online_Retail
GROUP BY
    DATEPART(WEEKDAY, InvoiceDate)
ORDER BY
    WEEKDAY
--Friday has the highest Transactions. Transaction rises steadily from Monday to Friday before going down in trend on Saturday.

--==============================================================================
-- REVENUE ANALYSIS
--==============================================================================
-- MONTHLY REVENUE
--==============================================================================
 SELECT
    DATEPART(YEAR, InvoiceDate) AS Year,
    DATEPART(MONTH, InvoiceDate) AS Month,
    SUM(TotalSales) AS Monthly_REVENUE
FROM
    Online_Retail
GROUP BY
    DATEPART(YEAR, InvoiceDate),
    DATEPART(MONTH, InvoiceDate)
ORDER BY
    Year, Month;

-- MONTHLY REVENUE GROWTH
WITH MonthlySales AS (
    SELECT
        DATEPART(YEAR, InvoiceDate) AS Year,
        DATEPART(MONTH, InvoiceDate) AS Month,
        SUM(TotalSales) AS MonthlyRevenue
    FROM
        Online_Retail
    GROUP BY
        DATEPART(YEAR, InvoiceDate),
        DATEPART(MONTH, InvoiceDate)
)

SELECT
    Year,
    Month,
    MonthlyRevenue,
    LAG(MonthlyRevenue) OVER (ORDER BY Year, Month) AS PreviousMonthSales,
    (MonthlyRevenue - LAG(MonthlyRevenue) OVER (ORDER BY Year, Month)) / NULLIF(LAG(MonthlyRevenue) OVER (ORDER BY Year, Month), 0) 
	AS MonthlyGrowth
FROM
    MonthlySales
ORDER BY
    Year, Month;

SELECT * FROM Online_Retail
where DATEPART(YEAR, InvoiceDate) = 2011 AND DATEPART(MONTH, InvoiceDate) = 12
ORDER BY DATEPART(DAY, InvoiceDate) DESC
--December Stops at 9th day, reason why it is that low.

--==============================================================================
-- RFM ANALYSIS
--==============================================================================

SELECT
    CustomerID,
    AVG(UnitPrice) AS AvgUnitPrice,
    COUNT(DISTINCT InvoiceNo) AS TransactionCount,
    SUM(Quantity) AS TotalQuantity,
    AVG(Quantity) AS AvgQuantity,
    AVG(TotalSales) AS AvgTransactionValue,
	SUM(TotalSales) AS Revenue,
    MAX(InvoiceDate) AS LastPurchaseDate,
	MIN(InvoiceDate) AS FirstPurchaseDate,
    DATEDIFF(DAY, MIN(InvoiceDate), MAX(InvoiceDate)) AS DaysSinceFirstPurchase,
	DATEDIFF(DAY, MAX(InvoiceDate), (SELECT MAX(InvoiceDate) FROM Online_Retail)) AS Recency
FROM
    Online_Retail
GROUP BY
    CustomerID;

SELECT
    CustomerID,
    AVG(Quantity) AS AvgQuantity,
    AVG(TotalSales) AS AvgTransactionValue,
    MAX(InvoiceDate) AS LastPurchaseDate,
	COUNT(DISTINCT InvoiceNo) AS Frequency,
	SUM(TotalSales) AS Monetary,
    DATEDIFF(DAY, MAX(InvoiceDate), (SELECT MAX(InvoiceDate) FROM Online_Retail)) AS Recency
FROM
    Online_Retail
GROUP BY
    CustomerID
ORDER BY 
	Recency DESC, MOnetary DESC

WITH rfm AS (
SELECT
    CustomerID,
    AVG(Quantity) AS AvgQuantity,
    AVG(TotalSales) AS AvgTransactionValue,
    MAX(InvoiceDate) AS LastPurchaseDate,
	COUNT(DISTINCT InvoiceNo) AS Frequency,
	SUM(TotalSales) AS Monetary,
    DATEDIFF(DAY, MAX(InvoiceDate), (SELECT MAX(InvoiceDate) FROM Online_Retail)) AS Recency
FROM
    Online_Retail
GROUP BY
    CustomerID
)
SELECT
	r.*,
	NTILE(4) OVER (ORDER BY Recency DESC) AS rfm_Recency,
	NTILE(4) OVER (ORDER BY Frequency) AS rfm_Frequency,
	NTILE(4) OVER (ORDER BY Monetary) AS rfm_Monetary
FROM rfm AS r

WITH rfm AS (
SELECT
    CustomerID,
    MAX(InvoiceDate) AS LastPurchaseDate,
	COUNT(DISTINCT InvoiceNo) AS Frequency,
	SUM(TotalSales) AS Monetary,
    DATEDIFF(DAY, MAX(InvoiceDate), (SELECT MAX(InvoiceDate) FROM Online_Retail)) AS Recency
FROM
    Online_Retail
GROUP BY
    CustomerID
),
rfm_calc AS
(SELECT
	r.*,
	NTILE(4) OVER (ORDER BY Recency DESC) AS rfm_Recency,
	NTILE(4) OVER (ORDER BY Frequency) AS rfm_Frequency,
	NTILE(4) OVER (ORDER BY Monetary) AS rfm_Monetary
FROM rfm AS r
)
SELECT c.*,
	rfm_Recency + rfm_Frequency + rfm_Monetary AS rfm_cell,
	CONCAT(rfm_Recency, rfm_Frequency, rfm_Monetary) AS rfm_cell_string
FROM rfm_calc AS c

-- Create the temporary table
CREATE TABLE #RFM (
    CustomerID varchar(255),
    LastPurchaseDate datetime,
    Frequency int,
    Monetary DECIMAL(10,2),
    Recency int,
    rfm_Recency int,
    rfm_Frequency int,
    rfm_Monetary int,
    rfm_cell int,
    rfm_cell_string varchar(255)
);

-- Insert data into the temporary table
WITH rfm AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS LastPurchaseDate,
        COUNT(DISTINCT InvoiceNo) AS Frequency,
        SUM(TotalSales) AS Monetary,
        DATEDIFF(DAY, MAX(InvoiceDate), (SELECT MAX(InvoiceDate) FROM Online_Retail)) AS Recency
    FROM
        Online_Retail
    GROUP BY
        CustomerID
),
rfm_calc AS (
    SELECT
        r.*,
        NTILE(4) OVER (ORDER BY Recency DESC) AS rfm_Recency,
        NTILE(4) OVER (ORDER BY Frequency) AS rfm_Frequency,
        NTILE(4) OVER (ORDER BY Monetary) AS rfm_Monetary
    FROM rfm AS r
)
INSERT INTO #RFM
SELECT
    c.*,
    rfm_Recency + rfm_Frequency + rfm_Monetary AS rfm_cell,
    CONCAT(rfm_Recency, rfm_Frequency, rfm_Monetary) AS rfm_cell_string
FROM rfm_calc AS c;

select * from #RFM

select distinct rfm_cell_string from #rfm
order by rfm_cell_string

select distinct rfm_cell from #rfm
order by rfm_cell
	
SELECT 
	CustomerID, 
	rfm_Recency,
	rfm_Frequency, 
	rfm_Monetary, 
	rfm_cell_string, 
	rfm_cell,
	CASE
		WHEN rfm_cell_string IN (444,434,344,443) THEN 'Champions'
		WHEN rfm_cell_string IN (414,413,314,313,412,411,312,311,321,331) THEN 'New Customer'
		WHEN rfm_cell_string IN (442,432,433, 421, 431, 441,422,423,424) THEN 'Potential Loyalist'
		WHEN rfm_cell_string IN (213, 222, 223, 214, 224, 231, 232, 242, 233, 234, 243, 244) THEN 'Promising Csatomers'
		WHEN rfm_cell_string IN (114, 131, 132, 141, 142, 123, 124, 133, 134, 143, 144,212,221) THEN 'Needs Attention'
		WHEN rfm_cell_string IN (111, 112,113,211,121, 122) THEN 'Lost Customers'
		END rfm_segment
	FROM #RFM
	   			
SELECT
    rfm_segment,
    COUNT(rfm_segment) AS segment_count
FROM
    (
        SELECT
            CustomerID,
            rfm_Recency,
            rfm_Frequency,
            rfm_Monetary,
            rfm_cell_string,
            rfm_cell,
            CASE
				WHEN rfm_cell_string IN (444,434,344,443) THEN 'Champions'
				WHEN rfm_cell_string IN (414,413,314,313,412,411,312,311,321,331) THEN 'New Customer'
				WHEN rfm_cell_string IN (442,432,433, 421, 431, 441,422,423,424) THEN 'Potential Loyalist'
				WHEN rfm_cell_string IN (213, 222, 223, 214, 224, 231, 232, 242, 233, 234, 243, 244) THEN 'Promising Csatomers'
				WHEN rfm_cell_string IN (114, 131, 132, 141, 142, 123, 124, 133, 134, 143, 144,212,221) THEN 'Needs Attention'
				WHEN rfm_cell_string IN (111, 112,113,121, 122,211) THEN 'Lost Customers'
				END rfm_segment
     FROM
          #RFM
    ) AS SEGMENTS
GROUP BY
    rfm_segment;

--Calculating the Average Recency, Frequency and Monetary Value for various rfm segments to validate it

SELECT
    rfm_segment,
    AVG(Monetary) AS avg_sales,
	AVG(Frequency) AS avg_frequency,
	AVG(Recency) AS avg_recency
FROM
    (
        SELECT
            CustomerID,
			Monetary,
			Recency,
			Frequency,
            rfm_Recency,
            rfm_Frequency,
            rfm_Monetary,
            rfm_cell_string,
            rfm_cell,
            CASE
				WHEN rfm_cell_string IN (444,434,344,443) THEN 'Champions'
				WHEN rfm_cell_string IN (414,413,314,313,412,411,312,311,321,331) THEN 'New Customer'
				WHEN rfm_cell_string IN (442,432,433, 421, 431, 441,422,423,424) THEN 'Potential Loyalist'
				WHEN rfm_cell_string IN (213, 222, 223, 214, 224, 231, 232, 242, 233, 234, 243, 244) THEN 'Promising Csatomers'
				WHEN rfm_cell_string IN (114, 131, 132, 141, 142, 123, 124, 133, 134, 143, 144,212,221) THEN 'Needs Attention'
				WHEN rfm_cell_string IN (111, 112,113,121, 122,211) THEN 'Lost Customers'
				END rfm_segment
     FROM
          #RFM
    ) AS SEGMENTS
WHERE
    rfm_segment IN ('Champions', 'New Customer', 'Potential Loyalist', 'Promising Csatomers', 'Needs Attention', 'Lost Customers')
GROUP BY
    rfm_segment;

--It can be seen that Champions have the highest average sales amd frequency compared to others


--==============================================================================
--Calculating Other Expenses and Revenue From Other Sources
--==============================================================================
SELECT StockCode, Description, SUM(TotalSales) AS "OTHER REVENUE/EXPENSES"
FROM Shopping
WHERE StockCode IN ('B','S','POST','M','DOT','D','CRUK','C2','BANK CHARGES', 'AMAZONFEE') AND Description IS NOT NULL 
GROUP BY StockCode, Description
ORDER BY "OTHER REVENUE/EXPENSES"

SELECT SUM(TotalSales) AS "OTHER REVENUE/EXPENSES"
FROM Shopping
WHERE StockCode IN ('B','S','POST','M','DOT','D','CRUK','C2','BANK CHARGES', 'AMAZONFEE') AND Description IS NOT NULL 

SELECT SUM(TotalSales) AS "OTHER EXPENSES"
FROM Shopping
WHERE StockCode IN ('AMAZONFEE','S','M','D','CRUK','B','BANK CHARGES') AND Description IS NOT NULL

SELECT SUM(TotalSales) AS "OTHER REVENUE"
FROM Shopping
WHERE StockCode IN ('POST','DOT','C2') AND Description IS NOT NULL

SELECT SUM(TotalSales) AS "REVENUE FROM GIFTCARD"
FROM Shopping
WHERE StockCode LIKE '%gift%'


