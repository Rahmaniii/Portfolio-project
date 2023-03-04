select * 
from CovidVaccinations

select * from CovidDeaths
where continent is not null

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null

-- Total Cases vs Total Death

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rates
from CovidDeaths
where continent is not null
order by 1

-- Total Cases vs Population

select location, date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected
from CovidDeaths
where location like '%states%'
order by 1,2

--countries with highest infection per population

select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population)*100) as percentpopulationinfected
from CovidDeaths
where continent is not null
group by location, population
order by 4 desc

--countries with highest death per population

select location, max(cast(total_deaths as int)) as highestdeathcount
from CovidDeaths
where continent is not null
group by location
order by 2 desc

--continent with highest death count

select location, max(cast(total_deaths as int)) as highestdeathcount
from CovidDeaths
where continent is null
group by location
order by 2 desc

--WORLD COUNT
select sum(new_cases), sum(cast(new_deaths as int)), (sum(cast(new_deaths as int)))/(sum(new_cases))*100 as death_rates
from CovidDeaths
where continent is not null
--group by date
order by 1

-- Total population vs vaccination

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast (cv.new_vaccinations as int)) over (Partition by cd.location order by cd.location, cd.date)
from CovidDeaths as cd
Join CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2, 3

--Percentage vaccinated by Location 

with Vaccinated (Continent, Location, Date, Population, New_Vaccinations, Total_Vaccinated)
AS
(select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast (cv.new_vaccinations as int)) over (Partition by cd.location order by cd.location, cd.date)
from CovidDeaths as cd
Join CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null)

select Location, max(Total_Vaccinated/Population)*100
from Vaccinated
group by Location

-- Percent Popolation Vaccinated

Drop table if exists #Vaccinated
create table #Vaccinated 
(Continent varchar(255), 
Location varchar(255),
Date datetime, 
Population numeric,
New_Vaccinations bigint,
Total_Vaccinated numeric)

insert into #Vaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast (cv.new_vaccinations as int)) over (Partition by cd.location order by cd.location, cd.date)
from CovidDeaths as cd
Join CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null

select *, (Total_Vaccinated/Population)*100
from #Vaccinated

--for visualization
--Death Rate

Create view DeathRate
as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rates
from CovidDeaths
where continent is not null

-- Infection rat

Create view InfectionRate 
as
select location, date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected
from CovidDeaths
where continent is not null


Create view Vaccinated
as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast (cv.new_vaccinations as int)) over (Partition by cd.location order by cd.location, cd.date) as Vaccinated
from CovidDeaths as cd
Join CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
