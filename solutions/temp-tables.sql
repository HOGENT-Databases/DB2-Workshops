alter procedure DeleteOrdersFromSupplier3 @supplierid int,@nrdeletedorders int out,@nrdeleteddetails int out
as
begin
set nocount on;
if not exists (select null from supplier where supplierid = @supplierid)
begin
declare @msg varchar(200) 
set @msg = 'Supplier ' + cast(@supplierid as varchar) + ' doesn''t exist';
throw 50000,@msg,1 -- always use ; in front of throw !
end

create table #orders (orderid int)

insert into #orders
select distinct orderid
from product p join ordersdetail od on p.ProductID=od.productid
where supplierid = @supplierid

delete from ordersdetail where orderid in (select orderid from #orders)
set @nrdeleteddetails = @@rowcount

delete from orders where orderid in (select orderid from #orders)
set @nrdeletedorders = @@rowcount
end
