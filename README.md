# World Life Expectancy Project

## Overview
This project involves cleaning and refining the **world_life_expectancy** dataset by addressing duplicated records, filling in missing data, and ensuring consistency across key columns like `Status` and `Life expectancy`. The data is stored in the **base_data** csv file.
You will be able to check cleared data stored on **cleared_data** csv file.

## Data Cleaning Steps

### 1. Identifying and Removing Duplicates

#### 1.1 Find Duplicates Based on Country and Year
The following query identifies duplicate records by checking for multiple entries for each country and year:
```sql
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;
```

#### 1.2 Find Duplicates Based on Country and Year
```sql
SELECT * 
FROM (
	SELECT ROW_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy ) AS Row_Table
WHERE Row_Num  > 1;
```

#### 1.3 Deleting Duplicates
```sql
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
```
### 2. Empty values papulating 'Status' Column
#### 2.1 Find 'Status' values which are 'Developing' and 'Developed'
```sql
SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <> '';
```

#### 2.2 Find all countries  which has status 'Developing' 
```sql
SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing';
```

##### 2.3 Set the empty status values with 'Developing' 
```sql
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
USING  (Country)
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing';
```

#### 2.4 There is Country which have a status 'Developed'
```sql
SELECT *
FROM world_life_expectancy
WHERE Country = 'United States of America';
```
#### 2.5 Update the status of a status of empty 'Developed' country
```sql
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
USING  (Country)
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed';
```
### 3. Empty values papulating 'Life expectancy' Column

#### 3.1 Find average value as it should be Average value from next and previos year for 'Life expectancy' column 
```sql
SELECT t1.Country, t1.Year, t1.Life expectancy, 
	   t2.Country, t2.Year, t2.Life expectancy,
	   t3.Country, t3.Year, t3.Life expectancy,
       ROUND((t2.Life expectancy + t3.Life expectancy)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.Life expectancy = '';
```

#### 3.2 Set Empty values papulating 'Life expectancy' Column with Average value
```sql
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.Life expectancy =  ROUND((t2.Life expectancy + t3.Life expectancy)/2,1)
WHERE t1.Life expectancy = '';
```

## Exploratory data Analysis

#### 1.Inspect the Life expectancy value change for each country, which shows life increase over 15 years

```sql
SELECT Country, 
MIN(`Life expectancy`), 
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increase
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Country DESC;
```

#### 2.Life expectancy change over the years 

```sql
SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year;
```

#### 3.Check for corelation between Life expectancy value and GDP
```sql
SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_EXP > 0
AND GDP > 0
ORDER BY GDP;
```

#### 4.Adding a Filter for GDP and Life expectancy to showed with 'high' AND 'LOW' gdp countries depending from a SPECIFIC VALUE

```sql
SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS High_Gdp_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) AS High_Gdp_Life_expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) AS Low_Gdp_Count,
AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END) AS Low_Gdp_Life_expectancy
FROM world_life_expectancy
ORDER BY GDP;
````

#### 5.Corelation between countries with developing and developed status and how this change life expectancy

```sql
SELECT Status, ROUND(AVG(`Life expectancy`),1), COUNT(DISTINCT Country)
FROM world_life_expectancy
GROUP BY Status;
```
