/* 
Project: COVID-19 3-Year Look Back
Query: Data Cleaning
Author: Mandy HP Nguyen

Project Source: GitHub (https://github.com/MandyHPNguyen/covid-19-stats)
Data Source: Our World Data (https://github.com/owid/covid-19-data/tree/master/public/data)
*/


SELECT * FROM Covid19Stats..[covid-deaths]
-- #1. Correct Data Type

-- Death Table;
ALTER TABLE Covid19Stats..[covid-deaths] ALTER COLUMN date date;
ALTER TABLE Covid19Stats..[covid-deaths] ALTER COLUMN population INT;
ALTER TABLE Covid19Stats..[covid-deaths] ALTER COLUMN total_cases INT;
ALTER TABLE Covid19Stats..[covid-deaths] ALTER COLUMN new_cases INT;
ALTER TABLE Covid19Stats..[covid-deaths] ALTER COLUMN total_deaths INT;
ALTER TABLE Covid19Stats..[covid-deaths] ALTER COLUMN new_deaths INT;
ALTER TABLE Covid19Stats..[covid-deaths] ALTER COLUMN new_deaths INT;

--#2. Trim Records
-- Due to the ending of WHO's mandatory reporting on 5/5/2023, all records after that date will not be concerned and cut off.

DELETE FROM Covid19Stats..[covid-deaths]
WHERE date > '5/5/2023';

DELETE FROM Covid19Stats..[covid-vacinations]
WHERE date > '5/5/2023';