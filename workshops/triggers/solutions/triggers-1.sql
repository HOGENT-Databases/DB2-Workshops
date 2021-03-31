CREATE TRIGGER TR_Employee_SetReportsTo
ON employee -- The table we're invoking the trigger on.
AFTER INSERT -- Only when we insert the trigger should be invoked.
as
  DECLARE @reportsTo INT;

  SELECT TOP 1 @reportsTo = ReportsTo -- Set variable
  FROM employee
  WHERE ReportsTo is not null
  GROUP BY ReportsTo
  ORDER BY Count(ReportsTo)
 
  UPDATE employee
  SET reportsTo = @reportsTo
  WHERE EmployeeID = (select top 1 EmployeeID from inserted)

/*
REMARK:
  In case of a multiline insert   (e.g. when using an INSERT/SELECT statement).
  Only the first employee's ReportsTo field will be updated.
*/