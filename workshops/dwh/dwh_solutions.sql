-- DATEBASE ENTERTAINMENTAGENCY 
-- Queries OLTP

-- What is the average price per musical style per day based on contractprice of the engagement?
-- Only take into account StyleStrength = 1. Order by average price in descending way.

select ms.StyleID, ms.StyleName, avg(ContractPrice/(DATEDIFF(day,startdate,enddate)+1)) as AveragePrice
from Engagements eng join Entertainers ent
on eng.EntertainerID = ent.EntertainerID
join entertainer_Styles es on ent.EntertainerID = es.EntertainerID
join Musical_Styles ms on es.StyleID=ms.StyleID
where es.StyleStrength = 1
group by ms.StyleID, ms.StyleName
order by 3 DESC;

-- What are the earnings of each agent per quarter
-- Only take into account the commissionrate of the agent and the contractprice

WITH cte_1 (engagementnumber, agentid, contractprice, year, quarter)
AS
(SELECT engagementnumber, agentid, contractprice, YEAR(startdate),
CASE
WHEN MONTH(startdate) IN (1, 2,3) THEN 'First'
WHEN MONTH(startdate) IN (4, 5, 6) THEN 'Second'
WHEN MONTH(startdate) IN (7, 8, 9) THEN 'Third'
ELSE 'Fourth' 
END As Quarter
FROM engagements)

SELECT c.agentid, year, quarter, SUM(contractprice * commissionrate) As TotalCommission
FROM cte_1 c JOIN agents a ON c.agentid = a.agentid
GROUP BY c.agentid, quarter, year
ORDER BY c.agentid,year, quarter;


-- What are the customers that have booked the same entertainer every year.
WITH cte_3(NumberOfYears)
AS
(SELECT COUNT(DISTINCT YEAR(StartDate))
FROM Engagements)

SELECT CustomerID, EntertainerID, COUNT(DISTINCT YEAR(StartDate)) As NumberOfYear
FROM Engagements
GROUP BY  CustomerID, EntertainerID
HAVING COUNT(DISTINCT YEAR(StartDate)) = (SELECT NumberofYears FROM cte_3)
ORDER BY CustomerID ASC

-- Which Rhythm and Blues entertainer(s) is(are) the most popular one(s)?
-- Rhythm and Blues entertainers have R&B as one of their styles!

with cte_4(NumberOfEngagements) AS
(SELECT TOP 1 count(EngagementNumber) as TotalEngagements
from Entertainers e
join Engagements en on en.EntertainerID = e.EntertainerID
join Entertainer_Styles es on es.EntertainerID = en.EntertainerID
join Musical_Styles ms on es.StyleID = ms.StyleID
where StyleName = 'Rhythm and Blues'
group by e.EntertainerID, StyleName
order by count(EngagementNumber) DESC)

SELECT e.EntertainerID, EntStageName
from Entertainers e
join Engagements en on en.EntertainerID = e.EntertainerID
join Entertainer_Styles es on es.EntertainerID = en.EntertainerID
join Musical_Styles ms on es.StyleID = ms.StyleID
where StyleName = 'Rhythm and Blues'
group by e.EntertainerID, EntStageName
HAVING count(EngagementNumber) = (select numberOfEngagements from cte_4)

--alternatieve oplossing
WITH MostPopularEntertainerRB(MaxNumberOfEngagements) AS 
	(SELECT COUNT(en1.EngagementNumber) 
	FROM Musical_Styles ms1 JOIN Entertainer_Styles es1 ON ms1.StyleID = es1.StyleID
		JOIN Entertainers e1 ON e1.EntertainerID = es1.EntertainerID
		JOIN Engagements en1 ON e1.EntertainerID = en1.EntertainerID
	WHERE ms1.StyleName = 'Rhythm and Blues'
	GROUP BY e1.EntertainerID)

SELECT e.EntertainerID, e. EntStageName--, es.stylestrength
FROM Musical_Styles ms JOIN Entertainer_Styles es ON ms.StyleID = es.StyleID
	JOIN Entertainers e ON e.EntertainerID = es.EntertainerID
	JOIN Engagements en ON e.EntertainerID = en.EntertainerID
