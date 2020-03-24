# Solution - Data Definition Language

## Exercise 1
Recreate the following database called `Game_db` based on the following schema:
![img](../images/diagram-exercise-gamedb.png)

### Steps to accomplish this exercise:
1. Create a database named `Game_db`, then refresh your object explorer in SQL Management Studio so that the database is visible. Then execute the statement USE `Game_db` to make the database active as the default database.
    ```sql
    CREATE DATABASE Game_db;
    GO
    USE Game_db;
    ```
2. Create the `Game` table.
    ```sql
    CREATE TABLE Game
    (
        [Name]             VARCHAR(20),
        CONSTRAINT PK_Game PRIMARY KEY([Name])
    );
    ```
3. Create the `Goalcard` table.
    ```sql
    CREATE TABLE Goalcard​
    (
        Id              VARCHAR(5),
        [Name]          VARCHAR(30),
        CONSTRAINT PK_Goalcard PRIMARY KEY(Id)
    );
    ```
4. Create the `Hallcard` table.
    ```sql
    CREATE TABLE Hallcard
    (
        Id              VARCHAR(5),
        [Type]          VARCHAR(8),
        Treasure        VARCHAR(20),
        CONSTRAINT PK_Hallcard PRIMARY KEY(Id)
    );
    ```
5. Create the `Player` table
    - The `Id` column is automagically determined by the database engine
    -  Make sure to add a `constraint` called `CH_Player_Colors` so that the `Player` can only choose a `red` or `black` color, NULL is also fine.
    ```sql
    CREATE TABLE Player
    (
        Id      	    INT IDENTITY,
        [Name]          VARCHAR(100) NOT NULL,
        Birthyear       INT,
        Color           VARCHAR(10),
        CurrentSquare   VARCHAR(20),
        IsTurnPlayer    BIT,
        GameName        VARCHAR(20),
        CONSTRAINT PK_Player PRIMARY KEY(Id),
        CONSTRAINT FK_Player_Game FOREIGN KEY(GameName) REFERENCES Game([Name]),
        CONSTRAINT CH_Player_Color CHECK (Color IN ('red','black'))
    );
    ```
6. Create the `Game_Hallcard` table.
    ```sql
    CREATE TABLE Game_Hallcard
    (
        GameName	    VARCHAR(20),
        CardId          VARCHAR(5),
        Direction       VARCHAR(20),
        Position        VARCHAR(20),
        CONSTRAINT PK_Game_Hallcard PRIMARY KEY(GameName, CardId),
        CONSTRAINT FK_Game_Hallcard_Gamename FOREIGN KEY(GameName) REFERENCES Game([Name]),
        CONSTRAINT FK_Game_Hallcard_Hallcard FOREIGN KEY(CardId) REFERENCES Hallcard(Id)
    );
    ```
7. Create the `Player_Goalcard` table.
    ```sql
    CREATE TABLE Player_Goalcard​
    (
        PlayerId        INT,
        GoalId          VARCHAR(5),
        [Order]         INT,
        CONSTRAINT PK_Player_Goalcard PRIMARY KEY(PlayerId, GoalId),
        CONSTRAINT FK_Player_Goalcard_Player FOREIGN KEY(PlayerId) REFERENCES Player(Id),
        CONSTRAINT FK_Player_Goalcard_Goalcard FOREIGN KEY(GoalId) REFERENCES Goalcard(Id)
    );
    ```
8. Add an extra column `Email` to the `Player` entitytype, which is a `VARCHAR` of max. 50 characters long.
    ```sql
    ALTER TABLE Player
    ADD Email VARCHAR(50);
    ```
9. Adjust the column `Email` from the `Player` entity type to a maximum length of 100 characters.
    ```sql
    ALTER TABLE Player
    ALTER COLUMN Email VARCHAR(100);
    ```
10. Add an extra column `Phonenumber` to the `Player` entity type, which entitytype would be a good fit?
    ```sql
    ALTER TABLE Player
    ADD Phonenumber VARCHAR(25);
    ```
    > Why not an `INT` value? 
11. Remove the column `Phonenumber` fron the `Player` entity type since we don't need it anymore.
    ```sql
    ALTER TABLE Player
    DROP COLUMN Phonenumber;
    ```

## Exercise 2
Given the following Relational Model:
- Employee(<ins>Id</ins>, Name, Email)
- Project(<ins>Name</ins>, Description, StartDate, EndDate)
- Allocation(<ins>EmployeeId, ProjectName</ins>, HoursWorked) 
    - IR: EmployeeId References Employee(Id), mandatory
    - IR: ProjectName References Project(Name), mandatory

Complete the following tasks:
Before we start, we are dropping the tables if they exist.
> Remark: The order of the deletion is important due to `constraints`.
```sql
DROP TABLE IF EXISTS Allocation;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Project;
```

1. Create the table `Employee`
    - IR: `Id` is created by the database engine.
    - IR: `Name` is required.
    - IR: `Email` is unique and required.
    ```sql
    CREATE TABLE Employee 
    (
        Id INT IDENTITY, 
        [Name] VARCHAR(30) NOT NULL, 
        Email  VARCHAR(30) NOT NULL,
        CONSTRAINT PK_Employee PRIMARY KEY(Id),
        CONSTRAINT UX_Employee_Name UNIQUE([Name])
    ) 
    ```
2. Create the table `Project`
    - IR: `BeginDate` should always we smaller or equal to the `EndDate`.
    - IR: `Name` should only contain [alphanumeric characters](https://whatis.techtarget.com/definition/alphanumeric-alphameric).
    ```sql
    CREATE TABLE Project 
    (
        [Name] VARCHAR(50), 
        [Description] VARCHAR(30), 
        StartDate DATE, 
        EndDate DATE,
        CONSTRAINT PK_Project PRIMARY KEY([Name]),
        CONSTRAINT CH_Project_Begin_LessThan_End CHECK (StartDate <= EndDate),
        CONSTRAINT CH_Project_Name_Alphanumeric  CHECK ([Name] LIKE '[0-9a-zA-Z]{1,50}')
    ) 
    ```
3. Create the table `Allocation`
    - The default for `HoursWorked` is 3.
    - If a `Project` is deleted, so should the `allocation(s)`.
    - If an `Employee` is deleted, so should the `allocation(s)`.
    ```sql
    CREATE TABLE Allocation
    (
    EmployeeId INT, 
    ProjectName VARCHAR(50), 
    HoursWorked INT CONSTRAINT DF_HoursWorked DEFAULT 3,
    CONSTRAINT PK_Allocation PRIMARY KEY(EmployeeId, ProjectName),
    CONSTRAINT FK_Allocation_Employee FOREIGN KEY(EmployeeId) REFERENCES Employee(Id) ON UPDATE CASCADE,
    CONSTRAINT FK_Allocation_Project FOREIGN KEY(ProjectName) REFERENCES Project([Name]) 
        ON UPDATE CASCADE
        ON DELETE CASCADE
    ) 
    ```
4. Write an ALTER statement removing the constraint which ensures that `Email`s must be unique in the `Employee` table.
    ```sql
    ALTER TABLE Employee DROP CONSTRAINT UX_Employee_Name;
    ```

## Deep Dive:
1. Why is it sometimes better/mandatory to embrace certain table/column/... names like `Name`, `Type`, `Order`, etc. with square brackets like the following `[Name], [Type], [Order]` ?
    - [This StackOverflow post](https://stackoverflow.com/questions/3551284/sql-serverwhat-do-brackets-mean-around-column-name) can give some clarification.

## Exercises
Click [here](../ddl.md) to go back to the exercises.