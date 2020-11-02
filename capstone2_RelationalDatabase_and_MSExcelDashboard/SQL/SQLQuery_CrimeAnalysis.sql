USE SG_Crime
GO

/* Create VIEW that combined Crime_log and Crime_type table */
CREATE VIEW [vwCrimeLog_CrimeType]
AS 
SELECT c.Year, type.Type AS 'Crime_type',
	c.Total AS 'Total_crime', c.PoliceStation_ID
FROM [Crime_log] AS c
INNER JOIN [Crime_type] AS type
ON c.Crime_code = type.Crime_code;


/* Insights 1: Crime trend overal years based on Different classifications
Overall, Selected Major Offences, 5 Preventable Crimes, UML & Harrassment */
--- CREATE VIEW to classify them
DROP VIEW vwCrime_classification
CREATE VIEW [vwCrime_classification]
AS
SELECT Year, Crime_type, Total_crime, PoliceStation_ID,
CASE
	WHEN Crime_type = 'Murder' THEN 'major_offences'
	WHEN Crime_type = 'Serious Hurt' THEN 'major_offences'
	WHEN Crime_type = 'Rape' THEN 'major_offences'
	WHEN Crime_type = 'Outrage Of Modesty' THEN 'major_offences'
	WHEN Crime_type = 'Rioting' THEN 'major_offences'
	WHEN Crime_type = 'Robbery' THEN 'major_offences'
	WHEN Crime_type = 'Housebreaking' THEN 'major_offences'
	WHEN Crime_type = 'Theft Of Motor Vehicle' THEN 'major_offences'
	WHEN Crime_type = 'Snatch Theft' THEN 'major_offences'
	WHEN Crime_type = 'Cheating Related Offences' THEN 'major_offences'
	ELSE 'others'
END AS 'Major',
CASE
	WHEN Crime_type = 'Robbery' THEN 'preventable'
	WHEN Crime_type = 'Housebreaking' THEN 'preventable'
	WHEN Crime_type = 'Snatch Theft' THEN 'preventable'
	WHEN Crime_type = 'Theft Of Motor Vehicle' THEN 'preventable'
	WHEN Crime_type = 'Outrage Of Modesty' THEN 'preventable'
	ELSE 'others'
END AS 'Preventable',
CASE
	WHEN Crime_type = 'Crimes Against Persons' THEN 'Crimes Against Persons'
	WHEN Crime_type = 'Rape' THEN 'Crimes Against Persons'
	WHEN Crime_type = 'Outrage Of Modesty' THEN 'Crimes Against Persons'
	WHEN Crime_type = 'Violent / Serious Property Crimes' THEN 'Violent / Serious Property Crimes'
	WHEN Crime_type = 'Robbery' THEN 'Violent / Serious Property Crimes'
	WHEN Crime_type = 'Housebreaking And Related Crimes' THEN 'Housebreaking And Related Crimes'
	WHEN Crime_type = 'Housebreaking' THEN 'Housebreaking And Related Crimes'
	WHEN Crime_type = 'Theft And Related Crimes' THEN 'Theft And Related Crimes'
	WHEN Crime_type = 'Theft Of Motor Vehicle' THEN 'Theft And Related Crimes'
	WHEN Crime_type = 'Snatch Theft' THEN 'Theft And Related Crimes'
	WHEN Crime_type = 'Commercial Crimes' THEN 'Commercial Crimes'
	WHEN Crime_type = 'Cheating Related Offences' THEN 'Commercial Crimes'
	WHEN Crime_type = 'Miscellaneous Crimes' THEN 'Miscellaneous Crimes'
	WHEN Crime_type = 'Murder' THEN 'Miscellaneous Crimes'
	WHEN Crime_type = 'Serious Hurt' THEN 'Miscellaneous Crimes'
	WHEN Crime_type = 'Rioting' THEN 'Miscellaneous Crimes'
	ELSE 'others'
