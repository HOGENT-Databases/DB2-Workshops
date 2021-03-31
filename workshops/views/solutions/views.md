# Solutions - Views
## Dataset - Xtreme
![img](/workshops/shared/images/diagrams/diagram-xtreme.png)


# Exercise 1
The company wants to weekly check the stock of their products, if the stock is below 15, they'd like to order more to fulfill the need.
1. Create a `QUERY` that shows the ProductId, ProductName and the name of the supplier.
    ```sql
    SELECT 
    Product.ProductID AS [Id]
    ,Product.ProductName AS [Name]
    ,Supplier.SupplierName AS [Supplier]
    FROM Product
        JOIN Supplier on Product.SupplierID = Supplier.SupplierID
    WHERE Product.UnitsInStock < 15
    ```
2. Turn this `SELECT` statement into a `VIEW` called: `vw_products_to_order`.
    ```sql
    DROP VIEW IF EXISTS vw_products_to_order
    GO -- See Deep Dive

    CREATE VIEW vw_products_to_order AS
    SELECT 
    Product.ProductID AS [Id]
    ,Product.ProductName AS [Name]
    ,Supplier.SupplierName AS [Supplier]
    FROM Product
        JOIN Supplier on Product.SupplierID = Supplier.SupplierID
    WHERE Product.UnitsInStock < 15
    ```
3. Query the `VIEW` to see the results.
    ```sql
    SELECT * 
    FROM vw_products_to_order
    ```
---

## Exercise 2
1. Create a simple SQL Query to get the following resultset:
    ```sql
    SELECT
    Product.ProductID AS [Id]
    ,Product.ProductName AS [Name]
    ,Product.Price AS [Price]
    FROM Product
    WHERE Product.ProductName LIKE '%Guardian%' 
       OR Product.ProductID = 4101
    ```
2. Turn this `SELECT` statement into a `VIEW` called: `vw_price_increasing_products`.
    ```sql
    DROP VIEW IF EXISTS vw_price_increasing_products
    GO -- See Deep Dive

    CREATE VIEW vw_price_increasing_products AS
        SELECT
        Product.ProductID AS [Id]
        ,Product.ProductName AS [Name]
        ,Product.Price AS [Price]
        FROM Product
        WHERE Product.ProductName LIKE '%Guardian%' 
        OR Product.ProductID = 4101    
    ```
3. Query the `VIEW` to see the results.
    ```sql
    SELECT * 
    FROM vw_price_increasing_products
    ```
4. Increase the price of the resultset of the `VIEW`: `vw_price_increasing_products` by 2%.
    ```sql
    UPDATE vw_price_increasing_products
    SET Price = Price * 1.02    
    ```
5. Query the `VIEW` to see the updated results.
    ```sql
    SELECT * 
    FROM vw_price_increasing_products
    ```

## Deep Dive
1. Try to `DROP` a `VIEW` and in the same query batch, `CREATE` one. The following error message will be shown:
    > Msg 111, Level 15, State 1, Line 16
    >
    > `CREATE VIEW` must be the first statement in a query batch.
    - What's the problem and how can this be fixed? 
    >  Batches are delimited by the word GO - which is an instruction to client tools (e.g. Management Studio), not to SQL Server, specifically telling those tools how to split your query into batches.
    > The error tells you that CREATE VIEW must be the first statement in a batch. To fix this, add a `GO` statement before the `CREATE VIEW` statement.

## Exercises
Click [here](../views.md) to go back to the exercises.
