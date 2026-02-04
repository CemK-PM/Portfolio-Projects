SELECT * FROM [Portfolio Project]..CovidDeaths
where continent is not null
order by 3, 4

--SELECT * FROM [Portfolio Project]..CovidVaccs
--order by 3, 4

-- select Data that we are going to be using 


SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM [Portfolio Project]..CovidDeaths
where continent is not null
order by 1, 2 

-- looking at total cases vs total deaths
-- shows likelihood of dying i you contract covid in your country
SELECT location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as DeathPercantage
FROM [Portfolio Project]..CovidDeaths
where location like '%states%' and continent is not null
order by 1, 2 

-- Loking at total cases vs population
-- shows what percentage of population got covid

SELECT location, date, population, total_cases,
(total_cases/population)*100 as PercantPopulationInfected
FROM [Portfolio Project]..CovidDeaths
where continent is not null
--where location like '%states%' 
order by 1, 2 

-- looking at countries with highest infection rate compared to population
SELECT location, population, max(total_cases) as highestinfectioncount,
max((total_cases/population))*100 as PercantPopulationInfected
FROM [Portfolio Project]..CovidDeaths
where continent is not null
group by location, population
--where location like '%states%' 
order by PercantPopulationInfected desc

-- showing  countries with highest death count per population
SELECT location, max(cast(total_deaths as int)) as totaldeathcount
FROM [Portfolio Project]..CovidDeaths
where continent is not null
group by location
--where location like '%states%' 
order by totaldeathcount desc

-- breaking things down by continent 
SELECT continent, max(cast(total_deaths as int)) as totaldeathcount
FROM [Portfolio Project]..CovidDeaths
where continent is not null
group by continent 
--where location like '%states%' 
order by totaldeathcount desc



-- global numbers
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercantage
FROM [Portfolio Project]..CovidDeaths
--where location like '%states%' 
where continent is not null
--group by date
order by 1, 2 


--looking at total population vs vaccinations

-- use cte
with PopvsVac (Continent, location, date, population, new_vaccinations, 
RollingPeopleVaccinated) as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,   
sum(cast(vac.new_vaccinations as int)) over (partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM [Portfolio Project]..CovidDeaths dea 
join [Portfolio Project]..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2 ,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

 
-- Temp table


DROP TABLE IF EXISTS #PercentPopulationVaccinated 

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,    
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea  
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 2 ,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,    
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea  
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2 ,3

select * from PercentPopulationVaccinated