END AS 'Overall',
CASE
	WHEN Crime_type = 'Unlicensed Moneylending' THEN 'uml'
	WHEN Crime_type = 'Harassment' THEN 'uml'
	ELSE 'others'
END AS 'uml'
FROM vwCrimeLog_CrimeType;

SELECT * FROM vwCrime_classification;

/* CREATE PROCEDURE to retrieve crime cases, based on the classification:
'Overall', 'Major', 'Preventable', and 'uml'
*/
DROP PROCEDURE crime_classification
CREATE PROCEDURE crime_classification
(@class varchar(20))
AS
BEGIN
	SELECT Year, SUM(Total_crime) AS 'Total_reported'
	FROM vwCrime_classification
	WHERE @class <> 'others'
	GROUP BY Year
	ORDER BY Year;
END;

/* CREATE VIEW that combined Crime_log,Crime_type, and NPC */
DROP VIEW vwCrime_classNPC
CREATE VIEW [vwCrime_classNPC]
AS
SELECT Year, Crime_type, Total_crime, Major, Preventable, Overall, 
uml, PoliceStation, Division, Region
FROM vwCrime_classification AS c
INNER JOIN Police_station AS p
ON c.PoliceStation_ID = p.PoliceStation_ID
WHERE Preventable <> 'others' OR uml <> 'others';

SELECT c.Year, c.Crime_type, c.Total_crime,
	p.PoliceStation, p.Division, p.Region
FROM vwCrimeLog_CrimeType AS c
INNER JOIN Police_station AS p
ON c.PoliceStation_ID = p.PoliceStation_ID
WHERE PoliceStation = 'Yishun North NPC' AND Year = 2018;

select * from vwCrime_classNPC

--- 1a. Yearly Crime cases recorded based on Overall Crime 
--EXEC crime_classification "Overall";

SELECT Year, SUM(Total_crime) AS 'Total_reported_Overall'
FROM vwCrime_classification
WHERE Overall <> 'others'
GROUP BY Year
ORDER BY Year;

--- CREATE VIEW for Total Population from 2005 to 2019
CREATE VIEW [vwPop05_19]
AS
SELECT Year, SUM(Total_population) AS 'Total_Population'
FROM population
GROUP BY Year
HAVING Year BETWEEN 2005 AND 2019;

SELECT * FROM vwPop05_19;

/* GET The Annual Overall crime cases and rate (i.e. the 6 classes of crimes under 
the overall-crime cases recorded). The rate is calculated
based on the Residential population per 100k*/
WITH overall_crimes AS
	(SELECT Year, Overall AS 'Offences', 
	SUM(Total_crime) AS 'Total_reported'
	FROM vwCrime_classification
	WHERE Overall <> 'others'
	GROUP BY Year, Overall)
SELECT c.Year, c.Offences, c.Total_reported,
       p.Total_Population, 
	   c.Total_reported/(p.Total_Population/100000) AS 'Crime_rate'
FROM overall_crimes AS c
LEFT JOIN vwPop05_19 AS p
ON c.Year = p.Year
ORDER BY c.Year, c.Offences;

--- 1b. Yearly Crime rate
WITH total_pop 
AS 
(SELECT Year, SUM(Total_population) AS 'Total_Population'
FROM population
GROUP BY Year
HAVING Year BETWEEN 2005 AND 2019),
Overall_crime
AS 
(Select Year, SUM(Total_crime) AS 'Total_reported' 
FROM vwCrime_classification
WHERE Overall <> 'others'
GROUP BY [Year])
SELECT c.Year, c.Total_reported,
Total_reported/(Total_Population/100000) AS 'Crime_rate'
FROM Overall_crime AS c
INNER JOIN total_pop AS p
ON c.Year = p.Year;

--- 1c. Yearly Overall crime cases (showing count at the 6 crimes under 'Overall crime')
SELECT YEAR, Overall AS 'Offences', 
SUM(Total_crime) AS 'Total_reported'
FROM vwCrime_classification
GROUP BY Year, Overall 
HAVING NOT Overall = 'others'
ORDER BY Year;

