# Workshop - Views
In this workshop you'll learn the use of `views`. 


## Prerequisites
- SQL Server 2017+ Installed;
- **S**QL **S**erver **M**anagement **S**tudio Installed;
- A running copy of the database **xtreme**.
    > You can download the database by using [this link](https://github.com/HOGENT-Databases/DB2-Workshops/raw/master/databases/xtreme.bak), information on how to restore a database can be found [here](https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/restore-a-database-backup-using-ssms?view=sql-server-ver15).

## Getting started
Below you'll find a a few exercises, follow the steps **sequentially** to complete each exercise.

---

## Database schema - xtreme
![img](/workshops/shared/images/diagrams/diagram-xtreme.png)


# Exercise 1
The company wants to weekly check the stock of their products, if the stock is below 15, they'd like to order more to fulfill the need.
1. Create a `QUERY` that shows the ProductId, ProductName and the name of the supplier, do not forget the `WHERE` clause.
2. Turn this `SELECT` statement into a `VIEW` called: `vw_products_to_order`.
    > If you're struggling with editing or dropping the `VIEW`, the following statement might help:
    ```sql
    DROP VIEW IF EXISTS vw_products_to_order
    ```
3. Query the `VIEW` to see the results.

---

## Exercise 2
The Xtreme company has to increase prices of certain products. To make it seem the prices are not increasing dramatically they're planning to spread the price increase over multiple years. In total they'd like a 10% price for certain products. The list of impacted products can grow over the coming years. We'd like to keep all the logic of selecting the correct products in 1 SQL `View`, in programming terms 'keeping it DRY'. The updating of the items is not part of the view itself.

The products in scope are all the products that start with the term 'Guardian' and 1 special product the one with the productId: '4101'.

1. Create a simple SQL Query to get the following resultset:
    <table>
        <thead>
            <tr>
                <th>Id</th>
                <th>Name</th>
                <th align="right">Price</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>3301</td>
                <td>Guardian Chain Lock</td>
                <td align="right">4.59</td>
            </tr>
            <tr>
                <td>3302</td>
                <td>Guardian "U" Lock</td>
                <td align="right">17.85</td>
            </tr>
            <tr>
                <td>3303</td>
                <td>Guardian XL "U" Lock</td>
                <td align="right">20.30</td>
            </tr>
            <tr>
                <td>3304</td>
                <td>Guardian ATB Lock</td>
                <td align="right">22.34</td>
            </tr>
            <tr>
                <td>3305</td>
                <td>Guardian Mini Lock</td>
                <td align="right">22.34</td>
            </tr>
            <tr>
                <td>4101</td>
                <td>InFlux Crochet Glove</td>
                <td align="right">13.77</td>
            </tr>
        </tbody>
    </table>
2. Turn this `SELECT` statement into a `VIEW` called: `vw_price_increasing_products`.
    > If you're struggling with editing or dropping the `VIEW`, the following statement might help:
    ```sql
    DROP VIEW IF EXISTS vw_price_increasing_products
    ```
3. Query the `VIEW` to see the results.
4. Increase the price of the resultset of the `VIEW`: `vw_price_increasing_products` by 2%.
    > We will be increasing prices for 5 years in a row. By using a `VIEW` we made it possible to **re-use** the underlying query for the years to come. If we ever have to add certain products we can add them in the `QUERY` of the `VIEW` by using an `ALTER` statement.
    > 
5. Query the `VIEW` to see the updated results.

## Deep Dive
1. Try to `DROP` a `VIEW` and in the same query batch, `CREATE` one. The following error message will be shown:
    > Msg 111, Level 15, State 1, Line 16
    >
    > `CREATE VIEW` must be the first statement in a query batch.
    - What's the problem and how can this be fixed? 


### Solution
A possible solution for these exercises can be found [here](solutions/views.md).
