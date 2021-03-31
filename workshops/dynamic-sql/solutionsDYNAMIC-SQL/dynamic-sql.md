# Solutions - Dynamic SQL
## Exercise 1 - using dynamic SQL
```sql
CREATE PROCEDURE USP_CustomerIndex
 @amount INT = 10
,@sortColumn NVARCHAR(MAX) = 'customerid'
,@sortDirection VARCHAR(4) = 'ASC'
AS

-- reject any amount below or equal to zero, since it won't show anything.
IF(@amount <= 0 OR @amount IS NULL)
	THROW 50000, 'Invalid parameter for @amount', 1

-- reject any invalid sort directions:
IF UPPER(@SortDirection) NOT IN ('ASC','DESC')
	THROW 50001, 'Invalid parameter for @SortDirection', 2

-- reject any unexpected column names:
IF LOWER(@SortColumn) NOT IN (N'customerid', N'customername', N'postalcode')
	THROW 50002, 'Invalid parameter for @sortColumn', 3

DECLARE @sql NVARCHAR(MAX) =
FORMATMESSAGE
(
'
	SELECT TOP %i 
	 [CustomerID]
	,[CustomerName]
	,[Address]
	,[PostalCode]
	,[Country]
	,[Email]
	FROM [Customer] 
	ORDER BY
	%s %s
',
 @amount -- is filled in at %i
,@sortColumn -- is filled in for the first %s
,@sortDirection -- is filled in for the second/last %s
)

EXECUTE (@sql) -- Don't forget the brackets, or you'll have a bad time...
```
> This solution works and is pretty safe, but the performance implications cannot be underestimated.
>
> Therefore we'd like to propose an alternative solution which does **not** use dynamic SQL at all, but gives the same flexibility.

## Exercise 1 - Safe and Performant
```sql
CREATE PROCEDURE USP_CustomerIndexPerformant
 @amount INT = 10
,@sortColumn NVARCHAR(128) = 'customerid' -- 128 is the max. column length in MS SQL.
,@sortDirection VARCHAR(4) = 'ASC'
AS

-- We clean-up the parameters to make sure we can compare them later and don't have to bother with lower-/uppercase.
SET @sortColumn = LOWER(@sortColumn);
SET @sortDirection = UPPER(@sortDirection);

-- reject any amount below or equal to zero, since it won't show anything.
IF(@amount <= 0 OR @amount IS NULL)
	THROW 50000, 'Invalid parameter for @amount', 1

-- reject any invalid sort directions
IF(@sortDirection NOT IN ('ASC','DESC'))
	THROW 50001, 'Invalid parameter for @sortDirection', 2

-- reject any unexpected column names
IF(@sortColumn NOT IN (N'customerid', N'customername', N'postalcode'))
	THROW 50002, 'Invalid parameter for @sortColumn', 3

SELECT TOP(@amount) 
 [CustomerID]
,[CustomerName]
,[Address]
,[PostalCode]
,[Country]
,[Email]
FROM [Customer] 
-- If you like you can even add a WHERE clause here, even in the LIKE statement you can use a variable it's safe.
ORDER BY
-- This CASE statement might look cumbersome and fragile, which it is especially for refactoring... 
-- but it's still out-performing the dynamic SQL solution.
CASE WHEN @sortDirection = 'ASC' THEN
	CASE 
		WHEN @sortColumn = 'customername'  THEN CustomerName 
		WHEN @sortColumn = 'postalcode'    THEN PostalCode
		WHEN @sortColumn = 'customerId'    THEN CAST(CustomerID AS NVARCHAR(MAX))
		-- CONVERT | CAST since the datatype of CustomerId is an INTEGER.
	END
END ASC
, CASE WHEN @SortDirection = 'DESC' THEN
	CASE 
		WHEN @sortColumn = 'customername'  THEN CustomerName 
		WHEN @sortColumn = 'postalcode'    THEN PostalCode
		WHEN @sortColumn = 'customerId'    THEN CAST(CustomerID AS NVARCHAR(MAX))
		-- CONVERT | CAST since the datatype of CustomerId is an INTEGER.
	END
END DESC
```


## Exercise 2
```sql
CREATE PROCEDURE SP_ProductClass_By_Country_Amount
AS
DECLARE CountryCursor CURSOR FOR 
(
    SELECT DISTINCT Country
    FROM Product
    JOIN Supplier on Product.SupplierID = Supplier.SupplierID
)

DECLARE @sqlString VARCHAR(4000) = ''
DECLARE @country varchar(100);

SET @sqlString = 'SELECT Product.ProductClassID,'
OPEN CountryCursor
FETCH NEXT FROM CountryCursor into @country

WHILE @@FETCH_STATUS = 0 
BEGIN
    SET @sqlString += 'SUM(CASE WHEN Supplier.Country=''' + @country + ''' THEN 1 ELSE 0 end) AS ' + ''''+@country+''','
    FETCH NEXT FROM CountryCursor into @country
END

DEALLOCATE CountryCursor
SET @sqlString += 'COUNT(Product.ProductId) TOTAL FROM PRODUCT JOIN Supplier on Product.SupplierID = Supplier.SupplierID '
SET @sqlString += 'GROUP BY Product.ProductClassID';
PRINT @sqlString
EXECUTE (@sqlString);
```
    