--- 1d. Yearly Crime cases recorded based on Five Preventable Crimes cases
SELECT Year, SUM(Total_crime) AS 'Total_reported_Preventable'
FROM vwCrime_classification
WHERE Preventable <> 'others'
GROUP BY Year
ORDER BY Year;

--- 1e. Yearly Preventable crime cases (showing count at the 5 Offences under 'Preventable crimes')
SELECT Year, Crime_type AS 'Offences', 
SUM(Total_crime) AS 'Total_reported'
FROM vwCrime_classification
WHERE Preventable <> 'others'
GROUP BY Year, Crime_type 
ORDER BY Year;

--- 1f. Yearly Crime cases recorded based on Selected Major Offences
SELECT Year, SUM(Total_crime) AS 'Total_reported_Major'
FROM vwCrime_classification
WHERE Major <> 'others'
GROUP BY Year
ORDER BY Year;

--- 1g. Yearly Selected major offences (showing count at the 10 Offences under 'Selected Major')
SELECT Year, Crime_type, SUM(Total_crime) AS 'Total_reported_Major'
FROM vwCrime_classification
WHERE Major <> 'others'
GROUP BY Year, Crime_type
ORDER BY Year;

--- 2a. Crimes reported by NPC
SELECT Year, Crime_type, Total_crime, Preventable, Overall, uml,
	PoliceStation, Division, Region
FROM vwCrime_classNPC

SELECT Year, PoliceStation, Division, Region,
       SUM(Total_crime) AS 'Total_reported'
FROM vwCrime_classNPC
GROUP BY Year, Region, Division, PoliceStation
ORDER BY Year, Total_reported DESC;

--- 2b. Top 5 NPC with Most reported Crime over the year

/* Create VIEW that aggregate the total crime by NPC and rank it
from high to low*/
CREATE VIEW [vwCrimeRankbyNPC]
AS
	WITH Sum_query AS
	(SELECT Year, PoliceStation, SUM(Total_crime) AS 'Total_reported'
	FROM vwCrime_classNPC
	GROUP BY Year, PoliceStation)
	SELECT Year, PoliceStation, Total_reported,
	ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Total_reported DESC) AS 'crime_rank'
	FROM Sum_query;

--- Retrieve from the VIEW, the TOP 5 NPC with most crime reported
SELECT *
FROM vwCrimeRankbyNPC
WHERE crime_rank <= 5;

/* 2c. For the top 5 NPC with MOST Crime_reported, 
what are the top crime? */
DROP PROCEDURE NPCTop5Crime
CREATE PROCEDURE NPCTop5Crime
(@npc varchar(30), @year int)
AS
BEGIN
	SELECT TOP 5 Year, Crime_type, PoliceStation, 
			SUM(Total_crime) AS 'Total_reported' 
	FROM vwCrime_classNPC
	WHERE PoliceStation = @npc AND Year = @year
	GROUP BY Year, Crime_type, PoliceStation
	ORDER BY Year, Total_reported DESC;
END;

EXEC NPCTop5Crime 'Yishun North NPC', 2018
EXEC NPCTop5Crime 'Woodlands East NPC', 2018
EXEC NPCTop5Crime 'Nanyang NPC', 2018
EXEC NPCTop5Crime 'Choa Chu Kang NPC', 2018
EXEC NPCTop5Crime 'Woodlands West NPC', 2018
EXEC NPCTop5Crime 'Sengkang NPC', 2018

--- 3. Person Arrested on Selected Major Offences
/* Create VIEW to combine Arrested + Crime_type */
CREATE VIEW [vwArrestedCrimeType]
AS
SELECT a.Year, c.Type AS 'Major_offences',
		a.Age_group, a.Gender, a.Total_count
FROM Arrested AS a
INNER JOIN Crime_type AS c
ON a.Crime_code = c.Crime_code;

--- 3a. Person Arrested from Major Offences
SELECT * FROM vwArrestedCrimeType;