WHERE ms.StyleName = 'Rhythm and Blues'
GROUP BY e.EntertainerID, e. EntStageName--, es.stylestrength
HAVING COUNT(en.EngagementNumber) = 
	(SELECT max(MaxNumberOfEngagements) 
	 FROM MostPopularEntertainerRB)

-- What is the TOP 3 of most booked musical styles
-- Assume the musical style of an engagement is the style with strength=1 from the entertainer
-- eerste stap: count van de engagements per musical style
-- tweede stap: dense_rank
-- derde stap: top 3

with cte_5_1 (stylename, TotalEngagements)
AS
(SELECT StyleName, count(EngagementNumber) as TotalEngagements
from Entertainers e
join Engagements en on en.EntertainerID = e.EntertainerID
join Entertainer_Styles es on es.EntertainerID = en.EntertainerID
join Musical_Styles ms on es.StyleID = ms.StyleID
where StyleStrength = 1
group by StyleName),

cte_5_2(stylename, totalEngagments, ranking)
AS
(SELECT styleName, totalEngagements,
rank() OVER (order by totalEngagements DESC) AS RankEngagements
FROM cte_5_1)

SELECT * FROM cte_5_2
WHERE ranking <= 3


-- Give for each year the top 3 of most popular entertainers 
-- (= entertainers with most engagements for that year)
-- eerste stap: count van de engagements per entertainer per year
-- tweede stap: dense_rank
-- derde stap: top 3

WITH NumberOfEngagementsPerYear(EntertainerID, YearEngagement,NumberOfEngagements) AS
(SELECT entertainerid, year(startdate), COUNT(engagementnumber)
FROM engagements
GROUP BY entertainerid, year(startdate)),

RankingNumberOfEngagements(YearEngagement, EntertainerID, NumberOfEngagements,DenseRankEngagements) AS
(SELECT YearEngagement, EntertainerID, NumberOfEngagements, dense_rank() OVER (partition by YearEngagement order by NumberOfEngagements DESC) AS DenseRankEngagements
FROM NumberOfEngagementsPerYear)

SELECT * FROM RankingNumberOfEngagements
WHERE DenseRankEngagements <= 3



-- Queries DWH
-- query over de most popular Rhytm and Blues entertainer
-- query over de TOP 3 most booked styles


-- What is the average price per musical_style per day based on contractprice of the engagement?

SELECT ms.StyleName, AVG(ContractPrice / numberOfDays) As AveragePrice
FROM FactEngagements f JOIN DimMusical_Styles ms
ON f.Musical_StyleKey = ms.Musical_StyleKey
GROUP BY ms.StyleName


-- What are the earnings of each agent per quarter
SELECT d.QuarterName, d.Year, f.AgentKey, SUM(f.CommissionAgent) 
FROM FactEngagements f INNER JOIN DimDate d ON f.StartDateKey = d.DateKey
GROUP BY f.AgentKey, d.Year,d.QuarterName 
ORDER BY f.AgentKey, d.Year,d.QuarterName 


-- What are the customers that have booked the same entertainer every year.

SELECT Customerid, EntertainerKey, COUNT(DISTINCT d.year) As NumberOfYears
FROM FactEngagements f INNER JOIN DimDate d ON f.StartDateKey = d.DateKey
JOIN DimCustomers c on f.CustomerKey = c.CustomerKey
GROUP BY Customerid, EntertainerKey
HAVING COUNT(DISTINCT d.year) = (select COUNT(distinct(year)) from DimDate d join FactEngagements f on d.DateKey=f.StartDateKey)
order by 1


-- Which Rhythm and Blues entertainer(s) is(are) the most popular one(s)?
-- Rhythm and Blues entertainers have R&B as one of their styles!

