# Workshop - Revisit the basics : Xtreme
In this workshop you'll learn how to consult, filter, aggregate, join, order and project data coming from the relational database called `Xtreme` by using the following statements:
- `SELECT`
- `DISTINCT`
- `WHERE`
- `ORDER BY`
- `GROUP BY`
- `[INNER|LEFT|OUTER] JOIN`

## Prerequisites
- SQL Server 2017+ Installed;
- **S**QL **S**erver **M**anagement **S**tudio Installed;
- A running copy of the database **xtreme**.
    > You can download the database by using [this link](https://github.com/HOGENT-Databases/DB2-Workshops/raw/master/databases/xtreme.bak), information on how to restore a database can be found [here](https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/restore-a-database-backup-using-ssms?view=sql-server-ver15).

## Getting started
Below you'll find multiple exercises, for each exercise do the following:
1. Investigate the database schema of the **xtreme** database;
2. Figure out which:
    - table(s) you will be consulting;
    - columns you will be projecting;
    - filters that are needed;
    - aggregations that are mandatory;
    - sort order is necessary.
3. Write the query;
4. Check your results.

---

## Database schema - xtreme
![img](/workshops/shared/images/diagrams/diagram-xtreme.png)

## Exercises
1. Give the unique names of all products containing the word 'helmet' or with a name of 6 characters.
2. Show the name and the reorderlevel of all products with a level between 50 and 500 (boundaries included)
3. Count the amount of products, give the column the following name  "Amount of Products". In a second column, count the amount of products where the unit in stock is known. Give the second column a descriptive column name.
4. How many unique supervisors are there?
    > Hint: Count all the unique people who are supervising others;
5. Give the date of birth of the youngest employee and the oldest.
6. What’s the number of employees who will retire (at 65) within the first 30 years?
7. Show a list of different countries where 2 of more suppliers live in, make sure to order alphabeticaly. 
8. Which suppliers offer at least 10 products with a price less then 100 dollar? Show supplierIdand the number of different products. The supplier with the highest number of products comes first.
9. Count the number of workers (salary below 40.000), clerks (salary between 40.000 and 50.000 EUR) and managers (salary > 50000). Show 2 columns the name of the role and the amount of people in that role. 
10. Which suppliers (Id and name) deliver products from the class "Bicycle"?
11. Give for each supplier the number of orders that contain products of that supplier. Show supplierID, supplier name and the number of orders. Order the results alphabetically by the name of the supplier.
12. What’s for each type the lowest productpriceof products for Youth? Show producttypename and lowest. 
    > Hint: products for youth contain `Y` in the `M_F` field
13. Give for each purchased productId: productname, the least and the most ordered. Order by productname.
14. Give a summary for each employee with orderID, employeeIDand employeename. 
    > Make sure that the list also contains employees who don’t have orders yet. 

## Deep Dive
1. Is the `LIKE` operator case-sensitive or not?
2. Why is it not possible to use certain columns from the `SELECT` statement in the `WHERE`, `ORDER BY` or `GROUP BY` clauses?

### Solution
A possible solution for these exercises can be found [here](solutions/basic-xtreme.md).
