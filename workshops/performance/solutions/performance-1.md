# Solutions - Performance 1
- A table scan vs. an index scan 
- Look at the execution plan
    - Factor 1 / 100 
- Using `SELECT *` is a bad practise since most of the time you're overfetching data.
    - If you're familiar with an Object Relational Mapper(ORM) like Entity Framework Core (EF) or Dapper for example. You should check out what the queries are being send to the database. A lot of performance issues in the real world are due to overfetching data.