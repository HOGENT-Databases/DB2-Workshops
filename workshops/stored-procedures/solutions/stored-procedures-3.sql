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