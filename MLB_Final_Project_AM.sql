/* 
Final project for SQL Advanced Query 

Data from: Sean Lahman Baseball Database
Tables : players, salaries, schools, school_details

This is a guided project from Maven Analytics Advanced SQL Querying by Alice Zhao.
It is divided into four parts: 

	- PART 1. School analysis. line 28
    - PART 2. Salary analysis. line 85
    - PART 3. Player career analysis. line 160
    - PART 4. Player comparison analysis. line 235
*/ 

SELECT * 
FROM schools;

SELECT *
FROM school_details;

SELECT * 
FROM players;

SELECT * 
FROM salaries; 

-- PART 1. School Analysis 


-- Q1. In each decade, how many schools were there that produced MLB players?

-- The schools table has all I need: the yearID and schoolID columns. 
-- I will use FLOOR function to create decade bins and COUNT DISTINCT for schools. 

SELECT FLOOR(yearID / 10) * 10 as decade, COUNT(DISTINCT schoolID) as num_schools
FROM schools
GROUP BY decade
ORDER BY decade;


-- Q2. What are the names of the top 5 schools that produced the most players?

SELECT 	sd.name_full, 
		COUNT(DISTINCT s.playerID) as player_count

FROM schools s LEFT JOIN school_details sd 
	ON s.schoolID = sd.schoolID
GROUP BY sd.name_full
ORDER BY player_count desc
LIMIT 5; -- added a limit to only get the top five

/* COMMENT : 
		The only error I made in this query was the joining order. 
        That lead me to have some null values at the end of my query. 
 */ 


-- Q3. For each decade, what were the names of the top 3 schools that produced the most players?

WITH ds as (SELECT 	FLOOR(s.yearID / 10) * 10 as decade, sd.name_full, 
					COUNT(DISTINCT s.playerID) as player_count

			FROM schools s LEFT JOIN school_details sd 
				ON s.schoolID = sd.schoolID
			GROUP BY decade, sd.name_full),

     rn AS (SELECT decade, name_full, player_count, 
					ROW_NUMBER() OVER(PARTITION BY decade ORDER BY player_count DESC) AS row_num  
			 
			 FROM ds)
             
SELECT decade, name_full, player_count
FROM rn
WHERE row_num <= 3
ORDER BY decade desc, row_num;

/* COMMENT : 
	
    This was the hardest one to figure out, and I struggled trying to writing the right query.
    At the end, I tried to use a window function and got to the right solution.
*/


-- PART 2. SALARY ANALYSIS

SELECT *
FROM salaries;

-- Q1. Return the top 20% of teams in terms of average annual spending

WITH sal_sp AS (SELECT yearID, teamID, 
						SUM(salary) as salary_spend
				FROM salaries
                GROUP BY yearID, teamID),
	annual_avg AS (SELECT teamID, 
							AVG(salary_spend) as avg_spend
					FROM sal_sp
                    GROUP BY teamID
                    order by avg_spend desc),
	sr AS(SELECT teamID, avg_spend, NTILE(5) OVER(ORDER BY avg_spend desc) as spend_percentile
			FROM annual_avg
			ORDER BY avg_spend desc)
            
SELECT *
FROM sr
WHERE spend_percentile = 1;

/* 
COMMENTS : 
		
        The first try was wrong. Maybe the query order was wrong.
        Second try was wrong again, but helped me understanding my mistakes.
        The third try was perfect. I went back to my first query and fixed some point et voila!!
*/


-- Q2. For each team, show the cumulative sum of spending over the years

-- First is calculating the spend in salaries fro each year and team
SELECT yearID, teamID, SUM(salary) as sal_spend
FROM salaries
GROUP BY yearID, teamID;

-- Then I need to convert the first query into a CTE, and write a new query for the cumulating sum.

WITH ssp AS (SELECT yearID as yr, teamID as team, SUM(salary) as sal_spend
			FROM salaries
			GROUP BY yearID, teamID )

SELECT yr, team, sal_spend,
		SUM(sal_spend) OVER(PARTITION BY team ORDER BY yr, team) AS cumulative_sum
FROM ssp;



-- Q3. Return the first year that each team's cumulative spending surpassed 1 billion

-- I'll use the previous query and add filter for billion

WITH ssp AS (SELECT yearID as yr, teamID as team, SUM(salary) as sal_spend
			FROM salaries
			GROUP BY yearID, teamID ),
	cs AS(SELECT yr, team, sal_spend,
					SUM(sal_spend) OVER(PARTITION BY team ORDER BY yr, team) AS cumulative_sum
                   
			FROM ssp),
	rn AS (SELECT yr, team, cumulative_sum,
					ROW_NUMBER() OVER(PARTITION BY team ORDER BY cumulative_sum) as rn
			FROM cs
			WHERE cumulative_sum > 1000000000)
            
SELECT *
FROM rn 
WHERE rn = 1;

-- Again it took me a while to understand that I needed the ROW_NUMBER function


-- PART 3. PLAYER CAREER ANALYSIS 

