-- AGGREGATE FUNCTIONS and GROUP BY Practices (Source SQLZoo)

-- Q1
-- Show the total population of the world.
SELECT SUM(population)
FROM world;

-- Q2
-- List all the continents 
SELECT DISTINCT continent
FROM world;

-- Q3
-- total GDP of Africa
SELECT SUM(gdp)
FROM world
WHERE continent = 'Africa';

-- Q4
-- How many countries have an area of at least 1000000
SELECT COUNT(name)
FROM world
WHERE area > 1000000;

-- Q5
-- What is the total population of Baltic states('Estonia', 'Latvia', 'Lithuania')
SELECT SUM(population)
FROM world
WHERE name IN ('Estonia', 'Latvia', 'Lithuania');

-- Q6
-- For each continent show the number of countries:
SELECT continent, COUNT(name)
  FROM world
 GROUP BY continent

 -- Q7
 -- For each continent show the total population:
 SELECT continent, SUM(population)
  FROM world
 GROUP BY continent;

 -- Q8
 -- For each relevant continent show the number of countries that has a population of at least 200000000.
 SELECT continent, COUNT(name)
  FROM world
 WHERE population>200000000
 GROUP BY continent;

 -- Q9
 --  Show the total population of those continents with a total population of at least half a billion.
 SELECT continent, SUM(population)
    FROM world
    GROUP BY continent
    HAVING SUM(population)>500000000;

-- Q10
-- For each continent show the continent and number of countries with populations of at least 10 million.
SELECT continent, COUNT(name)
FROM world
WHERE population >= 10000000
GROUP BY continent;

-- Q11
-- List the continents that have a total population of at least 100 million.
SELECT continent
FROM world
GROUP BY continent
HAVING SUM(population) >= 100000000;

-- Q12
-- For each subject show the first year that the prize was awarded.
SELECT subject, MIN(yr)
FROM nobel
GROUP BY subject;

-- Q13
-- For each subject show the number of prizes awarded in the year 2000.
SELECT subject, COUNT(subject)
FROM nobel
WHERE yr = 2000
GROUP BY subject;

-- Q14
-- Show the number of different winners for each subject.
SELECT subject, COUNT(DISTINCT winner)
FROM nobel
GROUP BY subject;

-- Q15
-- For each subject show how many years have had prizes awarded.
SELECT subject, COUNT(DISTINCT yr)
FROM nobel
GROUP BY subject;

-- Q16
-- Show the years in which three prizes were given for Physics.
SELECT yr 
    FROM nobel
    WHERE subject = 'Physics'
    GROUP BY yr
    HAVING COUNT(*) = 3;

-- Q17
-- Show winners who have won more than once.
SELECT winner
FROM nobel
GROUP BY winner
HAVING COUNT(*)>1


