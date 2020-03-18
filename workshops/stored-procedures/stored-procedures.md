# Workshop - Stored Procedures
In this workshop you'll learn how to create and use a Stored Procedure to reuse pieces of code.

## Prerequisites
- SQL Server 2017+ Installed;
- **S**QL **S**erver **M**anagement **S**tudio Installed;
- A running copy of the database **xtreme**.
    > You can download the database by using [this link](https://github.com/HOGENT-Databases/DB2-Workshops/raw/master/databases/xtreme.bak), information on how to restore a database can be found [here](https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/restore-a-database-backup-using-ssms?view=sql-server-ver15).

---

## Exercise 1
Lately a lot of our `suppliers` are going bankrupt, therefore we'd like to delete all `OrderDetails` which contains a `product` of a given `supplier`. But only for `Orders` placed by `customers` after `2018-04-01`. Finally we would still like to inform the `Customers` that the delivery of the particular product cannot occur. Therefore we need the following information:
- The name of the customer
- The title, first- and lastname of the contact person of the customer

### Call to action
- Create a new stored procedure called `DeleteOrderDetailsForBankruptSupplier` which deletes all `OrderDetails` that contain a `product` of a given supplier, given the `SupplierId`. Before deleting the rows, show a resultset with the impacted customers.
- If the stored procedure already exists, change or delete it first.
- Show the impacted customers in a resultset, simply query the impacted customers before the delete step in the stored procedure.
- Return the number of deleted `OrderDetails` as an output parameter. 

### Execution
Make sure the following code can be executed:
```sql
BEGIN TRANSACTION -- So we can rollback the changes later.
-- Arrange
DECLARE @supplierid INT,
        @amountOfDeletedDetails INT

-- Act
EXECUTE DeleteOrderDetailsForBankruptSupplier 6, @amountOfDeletedDetails OUTPUT
-- Print
PRINT CONCAT('Deleted: ',@amountOfDeletedDetails,' of OrderDetail rows, the impacted customers can be seen in the resultset.') 
ROLLBACK -- Don't change anything so we can keep running the stored procedure.
```

### Results
The result should be the following resultset:
|CustomerName       |ContactTitle|ContactFirstName|ContactLastName|
|-------------------|------------|----------------|---------------|
|City Cyclists      |Mr.         |Chris           |Christianson   |
|Cycles and Sports  |Mr.         |Zachary         |Barbera        |
|Magazzini          |Mr.         |Giovanni        |Rovelli        |
|Warsaw Sports, Inc.|Mr.         |Pavel           |Ropoleski      |

The print statement should output:
> Deleted: 4 of OrderDetail rows, the impacted customers can be seen in the resultset.

### Tips
1. Ask yourself what the use case of this exercise is, first complete the use case and afterwards wrap it inside a stored procedure.
2. Look at the data/tables which are needed for the use case.
3. Write out the code that is needed to complete the use case.
4. Wrap the use case inside a stored procedure

### Deep Dive
1. What is the difference between a `Stored Procedure` and a `User Defined Function`?
2. Is it possible to mutate data inside a function?
3. Can you `EXECUTE`/`EXEC` a `Stored Procedure` inside a `Function`?

### Solution
A possible solution of exercise 1 can be found [here](solutions/stored-procedures.md/#exercise-1)

---

## Exercise 2
We'd like to clean-up the `product` table since a lot of `products` are no longer present in our inventory. However... we have to make sure we don't delete `products` if they're already `purchased` or `ordered` for historical reasons.

### Call to action
- Read the [Deep Dive](#Deep-Dive-Exception-Handling)
- Create a stored procedure called `DeleteProduct1` for deleting a product. You can only delete a product if
    - The `product` exists
    - There are no `purchases` for the `product`
    - There are no `orders` for the `product`
    - Check these conditions before deleting the product, so you don’t rely on SQL Server messages. Generate an appropriate error message if the product can’t be deleted. 
    - Use `RAISERROR` or `THROW`
        - It's better to fail immediatly and show the error when something goes wrong as soon as possible and stop the execution of the stored procedure. (also known as Defensive Programming).
- Create a stored procedure called `DeleteProduct2` (similar to `DeleteProduct1`) for deleting a product. 
You can only delete a product if:
    - The `product` exists
    - There are no `purchases` for the `product`
    - There are no `orders` for the `product`
    - In this version version you try to delete the product and catch the exceptions that might occur **inside** the stored procedure and `PRINT` a message to the console.
- Test your procedures. Give the `SELECT` statements to find appropriate test data. 

### Execution
Make sure the following code can be executed:

```sql
-- Version 1
BEGIN TRANSACTION
EXECUTE deleteproduct1 403000; --Another ID might be needed.
ROLLBACK
-- Version 2
BEGIN TRANSACTION
EXECUTE deleteproduct2 403000; --Another ID might be needed.
ROLLBACK
```

### Tips
- Version 1
    - First check and then `DELETE`, for example:
        ```sql
        IF NOT EXISTS (SELECT NULL FROM Product WHERE ProductID = @productid)
        THROW 50001, 'The product doesn''t exist',1;  
        ```
        > Notice the semicolon at the end, it's MANDATORY.
    - What are the SELECT statements to check if :
        - There are no `purchases` for the `product`
        - There are no `orders` for the `product`
- Version 2
    - Wrap your `DELETE` statement in a `TRY...CATCH` block
    - Check how many rows were mutated by using `@@ROWCOUNT`
    - If the `@@ROWCOUNT` is `0`, something went wrong and you should `THROW` a custom error message.
    - In the `CATCH` block you can check the `ERROR_NUMBER()` for custom error messages or database generated errors for example Foreign Key Constraints.

### Deep Dive Exception Handling
#### The THROW statement
Raises an exception and transfers execution to a `CATCH` block of a `TRY...CATCH` construct, or stops the execution of a stored procedure.

##### Arugments
- `error_number` is a constant or variable that represents the exception. error_number is int and must be greater than or equal to 50000 and less than or equal to 2147483647.
- `message` is an string or variable that describes the exception. message is nvarchar(2048).
- `state` is a constant or variable between 0 and 255 that indicates the state to associate with the message. state is a tinyint. [This post](https://dba.stackexchange.com/questions/35893/what-is-error-state-in-sql-server-and-how-it-can-be-used) explains why you should/could use `state`. 

> More information about the `THROW` statement can be found [here](https://docs.microsoft.com/en-us/sql/t-sql/language-elements/throw-transact-sql?view=sql-server-2017). Another possible statement to handle exceptions is `RAISERROR` but is considered obsolete by Microsoft. More information about the `RAISERROR` statement can be found [here](https://docs.microsoft.com/en-us/sql/t-sql/language-elements/raiserror-transact-sql?view=sql-server-2017).

##### Examples
```sql
THROW 50000, 'The record does not exist.', 1;  
```

```sql
BEGIN TRY
	INSERT INTO Customer (CustomerID, CustomerName)
				VALUES (1,'testing')
END TRY
BEGIN CATCH
	PRINT 'Some error occured...'
	PRINT error_message()
	PRINT error_number()
	PRINT error_procedure()
	PRINT error_line()
	PRINT error_severity()
END CATCH
```

### Solution
A possible solution of exercise 2 can be found [here](solutions/stored-procedures.md/#exercise-2)

---

## Exercise 3
We'd like to have 1 stored procedure to insert new `OrderDetails`, however make sure that:
- the `Order` and `Product` exist;
- the `Order` has not been `Shipped` yet;
- the `UnitPrice` is rather optional, use it when it's given else retrieve the product's price from the `product table`;
- the `Product` is still in `stock`, if it's not return `0` else `1`.


### Call to action
- Create a stored procedure called `SP_Create_OrderDetail` for creating a `OrderDetail`. Make sure all the requirements mentioned above are checked.

### Execution
Make sure the following code can be executed:

```sql
-- Version 1
BEGIN TRANSACTION
EXECUTE SP_Create_OrderDetail [OrderId] [ProductId] [UnitPrice] [Quantity];
ROLLBACK
```
> Note that the variables are just placeholders, fill in where necessary.

### Tips
- Make sure you provide all the necessary parameters (even the optional one);
- Check all the requirements step-by-step if they're not met, `THROW` an exception.

### Solution
A possible solution of exercise 3 can be found [here](solutions/stored-procedures.md/#exercise-3)

---

## Exercise 4
This exercise is closely related to [exercise 1](#exercise-1), but is different in many ways.
Lately a lot of our `suppliers` are going bankrupt, therefore we'd like to delete all `orders` which contains `products` of a given `supplier`.

### Call to action
- Create a new stored procedure called `DeleteOrdersFromSupplier` which deletes all `orders` that contain a `product` of a given supplier.
- If the stored procedure already exists, change or delete it first.
- Return the number of deleted `orders` as an output parameter. 

### Execution
Make sure the following code can be executed, but throws the following error:
> `The DELETE statement conflicted with the REFERENCE constraint "FK_OrdersDetail_Orders". The conflict occurred in database "xtreme", table "dbo.OrdersDetail", column 'OrderID'.`
> 
> A solution to this problem will be covered in the chapters about `Temp. Tables` and `Cursors`.
```sql
BEGIN TRANSACTION
-- Arrange
DECLARE @supplierid int,
        @nrdeletedorders int
SET @supplierid = 7
-- Act
EXECUTE DeleteOrdersFromSupplier 
         @supplierid
        ,@nrdeletedorders OUTPUT
-- Print
PRINT CONCAT(@nrdeletedorders, ' orders were deleted for supplier with id:',@supplierid);

ROLLBACK
```

### Tips
1. Ask yourself what the use case of this exercise is.
2. Look at the data/tables which are needed for the use case
3. Write out the code that is needed to complete the use case.
    - You'll need a subquery to get all the `orders`.
    - Delete the `orders` based on the results from the subquery.
4. Wrap the use case inside a stored procedure

### Deep Dive
1. Why is your code failing? A solution will be provided in chapter about `Cursors` and `Temp. Tables`.

### Solution
A possible solution of exercise 4 can be found [here](solutions/stored-procedures.md/#exercise-4)