with cte_rb(NumberOfEngagements) AS
(SELECT TOP 1 COUNT(f.EngagementKey)
FROM FactEngagements f JOIN  DimEntertainers e
ON f.EntertainerKey = e.EntertainerKey
JOIN DimMusical_Styles m
ON f.Musical_StyleKey = m.Musical_StyleKey
WHERE m.StyleName = 'Rhythm and Blues'
GROUP BY f.EntertainerKey
ORDER BY 1 DESC)

SELECT f.EntertainerKey,e.EntStageName,COUNT(EngagementKey) As NumberOfEngagements
FROM FactEngagements f JOIN  DimEntertainers e
ON f.EntertainerKey = e.EntertainerKey
JOIN DimMusical_Styles m ON f.Musical_StyleKey = m.Musical_StyleKey
WHERE m.StyleName = 'Rhythm and Blues'
GROUP BY f.EntertainerKey,e.EntStageName
HAVING COUNT(EngagementKey) = (SELECT NumberOfEngagements FROM cte_rb)

-- What is the TOP 3 of most booked musical styles

WITH cte_5_1(stylename, numberofengagements) AS
(SELECT ms.StyleName, COUNT(f.EngagementKey) As NumberOfEngagements
FROM FactEngagements f INNER JOIN DimMusical_Styles ms ON f.Musical_StyleKey = ms.Musical_StyleKey
GROUP BY ms.StyleName
)
,
cte_5_2(stylename, totalEngagements, ranking) AS
(SELECT styleName, NumberOfEngagements,
rank() OVER (order by NumberOfEngagements DESC) AS RankEngagements
FROM cte_5_1)

SELECT * 
FROM cte_5_2 
WHERE ranking <= 3


-- Give for each year the top 3 of most popular entertainers (= entertainers with most engagements for that year)
--! bij deze oorspronkelijke oplossing ontbrak het laatste deel
WITH cte_engagements_per_year(year, entertainerkey, numberofengagements) AS

(SELECT d.year, f.EntertainerKey, COUNT(f.EngagementKey) As NumberOfEngagements
FROM DimDate d JOIN FactEngagements f ON d.DateKey = f.StartDateKey
GROUP BY d.year, f.EntertainerKey)
,
rankengagements(year,entertainer,number,rank) as
(
select YEAR,entertainerkey,numberofengagements,
RANK() over (partition by year order by numberofengagements desc)
from cte_engagements_per_year)

select year,rank,entertainer,number
from rankengagements
where rank <= 3


-- Query to fill FactTable

insert into factengagements(EngagementKey,StartDateKey,EndDateKey, NumberOfDays, StartTime, StopTime, NumberOfHours, CustomerKey,AgentKey,EntertainerKey,
Musical_StyleKey, ContractPrice, CommissionAgent)
select DISTINCT e.EngagementNumber,CAST(format(e.startdate,'yyyyMMdd') as int),CAST(format(e.enddate,'yyyyMMdd') as int),
DATEDIFF(day, e.startdate, e.enddate)+1,-- + 1 because datediff between equal dates = 0
e.StartTime, e.StopTime, DateDIFF(hour, e.StartTime, e.StopTime) + case when e.StopTime<e.StartTime then 24 else 0 end,
c.CustomerKey,a.AgentID,ent.EntertainerID,s.StyleID, e.ContractPrice,e.ContractPrice * a.CommissionRate
from EntertainmentAgency.dbo.Engagements e
join DimCustomers c on e.CustomerID = c.CustomerID
join EntertainmentAgency.dbo.Entertainers ent on ent.EntertainerID=e.EntertainerID
join EntertainmentAgency.dbo.Entertainer_Styles s on ent.EntertainerID=s.EntertainerID
join EntertainmentAgency.dbo.Agents a on e.AgentID = a.AgentID
where 
/* Slowly Changing Dimension DimCustomer */
e.StartDate >= c.start and (c.[end] is null or e.StartDate <= c.[end])
AND /* pick dominant style */
s.StyleStrength = 1
AND /* always increment, never delete, also make sure it runs from an empty factengagements table */
e.EngagementNumber > (select isnull(max(EngagementKey),0) from FactEngagements)












