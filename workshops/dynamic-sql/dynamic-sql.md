# Workshop - Dynamic SQL
In this workshop you'll learn how to write flexible SQL statements.

## Prerequisites
- A running copy of database **xtreme**.
- Finalized the exercises about:
    - stored procedures;
    - cursors.

## Introduction
We'd like to know for every `ProductClassID` how many products are produced in.
- USA;
- Canada;
- Japan;
- UK;
- A total of all the countries combined.

A possible SQL statement that produces this output is listed below.
```sql
SELECT  Product.ProductClassID,
        SUM(CASE WHEN Supplier.Country ='USA' THEN 1 ELSE 0 end) AS 'USA',​
        SUM(CASE WHEN Supplier.Country ='Canada' THEN 1 ELSE 0 end) AS 'Canada',​
        SUM(CASE WHEN Supplier.Country ='Japan' THEN 1 ELSE 0 end) AS 'Japan',​
        SUM(CASE WHEN Supplier.Country ='UK' THEN 1 ELSE 0 end) AS 'UK',​
        COUNT(Product.productid) AS TOTAL
FROM Product 
JOIN Supplier ON Product.SupplierID = Supplier.SupplierID
GROUP BY ProductClassID
```
> Note that the `countries` are hardcoded in this statement, this can create a maintenance nightmare... Everytime a new country comes into the list we have to update the statement. We'd rather use a dynamic SQL approach so that every country is listed automagically and not only `USA`, `Canada`, ...


## Call to action
1. Rewrite the statement so that the countries are no longer hardcoded;
2. Wrap the statement in a `stored procedure` called `SP_ProductClass_By_Country_Amount`.

## Execution
Make sure the following code can be executed:

```sql
EXECUTE SP_ProductClass_By_Country_Amount;
```

## Tips
- Run the hardcoded statement to see the output;
- To know where the products are produced you have to look at the origin (country) of the supplier;
- A cursor can help to fetch all countries;
- Use dynamic SQL to create totals;
    - You can reuse parts of the given statement.

## Deep Dive
1. What are the disadvantages of using Dynamic SQL statements?
2. What is SQL Injection?
3. Can you invoke a Dynamic SQL statement in a User Defined Function(UDF)?

## Solution
A possible solution of this exercise can be found [here](solutions/dynamic-sql-1.sql)
