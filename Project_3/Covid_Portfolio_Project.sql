select * 
from PortfolioProject..CovidDeaths
order by 3,4


------select * 
------from PortfolioProject..CovidVaccinations
------order by 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

select * from information_schema.columns

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths FLOAT

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases FLOAT


-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%indonesia%'
ORDER BY 1,2

-- Looking at Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%indonesia%'
ORDER BY 1,2

-- Looking at Countries with highest Infection Rate compared to Population  

SELECT location, MAX(total_cases) as HighestInfectionNumber, population, MAX((total_cases/population))*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location
ORDER BY InfectionPercentage DESC

-- Looking at Countries with highest Death Number per Population

SELECT location, population, MAX(total_deaths) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeaths DESC

-- Break things down by Continent

SELECT continent, MAX(total_deaths) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeaths DESC

-- Global Numbers of Cases and Deaths

SELECT SUM(cast(new_cases as FLOAT)) as Total_Cases, 
SUM(cast(new_deaths as FLOAT)) as Total_Deaths , (SUM(cast(new_deaths as FLOAT))/SUM(cast(new_cases as FLOAT)))*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null


-- Comparing Total Population with Total Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

DROP View if exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 