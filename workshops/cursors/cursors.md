# Workshop - Cursors
In this workshop you'll learn how to create and use a Cursor.

## Prerequisites
- A running copy of database **xtreme**;
- Finalized the exercises about stored procedures.

## Exercise 1
In the previous workshop about [stored procedures](/workshops/stored-procedures/stored-procedures.md/#exercise-4), you wrote a stored procedure to delete all orders for a given supplier called `DeleteOrdersFromSupplier`, the output parameter/return value of this stored procedure was the number of deleted orders. However the stored procedure didn't work due to a **foreign key constraint**.

#### Code for the previous exercise

```sql
ALTER PROCEDURE [dbo].[DeleteOrdersFromSupplier] 
  @supplierid int,
  @nrdeletedorders int output
AS
  DELETE FROM orders WHERE orderid in 
  (
   SELECT DISTINCT OrderId
   FROM OrdersDetail 
   JOIN Product ON Product.ProductID=OrdersDetail.ProductId
   WHERE SupplierID = @supplierid
  )
  SET @nrdeletedorders = @@ROWCOUNT
```

#### Test code
```sql
DECLARE @supplier int,@amount int
SET @supplier = 7
EXEC DeleteOrdersFromSupplier @supplier, @amount output
PRINT CONCAT('Deleted: ',@amountOfDeletedDetails,' of OrderDetail rows, the impacted customers can be seen in the resultset.') 
```

### Call to action
- Adjust the stored procedure to delete all `orders` and `orderdetails` for a given `supplierId` using a `cursor`.
- Return the number of deleted `orders` **and** the number of deleted `orderdetails`.

### Execution
Make sure the following code can be executed:

```sql
BEGIN TRANSACTION

DECLARE @amountOfOrdersDeleted INT, 
        @amountOfOrdersDetailsDeleted INT
EXEC DeleteOrdersFromSupplier2 2, @amountOfOrdersDeleted OUTPUT, @amountOfOrdersDetailsDeleted OUTPUT
PRINT FORMATMESSAGE('Amount of deleted orders :%d', @amountOfOrdersDeleted)
PRINT FORMATMESSAGE('Amount of deleted orderdetails :%d', @amountOfOrdersDetailsDeleted)

ROLLBACK;
```

### Tips
- Make sure to declare all the necessary variables:
    - Input;
    - Output;
    - Cursor.
- Make sure to open the cursor;
- Fetch data coming from the `cursor` into the variable(s);
- Use a `loop` while there are still unprocessed records;
    - Delete some records in the loop;
    - Don't forget to increase your `counters` for the output.
    - Read the next record
- Don't forget to `close` and `dealloc` your cursor.

### Deep Dive
1. What happens if someone else is updating the row(s) you're about to delete?
    - Make sure that the selected rows cannot be modified during the execution. 
2. Is a close instruction necessary when you deallocate a cursor?

### Solution
A possible solution of this exercise can be found [here](solutions/cursors.md#exercise-1)

---

## Exercise 2
Sometimes things that seem complicated are much easier then you think and this is the power of using T-SQL to take care of repetitive tasks.  One of these tasks may be the need to backup all databases on your server. This is not a big deal if you have a handful of databases, but I have seen several servers where there are 100+ databases on the same instance of SQL Server. You could use SQL Server Management Studio to backup the databases or even use Maintenance Plans, but using T-SQL is a much simpler and faster approach. In this exercise we'll backup all the databases apart from some [system databases](https://docs.microsoft.com/en-us/sql/relational-databases/databases/system-databases?view=sql-server-ver15):
- The [master]() database records all the system-level information for a SQL Server system. This includes instance-wide metadata such as logon accounts, endpoints, linked servers, and system configuration settings. In SQL Server, system objects are no longer stored in the master database; instead, they are stored in the Resource database. Also, master is the database that records the existence of all other databases and the location of those database files and records the initialization information for SQL Server. Therefore, SQL Server cannot start if the master database is unavailable.
- The [model](https://docs.microsoft.com/en-us/sql/relational-databases/databases/model-database?view=sql-server-ver15) model database is used as the template for all databases created on an instance of SQL Server. Basically when you create a new database, this database is used. Because `tempdb` is created every time SQL Server is started, the model database must always exist on a SQL Server system. 
- The [msdb](https://docs.microsoft.com/en-us/sql/relational-databases/databases/msdb-database?view=sql-server-ver15) msdb database is used by SQL Server Agent for scheduling alerts and jobs and by other features such as SQL Server Management Studio, Service Broker and Database Mail.
- The [tempdb]() system database is a global resource that is available to all users connected to the instance of SQL Server or connected to SQL Database. Tempdb is used to hold temporary user objects that are explicitly created and internal objects that are created by the database engine.

With the use of T-SQL you can generate your backup commands and with the use of cursors you can cursor through all of your databases to back them up one by one.  This is a very straight forward process and you only need a handful of commands to do this. 

### Call to action
- Create a new stored procedure called `usp_backupNonSystemDatabases` which creates a back-up of every non-system database so make sure to exclude (`tempdb`, `master`, `model` and `msdb`). A backup creates a `.bak` file, do this for every database in de `C:\temp` folder, the name of the file should be `yyyyMMdd_[databasename]`, for example `20200318_xtreme.bak`
- If the stored procedure already exists, change or delete it first.
- Return the number of the amount of databases you backed up.

### Execution
This time you'll have to figure out how to call the stored procedure. The output should look something like this:
> usp_backupNonSystemDatabases returned status code: `[statuscode]` and took `[numberofbackups]` backups.

### Tips
- The following query returns all databases on the server, make sure to run it before you start this exercise:
  ```sql
  SELECT [Name] 
  FROM master.sys.databases --Notice the master.sys prefix
  ```
- Make sure to declare all the necessary variables:
    - Output
    - Cursor
- Make sure to `OPEN` the `CURSOR`;
- Fetch data coming from the `CURSOR` into the variable(s).
- Use a `loop` while there are still unprocessed databases;
    - use the following command to backup a database, but make sure to set the variables accordingly:
      ```sql
      BACKUP DATABASE @databaseName TO DISK = @filePath
      ```
    - Don't forget to increase your `counters` for the output.
    - Read the next record
- Don't forget to `CLOSE` and `DEALLOCATE` your cursor.

### Deep Dive
1. Make sure to read-up on the [system databases](https://docs.microsoft.com/en-us/sql/relational-databases/databases/system-databases?view=sql-server-ver15) and why they are used.
2. Make sure only databases that are online are backed-up. Try playing around with the `master.sys.databases` table and it's containing columns and data.

### Solution
A possible solution of this exercise can be found [here](solutions/cursors.md#exercise-2)

---


## Exercise 3
In this exercise you'll add some functionality and more power to the previous stored procedure `usp_backupNonSystemDatabases` from exercise 2. 

### Call to action
- Create a new stored procedure called `usp_backupNonSystemDatabases2`. Which will do the same as `usp_backupNonSystemDatabases` but with additional functionality, add an `INPUT` parameter so you can specify a databasename, if the databasename is specified you will only back-up that particular database and ignore all other databases. Make sure the database exists before trying to back it up and provide a clear error message if the database does not exist when it's provided as parameter (not null), 
- Return -1 as status code if something goes wrong.

### Execution
This time you'll have to figure out how to call the stored procedure. The output should look something like this:
> usp_backupNonSystemDatabases returned status code: `[statuscode]` and took `[numberofbackups]` backups.

 In the case you specified the databasename: 
> usp_backupNonSystemDatabases returned status code: `[statuscode]` and backed-up `[databasename]`.

### Tips
- You can call a stored procedure inside another stored procedure so you can create a so-called `wrapper` around your current code. 
- Don't copy paste code the cursor code.
- Use default values for your parameters.

### Deep Dive
1. Figure out a way to also pass the `directoryPath`, so you can choose where to store all the `.bak` files when calling the stored procedure(s), by default it should be `C:/temp/`

### Solution
A possible solution of this exercise can be found [here](solutions/cursors.md#exercise-3)

