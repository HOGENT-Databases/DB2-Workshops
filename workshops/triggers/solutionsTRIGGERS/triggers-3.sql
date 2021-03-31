-- Alter the ProductType Table
ALTER TABLE ProductType
ADD AmountOfProducts INT
GO

-- Update the existing records
UPDATE ProductType
SET AmountOfProducts = (SELECT COUNT(*) 
                        FROM Product
                        WHERE Product.ProductTypeID = ProductType.ProductTypeID)
                        -- Table prefixes are mandatory here, why?
GO

-- Trigger
-- Delete the trigger if it exists already
DROP TRIGGER TR_Product_SynchronizeProductType
GO

CREATE TRIGGER TR_Product_SynchronizeProductType
ON Product
FOR INSERT, UPDATE, DELETE
AS
  SET NOCOUNT ON
  DECLARE @oldProductTypeID INT
  DECLARE @newProductTypeID INT

  IF UPDATE(ProductTypeId) 
    BEGIN
        SELECT @newProductTypeID = ProductTypeID from inserted 
        UPDATE ProductType
        SET AmountOfProducts = AmountOfProducts + 1
        WHERE ProductTypeID = @newProductTypeID
    END

  SELECT @oldProductTypeID = ProductTypeID from deleted
  if @oldProductTypeID is not null
    BEGIN
        UPDATE ProductType
        SET AmountOfProducts = AmountOfProducts - 1
        WHERE ProductTypeID = @oldProductTypeID
    END
GO

/* Remark:
    - deleted virtual table contains copies of updated or inserted rows
        During update or delete rows are moved from the triggering table to the deleted table
    - inserted virtual table contains copies of updated or inserted rows.
        During update or insert each affected row is copied from the triggering table to the inserted table
        All rows from the inserted table are also in the triggering table
*/