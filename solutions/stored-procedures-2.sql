-- Version 1
alter procedure DeleteProduct1 @productid int
as
begin
if not exists (select 1 from Product where ProductID = @productid)
begin
raiserror('The product doesn''t exist',14,0)
return
end

if exists (select 1 from Purchases where ProductID = @productid)
begin
raiserror('Product not deleted: there are already purchases for the product. ',14,0)
return
end

if exists (select 1 from OrdersDetail where ProductID = @productid)
begin
raiserror('Product not deleted: there are already orders for the product. ',14,0)
return
end

delete from Product where ProductID = @productid
print 'Product ' + str(@productid) + ' deleted'
end

-- Version 2
alter procedure DeleteProduct2 @productid int
as
begin
begin try
delete from Product where ProductID = @productid
if @@ROWCOUNT = 0
throw 50000,'The product doesn''t exist',14
print 'Product ' + str(@productid) + ' deleted'
end try
begin catch
if ERROR_NUMBER() = 50000
print error_message()
else if ERROR_NUMBER() = 547 and ERROR_MESSAGE() like '%purchases%'
print 'Product not deleted: there are already purchases for the product. '
else if ERROR_NUMBER() = 547 and ERROR_MESSAGE() like '%ordersdetail%'
print 'Product not deleted: there are already orders for the product.'
end catch
end
