SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent is not null 
order by 3,4

-- select data to use
SELECT location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
WHERE continent is not null 
order by 1,2

--total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE continent is not null 
--where location like '%united kingdom'
order by 1,2

--total cases vs population
SELECT location, date, population, total_cases, (total_cases/population) *100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE continent is not null 
--where location like '%united kingdom'
order by 1,2

--highest infection rate countries compared to population
SELECT location, population, date, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population)) *100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE continent is not null 
Group by location, population, date
Order by PercentPopulationInfected desc

--view
CREATE VIEW PercentagePopInfected as
SELECT location, population, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population)) *100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE continent is not null 
Group by location, population 


--highest mortality per population 
SELECT location, MAX(Total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null 
Group by location
Order by TotalDeathCount desc

--highest mortality by continent
SELECT location, MAX(Total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent is null and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc

--avg cases, avg deaths and mortality per continent
SELECT
    continent,
    AVG(total_cases) AS avg_total_cases,
    AVG(total_deaths) AS avg_total_deaths,
    (SUM(total_deaths) * 100.0 / NULLIF(SUM(total_cases), 0)) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY continent;

--GLOBAL NUMBERS
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalNewDeaths, SUM(new_deaths)/SUM(new_cases)* 100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths
WHERE continent is not null 
order by 1,2

--total population vs vaccinations (how many vaccinated people in the world)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(new_vaccinations) OVER (Partition by dea.location ORDER BY Dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date 
WHERE dea.continent is not null 
order by 2,3

--using CTE 

With PopvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,new_vaccinations)) OVER (Partition by dea.location ORDER BY Dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date 
WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/population)* 100
FROM PopvsVac

--TEMP TABLE
CREATE TABLE #PercentPopulationVaccinated
(
    continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population numeric,
    new_vaccinartions numeric,
    RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,new_vaccinations)) OVER (Partition by dea.location ORDER BY Dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date 
WHERE dea.continent is not null 

SELECT *, (RollingPeopleVaccinated/population)* 100
FROM #PercentPopulationVaccinated

DROP Table if exists #PercentPopulationVaccinated


--View
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(new_vaccinations) OVER (Partition by dea.location ORDER BY Dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date 
WHERE dea.continent is not null 

select *
from PercentPopulationVaccinated