--- 3b. Total person Arrested over the years
SELECT Year, SUM(Total_count) AS 'Person_arrested'
FROM vwArrestedCrimeType
GROUP BY Year
ORDER By Year;

--- 3c. Total person Arrested over years by Crime
SELECT Year, Major_offences, SUM(Total_count) AS 'Person_arrested'
FROM vwArrestedCrimeType
GROUP BY Year, Major_offences
ORDER By Year, Person_arrested DESC;

/* Create VIEW that aggregate the Total person arrested by Crime Type
and rank it AS 'crime_rank' from high to low*/
CREATE VIEW [vwCrimeRankbyArrested]
AS
	WITH Sum_query AS
	(SELECT Year, Major_offences, SUM(Total_count) AS 'Person_arrested'
	FROM vwArrestedCrimeType
	GROUP BY Year, Major_offences)
	SELECT Year, Major_offences, Person_arrested,
	ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Person_arrested DESC) AS 'crime_rank_by_PersonArrested'
	FROM Sum_query;

--- Extract the top 3 Major Offences, by the number of Person Arrested
SELECT * FROM vwCrimeRankbyArrested
WHERE crime_rank_by_PersonArrested <=3;

SELECT DISTINCT(Major_offences) AS 'Top 3 Major Offences by Person Arrested'
FROM vwCrimeRankbyArrested
WHERE crime_rank_by_PersonArrested <=3;

--- 3d. Total person Arrested over years by Gender
SELECT Year, Gender, SUM(Total_count) AS 'Person_arrested'
FROM vwArrestedCrimeType
GROUP BY Year, Gender
ORDER By Year;

--- 3e. Top 3 Major Offences by Person Arrested and gender
SELECT Year, Major_offences, Gender,
		SUM(Total_count) AS 'Person_arrested'
FROM vwArrestedCrimeType
GROUP BY Year, Major_offences, Gender
HAVING Major_offences IN ('Cheating Related Offences','Outrage Of Modesty','Rioting')
ORDER BY Year;

--- 3f. Total person Arrested over years by AgeGroup
SELECT Year, Age_group, SUM(Total_count) AS 'Person_arrested'
FROM vwArrestedCrimeType
GROUP BY Year, Age_group
ORDER By Year;

--- 3g. Age_group of Majority Person_arrested for each offences
CREATE VIEW [vwCrimeRankbyArrestedAgeGroup]
AS
WITH Sum_query AS
	(SELECT Year, Major_offences, Age_group,
			SUM(Total_count) AS 'Person_arrested'
	FROM vwArrestedCrimeType
	GROUP BY Year, Major_offences, Age_group)
SELECT Year, Major_offences, Age_group, Person_arrested,
	ROW_NUMBER() OVER (PARTITION BY Year, Major_offences 
	ORDER BY Person_arrested DESC) AS 'rank'
FROM Sum_query;

SELECT Year, Major_offences, Age_group, Person_arrested
FROM vwCrimeRankbyArrestedAgeGroup
WHERE rank = 1;

--- 4. Victims of Selected Major Offences
/* Create VIEW to combine Victims + Crime_type */
CREATE VIEW [vwVictimsCrimeType]
AS
SELECT v.Year, c.Type AS 'Major_offences', v.Age_group, v.Gender, 
		v.Total_count
FROM Victims AS v
INNER JOIN Crime_type AS c
ON v.Crime_code = c.Crime_code;

--- 4a. Victims from Major Offences
SELECT * FROM vwVictimsCrimeType;

SELECT DISTINCT(Major_offences) FROM vwVictimsCrimeType;
SELECT DISTINCT(Major_offences) FROM vwArrestedCrimeType;


--- 4b. Victims over the years
SELECT Year, SUM(Total_count) AS 'Victims_recorded'
FROM vwVictimsCrimeType
GROUP BY Year
ORDER BY Year;

--- 4c. Victims over year by Crime
SELECT Year, Major_offences, SUM(Total_count) AS 'Victims_reported'
FROM vwVictimsCrimeType
GROUP BY Year, Major_offences
ORDER BY Year, Victims_reported DESC;

