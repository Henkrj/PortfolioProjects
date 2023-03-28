select * 
from dbo.CovidDeaths
where continent is not null
order by 3,4;

--select * 
--from dbo.CovidVaccinations
--order by 3,4


-- Select Data that we are going to be using

select location,date,total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2;


-- Looking at Total Cases vs Total Deaths

select location,date,total_cases,total_deaths
from CovidDeaths
order by 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your countr
select location,date,total_cases,total_deaths, total_deaths/nullif(total_cases,0)*100 as DeathPercentage
from CovidDeaths
where location like '%Brazil%'
order by 1,2;


-- looking at total cases vs population
-- Show what percentage of population got covid
select location,date,population,total_cases, total_cases/population*100 as PercentOfPopulationInfected
from CovidDeaths
where 
location like '%Brazil%'
and total_cases <> 0
order by 1,2;


--   Looking at Countries with Highest Infecion Rate compared to Population
select location,population,max(total_cases) HighestInfectionCount, MAX(total_cases/population*100) as PercentOfPopulationInfected
from CovidDeaths
--where location like '%China%'
--and total_cases <> 0
group by location,population
order by PercentOfPopulationInfected desc;

-- Showing Countries With highest death count per population

select location, MAX(total_deaths) as TotalDeathCounts
from CovidDeaths
--where location like '%China%'
--and total_cases <> 0
where continent is not null
group by location
order by TotalDeathCounts desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continent with the highest death count

select continent, MAX(total_deaths) as TotalDeathCounts
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCounts desc;


-- Global numbers

select --Date, 
SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths,
SUM(new_deaths)/nullif(SUM(new_cases),0)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by Date
order by 1,2;



-- Looking at Total Population vs Vaccination 


--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, vac.total_vaccinations, (vac.total_vaccinations/dea.population) as PercentageVaccination
--from CovidDeaths dea
--join CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--	where dea.continent is not null
--	and dea.location = 'Canada'
----	and vac.new_vaccinations is not null
--	order by 2,3


select
dea.continent,
dea.location,
dea.date, 
dea.population,
vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeoppleVaccinated
--(RollingPeoppleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


	-- WITH CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeoppleVaccinated)
as
(
select
dea.continent,
dea.location,
dea.date, 
dea.population,
vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeoppleVaccinated
--(RollingPeoppleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
Select *, (RollingPeoppleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeoppleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select
dea.continent,
dea.location,
dea.date, 
dea.population,
vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeoppleVaccinated
--(RollingPeoppleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--	where dea.continent is not null
	--order by 2,3

	Select *, (RollingPeoppleVaccinated/Population)*100
from #PercentPopulationVaccinated 


-- Creating VIEW to store data for later visualizations

Create View PercentPopulationVaccinated as
select
dea.continent,
dea.location,
dea.date, 
dea.population,
vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeoppleVaccinated
--(RollingPeoppleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3



select *
from PercentPopulationVaccinated