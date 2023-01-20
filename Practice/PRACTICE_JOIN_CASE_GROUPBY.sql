-- NULL value exercises
-- Source (https://sqlzoo.net/wiki/Using_Null)

-- Q1: use the available join type to list all the teachers who have dept names

SELECT teacher.name, dept.name
        FROM teacher 
        INNER JOIN dept
        ON (teacher.dept = dept.id)

-- Q2: use the available join type to list all the teachers and dept NAMES

SELECT t.name, d.name
        FROM teacher t
        LEFT JOIN dept d
        ON t.dept=d.id;

-- Q3: use the available join type to list all department names and teacher names
SELECT t.name, d.name
        FROM teacher t
        RIGHT JOIN dept d
        ON t.dept = d.id

-- Q4: Use COALESCE to print the mobile number. Use the number '07986 444 2266' 
-- if there is no number given. Show teacher name and mobile number or '07986 444 2266'

SELECT name, 
        COALESCE(mobile, '07986 444 2266')
        FROM teacher;

-- Q5: Use the COALESCE function and a LEFT JOIN to print the teacher name and department name. 
-- Use the string 'None' where there is no department.

SELECT t.name, 
        COALESCE(d.name, 'None')
        FROM teacher t
        LEFT JOIN dept d
        ON t.dept=d.id;

-- Q6: show the number of teachers and the number of mobile phones (!! nulls)
SELECT COUNT(name) as teacher_names, 
        COUNT(mobile) as mobile_phone
        FROM teacher;

-- Q7 : Show each department and the number of staff

SELECT d.name, 
        COUNT(t.name)
        FROM teacher t
        RIGHT JOIN dept d
        ON t.dept = d.id
        GROUP BY d.name

-- Q9 : show the name of each teacher followed by 'Sci' if the teacher is in dept 1 or 2 and 'Art' otherwise.

SELECT name, CASE
            WHEN dept IN (1,2) THEN 'Sci'
            ELSE 'Art'
            END
            FROM teacher;

-- Q10: Show the name of each teacher followed by 'Sci' if the teacher is in dept 1 or 2, show 'Art' if the 
-- teacher's dept is 3 and 'None' otherwise.

SELECT name, CASE
            WHEN dept IN (1,2) THEN 'Sci'
            WHEN dept=3 THEN 'Art'
            ELSE 'None'
            END 
            FROM teacher

-- Q11: Give the id and the name for the stops on the '4' 'LRT' service.
-- Source: https://sqlzoo.net/wiki/Self_join
SELECT s.id,s.name
        FROM stops s
        JOIN route r
        ON s.id = r.stop
        WHERE r.company = 'LRT' AND r.num = '4' 

-- 