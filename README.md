# World Life Expectancy Project

## Overview
This project involves cleaning and refining the **world_life_expectancy** dataset by addressing duplicated records, filling in missing data, and ensuring consistency across key columns like `Status` and `Life expectancy`. The data is stored in the **base_data** database.

## Data Cleaning Steps

### 1. Identifying and Removing Duplicates

#### 1.1 Find Duplicates Based on Country and Year
The following query identifies duplicate records by checking for multiple entries for each country and year:
```sql
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

#### 1.2 Find Duplicates Based on Country and Year
```sql
SELECT * 
FROM (
	SELECT ROW_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy ) AS Row_Table
WHERE Row_Num  > 1;

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
