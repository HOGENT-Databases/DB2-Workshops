# Workshop - Revisit the basics : Tennis
In this workshop you'll learn how to consult, filter, aggregate, join, order and project data coming from the relational database called `Tennis` by using the following statements:
- `SELECT`
- `DISTINCT`
- `WHERE`
- `ORDER BY`
- `GROUP BY`
- `[INNER|LEFT|OUTER] JOIN`

## Prerequisites
- SQL Server 2017+ Installed;
- **S**QL **S**erver **M**anagement **S**tudio Installed;
- A running copy of the database **Tennis**.
    > You can download the database by using [this link](https://github.com/HOGENT-Databases/DB2-Workshops/raw/master/databases/tennis.bak), information on how to restore a database can be found [here](https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/restore-a-database-backup-using-ssms?view=sql-server-ver15).

## Getting started
Below you'll find multiple exercises, for each exercise do the following:
1. Investigate the database schema of the **Tennis** database;
2. Figure out which:
    - table(s) you will be consulting;
    - columns you will be projecting;
    - filters that are needed;
    - aggregations that are mandatory;
    - sort order is necessary.
3. Write the query;
4. Check your results.

---

## Database schema - Tennis
![img](/workshops/shared/images/diagrams/diagram-tennis.png)

## Exercises
1. In which towns do more than 5 players live, provide the name of the town and the amount of players who live there.
2. Give the name and total penalty amount for each player that already has a total of more than or equal to 150 euro in penalties.

> If you need more exercises please check the Planten exercises.

### Solution
A possible solution for these exercises can be found [here](solutions/basic-tennis.md).
