alter procedure pivotperland
as
DECLARE @sqlString    VARCHAR(4000) = ''

DECLARE landCursor CURSOR FOR 
select distinct country from product p join supplier s on p.supplierid=s.supplierid

DECLARE @land varchar(100);

set @sqlString = 'select p.productclassid,'
open landCursor
fetch next from landCursor into @land
while @@FETCH_STATUS = 0 begin
set @sqlString += 'sum(case when s.country=''' + @land + ''' then 1 else 0 end) as ' + ''''+@land+''','
fetch next from landCursor into @land
end
deallocate landcursor
set @sqlString += 'count(productid) TOTAAL from product p join supplier s on p.supplierid = s.supplierid '
set @sqlString += 'group by p.productclassid';
print @sqlString

exec (@sqlString);
