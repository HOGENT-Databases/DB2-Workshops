# Workshop - Performance
In this workshop you'll learn how to optimize the performance of SQL queries by applying `indices` and using best practises. 

## Prerequisites
In this workshop we'll use the a fragment of the famous Stack Overflow database (years 2008-2010). Because of the size we don’t deliver a backup file but we restore the database directly from the datafile `StackOverflow2010.mdf`. 

1. Download the `.mdf` file from [here](http://downloads.brentozar.com.s3.amazonaws.com/StackOverflow2010.7z)
    > Caution the zipped size is about 1 Gigabyte, unzipped the Database is about 10 Gigabyte. You can unzip the `.7z` file using [7 zip](https://www.7-zip.org/download.html) 
2. Copy the file in  your  SQL  Server  data  directory `C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA` 
3. In  SQL Server Management Studio (SSMS), right  click  on  Databases,  Attach, Add and browse to the `.mdf` file.

## Exercise 1 - Exploration
Since the folks at Stack Overflow were so friendly to open-source their data, we can take a look around in the database. 

### Call to action
0. Execute the following command to change ownership of the database:
    ```sql
    use [StackOverflow2010] EXEC sp_changedbowner 'sa'
    ```
1. Draw the database diagram using SSMS;
2. Which table will contain the most amount of records, in other words which table is the biggest?
3. How many records does the table hold?
    > Please note that this database is just a small subset of their actual data.
4. Execute the following query
    ```sql
    SELECT * FROM Posts
    ```
5. How many seconds does it take on your computer? 
6. Why does it take so long? 
7. How many seconds does the following query take?
    ```sql
    SELECT Id FROM Posts
    ``` 
8. Is there a big difference? Explain why by using the correct terms found in the PowerPoint presentation.

### Solution
A possible solution of exercise 1 can be found [here](solutions/performance-1.md).

---

## Exercise 2 - Optimization
So it's clear that there is quite a lot of data (well atleast more then you're used to work with in the past). It's time to optimize some queries by using best practises and indices.

### Call to action
1.  Find the best way to select the following columns for all `posts` created in `2008`:
    - `id`;
    - `body`;
    - `lasteditordisplayname`.  
2. Order `posts` by `score` and (in case of equal score) `commentcount` both in `descending` order. 
Show the following columns of all the `posts` in the most efficient way:
    - `id`;
    - `score`;
    - `commentcount`
    - `title`
    > How can you check if your result is executed in the most efficient way? Is the actual table used or are you using an index?  
3. Create an index on title. Then explain the difference (in the execution plan) between following queries:  
    ```sql
    SELECT Id
        ,Title 
    FROM Posts  
    WHERE Title LIKE '%php%'; 
    ``` 
    ```sql
    SELECT Id
        ,Title 
    FROM Posts  
    WHERE Title LIKE 'php%';
    ```

### Solution
A possible solution of exercise 2 can be found [here](solutions/performance-2.md).

---
