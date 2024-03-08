select *
from [covid-deaths]
order by 3, 4;

select *
from [covid-vacinations]
order by 3, 4;

select location, date, total_cases, new_cases, total_deaths, population
from [covid-deaths]
order by 1, 2;