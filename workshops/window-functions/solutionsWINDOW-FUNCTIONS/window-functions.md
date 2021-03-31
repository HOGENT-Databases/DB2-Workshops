# Solutions - Window Functions
In this workshop you'll learn the use of `window functions` and partitioning data of the result set.
> A window function performs a calculation across a set of table rows that are somehow related to the current row. This is comparable to the type of calculation that can be done with an aggregate function. But unlike regular aggregate functions, use of a window function does not cause rows to become grouped into a single output row — the rows retain their separate identities. Behind the scenes, the window function is able to access more than just the current row of the query result.

## Database schema - Corona
![Diagram Corona](/workshops/shared/images/diagrams/diagram-corona.png)

## Exercises
1. `The total_cases` column is a calculated column. Recalculate this column and calculate for each line the difference between this column and your calculation. 
    ```sql
    SELECT 
    [date]
    ,[location]
    ,new_cases
    ,total_cases,
    total_cases-SUM(new_cases) OVER (PARTITION BY location ORDER BY date) AS [error (>0 means overestimatioin)]
    FROM Corona;
    ```
2. Show for Belgium, France and the Netherlands a `ranking` (per country) of the days with the most new cases. Show only the top 5 days per country. 
    ```sql
    WITH ranking AS
    (SELECT 
     date
    ,location
    ,new_cases
    ,RANK() OVER (PARTITION BY location ORDER BY new_cases DESC) AS rank_new_cases
    FROM Corona
    WHERE location IN ('Belgium','France','Netherlands'))

    SELECT
     location
    ,rank_new_cases
    ,date
    ,new_cases 
    FROM ranking 
    WHERE rank_new_cases <= 5
    ORDER BY location, rank_new_cases;
    ```
3. It is assumed the virus is "under control" in a country if during three consecutive days 
the number of new cases decreases. In which countries and on which days was the virus "under control"?
    ```sql
    WITH previous_days AS
    (SELECT 
    location
    ,date
    ,new_cases,
    LAG(new_cases) OVER (PARTITION BY location ORDER BY date) dayminus1,
    SUM(new_cases) OVER (PARTITION BY location ORDER BY date ROWS BETWEEN 2 PRECEDING AND 2 PRECEDING) dayminus2,
    SUM(new_cases) OVER (PARTITION BY location ORDER BY date ROWS BETWEEN 3 PRECEDING AND 3 PRECEDING) dayminus3
    FROM corona)

    SELECT
     date
    ,location
    ,new_cases
    ,dayminus1
    ,dayminus2
    ,dayminus3
    ,CASE WHEN 
            new_cases < dayminus1 
        AND dayminus1 < dayminus2 
        AND dayminus2 < dayminus3 
        THEN 'YES' 
        ELSE 'NO' END AS [under control]
    FROM previous_days
    WHERE 
    (CASE WHEN 
            new_cases < dayminus1 
        AND dayminus1 < dayminus2 
        AND dayminus2 < dayminus3 
        THEN 'YES' 
        ELSE 'NO' END) = 'YES'
    ORDER BY location, date
    ```
4. You can only compare countries if you take into account there population. Make a ranking (high to low) of countries for the maximum number of total cases until now per million inhabitants. However, as we have seen in exercise 1, you can’t fully trust the total_cases column, so use your own calculation instead. 
    ```sql
    WITH total_cases(date,country,total) AS 
    (SELECT
     date
    ,location
    ,(SUM(new_cases) OVER (PARTITION BY location ORDER BY date)) FROM Corona)

    SELECT
     t.country
    ,MAX(total)*1000000.0/ct.population AS total_cases_per_mio
    ,ct.population
    FROM total_cases t 
        JOIN country ct ON t.country=ct.country
    GROUP BY
     t.country
    ,ct.population
    ORDER BY 2 DESC;
    ```

## Exercises
Click [here](../window-functions.md) to go back to the exercises.

