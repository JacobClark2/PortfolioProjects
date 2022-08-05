--COVID DEATH DATA

Select *
From [Portfolio Project]..CovidDeaths
order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Order By 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
Order By 1,2

-- Looking at Total Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 AS contraction_chance
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
Order By 1,2

-- Looking at Countries with highest Infection Rate compared to Population

Select location, MAX(total_cases) AS highest_infection_count, population, MAX((total_cases/population))*100 AS infection_rate
From [Portfolio Project]..CovidDeaths
Group By population, location
Order By infection_rate DESC

-- Showing Countries with Highest Death Count per Population
Select location, MAX(total_deaths) AS highest_death_count, population, MAX((total_deaths/population))*100 AS death_rate
From [Portfolio Project]..CovidDeaths
Group By population, location
Order By death_rate DESC

-- Break down of Death Rate by Continent

--Africa
Select location, continent, MAX(total_deaths) AS total_death_count, population, MAX((total_deaths/population))*100 AS death_rate
From [Portfolio Project]..CovidDeaths
Where continent = 'Africa'
Group By location, continent, population
Order By death_rate DESC

--Asia
Select location, continent, MAX(total_deaths) AS total_death_count, population, MAX((total_deaths/population))*100 AS death_rate
From [Portfolio Project]..CovidDeaths
Where continent = 'Asia'
Group By location, continent, population
Order By death_rate DESC

--Europe
Select location, continent, MAX(total_deaths) AS total_death_count, population, MAX((total_deaths/population))*100 AS death_rate
From [Portfolio Project]..CovidDeaths
Where continent = 'Europe'
Group By location, continent, population
Order By death_rate DESC

--North America
Select location, continent, MAX(total_deaths) AS total_death_count, population, MAX((total_deaths/population))*100 AS death_rate
From [Portfolio Project]..CovidDeaths
Where continent = 'North America'
Group By location, continent, population
Order By death_rate DESC

--Oceania
Select location, continent, MAX(total_deaths) AS total_death_count, population, MAX((total_deaths/population))*100 AS death_rate
From [Portfolio Project]..CovidDeaths
Where continent = 'Oceania'
Group By location, continent, population
Order By death_rate DESC

--South America
Select location, continent, MAX(total_deaths) AS total_death_count, population, MAX((total_deaths/population))*100 AS death_rate
From [Portfolio Project]..CovidDeaths
Where continent = 'South America'
Group By location, continent, population
Order By death_rate DESC

-- Showing Continents with the Highest Death Count
Select continent, MAX(cast(total_deaths as int)) AS total_death_count
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group By continent
Order By total_death_count DESC


-- GLOBAL NUMBERS

-- Global Death Percentage
Select SUM(new_cases) AS total_cases_global, SUM(cast(new_deaths as int)) AS total_deaths_global, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
From [Portfolio Project]..CovidDeaths
Where continent is not null

-- Daily Global Death Percentage
Select date, SUM(new_cases) AS total_cases_global, SUM(cast(new_deaths as int)) AS total_deaths_global, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group By date
Order By date

-- Daily Global Death Percentage Sorted Highest to Lowest
Select date, SUM(new_cases) AS total_cases_global, SUM(cast(new_deaths as int)) AS total_deaths_global, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group By date
Order By death_percentage DESC

-- COVID VACCINATIONS DATA

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) AS rolling_vaccination_count,
(rolling_vaccination_count/dea.population)*100 
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
AND vac.new_vaccinations is not null
Order by 2,3

--USE CTE
With pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vaccination_count)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) AS rolling_vaccination_count
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
AND vac.new_vaccinations is not null
)
Select *, (rolling_vaccination_count/population)*100 AS rolling_vaccination_percentage
From pop_vs_vac

--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccination_count numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) AS rolling_vaccination_count
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
AND vac.new_vaccinations is not null

Select *, (rolling_vaccination_count/population)*100 AS rolling_vaccination_percentage
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPolulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) AS rolling_vaccination_count
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
AND vac.new_vaccinations is not null