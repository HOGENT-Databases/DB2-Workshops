# Solutions - Revisit the basics
## Dataset - Tennis
![img](/workshops/shared/images/diagrams/diagram-tennis.png)

1. In which towns do more than 5 players live, provide the name of the town and the amount of players who live there.
    ```sql
    SELECT 
     Town
    ,count(*) 
    FROM Players 
    GROUP BY Town 
    HAVING COUNT(*) > 5;
    ```
2. Give the name and total penalty amount for each player that already has a total of more than or equal to 150 euro in penalties.
    ```sql
    SELECT 
     p.playerno
    ,SUM(pe.amount)
    FROM players p 
        JOIN penalties pe ON p.playerno = pe.playerno
    GROUP BY p.playerno
    HAVING SUM(pe.amount) >= 150;
    ```
## Exercises
Click [here](../basic-tennis.md) to go back to the exercises.
