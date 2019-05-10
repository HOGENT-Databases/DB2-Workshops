# Workshop - Stored Procedures
In this workshop you'll learn how to create and use a Stored Procedure to reuse pieces of code.

## Prerequisites
- A running copy of database **xtreme**;

---

## Exercise 1
Lately a lot of our `suppliers` are going bankrupt, therefore we'd like to delete all `orders` which contains `products` of a given `supplier`.

### Call to action
- Create a new stored procedure called `DeleteOrdersFromSupplier` which deletes all `orders` that contain a `product` of a given supplier.
- If the stored procedure already exists, change or delete it first.
- Return the number of deleted orders as an output parameter. 

### Execution
Make sure the following code can be executed:
```sql
BEGIN TRANSACTION
-- Arrange
DECLARE @supplierid int,
         @nrdeletedorders int
SET @supplierid = 7
-- ACT
EXECUTE DeleteOrdersFromSupplier 
        @supplierid, @nrdeletedorders OUTPUT
-- PRINT
print 'Amount of orders deleted for supplier ' + ltrim(str(@supplierid)) + ' = ' + ltrim(str(@nrdeletedorders))

ROLLBACK
```
> Chances are that your code will fail to delete the orders, why?
> A solution will be provided in the chapter about `Cursors`.

### Tips
1. Ask yourself what the use case of this exercise is.
2. Look at the data/tables which are needed for the use case
3. Write out the code that is needed to complete the use case.
    - You'll need a subquery to get all the `orders`.
    - Delete the `orders` based on the results from the subquery.
4. Wrap the use case inside a stored procedure

### Deep Dive
1. Why is your code failing? A solution will be provided in chapter about `Cursors`.
1. What is the difference between a `Stored Procedure` and a `User Defined Function`?
2. Is it possible to mutate data inside a function?
3. Can you `EXECUTE`/`EXEC` a `Stored Procedure` inside a `Function`?

### Solution
A possible solution of exercise 1 can be found [here](/solutions/stored-procedures-1.sql)

---

## Exercise 2
We'd like to clean-up the `product` table since a lot of `products` are no longer present in our inventory. However... we have to make sure we don't delete `products` if they're already `purchased` or `ordered` for historical reasons.

### Call to action
- Create a stored procedure called `DeleteProduct1` for deleting a product. You can only delete a product if
    - The `product` exists
    - There are no `purchases` for the `product`
    - There are no `orders` for the `product`
    - Check these conditions before deleting the product, so you don’t rely on SQL Server messages. Generate an appropriate error message if the product can’t be deleted. 
    - Use `RAISERROR` or `THROW` (see Deep Dive further in this document)
        - It's better to fail immediatly and show the error when something goes wrong as soon as possible and stop the execution of the stored procedure. (also known as Defensive Programming).
- Create a stored procedure called `DeleteProduct2` (similar to `DeleteProduct1`) for deleting a product. 
You can only delete a product if:
    - The `product` exists
    - There are no `purchases` for the `product`
    - There are no `orders` for the `product`
    - In this version version you try to delete the product and catch the exeptions that might occur **inside** the stored procedure and `PRINT` a message to the console.
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
    - First check and then `DELETE`
    - What are the SELECT statements to check if :
        - The `product` exists
        - There are no `purchases` for the `product`
        - There are no `orders` for the `product`
- Version 2
- First try to `DELETE` and then check the `ERROR_NUMBER()`.

### Deep Dive Exception Handling
#### The THROW statement
Raises an exception and transfers execution to a CATCH block of a TRY...CATCH construct, or stops the execution of a stored procedure.
> Remark: Only available in SQL Server 2012 and higher.

##### Arugments
- `error_number` is a constant or variable that represents the exception. error_number is int and must be greater than or equal to 50000 and less than or equal to 2147483647.
- `message` is an string or variable that describes the exception. message is nvarchar(2048).
- `state` is a constant or variable between 0 and 255 that indicates the state to associate with the message. state is a tinyint. [This post](https://dba.stackexchange.com/questions/35893/what-is-error-state-in-sql-server-and-how-it-can-be-used) explains why you should/could use `state`. 

> More information about the `THROW` statement can be found [here](https://docs.microsoft.com/en-us/sql/t-sql/language-elements/throw-transact-sql?view=sql-server-2017). Another possible statement to handle exceptions is `RAISERROR` but is considered obsolete by Microsoft. More information about the `RAISERROR` statement can be found [here](https://docs.microsoft.com/en-us/sql/t-sql/language-elements/raiserror-transact-sql?view=sql-server-2017).

##### Example
```sql
THROW 50000, 'The record does not exist.', 1;  
```

### Solution
A possible solution of exercise 2 can be found [here](/solutions/stored-procedures-2.sql)
