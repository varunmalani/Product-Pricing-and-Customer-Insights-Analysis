-- Performing ETL
SELECT * FROM [dbo].[BigBasketProducts]
ORDER BY [index]

-- Checking if we have any product which has NULL value
SELECT COUNT(*) AS ProductCount FROM [dbo].[BigBasketProducts]
WHERE [product] IS NULL

SELECT COUNT(*) AS CategoryCount FROM [dbo].[BigBasketProducts]
WHERE [category] IS NULL

SELECT COUNT(*) AS SubCategoryCount FROM [dbo].[BigBasketProducts]
WHERE sub_category IS NULL

SELECT COUNT(*) AS BrandCount FROM [dbo].[BigBasketProducts]
WHERE brand IS NULL

SELECT COUNT(*) AS TypeCount FROM [dbo].[BigBasketProducts]
WHERE [type] IS NULL


-- We dont require the index column, hence we can drop that column
ALTER TABLE [dbo].[BigBasketProducts]
DROP COLUMN [index]


-- Looking into which product has blank value, we can ignore the brand count as null as it does not impact the data much
SELECT * FROM [dbo].[BigBasketProducts]
WHERE [product] IS NULL

SELECT * FROM [dbo].[BigBasketProducts]
WHERE sub_category = 'Coffee' and brand = 'Cothas Coffee'

-- Looking into the data we see that as we only have 1 NULL value for product and looking into the description we can find that the product could be called Coffee - Powder, Premium Blended, Chicory
-- We can ignore the NULL value which is present in the brand as it won't affect the data
-- Updating the NULL value
UPDATE [dbo].[BigBasketProducts]
SET [product] = 'Coffee - Powder, Premium Blended, Chicory'
WHERE [product] IS NULL AND sub_category = 'Coffee' AND brand = 'Cothas Coffee'


--We see that we have NULL values in rating, we will be replacing it with the avg rating based on the Product category, sub_category and type
SELECT * FROM [dbo].[BigBasketProducts]
WHERE rating IS NULL

UPDATE BBP
SET BBP.rating = BBPU.AvgRating
FROM [dbo].[BigBasketProducts] BBP
JOIN 
	(
	SELECT category, sub_category, AVG(rating) AS AvgRating
	FROM [dbo].[BigBasketProducts]
	GROUP BY category, sub_category
	) BBPU
ON BBP.category = BBPU.category
AND BBP.sub_category = BBPU.sub_category
WHERE BBP.rating IS NULL;


-- Looking for duplicates
SELECT [product], category, sub_category, brand, type, COUNT(*) AS DuplicateCount FROM [dbo].[BigBasketProducts]
GROUP BY [product], category, sub_category, brand, type
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC

--Duplicate 1
SELECT * FROM [dbo].[BigBasketProducts]
WHERE [product] = 'Colorsilk Hair Colour With Keratin' and category = 'Beauty & Hygiene' AND sub_category = 'Hair Care' AND brand = 'Revlon' AND type = 'Hair Color'

--Duplicate 2
SELECT * FROM [dbo].[BigBasketProducts]
WHERE [product] = 'Casting Creme Gloss Hair Color' and category = 'Beauty & Hygiene' AND sub_category = 'Hair Care' AND brand = 'Loreal Paris' AND type = 'Hair Color'


--Eliminating duplicates with the help of group by
--1. Groupping by categorical columns
--2. Taking the average of numerical columns
SELECT [product], category, sub_category, brand, type, description, count(*) FROM (
	SELECT [product], category, sub_category, brand, AVG(sale_price) AS AvgSalesPrice, AVG(market_price) AS AvgMarketprice, type, AVG(rating) AS AvgRating, description
	FROM [dbo].[BigBasketProducts]
	GROUP BY [product], category, sub_category, brand, type, description 
) clnBigBasketData
GROUP BY [product], category, sub_category, brand, type, description
having count(*) > 1


-- Creating a view so that we can convert 
--1. sale_price -> DECIMAL
--2. market_price -> DECIMAL
--3. rating -> DECIMAL
--4. All categorical columns into NVARCHAR

ALTER VIEW [dbo].[vwBigBasketProducts]
WITH SCHEMABINDING
AS
SELECT 
    CAST([product] AS NVARCHAR(255)) AS [Product Name],
    CAST([category] AS NVARCHAR(255)) AS [Category],
    CAST([sub_category] AS NVARCHAR(255)) AS [Sub Category],
    CAST([brand] AS NVARCHAR(255)) AS [Brand Name],
    CAST(AVG(sale_price) AS DECIMAL(10, 2)) AS [Sale Price],
    CAST(AVG(market_price) AS DECIMAL(10, 2)) AS [Market Price],
    CAST([type] AS NVARCHAR(255)) AS [Type],
    CAST(AVG(rating) AS DECIMAL(10, 2)) AS [Rating],
    CAST([description] AS NVARCHAR(4000)) AS [Description]
FROM 
    [dbo].[BigBasketProducts]
GROUP BY 
    [product], category, sub_category, brand, [type], [description];


-- Looking into the view
SELECT * FROM [dbo].[vwBigBasketProducts]