use Protfoliodb;
select *
from Protfoliodb..coviddeaths
order by population desc;

select *
from Protfoliodb..covidvacs;
-- Total Deaths till 2024 in India Due to Covid
select location,SUM(cast(total_deaths as bigint)) AS Total_deaths
from coviddeaths
where location = 'India'
group by location;

-- Total Cases, Total Deaths & Death Percentage against cases in India yearly
select  year(date) as Year,
		location,
		sum(population) as Total_Population,
		sum(cast(total_cases as bigint)) As Total_Cases, 
		sum(cast(total_deaths as bigint)) as Total_Deaths, 
		cast(sum(cast(total_deaths as bigint))*100.00/sum(cast(total_cases as bigint)) AS DECIMAL(10,2))AS DeathPercentage
from coviddeaths
where location = 'India' 
group by year(date), location
order by year(date) desc;

-- Total % Loss of Population in India
select	location,
		CAST(SUM(CAST(total_deaths as bigint))*100.00/SUM(CAST(population as bigint)) AS decimal (10,4)) AS PCT_Loss
from coviddeaths
where location = 'India'
group by location;

-- Infection rate against Population over the Year in India
select	location,
		year(date) as Year, 
		population, 
		sum(cast(total_cases as bigint)) as Total_Cases,
		CAST(sum(cast(total_cases as bigint))*100.00/SUM(population) as decimal (10,2)) as Infection_Rate
from coviddeaths
where location = 'India'
group by location, population, year(date);

-- Total Percentage Infected in India
select  location,
		CAST(sum(cast(total_cases as bigint))*100.00/SUM(population) as decimal (10,2)) as PCT_Infected
from coviddeaths
where location = 'India'
group by location

-- Percentage Loss of Life in India by World
select	'India' as location,
		(select SUM(total_deaths) from coviddeaths where location = 'India') as Total_India_Deaths,
		(select SUM(total_deaths) from coviddeaths where location = 'World') as Total_world_Deaths,
		cast((select SUM(population) from coviddeaths where location = 'India')*100.00/
		(select SUM(population) from coviddeaths where location = 'world') as decimal (10,2)) as Percentage_Deaths_In_India;

-- Show what % of population got COVID

select	location, 
		population, 
		total_deaths,
		CAST((select SUM(CAST(total_deaths as bigint))from coviddeaths)*100.00/(select sum(CAST(population as bigint)) from coviddeaths) as decimal(10,2)) As Death_PCT
from coviddeaths
order by total_deaths;

-- Looking at the Highest Infection Rate compared to population
select location, population, Max(total_cases) as Highest_Infection_Count, Max((total_cases*100.0/population)) as PCT_POP_INFC
from coviddeaths
Group by location,population
order by PCT_POP_INFC DESC;

-- Showing the Top 10 Highest Death Count Per Population
select top 10 location, Max(total_deaths) as Total_Death_Count
from coviddeaths
where continent is not null
Group by location
Order by Total_Death_Count desc;

-- Total Death in Each Continent
select location, Max(total_deaths) as Total_Death_Count
from coviddeaths
where continent is null AND location != 'World'
group by location
order by Total_Death_Count Desc;

BEGIN TRANSACTION D;

delete FROM coviddeaths
where location IN( 'High income',
					'Upper middle income',
					'Lower middle income',
					'Low income');

ROLLBACK TRANSACTION D;


-- Looking at Total Population Vs vaccination
SELECT  dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(new_vaccinations) over (Partition by dea.location order by dea.location, dea.Date) as RPV
FROM Protfoliodb..coviddeaths dea
join Protfoliodb..covidvacs vac
on dea.location=vac.location and 
	dea.date= vac.date
where dea.continent is not null
order by vac.new_vaccinations desc;

-- USE CTE
with popvsvac (Continent, Location, Date, Population, New_Vaccination, RPV)
as
(
SELECT  dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(new_vaccinations) over (Partition by dea.location order by dea.location, dea.Date) as RPV
FROM Protfoliodb..coviddeaths dea
join Protfoliodb..covidvacs vac
on dea.location=vac.location and 
	dea.date= vac.date
where dea.continent is not null
)

select * , (RPV*100.0/Population)
from popvsvac;

-- Temp Table 
Drop TABLE IF Exists PCTPOPVAC
create table PCTPOPVAC
(
Continent nvarchar(225), 
Location nvarchar(225), 
Date datetime, 
Population bigint, 
New_Vaccination numeric, 
RPV numeric
)

insert into PCTPOPVAC
SELECT  dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(new_vaccinations) over (Partition by dea.location order by dea.location, dea.Date) as RPV
FROM Protfoliodb..coviddeaths dea
join Protfoliodb..covidvacs vac
on dea.location=vac.location and 
	dea.date= vac.date
-- where dea.continent is not null

select * , (RPV*100.0/Population)
from PCTPOPVAC;

-- creating view 

create view PCTPOPVAC1 as 
SELECT  dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(new_vaccinations) over (Partition by dea.location order by dea.location, dea.Date) as RPV
FROM Protfoliodb..coviddeaths dea
join Protfoliodb..covidvacs vac
on dea.location=vac.location and 
	dea.date= vac.date
where dea.continent is not null

select * from PCTPOPVAC1;