/* 
	Q1.	For each player, calculate their age at their first (debut) game, their last game, and their career length (all in years). 
		Sort from longest career to shortest career. 
*/

-- First I need to combine the birth year month and day into one string and cast it as a date
SELECT playerID, nameGiven, CAST(CONCAT(birthYear,"-", birthMonth,"-", birthDay) as DATE)  as birthday,
		debut
FROM players;

-- now I will convert the query into CTE and use datediff

WITH brtd as (SELECT playerID, nameGiven, CAST(CONCAT(birthYear,"-", birthMonth,"-", birthDay) as DATE)  as birthday,
						debut, finalGame
				FROM players)
                
SELECT 	nameGiven, 
		TIMESTAMPDIFF(year, birthday, debut) as debut_age,
        TIMESTAMPDIFF(year, birthday, finalGame) as retire_age,
        TIMESTAMPDIFF(year, debut, finalGame) as career_length
FROM brtd
ORDER BY career_length desc; 


-- Q2.	What team did each player play on for their starting and ending years?

SELECT *
FROM players;

SELECT *
FROM salaries;

-- I need to joins players and salaries tables on playerID

SELECT 	p.playerID, p.nameGiven, p.debut, p.finalGame,
		s.yearID, s.teamID,
        e.yearID, e.teamID
FROM players p 		INNER JOIN salaries s
					ON p.playerID = s.playerID
					AND YEAR(p.debut) = s.yearID
                    
                    INNER JOIN salaries e
					ON p.playerID = e.playerID
					AND YEAR(p.finalGame) = e.yearID;
        
-- Cleaned up version: 

SELECT 	p.nameGiven,
		s.yearID as starting_year, s.teamID as starting_team,
        e.yearID as ending_year, e.teamID as ending_team
FROM players p 		INNER JOIN salaries s
					ON p.playerID = s.playerID
					AND YEAR(p.debut) = s.yearID
                    
                    INNER JOIN salaries e
					ON p.playerID = e.playerID
					AND YEAR(p.finalGame) = e.yearID;

-- Q3. How many players started and ended on the same team and also played for over a decade?

SELECT 	p.nameGiven,
		s.yearID as starting_year, s.teamID as starting_team,
        e.yearID as ending_year, e.teamID as ending_team
FROM players p 		INNER JOIN salaries s
					ON p.playerID = s.playerID
					AND YEAR(p.debut) = s.yearID
                    
                    INNER JOIN salaries e
					ON p.playerID = e.playerID
					AND YEAR(p.finalGame) = e.yearID
WHERE s.teamID = e.teamID AND e.yearId - s.yearID > 10;


-- PART 4. PLAYER COMPARISON ANALYSIS

/* 
a) Which players have the same birthday?

b) Create a summary table that shows for each team, what percent of players bat right, left and both.

c) How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?
*/ 
SELECT *
FROM players;

-- Q1. Which players have the same birthday?

WITH brtd as (SELECT playerID, nameGiven, CAST(CONCAT(birthYear,"-", birthMonth,"-", birthDay) as DATE)  as birthday
				FROM players)
                
SELECT		birthday,
			GROUP_CONCAT(nameGiven ORDER BY nameGiven SEPARATOR ", ") AS player_names
FROM brtd
WHERE birthday IS NOT NULL
GROUP BY birthday
ORDER BY birthday; 


-- Q2. Create a summary table that shows for each team, what percent of players bat right, left and both.

WITH up AS (SELECT DISTINCT s.teamID, s.playerID, p.bats
           FROM salaries s LEFT JOIN players p
           ON s.playerID = p.playerID) -- unique players CTE

SELECT teamID,
		ROUND(SUM(CASE WHEN bats = 'R' THEN 1 ELSE 0 END) / COUNT(playerID) * 100, 1) AS bats_right,
        ROUND(SUM(CASE WHEN bats = 'L' THEN 1 ELSE 0 END) / COUNT(playerID) * 100, 1) AS bats_left,
        ROUND(SUM(CASE WHEN bats = 'B' THEN 1 ELSE 0 END) / COUNT(playerID) * 100, 1) AS bats_both
FROM up
GROUP BY teamID;

-- I got the joning order wrong again and got some null values. But after some trial and errors I got to the right solution.

-- Q3. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?

WITH hw AS (SELECT	FLOOR(YEAR(debut) / 10) * 10 AS decade,    -- for binning 
					AVG(height) AS avg_height, AVG(weight) AS avg_weight
			FROM	players
			GROUP BY decade)
            
SELECT	decade,
		avg_height - LAG(avg_height) OVER(ORDER BY decade) AS height_diff, 
        avg_weight - LAG(avg_weight) OVER(ORDER BY decade) AS weight_diff
FROM	hw
WHERE	decade IS NOT NULL;

/* 
COMMENT :
	
    This one was really tough to figure out. 
    At first I tried a self join to calculate the height and weight difference Decade-over-Decade.
    After checking the course materials I saw the LAG function and finally reached the correct answer. 
*/

