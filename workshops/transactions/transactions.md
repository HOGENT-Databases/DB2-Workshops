# Tranactions - Isolation Levels
Isolation levels determine the behavior of concurrent users who read or write data. A reader is any statement that selects data, using a shared lock by default. A writer is any statement that makes a modification to a table and requires an exclusive lock. **You cannot control the way writers behave in terms of the locks that they acquire and the duration of the locks, but you can control the way readers behave.** Also, as a result of controlling the behavior of readers, you can have an **implicit influence on the behavior of writers.** You do so by setting the isolation level, either at the session level with a session option or at the query level with a table hint. 


## Prerequisties
Execute the following batches to setup the test environment.
### Create a new database
```sql
USE MASTER;
SET NOCOUNT ON;
CREATE DATABASE [Transactions_Db];
```

### Create a new test table with dummy data
```sql
USE [Transactions_Db];
SET NOCOUNT ON;
GO
-- Create Test Table
CREATE TABLE TestIsolationLevels (
EmpID INT NOT NULL,
EmpName VARCHAR(100),
EmpSalary MONEY,
CONSTRAINT pk_EmpID PRIMARY KEY(EmpID) )
GO
-- Insert Test Data
INSERT INTO TestIsolationLevels 
VALUES 
(2322, 'Dave Smith', 35000),
(2900, 'John West', 22000),
(2219, 'Melinda Carlisle', 40000),
(2950, 'Adam Johns', 18000) 
GO
```

## Levels
SQL Server supports four traditional isolation levels that are based on pessimistic concurrency control (locking): 
1. Read Uncommitted
2. Read Committed (the default in on-premises SQL Server instances)
3. Repeatable Read
4. Serializable

### READ UNCOMMITTED
Is the **least** restrictive isolation level because it **ignores locks placed by other transactions**. Transactions executing under `READ UNCOMMITTED` can read modified data values that have not yet been committed by other transactions; these are called "dirty" reads.

#### Session 1
Create a new Query Window in SSMS **CTRL+N**, afterwards execute the following code in this query window, let's call it **Session 1**. Make sure to look at the messages tab in SSMS.
```sql
BEGIN TRANSACTION
DECLARE @startMessage varchar(200) = 'Transaction started at ' + CONVERT(varchar, SYSDATETIME(), 121)
RAISERROR(@startMessage,0,0) WITH NOWAIT

UPDATE  dbo.TestIsolationLevels 
SET     EmpSalary = 25000
WHERE   EmpID = 2900

RAISERROR('Update happend, waiting 20 seconds to ROLLBACK',0,0) WITH NOWAIT
WAITFOR DELAY '00:00:20'
ROLLBACK;
DECLARE @endMessage varchar(200) = 'Rollback happend at ' + CONVERT(varchar, SYSDATETIME(), 121)
RAISERROR(@endMessage,0,0) WITH NOWAIT
```
> The previous code starts a transaction, updates the `EmpSalary` to `25.000`, waits for 20 seconds to simulate a long statement and after 20 seconds, the transaction is `rolledback`. Within those 20 seconds of waiting make sure to trigger the following piece of code for **Session 2**. If you waited too long you can execute **Session 1** again.

#### Session 2
Create another Query Window in SSMS **CTRL+N**, afterwards execute the following code in this query window, let's call it Session 1.
Execute the following code in another query window, let's call it **Session 2**.
```sql
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
DECLARE @startMessage varchar(200) = 'Select requested at ' + CONVERT(varchar, SYSDATETIME(), 121)
RAISERROR(@startMessage,0,0) WITH NOWAIT

SELECT EmpID, EmpName, EmpSalary
FROM dbo.TestIsolationLevels
WHERE EmpID = 2900
DECLARE @endMessage varchar(200) = 'Select completed at ' + CONVERT(varchar, SYSDATETIME(), 121)
RAISERROR(@endMessage,0,0) WITH NOWAIT
```

> **Result**
> 1. **Session 1** tried to update the salary;
> 2. During the update of **Session 1**, **Session 2** read the data after it was updated by **Session 1**, however the transaction of **Session 2** was not committed yet.
> 3. **Session 1** did a rollback of it's changes, so basically the update did not happend but **Session 1** is already using the updated values.

### READ COMMITTED
Is the default isolation level for SQL Server. It **prevents dirty reads** by specifying that statements **cannot** read data values that **have been modified but not yet committed by other transactions**. Other transactions can still modify, insert, or delete data between executions of individual statements within the current transaction, resulting in non-repeatable reads, or "phantom" data.

#### Session 1
```sql
BEGIN TRANSACTION
DECLARE @startMessage varchar(200) = 'Transaction started at ' + CONVERT(varchar, SYSDATETIME(), 121)
RAISERROR(@startMessage,0,0) WITH NOWAIT

UPDATE  dbo.TestIsolationLevels 
SET     EmpSalary = 25000
WHERE   EmpID = 2900

RAISERROR('Update happend, waiting 20 seconds to ROLLBACK',0,0) WITH NOWAIT
WAITFOR DELAY '00:00:20'
ROLLBACK;
DECLARE @endMessage varchar(200) = 'Rollback happend at ' + CONVERT(varchar, SYSDATETIME(), 121)
RAISERROR(@endMessage,0,0) WITH NOWAIT
```
> The previous code starts a transaction, updates the `EmpSalary` to `25.000`, waits for 20 seconds to simulate a long statement and after 20 seconds, the transaction is `rolledback`. Within those 20 seconds of waiting make sure to trigger the following piece of code for **Session 2**. If you waited too long you can execute **Session 1** again.

