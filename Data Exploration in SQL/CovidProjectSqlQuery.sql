SELECT *
FROM CovidProject..CovidDeaths
where continent is not null
ORDER BY 3,4

SELECT *
FROM CovidProject..CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
ORDER BY 1,2

--total cases vs. total deaths in the U.S.
SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as death_to_cases_percent
FROM CovidProject..CovidDeaths
Where location like 'United States'
ORDER BY 1,2

--total cases vs population in the U.S.
Select location, date, total_cases, population, round((total_cases/population)*100, 2) as cases_to_population_percent
From CovidProject..CovidDeaths
Where location like 'United States'
Order By 1,2

--Country by infection rate
Select location, max(total_cases) as highest_total_cases, population, round((max(total_cases/population))*100, 3) as cases_to_population_rate
From CovidProject..CovidDeaths
Group By location, population
Order By cases_to_population_rate desc

--Country by death count
Select location, population, max(cast(total_deaths as int)) as total_death_count, 
round((max(cast(total_deaths as int))/population)*100, 3) as death_to_population_rate
From CovidProject..CovidDeaths
where continent is not null
Group By location, population
Order By total_death_count desc

--Contient deaths
Select location, max(cast(total_deaths as int)) as total_death_count
From CovidProject..CovidDeaths
where continent is null
Group By location
Order By total_death_count desc

--Continets with death count per population
Select location, population, max(cast(total_deaths as int)) as total_death_count
From CovidProject..CovidDeaths
where continent is null
Group By location, population
Order By total_death_count desc


--Global Metrics

select date, sum(new_cases) as total_world_cases, sum(cast(new_deaths as int)) as total_world_deaths, 
round((sum(cast(new_deaths as int))/sum(new_cases))*100, 3) as deaths_to_cases_percent
from CovidProject..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_world_cases, sum(cast(new_deaths as int)) as total_world_deaths, 
round((sum(cast(new_deaths as int))/sum(new_cases))*100, 3) as deaths_to_cases_percent
from CovidProject..CovidDeaths
where continent is not null
order by 1,2



--World Population vs. Vaccinations
select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations,
sum(cast(vacs.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_population_vaccinated
from CovidProject..CovidDeaths deaths
join CovidProject..CovidVaccinations vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
where deaths.continent is not null
order by 2,3


--Useing CTE

with PopulationVsVaccinations (Continent, Location, Date, Population, NewVaccinations, RollingVaccinations)
as
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations,
sum(cast(vacs.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_population_vaccinated
from CovidProject..CovidDeaths deaths
join CovidProject..CovidVaccinations vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
where deaths.continent is not null
)
select *, (RollingVaccinations/Population)*100 as GlobalVacsPercenthage
from PopulationVsVaccinations
order by 2,3


--Temp Table

drop table if exists #PopulationPercentVaccinations
create table #PopulationPercentVaccinations
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, NewVaccinations numeric, RollingVaccinations numeric
)

insert into #PopulationPercentVaccinations
select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations,
sum(cast(vacs.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_population_vaccinated
from CovidProject..CovidDeaths deaths
join CovidProject..CovidVaccinations vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
where deaths.continent is not null

select *, (RollingVaccinations/Population)*100 as GlobalVacsPercenthage
from #PopulationPercentVaccinations
order by 2,3




-- Creating view to store date for data visulization

Create View PercentPopulationVaccinated as
select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations,
sum(cast(vacs.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_population_vaccinated
from CovidProject..CovidDeaths deaths
join CovidProject..CovidVaccinations vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
where deaths.continent is not null




