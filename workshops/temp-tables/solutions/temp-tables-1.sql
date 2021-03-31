ALTER PROCEDURE DeleteOrdersFromSupplier3 
    @supplierid INT,
    @nrdeletedorders INT OUT,
    @nrdeleteddetails INT OUT
AS
SET NOCOUNT ON;
IF NOT EXISTS (SELECT NULL FROM Supplier WHERE SupplierID = @supplierid)
BEGIN
    DECLARE @message NVARCHAR(200) = FORMATMESSAGE('Supplier with id: %d, does not exist',@supplierid);
    THROW 50000,@message,1;  -- always use ; in front of throw.
                             -- FormatMessage cannot directly be used in a THROW statement.
END;

-- Create a temp. table
CREATE TABLE #Orders (OrderID INT) -- Note the '#'

-- Insert all orders in scope in the temp. table
INSERT INTO #Orders
SELECT DISTINCT OrderID
FROM OrdersDetail 
JOIN Product on Product.ProductID = OrdersDetail.ProductID
WHERE SupplierID = @supplierid;

-- Delete all orderdetails based on the temp. table
DELETE FROM OrdersDetail WHERE OrderID IN (SELECT OrderID FROM #Orders);
SET @nrdeleteddetails = @@ROWCOUNT;

-- Delete all orders based on the temp. table
DELETE FROM Orders WHERE OrderID IN (SELECT OrderID FROM #Orders);
SET @nrdeletedorders = @@rowcount;
