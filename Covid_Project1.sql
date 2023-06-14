SELECT *
FROM [dbo].[CovidDeaths]
ORDER BY 3,4

SELECT *
FROM [dbo].[CovidVaccinations]
ORDER BY 3,4

-- SELECT DATA THAT WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [dbo].[CovidDeaths]
ORDER BY 1,2


-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM [dbo].[CovidDeaths]
WHERE location LIKE '%Chile%'
AND continent IS NOT NULL
ORDER BY 1,2

-- LOOKING AT TOTAL CASES VS POPULATION
-- SHOWS PERCENTAGE OF POPULATION WITH COVID

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS percent_population
FROM [dbo].[CovidDeaths]
-- WHERE location LIKE '%Chile%'
ORDER BY 1,2

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, 
MAX(total_cases) AS highest_infection_count,
MAX((total_cases/population)) * 100 AS percent_population_infected
FROM [dbo].[CovidDeaths]
--WHERE location LIKE '%Chile%'
GROUP BY location, population
ORDER BY percent_population_infected DESC

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION 

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM [dbo].[CovidDeaths]
--WHERE location LIKE '%Chile%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC


-- SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM [dbo].[CovidDeaths]
--WHERE location LIKE '%Chile%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM [dbo].[CovidDeaths]
--WHERE location LIKE '%Chile%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- LOOKING AT TOTAL POPULATION VACCINATED

SELECT
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location
ORDER BY dea.location, dea.date) AS rolling_people_vac
--, (rolling_people_vac/population)*100
FROM PortfolioProject_covid..CovidDeaths AS dea
JOIN PortfolioProject_covid..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


-- USE CTE (COMMON TABLE EXPRESSION)

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vac)
AS (
SELECT
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location
ORDER BY dea.location, dea.date) AS rolling_people_vac
--, (rolling_people_vac/population)*100
FROM PortfolioProject_covid..CovidDeaths AS dea
JOIN PortfolioProject_covid..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (rolling_people_vac/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #percent_pop_vac
CREATE TABLE #percent_pop_vac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_people_vac numeric, 
)

INSERT INTO #percent_pop_vac
SELECT
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location
ORDER BY dea.location, dea.date) AS rolling_people_vac
--, (rolling_people_vac/population)*100
FROM PortfolioProject_covid..CovidDeaths AS dea
JOIN PortfolioProject_covid..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
SELECT *, (rolling_people_vac/population)*100
FROM #percent_pop_vac


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW percent_pop_vac AS
SELECT
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location
ORDER BY dea.location, dea.date) AS rolling_people_vac
--, (rolling_people_vac/population)*100
FROM PortfolioProject_covid..CovidDeaths AS dea
JOIN PortfolioProject_covid..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *
FROM percent_pop_vac