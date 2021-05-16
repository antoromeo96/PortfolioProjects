select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

select *
from PortfolioProject..CovidVaccinations
order by 3,4;

--Select data that we are going to be using
select Location ,date, total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--Show likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where Location like '%states%'
order by 1,2

--Looking at Total cases vs Populations
--Shows what percentage of population got covid
select Location, date, Population, total_cases, (cast(total_cases as float)/cast(population as float))*100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
where Location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population
Select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases)/MAX(population)*100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
GROUP BY Location, Population
order by PercentPopulationInfected desc

--Showing countries with highest death count for population
Select Location, MAX(cast(total_deaths as int)) AS TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is not null
GROUP BY Location
order by TotalDeathsCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing the continents with the highest deaths count per population
Select Continent, MAX(cast(total_deaths as int)) AS TotalDeathsCount
from PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY Continent
order by TotalDeathsCount desc

--GLOBAL NUMBERS
Select SUM(new_cases) total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where Continent is not null
--GROUP by date
order by 1,2;

--Looking at Total Populations vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea, PortfolioProject..CovidVaccinations vac
where dea.location=vac.location
	  and dea.date=vac.date
	  and dea.continent is not null
order by 2,3;

--USE CTE

With PopvsVac(Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea, PortfolioProject..CovidVaccinations vac
where dea.location=vac.location
	  and dea.date=vac.date
	  and dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac;


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea, PortfolioProject..CovidVaccinations vac
where dea.location=vac.location
	  and dea.date=vac.date
	  --and dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated;


--Creating view to store data for later visualizations 
GO
Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea, PortfolioProject..CovidVaccinations vac
where dea.location=vac.location
	  and dea.date=vac.date
	  and dea.continent is not null;
--order by 2,3;

select *
from PercentPopulationVaccinated;
