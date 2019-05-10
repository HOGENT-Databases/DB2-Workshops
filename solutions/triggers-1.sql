create trigger setReportsTo
on employee
after insert
as begin
  set nocount on
  -- in case of a multiline insert 
  -- (e.g. when using an INSERT/SELECT statement)
  -- only the first employee's ReportsTo field is updated
  declare @reportsTo int
  select top 1 @reportsTo = reportsTo
  from employee
  where reportsTo is not null
  group by reportsTo
  order by count(reportsTo)
 
  update employee
  set reportsTo = @reportsTo
  where employeeID = (select top 1 EmployeeID from inserted)
end