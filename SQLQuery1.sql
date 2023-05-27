
SELECT *
FROM [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4 


/*
COVID-19 Data Exploration Project

Skills: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


*/


--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--order by 3,4 

-- Select Data that we are goin to be using
select Location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
order by 1,2 

-- Looking at Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract covid in your country
select Location, date, total_cases,  total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location like '%states%'
order by 1,2 


-- Looking at Total cases vs Population
-- shows what percentage of population got COVID
select Location, date, total_cases,  population,(total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
--where location like '%states%'
order by 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population
select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
--where location like '%states%'
group by Location, population
order by PercentPopulationInfected desc


-- showing the countries with the highest death count per popualation
select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

--	BREAKING THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population
select location,MAX(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc



-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null
--group by date
order by 1,2 


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 


-- USE CTE

With PopvsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



-- Using Temp Table to perform calculation on partition by in previous query
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- creating view to store data for later visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated