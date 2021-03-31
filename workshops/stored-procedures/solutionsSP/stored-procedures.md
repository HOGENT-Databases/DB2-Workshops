# Solutions - Stored Procedures
## Exercise 1

```sql
CREATE PROCEDURE sp_DeleteOrderDetailsForBankruptSupplier
	  @supplierID INT
	 ,@deletedDetailsAmount INT OUTPUT
AS
-- The resultset of the impacted customers
SELECT 
 Customer.CustomerName
,Customer.ContactTitle
,Customer.ContactFirstName
,Customer.ContactLastName
FROM OrdersDetail AS [Detail]
	JOIN Orders [Order] ON [Order].OrderID = [Detail].OrderID
	JOIN Product ON Product.ProductID = [Detail].ProductID
	JOIN Customer ON Customer.CustomerID = [Order].CustomerID
WHERE Product.SupplierID = @supplierID
  AND [Order].OrderDate >= '2018-04-01'
GROUP BY 
 Customer.CustomerName
,Customer.ContactTitle
,Customer.ContactFirstName
,Customer.ContactLastName

-- The actual delete statement
DELETE [Detail] FROM OrdersDetail AS [Detail]
	JOIN Orders [Order] ON [Order].OrderID = [Detail].OrderID
	JOIN Product ON Product.ProductID = [Detail].ProductID
WHERE Product.SupplierID = @supplierID
  AND [Order].OrderDate >= '2018-04-01'

-- Setting the OUTPUT parameter to the amount of rows we just deleted.
SET @deletedDetailsAmount = @@ROWCOUNT
```

## Exercise 2
```sql
CREATE PROCEDURE DeleteProduct1 
    @productid INT
AS
-- Check if the product exists.
IF NOT EXISTS (SELECT NULL FROM Product WHERE ProductID = @productid)
    THROW 50001, 'The product doesn''t exist',1;  

-- Check if the product is already purchased.
IF EXISTS (SELECT NULL FROM Purchases WHERE ProductID = @productid)
    THROW 50002, 'Product not deleted: there are already purchases for the product.',2;  

-- Check if the product is already ordered
IF EXISTS (SELECT NULL FROM OrdersDetail WHERE ProductID = @productid)
    THROW 50003, 'Product not deleted: there are already orders for the product.',3;  

-- Actually delete the Product if we get here. 
DELETE FROM Product WHERE ProductID = @productid;
PRINT 'Product ' + str(@productid) + ' was successfully deleted.'

GO; -- You can only Alter/Create or Delete a SP in 1 batch.

-- Version 2
CREATE PROCEDURE DeleteProduct2 
    @productid int
AS
BEGIN TRY
    DELETE FROM Product WHERE ProductID = @productid
    IF @@ROWCOUNT = 0 -- No rows were mutated, so there is something wrong.
        THROW 50001,'The product doesn''t exist',1;

    PRINT 'Product ' + str(@productid) + ' was successfully deleted.'
END TRY

BEGIN CATCH
    IF ERROR_NUMBER() = 50001 -- In other words a custom error message. (See Deep Dive)
        PRINT error_message()
    ELSE IF ERROR_NUMBER() = 547 and ERROR_MESSAGE() like '%purchases%' -- 547 FK Exception.
            PRINT 'Product not deleted: there are already purchases for the product. '
    ELSE IF ERROR_NUMBER() = 547 and ERROR_MESSAGE() like '%ordersdetail%'
            PRINT 'Product not deleted: there are already orders for the product.'
END CATCH
```

## Exercise 3
```sql
CREATE PROCEDURE SP_Create_OrderDetail
@OrderId int,@ProductId int,@UnitPrice decimal(8,2)=NULL,@Quantity int
AS

IF NOT EXISTS (SELECT NULL FROM Product WHERE ProductID=@ProductId)
    THROW 50001, 'The Product doesn''t exist',1;  

IF NOT EXISTS (SELECT NULL FROM Orders WHERE OrderID=@OrderId)
    THROW 50002, 'The Order doesn''t exist',2;  

IF @UnitPrice IS NULL 
    SELECT @UnitPrice = Price FROM Product WHERE ProductID=@ProductId

DECLARE @shipped bit
SELECT @shipped = shipped FROM Orders WHERE OrderID=@OrderId

IF @shipped = 1
    THROW 50002, 'The Order is already shipped.',2;  

DECLARE @rest int
SELECT @rest=ISNULL(UnitsInStock,0) - ISNULL(@Quantity,0)
FROM Product WHERE Productid=@ProductId

IF @rest < 0
    THROW 50003, 'The product is out of stock.',3;  

INSERT INTO OrdersDetail VALUES (@OrderId,@ProductId,@UnitPrice,@Quantity)
return 1
```

## Exercise 4
```sql
CREATE PROCEDURE [DeleteOrdersFromSupplier] 
  @supplierid int,
  @nrdeletedorders int output
AS
  DELETE FROM orders WHERE OrderID IN 
  (
    SELECT DISTINCT OrderID 
    FROM OrdersDetail
    JOIN Product ON Product.ProductID = OrdersDetail.ProductID
    WHERE Product.SupplierID = @supplierid
  )
  SET @nrdeletedorders = @@ROWCOUNT
  
-- The subquery can also start from the Product table  and join the OrderDetail
   SELECT DISTINCT OrderID
   FROM Product
   JOIN OrdersDetail ON Product.ProductID = ordersdetail.ProductID
   WHERE SupplierID = @supplierid
```

## Exercises
Click [here](../stored-procedures.md) to go back to the exercises.