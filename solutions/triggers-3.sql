-- DLL Alter the ProductType Table
alter table ProductType
add AmountOfProducts int
go

-- DML Update the existing records
update ProductType
set AmountOfProducts = (select count(*) 
                        from Product
where ProductTypeID = ProductType.ProductTypeID)
go

-- Trigger
-- Delete the trigger if it exists already
drop trigger synchronizeProductType
go

create trigger synchronizeProductType
on Product
for insert, update, delete
as 
begin
  set nocount on
  declare @oldProductTypeID int
  declare @newProductTypeID int
  if update(productTypeID) 
    begin
        select @newProductTypeID = ProductTypeID from inserted
        update ProductType
            set AmountOfProducts = AmountOfProducts + 1
        where productTypeID = @newProductTypeID
    end
  select @oldProductTypeID = ProductTypeID from deleted
  if @oldProductTypeID is not null
   update ProductType
   set AmountOfProducts = AmountOfProducts - 1
   where productTypeID = @oldProductTypeID
end
go