# MLB_Advanced_SQL_Querying_Project
My first project using advanced MySQL querying techniques and functions


### Introduction

From Maven Analytics Advanced SQL Querying course: 

>You’ve just been hired as a Data Analyst Intern for Major League Baseball (MLB), who has recently gotten access to a large amount of historical player data
>You have access to decades worth of data, including player statistics like schools attended, salaries, teams played for, height and weight, and more
>Your task is to use advanced SQL querying techniques to track how player statistics have changed over time and across different teams in the league

The dataset comes from **Sean Lahman's Baseball Database** and is divided into four tables:
1. **schools:** *playerID, schoolID, yearID.*
2. **school_details:** *schoolID, name_full, city, state, country.*
3. **players:**
   - *birthYear, birthMonth, birthDay, birthCountry, birthState, birthCity,*
   - *deathYear, deathMonth, deathDay, deathCountry, deathState, deathCity,*
   - *nameFirst, nameLast, nameGiven,*
   - *weight(lb), height(in), bats(R/L/B), throws, debut, finalGame, retroID, bbrefID*
5. **salaries:**
   - *yearID, teamID, lgID, playerID, salary*

### Key Findings

1. The top five schools that produced the most players

![The top five schools that produced the most players](https://github.com/user-attachments/assets/a6cb57c7-0361-4dd2-81d6-07d7a3703ebe)

The top three schools that produced over one hundred players are particularly impressive. University of Texas at Austin(winning percentage: .600), University of Southern California(wp: .627), Arizona State University(wp: .664). It will be interesting to understand how these three universities managed to create so many players. 

2. 

### Impact



### Disclaimer
This project uses a dataset provided by Maven Analytics from  Sean Lahman's Baseball Database. I do not own or claim any rights to the dataset. This analysis is conducted purely for educational and non-commercial purposes.
