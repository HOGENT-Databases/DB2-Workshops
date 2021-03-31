-- Exercise 2
-- Create Temp. Table
CREATE TABLE #demo (field1 XML) 

-- Fill the temp. table with XML Data
DECLARE @xmlDoc XML   
SET @xmlDoc = (SELECT ProductName, Price 
               FROM   Product 
               WHERE  ProductTypeID=1   
               FOR XML AUTO, TYPE)   

INSERT INTO #demo(field1)  
SELECT @xmlDoc 

-- Query the temp table
SELECT field1 
FROM #demo 

-- Using XQuery, get all products with prices higher than 1000.
SELECT field1.query('/Product[@Price>1000]') 
FROM #demo 