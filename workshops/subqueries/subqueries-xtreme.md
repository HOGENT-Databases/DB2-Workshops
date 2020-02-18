# Workshop - Subqueries : Xtreme
In this workshop you'll learn the use of `subqueries`, using the the relational database called `Xtreme`:

## Prerequisites
- SQL Server 2017+ Installed;
- **S**QL **S**erver **M**anagement **S**tudio Installed;
- A running copy of the database **xtreme**.
    > You can download the database by using [this link](https://github.com/HOGENT-Databases/DB2-Workshops/raw/master/databases/xtreme.bak), information on how to restore a database can be found [here](https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/restore-a-database-backup-using-ssms?view=sql-server-ver15).

## Getting started
Below you'll find multiple exercises, for each exercise do the following:
1. Investigate the database schema of the **xtreme** database;
2. Write the query;
3. Check your results.

---

## Database schema - xtreme
![img](/workshops/shared/images/diagrams/diagram-xtreme.png)

## Exercises
1. Give the id and name of the products that have not been purchased yet. 
2. Select the names of the suppliers who supply products that have not been ordered yet. 
3. Select the products (all columns) with a price that is higher than the average price of the "Bicycle" products. Order the results by descending order of the price. 
4. Show a list of the orderID's of the orders for which the order amount differs from the amount calculated through the ordersdetail. 
5. Which employee has processed most orders? Show the fullname of the employee and the amount of order he/she processed.
6. Give per employee and per orderdate the total order amount. Also add the name of the employee and the running total per employee when ordering by orderdate, an example can be seen below. Note that the running total is the sum of all orders where the employee is responsible at the order date's time.
    <table>
        <thead>
            <tr>
                <th>EmployeeId</th>
                <th>Lastname</th>
                <th>Firstname</th>
                <th>Orderdate</th>
                <th align="right">Sum (€)</th>
                <th align="right">Running (€)</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>1</td>
                <td>Davolio</td>
                <td>Nancy</td>
                <td>19/02/2000</td>
                <td align="right">848.00</td>
                <td align="right">848.00</td>
            </tr>
            <tr>
                <td>1</td>
                <td>Davolio</td>
                <td>Nancy</td>
                <td>26/02/2000</td>
                <td align="right">69.00</td>
                <td align="right">916.00</td>
            </tr>
                <tr>
                <td>1</td>
                <td>Davolio</td>
                <td>Nancy</td>
                <td>27/02/2000</td>
                <td align="right">5308.00</td>
                <td align="right">6224.00</td>
            </tr>
            </tr>
                <tr>
                <td>1</td>
                <td>Davolio</td>
                <td>Nancy</td>
                <td>2/12/2000</td>
                <td align="right">42.00</td>
                <td align="right">6266.00</td>
            </tr>
            </tr>
                <tr>
                <td>...</td>
                <td>...</td>
                <td>...</td>
                <td>...</td>
                <td align="right">...</td>
                <td align="right">...</td>
            </tr>
        </tbody>
    </table>

### Solution
A possible solution for these exercises can be found [here](solutions/subqueries-xtreme.md).
