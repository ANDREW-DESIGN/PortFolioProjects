select * from coviddeaths;
select * from covidvaccinations;


-- looking at total cases vs total deaths

SELECT location, 
       dates, 
       total_cases, 
       total_deaths, 
       CASE 
           WHEN total_cases > 0 THEN (total_deaths/total_cases)*100
           ELSE 0 
       END AS DEATHPERCENTAGE
FROM CovidDeaths
where location like '%United States%'
ORDER BY location, dates;

--looking at total cases vs population

select location, dates, total_cases, population, (total_cases/population)*100 as PopulationPercentage
from CovidDeaths
where location like '%United States%'
order by 1,2;



--looking at highest infection rate compared to population
select location, population, MAX(total_cases) AS HIGHESTINFECTIONCOUNT,
MAX((total_cases/population))*100 AS PERCENTOFPUPULATIONINFECTED
from CovidDeaths
GROUP BY LOCATION, POPULATION
order by PERCENTOFPUPULATIONINFECTED DESC;




--showing countries with highest death count per population 
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not NULL
GROUP BY LOCATION
HAVING MAX(cast(total_deaths as int)) IS NOT NULL
order by TotalDeathCount DESC;




--lets break things down by continent
--showing continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not NULL
GROUP BY continent
HAVING MAX(cast(total_deaths as int)) IS NOT NULL
order by TotalDeathCount DESC;



--global numbers
SELECT 
    dates, 
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 
    END AS DeathPercentage
FROM 
    CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY dates
ORDER BY 
    dates;


--Now looking at covidvaccinations table

select * from covidvaccinations;


--joining both the tables

select * from CovidDeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.dates = vac.dates;


--looking at total population vs vaccinations

select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.dates) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location =vac.location
and dea.dates = vac.dates
where dea.continent is not null
order by 2,3;


--use cte
with PopvsVac (Continent, location, dates, population, new_Vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.dates) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location =vac.location
and dea.dates = vac.dates
where dea.continent is not null)
--order by 2,3
select Continent, 
    Location, 
    Dates, 
    Population, 
    New_Vaccinations, 
    RollingPeopleVaccinated,(RollingPeopleVaccinated/Population)*100
from PopvsVac;



-- Temp table
drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(continent varchar(255),
location varchar(225),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.dates) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location =vac.location
and dea.dates = vac.dates
where dea.continent is not null;
--order by 2,3

select Continent, 
    Location, 
    Dates, 
    Population, 
    New_Vaccinations, 
    RollingPeopleVaccinated,(RollingPeopleVaccinated/Population)*100
from PercentPopulationVaccinated;



--creating view to store data for later visualizations
create view PercentPopluationVaccinated as
(select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.dates) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location =vac.location
and dea.dates = vac.dates
where dea.continent is not null);


select * from percentpopluationvaccinated;


