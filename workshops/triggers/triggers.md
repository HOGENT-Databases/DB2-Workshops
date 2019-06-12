# Workshop - Triggers
In this workshop you'll learn how to create and use a Trigger.

## Prerequisites
- A running copy of database **xtreme**;

## Exercise 1 
In our organisation `Employees` report to other `employees` a.k.a Managers. To make sure certain managers are not supervising too many employees, we'd like to find out which manager supervises **the least** amount of `employees`. Each time a new `employee` starts in our organisation we'll let the new `employee` `ReportTo` the manager with the least of employees reporting to him, a perfect use case for a `trigger`.
# Call to action
- Create a trigger that, when adding a new employee, sets the reportsTo attribute to the employee to whom the least employees already report. Use the **naming conventions** mentioned in Deep Dive.

### Execution
Make sure the following code can be executed and gives the correct output:
```sql
BEGIN TRANSACTION
INSERT INTO Employee(EmployeeID,LastName,FirstName)
       VALUES (100,'New','Emplo');

SELECT 
    EmployeeID,
    LastName,
    FirstName,
    ReportsTo
FROM Employee
WHERE EmployeeID = 100; -- The ReportsTo should be filled in correctly.
ROLLBACK
```

### Tips
1. Find out how to check which employee has the least `reportsTo` count.
    - Don't use the `SuperviserId`
2. Wrap the previous `SELECT` statement in a trigger.
3. Update the **first** inserted record.

### Deep Dive
1. Is it also needed to `EXECUTE` the trigger on a `DELETE` or `UPDATE` statement?
2. What happens if multiple `Employees` are inserted at the same time?
3. Naming conventions for triggers:
    1. Each trigger name should use the syntax  `TR_[TableName]_[ActionName]`.
    2. Each table name and action name should start with a capital letter.
4. Read more about triggers in [this article](https://docs.microsoft.com/en-us/sql/t-sql/statements/create-trigger-transact-sql?view=sql-server-2017), if you want to know more about `naming conventions` [this article](https://www.c-sharpcorner.com/UploadFile/f0b2ed/what-is-naming-convention/) can provide some insight.

### Solution
A possible solution of exercise 1 can be found [here](solutions/triggers-1.sql)

---

## Exercise 2
To keep track of all the modifications done to the `product` table, we want to create a separate table to check who did what at which specific time (also referred as an audit table). To make sure this is persisted in a uniformal way, we're going to use a `trigger`. The trigger should log a new record in the `ProductAudit` table when a mutation of the `product` table has taken place.

### Call to action
- Create a new table called `ProductAudit` with the following columns:
    - Id - Primary Key
        - Identity
    - UserName - nvarchar(128)
        - Default SystemUser
    - CreatedAt - DateTime
        - Default UTC Time
    - Operation - nchar(6)
        - The name of the operation we performed on a row
            - Updated
            - Created
            - Deleted
- If the table is already present, drop it.
- Create a trigger for all actions (Update, Delete, Insert) to persist the mutation of the `product` table.
- Use system functions to populate the `UserName` and `CreatedAt`.

### Execution
Make sure the following code can be executed:

```sql
BEGIN TRANSACTION
DECLARE @productId INT;

SET @productId = 12;
INSERT INTO Product(ProductID, ProductName)
VALUES(@productId, 'New product12')

UPDATE Product
SET productName = 'abc'
WHERE ProductID = @productId

DELETE FROM Product
WHERE ProductID = @productId

SELECT * FROM ProductAudit -- Changes should be seen here.
ROLLBACK
```

### Deep Dive
1. What are some possible issues having a lot of triggers?
2. What is the difference between `GETDATE()` and `GETUTCDATE()`?

### Solution
A possible solution of exercise 2 can be found [here](solutions/triggers-2.sql)

---

## Exercise 3
For this exercise we'll introduce a new (redundant) attribute/column for the `ProductType` table called `AmountOfProducts` (int). The column will keep track of all the `products` that have this specific `ProductType`. Doing so the amount a `ProductType` is linked to `products` does not have to be recalculated each time on a `SELECT` query but should be updated each time a `product` is `mutated`(Deleted, Inserted or Updated). For this overhead we'll use a `trigger` on the `product` table.

> Redundant data is not always a bad idea, it can speed up the performance drastically when done correctly, since you often read data a lot more than you write it. However this can create some additional complexity or overhead in your database, so be cautious when introducing redundant columns. 

### Call to action
- Add a new column to the table `ProductType`:
    - `AmountOfProducts` - int
- Update all the rows of the `ProductType` table to reflect the actual `AmountOfProducts`.
    - Write an update query for this.
- Create a trigger for all actions (Update, Delete, Insert) to reflect the possible mutation of the `product` table, so the `AmountOfProducts` attribute of all the `ProductType` rows are correct.

### Execution
Make sure the following code can be executed:

```sql
BEGIN TRANSACTION
SET NOCOUNT ON
DECLARE @typeName NVARCHAR(MAX);
DECLARE @amount INT;

-- Get initial value
SELECT 
    @typeName = ProductTypeName,
    @amount = AmountOfProducts
FROM ProductType
WHERE ProductTypeID = 1  -- ProductType's AmountOfProducts  should be updated

PRINT FORMATMESSAGE('Initial amount of productType: %s is %d', @typeName, @amount)

-- Adding a new product
PRINT 'Insert of a new product happend.';
INSERT  INTO Product(ProductID, ProductName, ProductTypeID) 
        VALUES(999, 'New product 61',1)

SELECT @amount = AmountOfProducts
FROM ProductType
WHERE ProductTypeID = 1  -- ProductType's AmountOfProducts  should be updated
PRINT FORMATMESSAGE('After insert the amount of productType: %s is %d', @typeName, @amount)

-- Removing a product
DELETE FROM product 
WHERE productId = 999
PRINT 'Delete of a product happend.';

SELECT @amount = AmountOfProducts
FROM ProductType
WHERE ProductTypeID = 1  -- ProductType's AmountOfProducts  should be updated
PRINT FORMATMESSAGE('After delete the amount of productType: %s is %d', @typeName, @amount)

ROLLBACK
```

### Solution
A possible solution of exercise 3 can be found [here](solutions/triggers-3.sql)
