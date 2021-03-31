# Solutions - Common Table Expressions
## Dataset - Xtreme
![img](../images/diagram-xtreme-parts.png)

1. Rewrite the following query using a common table expressions.
    ```sql
    WITH 
    Ordered(Month, Amount) AS 
    (
        SELECT 
         FORMAT(OrderDate, 'yyyy-MM')
        ,SUM(OrderAmount)
        FROM Orders
        GROUP BY FORMAT(OrderDate, 'yyyy-MM')
    ),
    Purchased(Month, Amount) AS 
    (
        SELECT
         FORMAT(OrderDate, 'yyyy-MM')
        ,SUM(Product.Price * Purchase.UnitsOnOrder)
        FROM Purchases AS Purchase	
            JOIN Product ON Purchase.ProductId = Product.ProductId
        GROUP BY FORMAT(OrderDate, 'yyyy-MM')
    )
    -- Actual Selecting data based on the defined subqueries of the above CTE.
    SELECT 
     ISNULL(Ordered.Month, Purchased.month) AS [Month]
    ,ISNULL(Ordered.Amount, 0) - ISNULL(Purchased.Amount, 0) AS [Margin]
    FROM Ordered 
        FULL JOIN Purchased ON Ordered.month = Purchased.month
    ORDER BY [Month];
    ```
2. Make a histogram of the number of orders per customer (not the Excel equivalent shown below but as raw data in rows and columns). Show how many times each number occurs. E.g. in the graph below: 190 customers placed 1 order, 1 customer placed 2 orders, 1 customer placed 14 orders, etc. 
    ```sql
    WITH OrdersPerCustomer(Amount) AS 
    (
        SELECT COUNT(*) AS [Amount]
        FROM Orders
        GROUP BY CustomerId
    )

    SELECT 
     Amount
    ,COUNT(*)
    FROM OrdersPerCustomer
    GROUP BY Amount
    ORDER BY Amount;
    ```
3. Show all parts that are directly or indirectly part of O2, so all parts of which O2 is composed. Use the new `Parts` table you added in the Getting Started section.
    ```sql
    WITH Relation(Super, Sub) AS
    (
        -- Default query
        SELECT 
        Super
        ,Sub 
        FROM Parts 
        WHERE Super = 'O2'

        UNION ALL
        -- Join the results of the default query
        SELECT 
        Parts.Super
        ,Parts.Sub 
        FROM Parts 
            JOIN Relation ON Parts.Super = Relation.Sub
    )

    SELECT * FROM Relation;
    ```

4. Add an extra column to the last query with the Path as shown below:
    ```sql
    WITH Relation(Super, Sub, [Path]) AS
    (
        -- Default query
        SELECT 
         Super
        ,Sub
        ,[Path] =  CAST(CONCAT(Super, ' <- ',Sub) AS NVARCHAR(MAX))
        FROM Parts 
        WHERE Super = 'O2'

        UNION ALL
        -- Join the results of the default query
        SELECT 
         Parts.Super
        ,Parts.Sub 
        ,[Path] = CONCAT(Relation.[Path], ' <- ',Parts.Sub)
        FROM Parts 
            JOIN Relation ON Parts.Super = Relation.Sub
    )
    SELECT * FROM Relation;
    ```
 
## Exercises
Click [here](../cte.md) to go back to the exercises.
