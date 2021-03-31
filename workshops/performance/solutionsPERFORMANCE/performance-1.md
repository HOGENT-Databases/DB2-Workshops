# Solutions - Performance 1
## Showing all tables and their row count
Sometimes it can be easy to see which table has the most rows, but numbers speak louder than words. Therefore you can use the following query to get all tables and their rowcount
```sql
CREATE TABLE #counts
(
    table_name varchar(255),
    row_count int
)

EXEC sp_MSForEachTable @command1='INSERT #counts (table_name, row_count) SELECT ''?'', COUNT(*) FROM ?'
SELECT table_name, row_count FROM #counts ORDER BY row_count DESC
DROP TABLE #counts
```
> Alternatives are also fine. for example by using a cursor.

- A table scan vs. an index scan 
- Look at the execution plan
    - Factor 1 / 100 
- Using `SELECT *` is a bad practise since most of the time you're overfetching data.
    - If you're familiar with an Object Relational Mapper(ORM) like Entity Framework Core (EF) or Dapper for example. You should check out what the queries are being send to the database. A lot of performance issues in the real world are due to overfetching data.