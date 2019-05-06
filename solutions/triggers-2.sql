drop table productAudit
go

create table productAudit(
Id int not null primary key identity,
UserName nvarchar(256) default SUSER_SNAME(),
CreatedAt datetime default getutcdate(),
Operation nchar(6))
go

create trigger auditProductstrigger
on product
for insert, update, delete
as begin
  set nocount on
  declare @operation nchar(6)
  if not exists (select * from inserted)
    set @operation = 'delete'
  else if not exists(select * from deleted)
         set @operation = 'insert'
       else set @operation = 'update'
  insert into productAudit(operation)
  values (@operation)
end
go