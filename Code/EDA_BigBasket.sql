SELECT TOP 10 * FROM [dbo].[vwBigBasketProducts]

--What are the top 5 categories by the number of products listed?
SELECT TOP 5 Category, COUNT(DISTINCT [Product Name]) AS CountCategories
FROM [dbo].[vwBigBasketProducts]
GROUP BY Category
ORDER BY COUNT(*) DESC


-- What is the price difference between sale price and market price across brands?
-- Fetching the top 10 discounted brand
SELECT TOP 10 [Brand Name], CAST(AVG([Sale Price] - [Market Price]) AS DECIMAL(10,2)) AS DiscountedPrice
FROM [dbo].[vwBigBasketProducts]
GROUP BY [Brand Name]
ORDER BY 2 ASC
-- From this we can conclude that Lalique is the Brand that has given the most discounts


-- What are the top-rated products by category?
-- Fetching the top 5 rated products by their category
SELECT TOP 5 [Product Name], Category, CAST(AVG(Rating) AS DECIMAL(10,2)) AS DiscountedPrice
FROM [dbo].[vwBigBasketProducts]
GROUP BY [Product Name], Category
ORDER BY 3 DESC


-- Which sub-categories offer the largest discounts?
-- Fetching the top 10 discounted brand
SELECT TOP 10 [Sub Category], CAST(AVG([Sale Price] - [Market Price]) AS DECIMAL(10,2)) AS DiscountedPrice
FROM [dbo].[vwBigBasketProducts]
GROUP BY [Sub Category]
ORDER BY 2 ASC


-- Analyze where the highest sale-to-market price reductions are happening
-- In this we need to calculated the least reducded price between the sale price and market price, so we will look into the category and sub category and fetch the top 5 least discounted products
SELECT TOP 5 Category, [Sub Category], CAST(AVG([Sale Price] - [Market Price]) AS DECIMAL(10,2)) AS DiscountedPrice
FROM [dbo].[vwBigBasketProducts]
GROUP BY Category, [Sub Category]
ORDER BY 3 DESC


-- What are the most common brands across product categories?
SELECT TOP 5 [Brand Name], Category, COUNT(Category) AS CategoryCount
FROM [dbo].[vwBigBasketProducts]
GROUP BY [Brand Name], Category
ORDER BY 3 DESC


-- Determine which brands are dominating in terms of product count
-- Fetching the Top 5 brands with the most number of products
SELECT TOP 5 [Brand Name], COUNT(DISTINCT [Product Name]) AS ProductCount
FROM [dbo].[vwBigBasketProducts]
GROUP BY [Brand Name]
ORDER BY 2 DESC


-- What percentage of products have a rating above 4.0?
SELECT COUNT(*) 
FROM [dbo].[vwBigBasketProducts]

SELECT COUNT(*)
FROM [dbo].[vwBigBasketProducts]
WHERE Rating > 4

SELECT CAST(1.0 * (SELECT COUNT(*) FROM [dbo].[vwBigBasketProducts] WHERE Rating > 4) / (SELECT COUNT(*) FROM [dbo].[vwBigBasketProducts]) AS DECIMAL(4,2)) * 100 AS ProdcutsPercAboveFour


-- What is the correlation between product ratings and price discounts?
-- We are calculating the correlation using the Pearson Correlation
WITH DiscountData AS (
    SELECT 
        Rating,
        ([Market Price] - [Sale Price]) AS Discount
    FROM [dbo].[vwBigBasketProducts]
    WHERE Rating IS NOT NULL 
      AND [Market Price] IS NOT NULL 
      AND [Sale Price] IS NOT NULL
),
Stats AS (
    SELECT
		--Rating,
        AVG(Rating) AS AvgRating,
		--Discount,
		AVG(Discount) AS AvgDiscount
    FROM DiscountData
)
SELECT 
    ( SUM ( (Rating - AvgRating) * (Discount - AvgDiscount) ) )
	/
	SQRT( SUM ( (Rating - AvgRating) * (Rating - AvgRating) ) * SUM ( (Discount - AvgDiscount) * (Discount - AvgDiscount) ) )
	AS CorrelationCoefficient
FROM DiscountData, Stats;
-- So from above we can conclude that we have a weak correlation between Rating and Discount


-- Identify Products with Similar Pricing within the Same Category
-- By similar pricing, we mean that the difference between the Sales Prices should be <= 10
-- Find pairs of Products within the same Category where the sale price difference is within a specified range (e.g., within 10 units). This can reveal similar Products priced close to each other.
SELECT DISTINCT a.[Product Name], b.[Product Name], a.Category, a.[Sale Price], b.[Sale Price]
FROM [dbo].[vwBigBasketProducts] a
INNER JOIN [dbo].[vwBigBasketProducts] b
ON a.[Product Name] <> b.[Product Name]
AND a.Category = b.Category
WHERE (a.[Sale Price] - b.[Sale Price]) <= 10 AND (b.[Sale Price] - a.[Sale Price]) <= 10


-- Find Categories with the Most Price Variation
--Calculate the average sale price for each category, then use this to compare individual products within each category to identify high price variance.
WITH CategoryAvg AS (
	SELECT Category, AVG([Sale Price]) AS AvgSalePrice
	FROM [dbo].[vwBigBasketProducts]
	GROUP BY Category
)
SELECT bbp.[Product Name], bbp.Category, bbp.[Sale Price], ca.AvgSalePrice, ABS(bbp.[Sale Price] - ca.AvgSalePrice) AS PriceVariance
FROM [dbo].[vwBigBasketProducts] bbp
INNER JOIN CategoryAvg ca
ON bbp.Category = ca.Category
ORDER BY PriceVariance DESC
-- From this we can conclude that we have multiple products that have a high variance based on their Average Sales Price by Category (Outliers)


SELECT p1.[Product Name] AS Product1, p2.[Product Name] AS Product2, p1.[Brand Name], p1.rating
FROM [dbo].[vwBigBasketProducts] AS p1
JOIN [dbo].[vwBigBasketProducts] AS p2 
ON p1.[Brand Name] = p2.[Brand Name]
AND p1.rating = p2.rating
AND p1.[Product Name] <> p2.[Product Name];
