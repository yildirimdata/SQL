-- JOIN exercises:
-- Source: https://sqlzoo.net/wiki/The_JOIN_operation

-- QUESTION 1:
-- show the player, teamid, stadium and mdate for every German goal.

SELECT player,teamid, 
        stadium, mdate
    FROM game JOIN goal ON (id=matchid)
    WHERE teamid = 'GER';

-- QUESTION 2:
-- Show the team1, team2 and player for every goal scored by a player called Mario player LIKE 'Mario%'

SELECT team1, team2, player
    FROM game
    JOIN goal
    ON (id=matchid)
    WHERE player LIKE 'Mario%';

-- QUESTION 3
-- Show player, teamid, coach, gtime for all goals scored in the first 10 minutes gtime<=10
SELECT player, teamid, coach, gtime
    FROM goal 
    JOIN eteam
    ON teamid=id
    WHERE gtime<=10;

-- QUESTION 4
-- List the dates of the matches and the name of the team in which 'Fernando Santos' was the team1 coach.

SELECT g.mdate, e.teamname
    FROM game g
    JOIN eteam e
    ON g.team1=e.id
    WHERE e.coach = 'Fernando Santos';

-- QUESTION 5
-- List the player for every goal scored in a game where the stadium was 'National Stadium, Warsaw'

SELECT g.player
    FROM goal g
    JOIN game e
    ON g.matchid = e.id
    WHERE e.stadium = 'National Stadium, Warsaw';

-- QUESTION 7:
-- The example query shows all goals scored in the Germany-Greece quarterfinal.
-- Instead show the name of all players who scored a goal against Germany.

SELECT DISTINCT player 
    FROM game 
    JOIN goal 
    ON (id = matchid)
	WHERE (team1 = 'GER'    
            OR team2 = 'GER') 
		    AND teamid <> 'GER';

-- QUESTION 8
-- Show teamname and the total number of goals scored.

SELECT e.teamname, COUNT(g.gtime)
    FROM eteam e
    JOIN goal g
    ON e.id=g.teamid
    GROUP BY e.teamname;

-- QUESTION 9
-- Show the stadium and the number of goals scored in each stadium.

SELECT stadium, COUNT(go.gtime)
    FROM game g
    JOIN goal go
    ON g.id=go.matchid
    GROUP BY g.stadium

-- QUESTION 10
-- For every match involving 'POL', show the matchid, date and the number of goals scored.

SELECT  go.matchid, ga.mdate, 
        COUNT(go.gtime)
    FROM game ga
    LEFT JOIN goal  go
    ON ga.id = go.matchid
    WHERE (ga.team1 = 'POL' OR ga.team2 = 'POL')
    GROUP BY go.matchid, ga.mdate;

-- QUESTION 11
-- For every match where 'GER' scored, show matchid, match date and the number of goals scored by 'GER'

SELECT go.matchid, ga.mdate, 
        COUNT(go.gtime)
    FROM goal go
    JOIN game ga
    ON ga.id = go.matchid
    WHERE go.teamid = 'GER'
    GROUP BY go.matchid, ga.mdate;

-- TABLE TENNIS OLYMPICS DATABASE (source: https://sqlzoo.net/wiki/Old_JOIN_Tutorial)

-- Question 12
-- Show the who and the color of the medal for the medal winners from 'Sweden'.

SELECT t.who, t.color
    FROM ttms t
    JOIN country c
    ON t.country = c.id
    WHERE c.name = 'Sweden'

-- Question 13
-- Show the years in which 'China' won a 'gold' medal.

SELECT t.games
    FROM ttms t
    JOIN country c
    ON t.country = c.id
    WHERE c.name = 'China' 
        AND t.color = 'gold';

-- Women's Singles Table Tennis Olympics Database (source: https://sqlzoo.net/wiki/Old_JOIN_Tutorial)


-- QUESTION 14
-- Show who won medals in the 'Barcelona' games.

SELECT t.who
    FROM ttws t 
    JOIN games g 
    ON (t.games=g.yr)
    WHERE g.city = 'Barcelona';



-- QUESTION 15
-- Show which city 'Jing Chen' won medals. Show the city and the medal color.

SELECT g.city, t.color
    FROM ttws t
    JOIN games g
    ON t.games = g.yr
    WHERE t.who = 'Jing Chen'; 

-- Question 16
-- Show who won the gold medal and the city.

SELECT t.who, g.city
    FROM ttws t
    JOIN games g
    ON t.games=g.yr
    WHERE color = 'gold'


-- Table Tennis Mens Doubles (source: https://sqlzoo.net/wiki/Old_JOIN_Tutorial)

-- Question 17
-- Show the games and color of the medal won by the team that includes 'Yan Sen'.

SELECT t.games, t.color
    FROM ttmd t
    JOIN team m
    ON t.team = m.id
    WHERE m.name LIKE '%Yan Sen%'

-- Question 18
-- Show the 'gold' medal winners in 2004.

SELECT m.name
    FROM team m
    JOIN ttmd t
    ON t.team = m.id
    WHERE t.games = 2004 
            AND t.color = 'gold'

-- Question 19
-- Show the name of each medal winner country 'FRA'.

SELECT m.name
    FROM team m
    JOIN ttmd t
    ON t.team = m.id
    WHERE t.country = 'FRA'

-- QUESTION 20 (source: https://sqlzoo.net/wiki/More_JOIN_operations)
-- Obtain the cast list for 'Casablanca'. The cast list is the names of the actors who were in the movie.

SELECT a.name 
    FROM casting c
    JOIN movie m 
        ON c.movieid=m.id
    JOIN actor a 
        ON c.actorid = a.id
    WHERE c.movieid = 
            (
            SELECT id FROM movie
            WHERE title = 'Casablanca'
            )


-- Q21
-- Obtain the cast list for the film 'Alien'

SELECT a.name
    FROM casting c
    JOIN actor a
        ON c.actorid=a.id
    WHERE movieid = 
        (
        SELECT id 
        FROM movie
        WHERE title= 'Alien'
        )

-- Q22
-- List the films in which 'Harrison Ford' has appeared

SELECT m.title
    FROM movie m
    JOIN casting c
        ON m.id = c.movieid
    WHERE c.actorid =
        (
        SELECT id 
        FROM actor
        WHERE name = 'Harrison Ford'
        )

-- Q23
-- List the films where 'Harrison Ford' has appeared - but not in the starring role. [Note: the ord field of casting gives 
-- the position of the actor. If ord=1 then this actor is in the starring role]

SELECT m.title
    FROM movie m
    JOIN casting c
        ON m.id = c.movieid
    WHERE c.ord !=1 
        AND c.actorid = 
            (
            SELECT id 
            FROM actor
            WHERE name = 'Harrison Ford'
            )

-- Q24
-- List the films together with the leading star for all 1962 films.

SELECT m.title, a.name
    FROM movie m
    JOIN casting c
        ON m.id = c.movieid
    JOIN actor a
    ON c.actorid = a.id 
    WHERE c.ord = 1 
        AND m.yr = 1962;