# World Life Expectancy Project

This project involves cleaning and refining the **world_life_expectancy** dataset by addressing duplicated records, filling in missing data, and ensuring consistency across key columns like `Status` and `Life expectancy`. The data is stored in the **base_data.csv** file. The cleaned data will be available in the **cleared_data.csv** file.

## Table of Contents
- [Overview](#overview)
- [Data Cleaning Steps](#data-cleaning-steps)
  - [Identifying and Removing Duplicates](#identifying-and-removing-duplicates)
  - [Populating Empty 'Status' Values](#populating-empty-status-values)
  - [Filling Missing 'Life Expectancy' Values](#filling-missing-life-expectancy-values)
- [Exploratory Data Analysis](#exploratory-data-analysis)

---

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

#### 1.2 Find Duplicate Records
To isolate duplicates:

```sql

    SELECT * 
    FROM (
        SELECT ROW_ID, CONCAT(Country, Year),
        ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
        FROM world_life_expectancy
    ) AS Row_Table
    WHERE Row_Num > 1;
```

#### 1.3 Deleting Duplicates
Delete duplicate records, keeping only the first occurrence:

```sql

    DELETE FROM world_life_expectancy
    WHERE Row_ID IN (
        SELECT Row_ID 
        FROM (
            SELECT ROW_ID, CONCAT(Country, Year),
            ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
            FROM world_life_expectancy
        ) AS Row_Table
        WHERE Row_Num > 1
    );
```

---

### 2. Populating Empty 'Status' Values

#### 2.1 Identify Distinct 'Status' Values
Find all distinct 'Status' values:

```sql

    SELECT DISTINCT(Status)
    FROM world_life_expectancy
    WHERE Status <> '';
```

#### 2.2 Find Countries with 'Developing' Status
Filter for countries that have the status 'Developing':

```sql

    SELECT DISTINCT(Country)
    FROM world_life_expectancy
    WHERE Status = 'Developing';
```

#### 2.3 Fill Empty 'Status' Fields with 'Developing'
For countries marked as 'Developing', populate empty status fields:

```sql

    UPDATE world_life_expectancy t1
    JOIN world_life_expectancy t2
    USING (Country)
    SET t1.Status = 'Developing'
    WHERE t1.Status = ''
    AND t2.Status = 'Developing';
```

#### 2.4 Country with 'Developed' Status
Retrieve the record for a country with a 'Developed' status, e.g., the USA:

```sql

    SELECT *
    FROM world_life_expectancy
    WHERE Country = 'United States of America';
```

#### 2.5 Fill Empty 'Status' Fields with 'Developed'
For countries marked as 'Developed', populate empty status fields:

```sql

    UPDATE world_life_expectancy t1
    JOIN world_life_expectancy t2
    USING (Country)
    SET t1.Status = 'Developed'
    WHERE t1.Status = ''
    AND t2.Status = 'Developed';
```

---

### 3. Filling Missing 'Life Expectancy' Values

#### 3.1 Calculate Average 'Life Expectancy' from Adjacent Years
Find the average life expectancy by taking the mean of the values from the previous and next years:

```sql

    SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
           t2.Country, t2.Year, t2.`Life expectancy`,
           t3.Country, t3.Year, t3.`Life expectancy`,
           ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1) AS Avg_Life_Expectancy
    FROM world_life_expectancy t1
    JOIN world_life_expectancy t2 ON t1.Country = t2.Country AND t1.Year = t2.Year - 1
    JOIN world_life_expectancy t3 ON t1.Country = t3.Country AND t1.Year = t3.Year + 1
    WHERE t1.`Life expectancy` = '';
```

#### 3.2 Fill Missing 'Life Expectancy' Fields with Average Values
Use the calculated average to fill empty 'Life Expectancy' values:

```sql

    UPDATE world_life_expectancy t1
    JOIN world_life_expectancy t2 ON t1.Country = t2.Country AND t1.Year = t2.Year - 1
    JOIN world_life_expectancy t3 ON t1.Country = t3.Country AND t1.Year = t3.Year + 1
    SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
    WHERE t1.`Life expectancy` = '';
```
---

## Exploratory Data Analysis

### 1. Inspect Life Expectancy Change Over 15 Years
Analyze the change in life expectancy for each country over a 15-year period:

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

### 2. Life Expectancy Change Over the Years
Examine life expectancy trends over time:

```sql

    SELECT Year, ROUND(AVG(`Life expectancy`),2)
    FROM world_life_expectancy
    WHERE `Life expectancy` <> 0
    GROUP BY Year
    ORDER BY Year;
```

### 3. Correlation Between Life Expectancy and GDP
Check for a correlation between life expectancy and GDP:

```sql

    SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
    FROM world_life_expectancy
    GROUP BY Country
    HAVING Life_EXP > 0 AND GDP > 0
    ORDER BY GDP;
```

### 4. Life Expectancy and GDP Categories (High vs. Low)
Add a filter to differentiate between countries with high and low GDP, using a threshold of 1500:

```sql

    SELECT 
        SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS High_Gdp_Count,
        AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) AS High_Gdp_Life_expectancy,
        SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) AS Low_Gdp_Count,
        AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END) AS Low_Gdp_Life_expectancy
    FROM world_life_expectancy;
```

### 5. Correlation Between Status (Developing/Developed) and Life Expectancy
Analyze how the status of a country (Developing or Developed) affects life expectancy:

```sql

    SELECT Status, ROUND(AVG(`Life expectancy`),1), COUNT(DISTINCT Country)
    FROM world_life_expectancy
    GROUP BY Status;
```
