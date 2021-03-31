# Solutions - Cursors
## Exercise 1

```sql
ALTER PROCEDURE DeleteOrdersFromSupplier2 
    @supplierid INT,
    @nrdeletedorders INT OUTPUT,
    @nrdeleteddetails INT OUTPUT
AS
SET NOCOUNT ON
DECLARE orderscursor CURSOR FOR 
    SELECT DISTINCT OrderID
    FROM OrdersDetail 
    JOIN Product on OrdersDetail.ProductID = Product.ProductID
    WHERE SupplierID = @supplierid
FOR UPDATE -- Deep Dive #1

DECLARE @orderid INT
SET @nrdeletedorders = 0
SET @nrdeleteddetails = 0

OPEN orderscursor
FETCH NEXT FROM orderscursor INTO @orderid

WHILE @@FETCH_STATUS = 0
BEGIN
    -- First delete the orderdetails to get rid of the FK constaint.
    DELETE FROM OrdersDetail WHERE OrderID = @orderid
    SET @nrdeleteddetails += @@ROWCOUNT

    -- Delete the orders
    DELETE FROM Orders WHERE OrderID = @orderid
    SET @nrdeletedorders += 1

    -- Read the next record
    FETCH NEXT FROM orderscursor INTO @orderid
END

CLOSE orderscursor -- Deep Dive #2
DEALLOCATE orderscursor
```

## Exercise 2
### Creating the back-up stored procedure
```sql
CREATE PROCEDURE usp_backupNonSystemDatabases 
-- Variables
 @amountOfBackups INT = 0 OUTPUT
AS
DECLARE 
 @databaseName VARCHAR(50) -- database name used in the cursor
,@directoryPath VARCHAR(256) = 'C:/temp/'   -- path for backup files  
,@filePath VARCHAR(256) -- filename for backup  
,@fileDate VARCHAR(20) = FORMAT(GETDATE(), 'yyyyMMdd') -- used for file name
 
DECLARE db_cursor CURSOR READ_ONLY FOR  
    SELECT [Name]
    FROM master.sys.databases -- exclude system databases
    WHERE [Name] NOT IN ('master','model','msdb','tempdb')  
      AND [State] = 0 -- database is online (Deep Dive 2.)
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @databaseName   
 
WHILE @@FETCH_STATUS = 0   
BEGIN   
   SET @filePath = CONCAT(@directoryPath,@fileDate,'_',@databaseName,'.bak');
   BACKUP DATABASE @databaseName TO DISK = @filePath  
   SET @amountOfBackups += 1;
   FETCH NEXT FROM db_cursor INTO @databaseName   
END   

CLOSE db_cursor   
DEALLOCATE db_cursor
```

### Executing the stored procedure
```sql
-- Arrange
DECLARE 
 @amountOfBackedUpDatabases INT = 0 -- if you don't initialize... NULL
,@returnValue INT;
-- Act
EXECUTE @returnValue = usp_backupNonSystemDatabases @amountOfBackedUpDatabases OUTPUT;
-- Print
PRINT FORMATMESSAGE('usp_backupNonSystemDatabases returned status code: %i and took %i backups.'
,@returnValue
,@amountOfBackedUpDatabases)
```

## Exercise 3
### Creating a wrapping stored procedure
You don't have to re-use the existing stored procedure, but there would be some duplicate code. 
```sql
CREATE PROCEDURE usp_backupNonSystemDatabases2
-- Variables
 @databaseName VARCHAR(50) = NULL
,@amountOfBackups INT = 0 OUTPUT
AS

DECLARE 
 @directoryPath VARCHAR(256) = 'C:/temp/'
,@fileDate VARCHAR(20) = FORMAT(GETDATE(), 'yyyyMMdd') -- used for file name
,@filePath VARCHAR(256);

SET @filePath = CONCAT(@directoryPath,@fileDate,'_',@databaseName,'.bak');

IF @databaseName IS NULL -- Watch out here, `IS NULL` is not equal to `= NULL` 
BEGIN
    PRINT 'Backing up all non-system databases, databasename was not specified.';
    EXECUTE usp_backupNonSystemDatabases @amountOfBackups OUTPUT 
    RETURN 0;
END

IF NOT EXISTS (SELECT NULL FROM master.dbo.sysdatabases WHERE ([Name] = @databaseName))
BEGIN
    PRINT FORMATMESSAGE('Could not back-up database: %s, the database does not exist.',@databaseName);
    RETURN -1
END

PRINT FORMATMESSAGE('Backing up database: %s',@databaseName);
BACKUP DATABASE @databaseName TO DISK = @filePath  
SET @amountOfBackups = 1;
PRINT FORMATMESSAGE('Backed up database: %s',@databaseName);
```

### Executing the stored procedure
#### For a specific database
```sql
DECLARE 
 @amountOfBackedUpDatabases INT = 0
,@returnValue INT
-- Act
EXECUTE @returnValue = usp_backupNonSystemDatabases2 'xtreme', @amountOfBackedUpDatabases OUTPUT;
-- Print
PRINT FORMATMESSAGE('usp_backupNonSystemDatabases2 returned status code: %i and took %i backups.'
,@returnValue
,@amountOfBackedUpDatabases)
```
> Notice `xtreme` here.
#### For all databases
```sql
DECLARE 
 @amountOfBackedUpDatabases INT = 0
,@returnValue INT
-- Act
EXECUTE @returnValue = usp_backupNonSystemDatabases2 NULL, @amountOfBackedUpDatabases OUTPUT;
-- Print
PRINT FORMATMESSAGE('usp_backupNonSystemDatabases2 returned status code: %i and took %i backups.'
,@returnValue
,@amountOfBackedUpDatabases)
```
> Notice `NULL` here.


## Exercises
Click [here](../cursors.md) to go back to the exercises.