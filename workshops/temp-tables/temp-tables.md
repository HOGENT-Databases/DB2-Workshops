# Workshop - Temporary Tables
In this workshop you'll learn how to create and use a temporary table.

## Prerequisites
- A running copy of database **xtreme**;
- Finalised the exercises about stored procedures and cursors.

## Introduction
In the [previous workshop about cursors](/workshops/cursors/cursors.md), you wrote a stored procedure to delete all orders and orderdetails for a given supplier called `DeleteOrdersFromSupplier`, the output parameter/return value of this stored procedure was the number of deleted orders and orderdetails. However there are always alternative approaches. This time we'll use a temporarly table to delete all the orders for a given supplier.

## Call to action
- Adjust the stored procedure to delete all `orders` and `orderdetails` for a given `supplierId` using a `temporarly table`.
- Return the number of deleted `orders` **and** the number of deleted `orderdetails`;
- Additionally, throw an exception if the given supplier doesn’t exist.

## Execution
Make sure the following code can be executed:

```sql
BEGIN TRANSACTION
BEGIN TRY
    DECLARE @amountOfOrders int, 
            @amountOfOrdersDetails int;

    EXEC DeleteOrdersFromSupplier3 2,@amountOfOrders OUT, @amountOfOrdersDetails OUT;

    PRINT FORMATMESSAGE('Amount of deleted orders  : %d',@amountOfOrders);
    PRINT FORMATMESSAGE('Amount of deleted details : %d',@amountOfOrdersDetails);
END TRY

BEGIN CATCH
    PRINT FORMATMESSAGE('Error: %s in procedure %s at line %d',ERROR_MESSAGE(),ERROR_PROCEDURE(), ERROR_LINE());
END CATCH

ROLLBACK;
```

## Tips
- Check if the supplier exists
- Create a temp. table for the orders.
- Insert all orders from the supplier into the temp. table;
- Delete all orderdetails for all orders in the temp. table;
- Delete all orders based on the temp. table; 
- Don't forget to set the OUTPUT values.

## Deep Dive
1. What is the difference between a local and global temporary table?

## Solution
A possible solution of this exercise can be found [here](solutions/temp-tables-1.sql)
