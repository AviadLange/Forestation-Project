/*This query creates a new table with all the relevant data from the original tables and additional columns of forest percentage per country (as ‘percentage’) and calculated land area per country in sq km.*/
CREATE VIEW forestation AS
(SELECT
    l.country_code,
    l.country_name,
    l.year,
    total_area_sq_mi*2.59 AS land_area_sqkm,
    forest_area_sqkm, (f.forest_area_sqkm/(total_area_sq_mi*2.59))*100 AS percentage,
    region
FROM land_area AS l
INNER JOIN forest_area AS f
ON f.country_code = l.country_code AND f.year = l.year
INNER JOIN regions AS r
ON l.country_code = r.country_code);

/*This query finds the forest area in the entire world in 1990*/
SELECT forest_area_sqkm
FROM forest_area
WHERE country_name = 'World'
AND year= 1990;

/*This query finds the forest area in the entire world in 2016*/
SELECT forest_area_sqkm
FROM forest_area
WHERE country_name = 'World' AND year = 2016;

/*This query finds the total forest loss from 1990 to 2016.*/
SELECT a.forest_area_sqkm - b.forest_area_sqkm
FROM forest_area a
INNER JOIN forest_area b
ON a.country_name = b.country_name AND a.year = 2016
AND b.year = 1990
WHERE a.country_name = 'World';

/*This query finds the percentage forest loss from 1990 to 2016.*/
SELECT ROUND((((a.forest_area_sqkm - b.forest_area_sqkm)*100)/b.forest_area_sqkm)::NUMERIC,1)
FROM forest_area a
INNER JOIN forest_area b
ON a.country_name = b.country_name AND a.year = 2016
AND b.year = 1990
WHERE a.country_name = 'World';

/*This query finds the country with land area equal to slightly less than the world’s deforestation from 1990-2016 (1324.45 sq km)*/
SELECT country_name,ROUND(land_area_sqkm::NUMERIC,2)
FROM forestation
WHERE land_area_sqkm < 1324449
AND year = 2016
ORDER BY land_area_sqkm DESC 
-------------------------------------------------

/*This query finds the forest percentage of the entire world in 2016.*/
SELECT ROUND(((SUM(forest_area_sqkm)/SUM(land_area_sqkm))*100)::NUMERIC,2) AS wrd_percentage
FROM forestation
WHERE country_name = 'World' AND year = 2016;

/*This query finds the region with the highest relative forestation in 2016.*/
SELECT ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::NUMERIC,2) AS percentage, region
FROM forestation
GROUP BY region, year
HAVING year = 2016
ORDER BY percentage DESC;

/*This query finds the region with the lowest relative forestation in 2016.*/
SELECT ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::NUMERIC,2) AS percentage, region
FROM forestation
GROUP BY region, year
HAVING year = 2016
ORDER BY percentage;

/*This query finds the forest percentage of the entire world in 1990.*/
SELECT ROUND(((SUM(forest_area_sqkm)/SUM(land_area_sqkm))*100)::NUMERIC,2) AS wrd_percentage
FROM forestation
WHERE country_name = 'World' AND year = 1990;

/*This query finds the region with the highest relative forestation in 1990.*/
SELECT ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::NUMERIC,2) AS percentage, region
FROM forestation
GROUP BY region, year
HAVING year = 1990
ORDER BY percentage DESC;

/*This query finds the region with the lowest relative forestation in 1990.*/
SELECT ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::NUMERIC,2) AS percentage, region
FROM forestation
GROUP BY region, year
HAVING year = 1990
ORDER BY percentage;

/*This query shows all the regions and their relative forestation percentage in 2016 and 1990.*/
SELECT ROUND(((SUM(forest_area_sqkm)/SUM(land_area_sqkm))*100)::NUMERIC,2) AS percentage, region, year
FROM forestation
GROUP BY region, year
HAVING year IN(2016, 1990)
ORDER BY region;

/*This query shows the world’s forestation percentage in 2016 and 1990.*/
SELECT ROUND(((SUM(forest_area_sqkm)/SUM(land_area_sqkm))*100)::NUMERIC,2) AS percentage, region, year
FROM forestation
GROUP BY region, year
HAVING year IN(2016, 1990)
AND region = 'World';
--------------------------

/*This query shows the countries with the highest forest increase in terms of sq km between
1990 and 2016.*/
SELECT ROUND((a.forest_area_sqkm-b.forest_area_sqkm)::NUMERIC,2) AS subtract, a.country_name
FROM forestation a
INNER JOIN forestation b
ON a.country_name=b.country_name
AND a.year = 2016
AND b.year = 1990
WHERE b.forest_area_sqkm IS NOT NULL AND a.forest_area_sqkm IS NOT NULL AND a.country_name <> 'World'
ORDER BY subtract DESC
LIMIT 5;

/*This query shows the countries with the highest forest increase in terms of percentage between 1990 and 2016.*/
SELECT ROUND(((a.percentage - b.percentage)*100/ b.percentage)::NUMERIC,2) AS subtract, a.country_name
FROM forestation a
INNER JOIN forestation b
ON a.country_name=b.country_name AND a.year = 2016
AND b.year = 1990
WHERE b.percentage IS NOT NULL AND a.percentage IS NOT NULL AND a.country_name <> 'World'
ORDER BY subtract DESC
LIMIT 5;

/*This query shows the countries with the highest forest decrease in terms of sq km between 1990 and 2016.*/
SELECT ROUND((a.forest_area_sqkm-b.forest_area_sqkm)::NUMERIC,2) AS subtract, a.country_name
FROM forestation a
INNER JOIN forestation b
ON a.country_name=b.country_name
AND a.year = 2016
AND b.year = 1990
WHERE b.forest_area_sqkm IS NOT NULL AND a.forest_area_sqkm IS NOT NULL AND a.country_name <> 'World'
ORDER BY subtract
LIMIT 5;

/*This query shows the countries with the highest forest decrease in terms of percentage between 1990 and 2016.*/
SELECT ROUND(((a.percentage - b.percentage)*100/ b.percentage)::NUMERIC,2) AS subtract, a.country_name
FROM forestation a
INNER JOIN forestation b
ON a.country_name=b.country_name AND a.year = 2016
AND b.year = 1990
WHERE b.percentage IS NOT NULL AND a.percentage IS NOT NULL AND a.country_name <> 'World' ORDER BY subtract
LIMIT 5;
---------------------------

/*This query counts the number of countries in each quartile as for 2016.*/
SELECT
    COUNT(CASE WHEN percentage < 25 THEN 1 END) AS first,
    COUNT(CASE WHEN percentage BETWEEN 25 AND 50 THEN 2 END) AS second,
    COUNT(CASE WHEN percentage BETWEEN 50 AND 75 THEN 3 END) AS third,
    COUNT(CASE WHEN percentage > 75 THEN 4 END) AS fourth FROM forestation
WHERE year = 2016
AND country_name <> 'World';

/*This query shows the countries with the highest forest percentage in 2016.*/
SELECT country_name, ROUND(percentage::NUMERIC,2), region
FROM forestation
WHERE year = 2016
AND percentage > 75
ORDER BY percentage DESC;