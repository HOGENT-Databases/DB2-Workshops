ALTER PROCEDURE [dbo].[DeleteOrdersFromSupplier] 
  @supplierid int,
  @nrdeletedorders int output
AS
  DELETE FROM orders WHERE orderid IN 
  (
   SELECT DISTINCT orderid
   FROM product p 
   JOIN ordersdetail od ON p.ProductID = od.productid
   WHERE supplierid = @supplierid
  )
  SET @nrdeletedorders = @@ROWCOUNT
  
  
  -- The subquery can also start from the OrderDetails and join the Product
SELECT DISTINCT OrderID FROM OrdersDetail
JOIN Product ON Product.ProductID = OrdersDetail.ProductID
WHERE Product.SupplierID = @supplierid
