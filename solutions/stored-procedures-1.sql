ALTER PROCEDURE [dbo].[DeleteOrdersFromSupplier] 
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
