SELECT*
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT*
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2

--Total cases vs total deaths
SELECT location,date,total_cases,new_cases,total_deaths,ROUND((total_deaths/total_cases*100),2) AS Death_percentage_of_total_cases
FROM CovidDeaths
WHERE location like 'India%'
ORDER BY 1,2

--Looking at total cases vs the population

SELECT location,date,total_cases,new_cases,total_deaths,ROUND((total_cases/population*100),2) as covidcasespercentage
FROM CovidDeaths
WHERE location like 'India%'
ORDER BY 1,2

--Countries with highest infection rate compared to population
SELECT location,population,MAX(total_cases) as highestInfectionCount,MAX(ROUND((total_cases/population*100),2)) as PercentagePopulationInfected
FROM CovidDeaths
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC

--Show continents with highest death count per population
SELECT continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Group by continent
SELECT location,SUM(cast(new_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

  --Excluding World, International and EU
  SELECT location,SUM(cast(New_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World','International','European Union')
GROUP BY location
ORDER BY TotalDeathCount DESC

--GLOBAL numbers

SELECT SUM(new_cases) as totalCases,SUM(cast(new_deaths as int)) as TotalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Joining both excel files, finding total ppltn vs vaccinations
  
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as rolling_people_vaccinated
FROM CovidDeaths dea
JOIn CovidVaccinations vac
ON dea.date=vac.date
AND dea.location=vac.location
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

---Finding the %, hence also making a CTE

WITH PopvsVac (continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
AS (SELECT dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,ROUND((RollingPeopleVaccinated/population*100,2)
From PopVsVac
--WHERE RollingPeopleVaccinated IS NOT NULL
--ORDER BY 6 DESC


--TEMP table
  
DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/Population*100) as percentageOfPeopleVaccinated
FROM  #PercentPopulationVaccinated
--Total population vs vaccinations
WITH PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as 
(SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL)
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/Population*100) as percentageOfPeopleVaccinated
FROM PopvsVac


---CTE
--WITH PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)

CREATE VIEW percentpopulationvaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
from percentpopulationvaccinated


