ALTER PROCEDURE DeleteProduct1 
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
ALTER PROCEDURE DeleteProduct2 
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
