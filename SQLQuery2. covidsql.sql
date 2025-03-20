select * 
from covid..CovidDeaths$
where continent is not null
order by 3,4;

--select * 
--from covid..CovidVaccination$
--order by 3,4;

--selct data that we are going to use

select Location, date, total_cases, new_cases, total_deaths, population
from covid..CovidDeaths$
where continent is not null
order by 1, 2;

--Looking at total cases vs total deaths
-- shows likelihood of dying if you contact with covid in your country
select Location, date, total_cases, new_cases, total_deaths, (total_deaths / total_cases)*100  as death_percentage
from covid..CovidDeaths$
where location like '%states%' and
continent is not null
order by 1, 2;

--looking at total cases vs population
--shows what percentage of population got covid

select Location, date, total_cases, population, (total_cases/ population )*100  as populationwithcovid
from covid..CovidDeaths$
where continent is not null
--where location like '%states%'
order by 1, 2;

--looking at countries with highest infection rate compared to population

select Location, max(total_cases) as HighestInfectionCount, population, max((total_cases/ population ))*100  as PercentPopulationInfected
from covid..CovidDeaths$
--where location like '%states%'
--where continent is not null
group by location, population
order by PercentPopulationInfected desc;

--showing countries with highest death count per population
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from covid..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc;

--let's bresk things down by continent 

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from covid..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc;

--showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from covid..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc;

--global numbers
--1
SELECT  sum(new_cases) as CovidCases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from covid..CovidDeaths$
--where location like'%states%'
where continent is not null
--and new_cases is not null
--group by date
order by 1,2 ;

--2.
SELECT  location, sum(cast(new_deaths as int)) as total_deathcount
from covid..CovidDeaths$
--where location like'%states%'
where continent is null
and location not in ('World', 'European Union', 'International')
group by location
order by total_deathcount desc;

--3.
select Location, max(total_cases) as HighestInfectionCount, population, max((total_cases/ population ))*100  as PercentPopulationInfected
from covid..CovidDeaths$
--where location like '%states%'
--where continent is not null
group by location, population
order by PercentPopulationInfected desc;


--4.
select Location,date,  max(total_cases) as HighestInfectionCount, population, max((total_cases/ population ))*100  as PercentPopulationInfected
from covid..CovidDeaths$
--where location like '%states%'
--where continent is not null
group by location, population, date
order by PercentPopulationInfected desc;


--looking at total population vs vaccinations
select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from covid..CovidDeaths$ as dea
join covid..CovidVaccination$ as vac
	on  dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by  2, 3;

--use cte

with PopVsVac(continent, location, date, population,new_vaccinations,  RollingPeopleVaccinated)
as
(select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from covid..CovidDeaths$ as dea
join covid..CovidVaccination$ as vac
	on  dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by  2, 3
)
select * , (RollingPeopleVaccinated/population)*100 as PercentageofPeopleVaccinated
from PopVsVac

--Temp Table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric )


insert into #PercentPopulationVaccinated
select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from covid..CovidDeaths$ as dea
join covid..CovidVaccination$ as vac
	on  dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by  2, 3

select * , (RollingPeopleVaccinated/population)*100 as PercentageofPeopleVaccinated
from #PercentPopulationVaccinated

--creating view to store data for later visualization
drop View if exists PercentagePopulationVaccinated
create View
PercentagePopulationVaccinated as
select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from covid..CovidDeaths$ as dea
join covid..CovidVaccination$ as vac
	on  dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by  2, 3

select * 
from PercentagePopulationVaccinated