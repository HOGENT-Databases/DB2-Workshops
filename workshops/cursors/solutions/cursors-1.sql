ALTER PROCEDURE DeleteOrdersFromSupplier2 
    @supplierid INT,
    @nrdeletedorders INT OUTPUT,
    @nrdeleteddetails INT OUTPUT
AS
SET NOCOUNT ON
DECLARE orderscursor CURSOR FOR 
    SELECT DISTINCT OrderID
    FROM OrdersDetail 
    JOIN Product on OrdersDetail.ProductID = Product.ProductID
    WHERE SupplierID = @supplierid
FOR UPDATE -- Deep Dive #1

DECLARE @orderid INT
SET @nrdeletedorders = 0
SET @nrdeleteddetails = 0

OPEN orderscursor
FETCH NEXT FROM orderscursor INTO @orderid

WHILE @@FETCH_STATUS = 0
BEGIN
    -- First delete the orderdetails to get rid of the FK constaint.
    DELETE FROM OrdersDetail WHERE OrderID = @orderid
    SET @nrdeleteddetails += @@ROWCOUNT

    -- Delete the orders
    DELETE FROM Orders WHERE OrderID = @orderid
    SET @nrdeletedorders += 1

    -- Read the next record
    FETCH NEXT FROM orderscursor INTO @orderid
END

CLOSE orderscursor -- Deep Dive #2
DEALLOCATE orderscursor