/* Create VIEW that aggregate the Total victims reported by Crime Type
and rank it from high to low*/
CREATE VIEW [vwCrimeRankbyVictims]
AS
	WITH Sum_query AS
	(SELECT Year, Major_offences, SUM(Total_count) AS 'Victims_reported'
	FROM vwVictimsCrimeType
	GROUP BY Year, Major_offences)
	SELECT Year, Major_offences, Victims_reported,
	ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Victims_reported DESC) AS 'rankBy_VictimsReported'
	FROM Sum_query;

--- Extract the top 3 Major Offences, by the number of Victims reported
SELECT * FROM vwCrimeRankbyVictims
WHERE rankBy_VictimsReported <=3;

SELECT DISTINCT(Major_offences) AS 'Top 3 Major Offences by Victims reported'
FROM vwCrimeRankbyVictims
WHERE rankBy_VictimsReported <=3;

--- 4d. Total Victims reported over years by Gender
SELECT Year, Gender, SUM(Total_count) AS 'Victims_reported'
FROM vwVictimsCrimeType
GROUP BY Year, Gender
ORDER By Year;

--- 4e. Top 3 Major Offences by Victims reported and gender
SELECT Year, Major_offences, Gender,
		SUM(Total_count) AS 'Victims_reported'
FROM vwVictimsCrimeType
GROUP BY Year, Major_offences, Gender
HAVING Major_offences IN
('Cheating Related Offences','Outrage Of Modesty','Robbery',
 'Serious Hurt')
ORDER BY Year;

--- 4f. Total Victims over years by AgeGroup
SELECT Year, Age_group, SUM(Total_count) AS 'Victims_reported'
FROM vwVictimsCrimeType
GROUP BY Year, Age_group
ORDER By Year;

--- 4g. Age_group of Majority Victims_reported for each offences
CREATE VIEW [vwCrimeRankbyVictimsAgeGroup]
AS
WITH Sum_query AS
	(SELECT Year, Major_offences, Age_group,
			SUM(Total_count) AS 'Victims_reported'
	FROM vwVictimsCrimeType
	GROUP BY Year, Major_offences, Age_group)
SELECT Year, Major_offences, Age_group, Victims_reported,
	ROW_NUMBER() OVER (PARTITION BY Year, Major_offences 
	ORDER BY Victims_reported DESC) AS 'rank'
FROM Sum_query;

SELECT Year, Major_offences, Age_group, Victims_reported
FROM vwCrimeRankbyVictimsAgeGroup
WHERE rank = 1;

--- 5. Employment rate (Annual)
SELECT * 
FROM unemployment_rate
WHERE Status = 'Total';

-- Cross compared to https://stats.mom.gov.sg/Pages/Unemployment-Summary-Table.aspx

/* This is to display the aggregated unemployment rate annually */
SELECT Year, AVG(Rate) AS 'Unemployment_rate'
FROM unemployment_rate
WHERE Status = 'Total' AND Year > 2004
GROUP BY Year
ORDER BY Year;

/* This display the crime_reported annually, for each offences */
SELECT Year, Crime_type, SUM(Total_crime) AS 'Total_crime' 
FROM vwCrime_classification
GROUP BY Year, Crime_type
ORDER BY Year, Total_crime DESC;

CREATE PROCEDURE crimeTrend
(@offences varchar(30))
AS
BEGIN
	SELECT Year, Crime_type, SUM(Total_crime) AS 'Total_crime' 
	FROM vwCrime_classification
	GROUP BY Year, Crime_type
	HAVING Crime_type = @offences
	ORDER BY Year;
END;

EXEC crimeTrend "Theft And Related Crimes"
EXEC crimeTrend "Housebreaking And Related Crimes"
EXEC crimeTrend "Cheating Related Offences"
EXEC crimeTrend "Rioting"
EXEC crimeTrend "Unlicensed Moneylending"
EXEC crimeTrend "Housebreaking"

SELECT * FROM Police_station