#### Session 2
You'll notice that the query does not complete since it's waiting on an action(`COMMIT` or `ROLLBACK`) from **Session 1**, after 20 seconds the query is completed since **Session 1** did a `ROLLBACK` of the transaction.
```sql
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
DECLARE @startMessage varchar(200) = 'Select requested at ' + CONVERT(varchar, SYSDATETIME(), 121)
RAISERROR(@startMessage,0,0) WITH NOWAIT

SELECT EmpID, EmpName, EmpSalary
FROM dbo.TestIsolationLevels
WHERE EmpID = 2900

DECLARE @endMessage varchar(200) = 'Select completed at ' + CONVERT(varchar, SYSDATETIME(), 121)
RAISERROR(@endMessage,0,0) WITH NOWAIT
```


> **Result** 
> 1. **Session 1** tried to update the salary;
> 2. During the update of **Session 1**, **Session 2** tried reading the data after it was updated by **Session 1**, however the transaction of **Session 2** was not committed yet. Therefore **Session 2** is waiting on an action(`ROLLBACK` or `COMMIT`) from **Session 1**.
> 3. **Session 1** did a rollback of it's changes, so basically the update did not happend. Suddenly **Session 1** can read the values. 

#### Issues
The issue with a `COMMITED READ` is that other transactions can still mutate the data outside of the first transaction. For example:
1. Session 1 reads data;
2. Session 1 does some other actions on other data (in the example below simulated with the `WAITFOR` 10 seconds statement);
3. Session 2 updates the same data as Session 1 just read and commits;
4. Session 1 reads the same data again after 10 seconds.
5. The data will no longer be the same.

The code that visualizes this behavior is the following:

##### Session 1
```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
SET NOCOUNT ON
GO
BEGIN TRAN
SELECT  EmpID, EmpName, EmpSalary
FROM    dbo.TestIsolationLevels 
WHERE   EmpID = 2900
WAITFOR DELAY '00:00:10' -- Do some other actions.
SELECT  EmpID, EmpName, EmpSalary
FROM    dbo.TestIsolationLevels 
WHERE   EmpID = 2900
COMMIT
```

##### Session 2
```sql
BEGIN TRANSACTION
UPDATE  dbo.TestIsolationLevels 
SET     EmpSalary = 25000
WHERE   EmpID = 2900
COMMIT
```

### REPEATABLE READ
Is a more restrictive isolation level than `READ COMMITTED`. It basically is a `READ COMMITTED` but additionally specifies that **no other transactions can modify or delete data that has been read by the current transaction until the current transaction commits**. Concurrency is lower than for `READ COMMITTED` because shared locks on read data are held for the duration of the transaction instead of being released at the end of each statement.

#### Session 1
```sql
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
SET NOCOUNT ON
GO
BEGIN TRANSACTION
SELECT  EmpID, EmpName, EmpSalary
FROM    dbo.TestIsolationLevels 
WHERE   EmpID = 2900
WAITFOR DELAY '00:00:10' -- Do some other actions.
SELECT  EmpID, EmpName, EmpSalary
FROM    dbo.TestIsolationLevels 
WHERE   EmpID = 2900
COMMIT
```

#### Session 2
You'll notice that **Session 2** (Update) is waiting on the **Session 1**(SELECT), and that the SELECT transaction yields the correct data if the transaction consistency as a whole is considered.
```sql
BEGIN TRANSACTION
UPDATE  dbo.TestIsolationLevels
SET     EmpSalary = 25000
WHERE   EmpID = 2900
COMMIT
```

#### Issues
Interestingly though, this still doesn't hold true for phantom rows - it's possible to insert rows into a table and have the rows returned by a calling SELECT transaction even under the REPEATABLE READ isolation level. The code that visualizes this behavior is the following:

##### Session 1
```sql
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
SET NOCOUNT ON
GO
BEGIN TRANSACTION
SELECT  EmpName
FROM    dbo.TestIsolationLevels 
WAITFOR DELAY '00:00:10'
SELECT  EmpName
FROM    dbo.TestIsolationLevels 
COMMIT
```
##### Session 2
```sql
BEGIN TRANSACTION
INSERT INTO dbo.TestIsolationLevels VALUES (3427, 'Phantom Employee 1', 30000)
COMMIT
```


### SERIALIZABLE
Is the **most restrictive** isolation level, because it locks entire ranges of keys and holds the locks until the transaction is complete. Basically it's the same as `REPEATABLE READ` but adds the restriction that **other transactions cannot insert new rows into ranges that have been read by the transaction until the transaction is complete**.

SERIALIZABLE has all the features of `READ COMMITTED`, `REPEATABLE READ` but also ensures concurrent transactions are treated as if they had been run in **serial**. This means **guaranteed repeatable reads, and no phantom rows**. Be warned, however, that this (and to some extent, the previous two isolation levels) **can cause large performance losses** as concurrent transactions are effectively queued. Here's the phantom rows example used in the previous section again but this time using the SERIALIZABLE isolation level:

#### Session 1
```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
SET NOCOUNT ON
GO
BEGIN TRANSACTION
SELECT  EmpName
FROM    dbo.TestIsolationLevels 
WAITFOR DELAY '00:00:10'
SELECT  EmpName
FROM    dbo.TestIsolationLevels 
COMMIT
```

#### Session 2
```sql
BEGIN TRANSACTION
INSERT INTO dbo.TestIsolationLevels VALUES (3427, 'Phantom Employee 1', 30000)
COMMIT
```

## Further Reading
 - [Microsoft SQL Tips](https://www.mssqltips.com/sqlservertip/2977/demonstrations-of-transaction-isolation-levels-in-sql-server/)
 - [Transaction Locking and Row Versioning Guide](https://docs.microsoft.com/en-us/sql/relational-databases/sql-server-transaction-locking-and-row-versioning-guide?view=sql-server-2017)












