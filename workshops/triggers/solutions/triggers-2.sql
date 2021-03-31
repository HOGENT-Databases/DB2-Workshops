-- Drop the objects created in this code (easier to re-run)
DROP TABLE ProductAudit
DROP TRIGGER TR_Product_AuditProducts
GO

-- Create the audit table
CREATE TABLE ProductAudit(
    Id INT NOT NULL PRIMARY KEY IDENTITY,
    UserName NVARCHAR(256) DEFAULT SUSER_SNAME(),
    CreatedAt DATETIME DEFAULT getutcdate(),
    Operation NCHAR(6))
GO

-- Create the trigger
CREATE TRIGGER TR_Product_AuditProducts
on Product
FOR INSERT, UPDATE, DELETE
AS

-- Get the text representation of the action that happned
DECLARE @operation NCHAR(6)
IF NOT EXISTS (SELECT NULL FROM inserted)
    SET @operation = 'delete'
ELSE IF NOT EXISTS (select NULL from deleted)
        SET @operation = 'insert'
     ELSE SET @operation = 'update'
    
-- Add a new record in the audit table.
INSERT INTO ProductAudit(operation)
VALUES (@operation)
GO