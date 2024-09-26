# World Life Expectancy Project 

# Data Cleaning 

# 	1. Find Duplicates as searching for each year for each country
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

# 	1.1 Find Duplicates  using Windows function
SELECT * 
FROM (
	SELECT ROW_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy ) AS Row_Table
WHERE Row_Num  > 1;

#	1.2 Deleting Duplicates
DELETE FROM world_life_expectancy
WHERE 
	Row_ID IN ( SELECT Row_ID 
				FROM (
					SELECT ROW_ID,
					CONCAT(Country, Year),
					ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
					FROM world_life_expectancy ) AS Row_Table
				WHERE Row_Num  > 1
				)
;

#	2. Empty values papulating 'Status' Column

#	2.1 Find 'Status' values which are 'Developing' and 'Developed'
SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <> '';

#	2.1 Find all countries  which has status 'Developing' 
SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing';

#	2.2 Set the empty status values with 'Developing' 
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
USING  (Country)
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing';

#	2.3 There is Country which have a status 'Developed'
SELECT *
FROM world_life_expectancy
WHERE Country = 'United States of America';

#	2.4 Update the status of a status of empty 'Developed' country
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
USING  (Country)
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed';

#	3. Empty values papulating 'Life expectancy' Column

#	3.1 Find average value as it should be Average value from next and previos year for 'Life expectancy' column 
SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
	   t2.Country, t2.Year, t2.`Life expectancy`,
	   t3.Country, t3.Year, t3.`Life expectancy`,
       ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = '';

#	3.2 Set Empty values papulating 'Life expectancy' Column with Average value
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` =  ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = '';

