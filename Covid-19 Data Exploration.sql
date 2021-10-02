/* Checking to verify tables match Excel files  */
Select *
FROM [Portfolio Project].[dbo].[CovidDeaths]
where continent is not null
order by 3,4

Select *
FROM [Portfolio Project].[dbo].[CovidVaccinations]
where continent is not null
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].[dbo].[CovidDeaths]
where continent is not null
Order by 1,2

/* Covid Cases in Canada with total deaths and death percentage */
-- This shows the liklihood of dying if you contract Covid-19--
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
FROM [Portfolio Project].[dbo].[CovidDeaths]
Where location = 'Canada' and continent is not null
Order by 1,2

-- Total cases vs population
Select location, date, total_cases, population, (total_cases/population)*100 As PopulationInfected
FROM [Portfolio Project].[dbo].[CovidDeaths]
Where location = 'Canada' and continent is not null
Order by 1,2

-- Checking to see what countries has the highest infection rate compared to population
Select location, population, MAX(total_cases) AS HighestInfectionCount,MAX(total_cases/population)*100 As PopulationInfected
FROM [Portfolio Project].[dbo].[CovidDeaths]
where continent is not null
GROUP BY location, population
ORDER BY PopulationInfected DESC

-- Countries with highest Death Count per population
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project].[dbo].[CovidDeaths]
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

/* looking at things by Continent   */
--- continents with highest Death Count per population---
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project].[dbo].[CovidDeaths]
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


/* Global Numbers   */
Select SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 As DeathPercentage
FROM [Portfolio Project].[dbo].[CovidDeaths]
where continent is not null
Order by 1,2


/*Merging the 2 tables*/      -- Looking at Total population vs Vaccinations ---

Select dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations, Sum(convert(int,Vacc.new_vaccinations)) OVER (partition by Dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
FROM [Portfolio Project].[dbo].CovidDeaths As Dea
JOIN [Portfolio Project].[dbo].CovidVaccinations As Vacc
	ON Dea.location = Vacc.location
	AND Dea.date = Vacc.date
Where dea.continent is not null
order by 2,3

--- USE CTE ---

WITH PopvsVac (Continent, location, date, population,new_vaccinations, RollingVaccinated)
As
(Select dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations, Sum(convert(int,Vacc.new_vaccinations)) OVER (partition by Dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
FROM [Portfolio Project].[dbo].CovidDeaths As Dea
JOIN [Portfolio Project].[dbo].CovidVaccinations As Vacc
	ON Dea.location = Vacc.location
	AND Dea.date = Vacc.date
Where dea.continent is not null
)
SELECT *, (RollingVaccinated/population)*100 
FROM PopvsVac

--- Temp Table ---   /* Percent Population  */

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations, Sum(convert(int,Vacc.new_vaccinations)) OVER (partition by Dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
FROM [Portfolio Project].[dbo].CovidDeaths As Dea
JOIN [Portfolio Project].[dbo].CovidVaccinations As Vacc
	ON Dea.location = Vacc.location
	AND Dea.date = Vacc.date
Where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated

/* Creating View to store data   for later visualizations   */

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations, Sum(convert(int,Vacc.new_vaccinations)) OVER (partition by Dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
FROM [Portfolio Project].[dbo].CovidDeaths As Dea
JOIN [Portfolio Project].[dbo].CovidVaccinations As Vacc
	ON Dea.location = Vacc.location
	AND Dea.date = Vacc.date
Where dea.continent is not null

Select *
FROM PercentPopulationVaccinated
