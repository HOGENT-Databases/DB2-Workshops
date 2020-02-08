# Workshop - Revisit the basics : Planten
In this workshop you'll learn how to consult, filter, aggregate, join, order and project data coming from the relational database called `Planten` by using the following statements:
- `SELECT`
- `DISTINCT`
- `WHERE`
- `ORDER BY`
- `GROUP BY`
- `[INNER|LEFT|OUTER] JOIN`

## Prerequisites
- SQL Server 2017+ Installed;
- **S**QL **S**erver **M**anagement **S**tudio Installed;
- A running copy of the database **Planten**.
    > You can download the database by using [this link](https://github.com/HOGENT-Databases/DB2-Workshops/raw/master/databases/planten.bak), information on how to restore a database can be found [here](https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/restore-a-database-backup-using-ssms?view=sql-server-ver15).

## Getting started
Below you'll find multiple exercises, for each exercise do the following:
1. Investigate the database schema of the **Planten** database;
2. Figure out which:
    - table(s) you will be consulting;
    - columns you will be projecting;
    - filters that are needed;
    - aggregations that are mandatory;
    - sort order is necessary.
3. Write the query;
4. Check your results.

---

## Database schema - Planten
![img](/workshops/shared/images/diagrams/diagram-planten.png)

## Exercises
The exercises are just a link to the exercises of last year's databases 1 course.
> Please note that in Databases 1 we used MySQL instead of Microsoft SQL Server. There can be subtly differences in the syntax. 

| Exercise | Subject | 
| ----- | ---- |
| [01 - Consult](https://github.com/HOGENT-Databases/DB1-Workshops/blob/master/workshops/06-SQL/exercises/exercise-1.md)    | Select, Where, Order By  | 
| [02 - Aggregate](https://github.com/HOGENT-Databases/DB1-Workshops/blob/master/workshops/06-SQL/exercises/exercise-2.md)  | Statistical Functions    |
| [03 - Join](https://github.com/HOGENT-Databases/DB1-Workshops/blob/master/workshops/06-SQL/exercises/exercise-3.md)       | Join                     |
| [04 - Manipulate](https://github.com/HOGENT-Databases/DB1-Workshops/blob/master/workshops/06-SQL/exercises/exercise-4.md) | C~~R~~UD                 | 
| [05 - Define](https://github.com/HOGENT-Databases/DB1-Workshops/blob/master/workshops/06-SQL/exercises/exercise-5.md)     | DDL                      | 