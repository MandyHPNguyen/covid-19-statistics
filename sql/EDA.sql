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
ORDER BY 3, 4
;
-- Vacination Tables
SELECT *
FROM Covid19Stats..[covid-vacinations]
ORDER BY 3, 4
;

-- #2-Exploratory Analysis

-- Case Demographics
----- All Records
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid19Stats..[covid-deaths]
ORDER BY 1, 2
;

-- Total Deaths Rank by Contient & Country
SELECT
	*
FROM (
	SELECT
		continent, location, population
		, MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths
		, RANK() OVER (ORDER BY MAX(total_deaths) DESC) AS death_rank
	FROM Covid19Stats..[covid-deaths]
	GROUP BY continent, location, population
) t
WHERE continent <> ''
ORDER BY continent, location, death_rank
;

-- Total Deaths vs Total Cases
------- The likelihood of deaths by country
SELECT 
	location, date, total_deaths, total_cases, new_cases, population
	, ROUND( ( CAST(total_deaths AS float) / NULLIF( CAST(total_cases AS float), 0) ) *100, 15) AS death_total_ratio
FROM (
	SELECT
		*,
		ROW_NUMBER() OVER ( PARTITION BY location
							ORDER BY date DESC) AS row_number
	FROM Covid19Stats..[covid-deaths]
) t
WHERE 
	continent <> ''
	and t.row_number = 1
ORDER by location
;

-- Total Cases vs Population
-- The likelihood of infection by population
SELECT 
	location, date, total_deaths, total_cases, new_cases, population
	, ROUND( ( CAST(total_cases AS float) / NULLIF( population, 0 ) ) *100, 15) AS total_pop_ratio
FROM (
	SELECT
		*,
		ROW_NUMBER() OVER ( PARTITION BY location
							ORDER BY date DESC) AS row_number
	FROM Covid19Stats..[covid-deaths]
) t
WHERE 
	continent <> ''
	AND t.row_number = 1
ORDER by location
;

-- Highest Infection By Population and Deaths by Infection
SELECT
	location, population, total_infected, total_dead, infected_pop_rank
	, ROUND( ( total_infected / NULLIF( population, 0 ) ) *100, 4) AS infected_pop_ratio
	, dead_infected_rank
	, ROUND( ( total_dead / NULLIF( total_infected , 0 ) ) *100, 4) AS dead_infected_ratio
FROM (
	SELECT 
		location, population
		, CAST( MAX(total_deaths) AS float ) AS total_dead
		, CAST( MAX(total_cases) AS float ) AS total_infected
		, RANK() OVER( ORDER BY( ROUND( ( CAST( MAX(total_cases) AS float ) / NULLIF( population, 0 ) ) *100, 4) ) DESC ) as infected_pop_rank
		, RANK() OVER( ORDER BY( ROUND( ( CAST( MAX(total_deaths) AS float ) / NULLIF( CAST( MAX(total_cases) AS float ), 0 ) ) *100, 4) ) DESC ) as dead_infected_rank
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

ORDER by t.location -- t.infected_pop_rank ASC, t.dead_infected_rank ASC
;

-- Death rate by continent
----- User continent column
SELECT
	continent
	, MAX( total_deaths ) AS TotalDeathCount
FROM Covid19Stats..[covid-deaths]
WHERE continent <> ''
GROUP BY continent
ORDER BY TotalDeathCount DESC
;
----- User location column
SELECT
	location
	, MAX( total_deaths ) AS TotalDeathCount
FROM Covid19Stats..[covid-deaths]
WHERE continent = ''
GROUP BY location
ORDER BY TotalDeathCount DESC
;

-- Global Number
SELECT
	SUM( CAST(new_cases AS float) ) AS NewCases
	, SUM( CAST(total_deaths AS float) ) AS TotalDeaths
	, ( SUM( CAST(new_deaths AS float) ) / SUM( CAST(new_cases AS float) ) )*100 AS death_new_ratio
FROM Covid19Stats..[covid-deaths]
WHERE continent <> ''
ORDER BY 1
;

-- Total Population vs Vaccination
SELECT
	d.continent, d.location, d.date, d.population
	, v.new_vaccinations
	, SUM( CONVERT(float, v.new_vaccinations) ) OVER( PARTITION BY d.location ORDER BY d.location, d.date ) AS RollingPeopleVaccinated
FROM Covid19Stats..[covid-deaths] d
JOIN Covid19Stats..[covid-vacinations] v
	ON d.location = v.location
	AND d.date = v.date
WHERE 
	d.continent <> ''
	AND d.location = 'United States'
ORDER BY 1,2,3
;