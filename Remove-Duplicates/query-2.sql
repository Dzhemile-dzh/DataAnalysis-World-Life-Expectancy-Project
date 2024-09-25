#World Life Expectancy Project (Exploratory data Analysis)

##Inspect the Life expectancy value change for each country, which shows life increase over 15 years

SELECT Country, 
MIN(`Life expectancy`), 
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increase
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Country DESC;

##Life expectancy change over the years 

SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year;

##Check for corelation between Life expectancy value and GDP

SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_EXP > 0
AND GDP > 0
ORDER BY GDP;

##Adding a Filter for GDP and Life expectancy to showed with 'high' AND 'LOW' gdp countries depending from a SPECIFIC VALUE

SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS High_Gdp_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) AS High_Gdp_Life_expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) AS Low_Gdp_Count,
AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END) AS Low_Gdp_Life_expectancy
FROM world_life_expectancy
ORDER BY GDP;

#Corelation between countries with developing and developed status and how this change life expectancy

SELECT Status, ROUND(AVG(`Life expectancy`),1), COUNT(DISTINCT Country)
FROM world_life_expectancy
GROUP BY Status;

