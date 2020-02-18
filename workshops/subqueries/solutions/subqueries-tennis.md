# Solutions - Subqueries
## Dataset - Tennis
![img](/workshops/shared/images/diagrams/diagram-tennis.png)

1. Give the name and number of the players that already got more penalties than
they played matches.
   ```sql
    SELECT 
     Player.Name
    ,Player.PlayerNo
    FROM Players Player
    WHERE 
        (
        SELECT COUNT(Penalty.PlayerNo) 
        FROM Penalties Penalty
        WHERE Penalty.PlayerNo = Player.PlayerNo) 
        >
        (
        SELECT COUNT(Match.MatchNo) 
        FROM Matches Match 
        WHERE Match.PlayerNo = Player.PlayerNo
        );
    ```

## Exercises
Click [here](../subqueries-tennis.md) to go back to the exercises.
