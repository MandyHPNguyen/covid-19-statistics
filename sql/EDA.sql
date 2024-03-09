/* 
Project: COVID-19 3-Year Look Back
Query: Data Exploration
Author: Mandy HP Nguyen

Project Source: GitHub (https://github.com/MandyHPNguyen/covid-19-stats)
Data Source: Our World Data (https://github.com/owid/covid-19-data/tree/master/public/data)
Data Cutoff: 5/5/2023 (https://github.com/owid/covid-19-data/issues/2784)
Reporting Frequency: Every Wednesday - Pattern changed from Johns Hopkins to WHO's (https://github.com/owid/covid-19-data/issues/2784)
*/


-- #1-Load Data

-- Death Tables
SELECT *
FROM Covid19Stats..[covid-deaths]
ORDER BY 3, 4;
-- Vacination Tables
SELECT *
FROM Covid19Stats..[covid-vacinations]
ORDER BY 3, 4;

-- #2-Exploratory Analysis

-- Case Demographics
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid19Stats..[covid-deaths]
ORDER BY 1, 2;

/*
SELECT 
	location, date, total_deaths, total_cases, new_cases, population,
	ROUND( ( CAST(total_deaths AS float) / NULLIF( CAST(total_cases AS float), 0) ) *100, 15) AS death_p_case,
	ROUND( ( CAST(total_cases AS float) / NULLIF( population, 0 ) ) *100, 15) AS case_p_pop,
	ROUND( ( CAST(total_deaths AS float) / NULLIF( population, 0 ) ) *100, 15) AS death_p_pop
FROM Covid19Stats..[covid-deaths]

WHERE location LIKE '%United States%'
	OR location LIKE '%Viet%'
ORDER BY 1, 2;
*/


-- Total Deaths Rank by Country
SELECT
	death_rank, continent, location, population, total_cases, total_deaths
FROM (
	SELECT
		continent, location, population, 
		MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths,
		RANK() OVER (ORDER BY MAX(total_deaths) DESC) AS death_rank
	FROM Covid19Stats..[covid-deaths]
	GROUP BY continent, location, population
) t
ORDER BY death_rank ASC;

-- Total Infection Rank by Country


-- Total Deaths vs Total Cases
-- The likelihood of deaths by country
SELECT 
	location, date, total_deaths, total_cases, new_cases, population,
	ROUND( ( CAST(total_deaths AS float) / NULLIF( CAST(total_cases AS float), 0) ) *100, 15) AS death_p_case
FROM (
	SELECT
		*,
		ROW_NUMBER() OVER ( PARTITION BY location
							ORDER BY date DESC) AS row_number
	FROM Covid19Stats..[covid-deaths]
) t
WHERE t.row_number = 1
ORDER by location;

-- Total Cases vs Population
-- The likelihood of infection by population
SELECT 
	location, date, total_deaths, total_cases, new_cases, population,
	ROUND( ( CAST(total_cases AS float) / NULLIF( population, 0 ) ) *100, 15) AS case_p_pop
FROM (
	SELECT
		*,
		ROW_NUMBER() OVER ( PARTITION BY location
							ORDER BY date DESC) AS row_number
	FROM Covid19Stats..[covid-deaths]
) t
WHERE t.row_number = 1
ORDER by location;

-- Highest Infection By Population and Deaths by Infection
SELECT
	location, population, total_infected, total_dead, infected_pop_rank,
	ROUND( ( total_infected / NULLIF( population, 0 ) ) *100, 4) AS pop_infected_ratio,
	dead_infected_rank,
	ROUND( ( total_dead / NULLIF( total_infected , 0 ) ) *100, 4) AS dead_infected_ratio
FROM (
	SELECT 
		location, population,
		CAST( MAX(total_deaths) AS float ) AS total_dead,
		CAST( MAX(total_cases) AS float ) AS total_infected,
		RANK() OVER( ORDER BY( ROUND( ( CAST( MAX(total_cases) AS float ) / NULLIF( population, 0 ) ) *100, 4) ) DESC ) as infected_pop_rank,
		RANK() OVER( ORDER BY( ROUND( ( CAST( MAX(total_deaths) AS float ) / NULLIF( CAST( MAX(total_cases) AS float ), 0 ) ) *100, 4) ) DESC ) as dead_infected_rank
	FROM Covid19Stats..[covid-deaths]
	GROUP BY location, population
	) t

WHERE 
	t.location = 'Vietnam'
	OR t.location = 'United States'
	OR t.location = 'India'
	OR t.location = 'China'
	OR t.location LIKE '%United Kingdom%'
	OR t.location = 'Japan'
	OR t.location = 'South Korea'

ORDER by t.infected_pop_rank ASC, t.dead_infected_rank ASC;

