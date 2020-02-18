# Solutions - Subqueries
## Dataset - Xtreme
![img](/workshops/shared/images/diagrams/diagram-xtreme.png)

1. Give the id and name of the products that have not been purchased yet. 
    ```sql
    SELECT 
     productid
    ,productname
    FROM product
    WHERE productid NOT IN (SELECT productid FROM Purchases);
    ```
    Alternative with a JOIN instead of a subquery:
    ```sql
    SELECT 
     product.productid
    ,product.ProductName 
    FROM product
        LEFT JOIN Purchases ON purchases.productId = product.productId
    WHERE purchases.productId is null
    ```
2. Select the names of the suppliers who supply products that have not been ordered yet. 
    ```sql
    SELECT
     supplier
    .supplierName 
    FROM supplier
        JOIN product ON supplier.supplierID = product.supplierID
    WHERE productID NOT IN (SELECT productID FROM ordersDetail);
    ```
3. Select the products (all columns) with a price that is higher than the average price of the "Bicycle" products. Order the results by descending order of the price. 
    ```sql
    SELECT * 
    FROM product 
    WHERE price > 
        (
        SELECT AVG(price) 
        FROM product p 
            JOIN productclass pc ON p.ProductClassID = pc.ProductClassID
        WHERE productclassname = 'Bicycle'
        )
    ORDER BY price DESC;
    ```
4. Show a list of the orderID's of the orders for which the order amount differs from the amount calculated through the ordersdetail. 
    ```sql
    SELECT orderID 
    FROM orders 
    WHERE orderAmount <> 
        (
        SELECT SUM(quantity * unitPrice) 
        FROM ordersDetail 
        WHERE orderID = orders.orderID
        );
    ```
5. Which employee has processed most orders? Show the fullname of the employee and the amount of order he/she processed.
    ```sql
    SELECT 
    CONCAT(e.firstname,' ', e.lastname) AS 'Employee'
    ,COUNT(*) AS 'No. of Orders'
    FROM employee e 
        JOIN orders o on e.employeeid = o.EmployeeID
    GROUP BY CONCAT(e.firstname,' ', e.lastname)
    HAVING COUNT(*) = 
        (
        SELECT TOP 1 count(*)
        FROM employee e 
            JOIN orders o ON e.employeeid = o.EmployeeID
        GROUP BY CONCAT(e.firstname,' ', e.lastname)
        ORDER BY count(*) DESC
        );
    ```
    Alternative without a subquery
    ```sql
    SELECT TOP 1
    CONCAT(e.firstname,' ', e.lastname) AS 'Employee'
    ,COUNT(*) AS 'No. of Orders'
    FROM orders o 
        JOIN employee e on e.employeeid = o.EmployeeID
    GROUP BY CONCAT(e.firstname,' ', e.lastname)
	ORDER BY COUNT(*) DESC
    ```
6. Give per employee and per orderdate the total order amount. Also add the name of the employee and the running total per employee when ordering by orderdate. Note that the running total is the sum of all orders where the employee is responsible at the order date's time.
    ```sql
    SELECT
     e.employeeid
    ,e.lastname
    ,e.firstname
    ,o.orderdate
    ,ROUND(SUM(orderamount),0) AS [Order Total]
    ,(
        SELECT ROUND(SUM(orderamount),0) 
        FROM orders 
        WHERE employeeid = e.employeeid 
        AND   orderdate <= o.orderdate
     ) AS [Employee Running Total]
    FROM employee e 
        LEFT JOIN orders o ON e.employeeid = o.employeeid
    GROUP BY 
     e.employeeid
    ,o.orderdate
    ,e.lastname
    ,e.firstname
    ORDER BY 
     e.employeeid
    ,o.orderdate;
    ```

## Exercises
Click [here](../subqueries-xtreme.md) to go back to the exercises.
