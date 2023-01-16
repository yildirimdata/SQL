-- SUBQUERY PRACTICES

-- world population database

-- Q1
-- List each country name where the population is larger than that of 'Russia'.

SELECT name FROM world
  WHERE population >
     (SELECT population FROM world
      WHERE name='Russia')

-- Q2
-- Show the countries in Europe with a per capita GDP greater than 'United Kingdom'.
SELECT name
    FROM world
    WHERE continent = 'Europe' AND gdp/population >
        (SELECT gdp/population
        FROM world
        WHERE name = 'United Kingdom')

-- Q3
-- List the name and continent of countries in the continents containing either Argentina or Australia. 
-- Order by name of the country.

SELECT name, continent
    FROM world
    WHERE continent =   
        (SELECT continent
        FROM world
        WHERE name = 'Argentina') OR continent = (SELECT continent
        FROM world
        WHERE name = 'Australia')
    ORDER BY name;

-- Q4
-- Which country has a population that is more than United Kingdom but less than Germany? Show the name and the population.

SELECT name, population
    FROM world
    WHERE population >(SELECT population
        FROM world
        WHERE name = 'United Kingdom')
        AND population < (SELECT population
        FROM world
        WHERE name = 'Germany');

-- Q5
-- Which countries have a GDP greater than every country in Europe? [Give the name only.]
SELECT name
    FROM world
    WHERE gdp > (SELECT MAX(gdp) FROM world 
        WHERE continent = 'Europe'
        GROUP BY continent);

-- Q6
-- Find the largest country (by area) in each continent, show the continent, the name and the area:
SELECT continent, name, area 
  FROM world
    WHERE area IN (SELECT MAX(area) 
                  FROM world 
                 GROUP BY continent);

-- Q7
-- List each continent and the name of the country that comes first alphabetically.

SELECT continent, MIN(name) as name
FROM world
GROUP BY continent
ORDER BY continent;

-- Q8
-- ind the continents where all countries have a population <= 25000000. 
-- Then find the names of the countries associated with these continents. Show name, continent and population.

SELECT name, continent, population 
FROM world x
  WHERE 25000000>=ALL (SELECT population FROM world y
                         WHERE x.continent=y.continent
                         AND population>0)

-- Q9
-- Some countries have populations more than three times that of all of their neighbours (in the same continent).
-- Give the countries and continents.

SELECT name, continent 
FROM world x 
WHERE population/3 >= ALL
    (SELECT population
     FROM world y
     WHERE y.continent=x.continent
     AND x.name != y.name)