# Workshop - Window Functions
In this workshop you'll learn the use of `window functions` and partitioning data of the result set.
> A window function performs a calculation across a set of table rows that are somehow related to the current row. This is comparable to the type of calculation that can be done with an aggregate function. But unlike regular aggregate functions, use of a window function does not cause rows to become grouped into a single output row — the rows retain their separate identities. Behind the scenes, the window function is able to access more than just the current row of the query result.

## Prerequisites
- SQL Server 2017+ Installed;
- **S**QL **S**erver **M**anagement **S**tudio Installed;
- A running copy of the database **corona**.
    > You can download the database by using [this link](https://github.com/HOGENT-Databases/DB2-Workshops/raw/master/databases/corona.bak), information on how to restore a database can be found [here](https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/restore-a-database-backup-using-ssms?view=sql-server-ver15). 

## Database schema - Corona
![Diagram Corona](/workshops/shared/images/diagrams/diagram-corona.png)

## Getting started
- Achieve the resultsets per exercise using window functions.

## Exercises
1. `The total_cases` column is a pre-calculated column (see schema). Recalculate this column and calculate for each line the difference between this column and your calculation. 
    |date      |location                        |new_cases|total_cases|error (>0 means overestimation)|
    |----------|--------------------------------|---------|-----------|--------------------------------|
    |2020-02-25|Afghanistan                     |0        |1          |1                               |
    |2020-02-26|Afghanistan                     |0        |1          |1                               |
    |2020-02-27|Afghanistan                     |0        |1          |1                               |
    |2020-02-28|Afghanistan                     |0        |1          |1                               |
    |2020-02-29|Afghanistan                     |0        |1          |1                               |
    |2020-03-01|Afghanistan                     |0        |1          |1                               |
    |2020-03-02|Afghanistan                     |0        |1          |1                               |
    |2020-03-03|Afghanistan                     |0        |1          |1                               |
    |2020-03-04|Afghanistan                     |0        |1          |1                               |
    |2020-03-05|Afghanistan                     |0        |1          |1                               |
    |2020-03-06|Afghanistan                     |0        |1          |1                               |
    |2020-03-07|Afghanistan                     |0        |1          |1                               |
    |2020-03-08|Afghanistan                     |3        |4          |1                               |
    |2020-03-09|Afghanistan                     |0        |4          |1                               |
    |2020-03-10|Afghanistan                     |0        |4          |1                               |
    |2020-03-11|Afghanistan                     |0        |4          |1                               |
    |2020-03-12|Afghanistan                     |3        |7          |1                               |
    |2020-03-13|Afghanistan                     |0        |7          |1                               |
    |2020-03-14|Afghanistan                     |0        |7          |1                               |
    |2020-03-15|Afghanistan                     |3        |10         |1                               |
    |2020-03-16|Afghanistan                     |6        |16         |1                               |
    |2020-03-09|Albania                         |0        |2          |2                               |
    |2020-03-10|Albania                         |0        |2          |2                               |
    |2020-03-11|Albania                         |8        |10         |2                               |
    |2020-03-12|Albania                         |0        |10         |2                               |
    |...|...                                    |...      |...        |...                             |
    > Not all results are shown.

2. Show for Belgium, France and the Netherlands a `ranking` (per country) of the days with the most new cases. Show only the top 5 days per country. 
    |location   |rank_new_cases|date      |new_cases|
    |-----------|--------------|----------|---------|
    |Belgium    |1             |2020-03-16|396      |
    |Belgium    |2             |2020-03-14|285      |
    |Belgium    |3             |2020-03-15|90       |
    |Belgium    |4             |2020-03-08|60       |
    |Belgium    |5             |2020-03-07|59       |
    |France     |1             |2020-03-16|911      |
    |France     |2             |2020-03-15|829      |
    |France     |3             |2020-03-14|780      |
    |France     |4             |2020-03-13|591      |
    |France     |5             |2020-03-12|495      |
    |Netherlands|1             |2020-03-14|190      |
    |Netherlands|2             |2020-03-16|176      |
    |Netherlands|3             |2020-03-15|155      |
    |Netherlands|4             |2020-03-12|121      |
    |Netherlands|5             |2020-03-13|111      |
3. It is assumed the virus is "under control" in a country if during three consecutive days 
the number of new cases decreases. In which countries and on which days was the virus "under control"?
    |date      |location   |new_cases|dayminus1|dayminus2|dayminus3|under control|
    |----------|-----------|---------|---------|---------|---------|-------------|
    |2020-03-16|Albania    |4        |5        |10       |13       |YES          |
    |2020-02-13|China      |1820     |2022     |2473     |2984     |YES          |
    |2020-02-20|China      |395      |1752     |1893     |19461    |YES          |
    |2020-02-24|China      |220      |650      |823      |894      |YES          |
    |2020-03-04|China      |118      |130      |206      |574      |YES          |
    |2020-03-09|China      |45       |46       |102      |146      |YES          |
    |2020-03-10|China      |20       |45       |46       |102      |YES          |
    |2020-03-11|Egypt      |0        |4        |7        |45       |YES          |
    |2020-03-13|Indonesia  |0        |7        |8        |13       |YES          |
    |2020-03-10|Iran       |595      |743      |1076     |1234     |YES          |
    |2020-03-11|Iraq       |0        |1        |6        |10       |YES          |
    |2020-03-10|Japan      |26       |33       |47       |59       |YES          |
    |2020-03-07|Oman       |0        |1        |3        |6        |YES          |
    |2020-03-13|Philippines|0        |3        |16       |23       |YES          |
    |2020-02-18|Singapore  |2        |3        |5        |9        |YES          |
    |2020-03-09|South Korea|248      |367      |483      |518      |YES          |
    |2020-03-10|South Korea|131      |248      |367      |483      |YES          |
    |2020-03-14|South Korea|107      |110      |114      |242      |YES          |
    |2020-03-15|South Korea|76       |107      |110      |114      |YES          |
    |2020-03-16|South Korea|74       |76       |107      |110      |YES          |
    |2020-03-16|Sweden     |68       |149      |155      |159      |YES          |

4. You can only compare countries if you take into account there population. Make a ranking (high to low) of countries for the maximum number of total cases until now per million inhabitants. However, as we have seen in exercise 1, you can’t fully trust the total_cases column, so use your own calculation instead. 
    |country   |total_cases_per_mio|population|
    |----------|-------------------|----------|
    |San Marino|3111.004751974291  |29251     |
    |Iceland   |454.260023781848   |299388    |
    |Qatar     |451.794130968341   |885359    |
    |Italy     |425.658117420711   |58133509  |
    |Bahrain   |304.902052005124   |698585    |
    |Switzerland|292.267316539459   |7523934   |
    |Monaco    |245.828596011431   |32543     |
    |Norway    |233.364130458356   |4610820   |
    |Iran      |218.217236081073   |68688433  |
    |Faeroe Islands|211.658129788765   |47246     |
    |Spain     |191.891438161474   |40397842  |
    |Liechtenstein|176.538088092505   |33987     |
    |South Korea|168.588241654938   |48846823  |
    |Denmark   |164.567196529008   |5450661   |
    |Estonia   |154.039807208609   |1324333   |
    |Brunei    |129.136315240193   |379444    |
    |Austria   |116.808741248498   |8192880   |
    |...       |...                |...   |
    > Not all results are shown.


### Solution
A possible solution for these exercises can be found [here](solutions/window-functions.md).
