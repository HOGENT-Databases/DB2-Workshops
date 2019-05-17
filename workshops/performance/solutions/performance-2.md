# Solutions - Performance 2
## Exercise 2.1
### Index
```sql
CREATE INDEX IX_Posts_CreationYear 
ON Posts(CreationDate) 
INCLUDE (Body,
         LastEditorDisplayName); 
```
### Query
> The following is an example of a **bad** query, don't try this at home.
```sql
SELECT Id
      ,Body
      ,LastEditorDisplayName
FROM Posts 
WHERE Year(creationdate) = 2008; -- Usage of a function
```
> The following is an example of a **good** query rather do this instead.
```sql
SELECT Id
      ,Body
      ,LastEditorDisplayName
FROM Posts 
where CreationDate BETWEEN '2008-01-01' AND '2008-12-31';
```
## Exercise 2.2
### Index
```sql
CREATE INDEX IX_Posts_Score_CommentCount 
ON Posts(Score,CommentCount) 
INCLUDE (Title); -- Why are we using an Include here?
```
### Query
```sql
SELECT Id
      ,Score,CommentCount,Title 
FROM Posts 
ORDER BY Score DESC, CommentCount DESC; 
```
### Exercise 2.3
Usage of the `%` at the **start** or in the **middle** of a `LIKE` statement is to be avoided, especially at the start. However if the use case really needs this kind of query, there is not that much you can do about it.
