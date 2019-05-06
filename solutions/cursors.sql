ALTER procedure [dbo].[DeleteOrdersFromSupplier2] @supplierid int,
@nrdeletedorders int output,@nrdeleteddetails int output
as
set nocount on
declare orderscursor 
cursor for select distinct orderid
from product p join ordersdetail od on p.ProductID=od.productid
where supplierid = @supplierid
for update -- Deep Dive #1

declare @orderid int
set @nrdeletedorders = 0
set @nrdeleteddetails = 0

open orderscursor
fetch next from orderscursor into @orderid

while @@FETCH_STATUS = 0
begin
delete from ordersdetail where orderid = @orderid
set @nrdeleteddetails += @@rowcount
delete from orders where orderid = @orderid
set @nrdeletedorders += 1
fetch next from orderscursor into @orderid
end

close orderscursor -- Deep Dive #2
deallocate orderscursor
