
USE PortfolioProject


SELECT *
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..Covidvaccinations
--ORDER BY 3,4


SELECT Location, Date, Total_cases, New_cases, Total_deaths, Population
FROM CovidDeaths ORDER BY 1,2


--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
--Death percentage
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    CASE 
        WHEN (total_cases  IS NOT NULL AND total_deaths  IS NOT NULL) AND total_cases > 0 
		THEN (CAST(total_deaths AS FLOAT) * 100 / CAST(total_cases AS FLOAT))
        ELSE NULL  -- Result is NULL if either total_cases or total_deaths is NULL or total_cases is 0
    END as Death_Percentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
--WHERE location  LIKE '%States%'
ORDER BY location, date;



--Looking at total cases vs population
--Shows the percentage of population got Covid

SELECT
    location, date, population, total_cases,
	CASE
	   WHEN (Total_cases IS NOT NULL ) AND  Total_cases > 0
	   THEN CAST(CAST(Total_cases AS FLOAT) * 100 / CAST(population AS FLOAT)AS DECIMAL (10,8))
	   ELSE NULL
	END AS PercentPopulationInfected
FROM CovidDeaths
WHERE Continent IS NOT NULL
--WHERE location LIKE '%states%'
ORDER BY 1,2;



--3,4.looking at countries with highest infection rate compared to population & Date

SELECT
    location, --Date,
    population,
    MAX(CAST(total_cases AS INT)) AS Highest_infection_count,
    CASE
        WHEN  MAX(CAST(total_cases AS INT)) IS NOT NULL AND  MAX(CAST(total_cases AS INT)) > 0
        THEN MAX(CAST(total_cases AS FLOAT)) * 100 / MAX(CAST(population AS FLOAT))
        ELSE NULL
    END AS Percent_population_infected
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY location, population --,Date
ORDER BY Percent_population_infected DESC 



--5.Countries with the highest death count per population

SELECT
    location,  MAX(CAST(total_deaths as INT)) AS TotalDeathCount 
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY location 
ORDER BY  TotalDeathCount  DESC;



--2.Continents with the highest death count per population 

SELECT
     Continent, MAX(CAST(total_deaths as INT)) AS TotalDeathCount 
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY  TotalDeathCount  DESC;



--1.GLOBAL NUMBERS

SELECT --Date,
       SUM(new_cases)as Total_cases,
       SUM(new_deaths) as Total_deaths,
      CASE
	    WHEN (SUM(new_cases) IS NOT NULL AND SUM(new_deaths) IS NOT NULL) AND SUM(new_cases) > 0 
		THEN (CAST(SUM(new_deaths) AS FLOAT)/ CAST(SUM(new_cases) AS FLOAT)) * 100 
        ELSE NULL  
      END as DeathPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
--GROUP BY Date
ORDER BY 1,2;



--Looking at total population vs. vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations )) 
OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS Total_vaccinations
FROM CovidDeaths dea
Join CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL
--WHERE dea.location LIKE 'Canada'
ORDER BY 2,3



--Using CTE to get the Vaccination Percentage

WITH PopVsVac (Continent, location, date, population, new_vaccinations, Total_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations )) 
OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS Total_vaccinations
FROM CovidDeaths dea
Join CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL
--WHERE dea.location LIKE 'Canada'
--ORDER BY 2,3
) 
SELECT *, (Total_vaccinations/Population)*100 AS  VaccinationPercentage
FROM PopVsVac
ORDER BY 2,3




-- Create a Temp Table to get the Vaccination Percentage

CREATE TABLE #PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population FLOAT,
    New_Vaccinations BIGINT,
    Total_Vaccinations BIGINT );

INSERT INTO #PercentPopulationVaccinated (Continent, Location, Date, Population, New_Vaccinations, Total_Vaccinations)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS Total_vaccinations
FROM CovidDeaths dea
Join CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL;

SELECT *, (Total_vaccinations / Population) * 100 AS VaccinationPercentage
FROM  #PercentPopulationVaccinated
ORDER BY 2, 3;



--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS Total_vaccinations
FROM CovidDeaths dea
Join CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL
--ORDER BY 2,3;


SELECT *
FROM PercentPopulationVaccinated
ORDER BY 2,3