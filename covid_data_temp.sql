SELECT * 
FROM giraffe.covid_deaths
WHERE continent is not null
ORDER BY 3,4;


-- SELECT * 
-- FROM giraffe.covid_vaccine
-- ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM giraffe.covid_deaths
ORDER BY 1,2;

-- death rate of people infected with covid in a specific country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM giraffe.covid_deaths
WHERE location = 'United States'
ORDER BY 1,2;

-- look at total cases as a percentage of population
SELECT location, date, total_cases, population, (total_cases/population)*100 as infected_percentage
FROM giraffe.covid_deaths
WHERE location = 'Canada'
ORDER BY 1,2;

-- look at countries with highest infection rate 
SELECT location, population, MAX(total_cases) as case_count, MAX(total_cases/population)*100 as infected_percentage
FROM giraffe.covid_deaths
GROUP BY location, population
ORDER BY 4 DESC;

-- look at countries with highest death rate
SELECT location, population, MAX(total_deaths) as death_count, MAX(total_deaths/population)*100 as death_percentage
FROM giraffe.covid_deaths
GROUP BY location, population
ORDER BY 4 DESC;

-- this data contains two different measures for continents. 
-- selecting location
SELECT location, MAX(total_deaths) as death_count
FROM giraffe.covid_deaths
WHERE continent is null
GROUP BY 1
ORDER BY death_count DESC;
-- selecting continent
SELECT continent, MAX(total_deaths) as death_count
FROM giraffe.covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY death_count;

-- global numbers by day
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) as death_rate
FROM giraffe.covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- global numbers total
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_rate
FROM giraffe.covid_deaths
WHERE continent is not null
ORDER BY 1,2;

-- select all while joining both tables based on date and location
SELECT *
FROM giraffe.covid_vaccine dea
JOIN giraffe.covid_deaths vac
	ON dea.date = vac.date
    AND dea.location = vac.location;

-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_count_vaccine
FROM giraffe.covid_vaccine vac
JOIN giraffe.covid_deaths dea
	ON dea.date = vac.date
    AND dea.location = vac.location
WHERE dea.continent is not null
ORDER by 2,3;

-- CTE 
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_count_vaccine)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_count_vaccine
FROM giraffe.covid_vaccine vac
JOIN giraffe.covid_deaths dea
	ON dea.date = vac.date
    AND dea.location = vac.location
WHERE dea.continent is not null
)
SELECT *, (rolling_count_vaccine/population)*100
FROM pop_vs_vac;

-- temp table
DROP TABLE IF EXISTS percentpopulationvaccinated;
CREATE TABLE percentpopulationvaccinated
(continent NVARCHAR(255), 
location NVARCHAR(255), 
date DATETIME, 
population BIGINT, 
new_vaccinations INT,
rolling_count_vaccine FLOAT);

INSERT INTO percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_count_vaccine
FROM giraffe.covid_vaccine vac
JOIN giraffe.covid_deaths dea
	ON dea.date = vac.date
    AND dea.location = vac.location
WHERE dea.continent is not null;

SELECT *, (rolling_count_vaccine/population)*100
FROM percentpopulationvaccinated;


-- create view to store data for later visualizations

CREATE VIEW percentpopulationvaccinated1 AS
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_count_vaccine
FROM giraffe.covid_vaccine vac
JOIN giraffe.covid_deaths dea
	ON dea.date = vac.date
    AND dea.location = vac.location
WHERE dea.continent is not null;