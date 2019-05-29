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
    