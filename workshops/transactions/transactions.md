# Transactions - Isolation Levels

## Introduction
Isolation levels determine the behavior of concurrent transactions that read or write data. A reader is any statement that selects data, using a `shared lock` by default. A writer is any statement that makes a modification to a table and requires an `exclusive lock`. **You cannot control the way writers behave in terms of the locks that they acquire and the duration of the locks, but you can control the way readers behave.** As a result of controlling the behavior of readers, you can have an **implicit influence on the behavior of writers.** You do so by setting the `isolation level`, either at the session level with a session option or at the query level with a table hint. 

## Levels
SQL Server supports four traditional isolation levels that are based on pessimistic concurrency control (locking): 
1. [Read Uncommitted](https://github.com/HOGENT-Databases/DB2-Workshops/blob/master/workshops/transactions/transactions.md#read-uncommitted)
2. [Read Committed](https://github.com/HOGENT-Databases/DB2-Workshops/blob/master/workshops/transactions/transactions.md#read-committed) (the default in on-premises SQL Server instances)
3. [Repeatable Read](https://github.com/HOGENT-Databases/DB2-Workshops/blob/master/workshops/transactions/transactions.md#repeatable-read)
4. [Serializable](https://github.com/HOGENT-Databases/DB2-Workshops/blob/master/workshops/transactions/transactions.md#serializable)


## Issues
In situations where different `concurrent transactions` attempt to access the **same** `database object`, some issues can occur. However, we can use different `isolations levels` which control the `locking behavior` to grant or deny access to the `database object`. The following issues can occur:
- Lost update
- Uncommitted dependency (dirty read)
- Inconsistent analysis
- Nonrepeatable read
- Phantom reads

### Lost update
`Lost update` problem occurs if an otherwise successful update of a data item by a transaction is overwritten by another transaction that wasn’t "aware' of the first update.

### Uncommitted dependency (dirty read)
If a transaction reads one or more data items that are being updated by another, as yet uncommitted, transaction, we may run into the `uncommitted dependency` (a.k.a. `dirty read`) problem.

### Inconsistent analysis
Denotes a situation where a transaction reads **partial** results of another transaction that simultaneously interacts with (and possibly updates) the same data items.

### Nonrepeatable read
`Nonrepeatable read` can occur when a transaction T<sub>1</sub> reads the **same row multiple times**, but obtains **different subsequent values**, because **another transaction T<sub>2</sub> updated** this row in the meantime.

### Phantom reads
`Phantom reads` can occur when a transaction T<sub>2</sub> is executing `insert` or `delete` operations on a set of rows that are being read by another transaction T<sub>1</sub>.

### Deadlock


#### Matrix
The following matrix shows the issues that can occur when using different isolation levels.
<table>
    <thead>
        <tr align="center">
            <th align="left">Isolation level</th>
            <th>Lost update</th>
            <th>Uncommitted dependency</th>
            <th>Inconsistent analysis</th>
            <th>Nonrepeatable read</th>
            <th>Phantom read</th>
        </tr>
    </thead>
    <tbody>
        <tr align="center">
            <th align="left">Read uncommitted</th>
            <td>Yes</td>
            <td>Yes</td>
            <td>Yes</td>
            <td>Yes</td>
            <td>Yes</td>
        </tr>
        <tr align="center">
            <th align="left">Read committed</th>
            <td>No</td>
            <td>No</td>
            <td>Yes</td>
            <td>Yes</td>
            <td>Yes</td>
        </tr>
        <tr align="center">
            <th align="left">Repeatable read</th>
            <td>No</td>
            <td>No</td>
            <td>No</td>
            <td>No</td>
            <td>Yes</td>
        </tr>
        <tr align="center">
            <th align="left">Serializable</th>
            <td>No</td>
            <td>No</td>
            <td>No</td>
            <td>No</td>
            <td>No</td>
        </tr>
    </tbody>
</table>


## Prerequisites
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

### READ UNCOMMITTED
Is the **least** restrictive isolation level because it **ignores locks placed by other transactions**. Transactions executing under `READ UNCOMMITTED` can read modified data values that have not yet been committed by other transactions; these are called "dirty" reads.

#### Session 1
Create a new Query Window in SSMS **(CTRL+N)**, afterwards execute the following code in this query window, let's call it **Session 1**. Make sure to look at the messages tab in SSMS.
```sql
BEGIN TRANSACTION
DECLARE @startMessage varchar(200) = 'Transaction started at ' + CONVERT(varchar, SYSDATETIME(), 121)
RAISERROR(@startMessage,0,0) WITH NOWAIT

SELECT 
 EmpName
,EmpSalary
FROM dbo.TestIsolationLevels
WHERE EmpID = 2900;

UPDATE  dbo.TestIsolationLevels 
SET     EmpSalary = 25000
WHERE   EmpID = 2900

RAISERROR('Update happened, waiting 20 seconds to ROLLBACK',0,0) WITH NOWAIT
WAITFOR DELAY '00:00:20'
ROLLBACK;
DECLARE @endMessage varchar(200) = 'Rollback happened at ' + CONVERT(varchar, SYSDATETIME(), 121)
RAISERROR(@endMessage,0,0) WITH NOWAIT
```
> The previous code starts a transaction, updates the `EmpSalary` to `25.000`, waits for 20 seconds to simulate a long statement and after 20 seconds, the transaction is `rolledback`. Within those 20 seconds of waiting, make sure to trigger the following piece of code for **Session 2**. If you waited too long you can execute **Session 1** again.

#### Session 2
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
> 3. **Session 1** did a rollback of it's changes, so basically the update did not happen but **Session 1** is already using the updated values, this is also known as a `dirty read`.

### READ COMMITTED
Is the default isolation level for SQL Server. It **prevents dirty reads and lost updates** by specifying that statements **cannot** read data values that **have been modified but not yet committed by other transactions**. However, the `inconsistent analysis` problem may still occur with this isolation level, as well as `nonrepeatable read`s and `phantom reads`.

#### Session 1
```sql
BEGIN TRANSACTION
DECLARE @startMessage varchar(200) = 'Transaction started at ' + CONVERT(varchar, SYSDATETIME(), 121)
RAISERROR(@startMessage,0,0) WITH NOWAIT

UPDATE  dbo.TestIsolationLevels 
SET     EmpSalary = 25000
WHERE   EmpID = 2900

RAISERROR('Update happened, waiting 20 seconds to ROLLBACK',0,0) WITH NOWAIT
WAITFOR DELAY '00:00:20'
ROLLBACK;
DECLARE @endMessage varchar(200) = 'Rollback happened at ' + CONVERT(varchar, SYSDATETIME(), 121)
RAISERROR(@endMessage,0,0) WITH NOWAIT
```
> The previous code starts a transaction, updates the `EmpSalary` to `25.000`, waits for 20 seconds to simulate a long statement and after 20 seconds, the transaction is `rolledback`. Within those 20 seconds of waiting make sure to trigger the following piece of code for **Session 2**. If you waited too long you can execute **Session 1** again.

#### Session 2
You'll notice that the query does not complete directly since it's waiting on an action(`COMMIT` or `ROLLBACK`) from **Session 1**, after 20 seconds the query is completed since **Session 1** did a `ROLLBACK` of the transaction.
```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION
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
> 2. During the update of **Session 1**, **Session 2** tried reading the data after it was updated by **Session 1**, notice that the transaction of **Session 1** was not committed yet. Therefore **Session 2** is waiting on an action(`ROLLBACK` or `COMMIT`) from **Session 1**.
> 3. **Session 1** did a rollback of it's changes, so basically the update did not happen. Only after **Session 1** completes, **Session 2** can read the values. 

#### Issues
The issue with a `COMMITED READ` is that other transactions can still mutate the data outside of the first transaction. For example:
1. **Session 1** reads data;
2. **Session 1** does some other actions on other data (in the example below simulated with the `WAITFOR` 20 seconds statement);
3. **Session 2** updates the same data as **Session 1** which just reads and commits, there is no mutation going on;
4. **Session 1** reads the same data again after 20 seconds.
5. The data will no longer be the same.

The code that visualizes this behavior is the following:

##### Session 1
```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED 
BEGIN TRANSACTION

RAISERROR('1. Going to select the data.',0,0) WITH NOWAIT
SELECT  EmpID, EmpName, EmpSalary
FROM    dbo.TestIsolationLevels 
WHERE   EmpID = 2900

RAISERROR('2. Selected all my data.',0,0) WITH NOWAIT
RAISERROR('Doing some other stuff for 20 seconds.',0,0) WITH NOWAIT

WAITFOR DELAY '00:00:20' -- Do some other actions.

RAISERROR('3. Going to select the data.',0,0) WITH NOWAIT
SELECT  EmpID, EmpName, EmpSalary
FROM    dbo.TestIsolationLevels 
WHERE   EmpID = 2900
RAISERROR('4. Selected all my data.',0,0) WITH NOWAIT

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
SET     EmpSalary = 26000
WHERE   EmpID = 2900
COMMIT
```

#### Issues
Interestingly though, this still doesn't hold true for `phantom rows` - it's possible to `insert` rows into a table and have the rows returned by a calling SELECT transaction even under the REPEATABLE READ isolation level. The code that visualizes this behavior is the following:

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

SERIALIZABLE has all the features of `READ COMMITTED`, `REPEATABLE READ` but also ensures concurrent transactions are treated as if they had been run in **serial**. This means **guaranteed repeatable reads, and no phantom rows**. Be warned, however, that this (and to some extent, the previous two isolation levels) **can cause large performance losses** as concurrent transactions are effectively queued. Here the phantom rows example used in the previous section again but this time using the SERIALIZABLE isolation level:

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


## Deadlocks

### Session 1
```sql
use xtreme;
-- 1
begin transaction
-- 3
select salary from employee where employeeid=1
-- S-lock on record for employeeid=1 is taken and released 
-- after the select statement (default isolation level = read committed)
-- 5
update employee set salary = salary * 1.1 where employeeid=1
-- X-lock on record for employeeid=1 is taken and held until end of transaction 
-- (write statements are not effected by isolation level)
-- 6
select salary from employee where employeeid=1
-- shows 44.000
RAISERROR('Session 1 - waiting for 5 so Session 2 can start.',0,0) WITH NOWAIT
WAITFOR DELAY '00:00:05'
-- 9
select salary from employee where employeeid=2
-- sessions "hangs", in fact it waits for the X-lock from session 2 on employeeid = 2 to be released
-- after session 2 queries the record from employee 1 a deadlock occurs and this session is chosen as the deadlock victim
-- a rollback is executed automatically and X-lock is released
-- 11
select salary from employee where employeeid=2
-- the session hangs again because session 2 still hasn't committed nor aborted
-- after session 2 commits the new salary for employee 2 is shown

```

### Session 2
```sql
use xtreme;
-- 2
begin transaction
-- 4
select salary from employee where employeeid=2
-- S-lock on record for employeeid=1 is taken and released 
-- after the select statement (default isolation level = read committed)
-- 7
update employee set salary = salary * 1.1 where employeeid=2
-- X-lock on record for employeeid=1 is taken and held until end of transaction 
-- (write statements are not effected by isolation level)
-- 8
select salary from employee where employeeid=2
-- 10
select salary from employee where employeeid=1
-- session "hangs" for a few seconds continues after session 1 has been killed (or vice versa)
-- due to deadlock detection
-- it shows the "old" value of the salary because session 1 has never committed its update
-- 12
commit
-- the X-lock is released
```

## Further Reading
 - [Microsoft SQL Tips](https://www.mssqltips.com/sqlservertip/2977/demonstrations-of-transaction-isolation-levels-in-sql-server/)
 - [Transaction Locking and Row Versioning Guide](https://docs.microsoft.com/en-us/sql/relational-databases/sql-server-transaction-locking-and-row-versioning-guide?view=sql-server-2017)












