USE PortfolioProject;
select * from [dbo].[sales_data_sample]

--CHecking unique values
select distinct status from [dbo].[sales_data_sample] 
select distinct year_id from [dbo].[sales_data_sample]
select distinct PRODUCTLINE from [dbo].[sales_data_sample] 
select distinct COUNTRY from [dbo].[sales_data_sample] 
select distinct DEALSIZE from [dbo].[sales_data_sample] 
select distinct TERRITORY from [dbo].[sales_data_sample] 

--Analysis
--Grouping sales by productline(problem statement-1)
SELECT
  [PRODUCTLINE],
  SUM([SALES]) AS TotalSales
FROM [PortfolioProject].[dbo].[sales_data_sample]
GROUP BY [PRODUCTLINE]
order by 2 desc;

--Grouping sales by years(ps-2)
SELECT
  YEAR([ORDERDATE]) AS SalesYear,
  SUM([SALES]) AS TotalSales
FROM [PortfolioProject].[dbo].[sales_data_sample]
GROUP BY YEAR([ORDERDATE])
order by 2 desc;
--sort by year and month sales
SELECT
  YEAR([ORDERDATE]) AS SalesYear,
  MONTH([ORDERDATE]) AS SalesMonth,
  SUM([SALES]) AS TotalSales
FROM [PortfolioProject].[dbo].[sales_data_sample]
GROUP BY YEAR([ORDERDATE]), MONTH([ORDERDATE])
ORDER BY YEAR([ORDERDATE]), MONTH([ORDERDATE]);

--Grouping sales by dealsize
SELECT
  [DEALSIZE],
  SUM([SALES]) AS TotalSales
FROM [PortfolioProject].[dbo].[sales_data_sample]
GROUP BY [DEALSIZE];

--Best months sales in that particular year and they earning in that month and how many product they sold?(ps-3)
SELECT TOP (1)
  YEAR([ORDERDATE]) AS SalesYear,
  MONTH([ORDERDATE]) AS SalesMonth,
  SUM([SALES]) AS TotalSales,
  SUM([QUANTITYORDERED]) AS TotalQuantity
FROM [PortfolioProject].[dbo].[sales_data_sample]
WHERE YEAR([ORDERDATE]) = 2003 --in 2003 nov is best month in the sales and profit earn
GROUP BY YEAR([ORDERDATE]), MONTH([ORDERDATE])
ORDER BY SUM([SALES]) DESC;

--total prductline sells in the november month with revenue(ps-4)
SELECT
  [PRODUCTLINE],
  SUM([SALES]) AS Revenue
FROM [PortfolioProject].[dbo].[sales_data_sample]
WHERE YEAR([ORDERDATE]) = 2003
  AND MONTH([ORDERDATE]) = 11
GROUP BY [PRODUCTLINE];

--who is best customer for that particular year and month (ps-5)
--we solve by RFM analysis 
--Recency: How recently a customer made a purchase.
--Frequency: How often a customer made purchases.
--Monetary: How much a customer spent on purchases
;WITH rfm AS 
(
    SELECT
        CUSTOMERNAME,
        SUM(sales) AS MonetaryValue,
        AVG(sales) AS AvgMonetarySales,
        COUNT(ORDERNUMBER) AS Frequency,
        MAX(ORDERDATE) AS LastOrderDate,
        DATEDIFF(DAY, MAX(ORDERDATE), (SELECT MAX(ORDERDATE) FROM [dbo].sales_data_sample)) AS Recency
    FROM [PortfolioProject].[dbo].[sales_data_sample]
    GROUP BY CUSTOMERNAME
)
SELECT 
    r.CUSTOMERNAME,
    rfe_recency,
    rfe_frequency,
    rfe_monetary,
    CASE
        WHEN rfe_recency <= 1 AND rfe_frequency <= 1 AND rfe_monetary <= 1 THEN 'New Customer'
        WHEN rfe_recency >= 3 AND rfe_frequency >= 3 AND rfe_monetary >= 3 THEN 'Loyal Customer'
        WHEN rfe_recency >= 3 AND rfe_frequency >= 3 AND rfe_monetary <= 1 THEN 'Active Customer'
        WHEN rfe_recency >= 3 AND rfe_frequency <= 1 AND rfe_monetary >= 3 THEN 'Lost Customer'
        WHEN rfe_recency <= 2 AND rfe_frequency <= 2 AND rfe_monetary >= 3 THEN 'Slipping Away'
        ELSE 'Potential Churners'
    END AS rfm_segment
FROM (
    SELECT 
        CUSTOMERNAME,
        NTILE(4) OVER (ORDER BY Recency DESC) AS rfe_recency,
        NTILE(4) OVER (ORDER BY Frequency DESC) AS rfe_frequency,
        NTILE(4) OVER (ORDER BY AvgMonetarySales DESC) AS rfe_monetary
    FROM rfm
) r;

--what products most often sold and display they particular year and month with category(ps-6)
WITH TopProducts AS (
    SELECT
        s.PRODUCTLINE,
        s.PRODUCTCODE,
        COUNT(*) AS Frequency,
        SUM(s.SALES) AS Revenue,
        MAX(s.MONTH_ID) AS HighestSellingMonth,
        MAX(s.YEAR_ID) AS HighestSellingYear,
        ROW_NUMBER() OVER (PARTITION BY s.PRODUCTLINE ORDER BY COUNT(*) DESC) AS RowNumber
    FROM [PortfolioProject].[dbo].[sales_data_sample] s
    GROUP BY s.PRODUCTLINE, s.PRODUCTCODE
)
SELECT
    tp.PRODUCTLINE AS Category,
    tp.PRODUCTCODE,
    tp.Frequency,
    tp.Revenue,
    tp.HighestSellingMonth,
    tp.HighestSellingYear
FROM TopProducts tp
WHERE tp.RowNumber = 1;

--now exporting the data to tableau for visulization and datastoretelling.. 










