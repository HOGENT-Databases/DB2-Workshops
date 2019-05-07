# Workshop - Cursors
In this workshop you'll learn how to create and use a Cursor.

## Prerequisites
- A running copy of database **xtreme**;
- Finalized the exercises about stored procedures.

## Introduction
In the previous workshop, you wrote a stored procedure to delete all orders for a given supplier called `DeleteOrdersFromSupplier`, the output parameter/return value of this stored procedure was the number of deleted orders. However the stored procedure didn't work due to a **foreign key constraint**.

#### Code for the previous exercise

```sql
ALTER PROCEDURE [dbo].[DeleteOrdersFromSupplier] 
  @supplierid int,
  @nrdeletedorders int output
AS
  DELETE FROM orders WHERE orderid in 
  (
   SELECT orderid
   FROM product p JOIN ordersdetail od ON p.ProductID=od.productid
   WHERE supplierid = @supplierid
  )
  SET @nrdeletedorders = @@ROWCOUNT
```

#### Test code
```sql
DECLARE @supplier int,@amount int
SET @supplier = 7
EXEC DeleteOrdersFromSupplier @supplier, @amount output
PRINT 'Amount of  orderdetails for supplier ' + LTRIM(STR(@supplier)) + ' = ' + LTRIM(STR(@amount))
```

## Call to action
- Adjust the stored procedure to delete all `orders` and `orderdetails` for a given `supplierId` using a `cursor`.
- Return the number of deleted `orders` **and** the number of deleted `orderdetails`.

## Execution
Make sure the following code can be executed:

```sql
BEGIN TRANSACTION

DECLARE @amountOfOrders int,@amountOfOrdersDetails int
EXEC DeleteOrdersFromSupplier2 6,@amountOfOrders OUT, @amountOfOrdersDetails OUT
PRINT 'Amount of deleted orders = ' + str(@amountOfOrders)
PRINT 'Amount of deleted orderdetails = ' + str(@amountOfOrdersDetails)

ROLLBACK;
```

## Tips
- Make sure to declare all the necessary variables:
    - Input;
    - Output;
    - Cursor.
- Make sure to open the cursor;
- Fetch data coming from the `cursor` into the variable(s);
- Use a `loop` while there are still unprocessed records;
    - Delete some records in the loop;
    - Don't forget to increase your `counters` for the output.
    - `Fetch` next record
- Don't forget to `close` and `dealloc` your cursor.

## Deep Dive
1. What happends if someone else is updating the row(s) you're about to delete?
    - Make sure that the selected rows cannot be modified during the execution. 
2. Is a close instruction necessary when you deallocate a cursor?

## Solution
A possible solution of this exercise can be found [here](/solutions/cursors.sql)
