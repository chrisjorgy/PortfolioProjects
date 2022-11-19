select * 
from PortfolioProject..covid_deaths
where continent is not null
order by 3,4;

select * 
from PortfolioProject..covid_deaths
where continent is not null
order by 3,4;

--select data we are going to be using

Select location,date,total_cases,new_cases,total_deaths
FROM PortfolioProject..covid_deaths
where continent is not null
order by 1,2;

--Looking at toal cases vs. total deaths
--Shows death percentage as time goes on

Select location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..covid_deaths
where location like '%states%'
order by 1,2;


--Total cases vs population, percentage of people who caught covid

Select location, date, population, total_cases, (total_cases/population)*100 AS DeathPercentage
From PortfolioProject..covid_deaths
where location like '%states%'
order by 1,2;


--Look at countries with highest infection rate compared to population


Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..covid_deaths
--where location like '%states%'
where continent is not null
Group by Location, population
order by PercentPopulationInfected desc


-- shows countries with highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc


--Broken down by continent

--Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
--From PortfolioProject..covid_deaths
----where location like '%states%'
--where continent is not null
--Group by continent
--order by TotalDeathCount desc


--shows continents with highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers - Cast new deaths as int due to being nvarchar and not a float.

Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..covid_deaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


Select date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..covid_deaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2


--Look at total population vs total vaccinations
--SUM(cast(... as int)) is the same as SUM(convert(int,...)) -- convert to bigint due to large number

Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, 
SUM(convert(bigint,dea.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population) *100
From PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE 

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, 
SUM(convert(bigint,dea.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)* 100  
from PopvsVac


-- Temp Table
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, 
SUM(convert(bigint,dea.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)* 100  
from #PercentPopulationVaccinated

--Creating view to store data for data Viz
USE PortfolioProject
GO
Create view PercentOfPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, 
SUM(convert(bigint,dea.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
From PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
 --order by 2,3

 Select *
 From PercentOfPopulationVaccinated

