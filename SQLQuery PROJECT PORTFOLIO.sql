--Testing if Tables have loaded correctly
Select *
from PortfolioProject..[COVID Deaths]
order by 3,4

----Select *
----from PortfolioProject..[COVID Vaccinations]
----order by 3,4

--Selecting Data that I'll be using

Select Location, date, total_cases, new_cases, total_deaths,population
From PortfolioProject..[COVID Deaths]
order by 1,2

--Looking at the total cases vs Total Deaths. This indicates the death percentage with relation to the total cases recorded in Kenya.
--This shows the likelihood of dying if you contract covid in Kenya

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..[COVID Deaths]
where location= 'kenya'
order by 1,2

--Looking at the total cases vs Total Deaths. This indicates the death percentage with relation to the total cases recorded.
--This shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..[COVID Deaths]
order by 1,2

--Looking at the total cases vs the population in Kenya
--Shows what percentage of population have covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentageHavingCovid
From PortfolioProject..[COVID Deaths]
where location= 'Kenya'
order by 1,2

--Looking at countries with highest infection rate compared to the population
--The GROUP BY statement groups rows that have the same values into summary rows.
--The GROUP BY statement is often used with aggregate functions ( COUNT() , MAX() , MIN() , SUM() , AVG() ) to group the result-set by one or more columns.
Select Location, population, max(total_cases) as HighestInfectionCount,max(total_cases/population)*100 as PopulationPercentageHavingCovid
From PortfolioProject..[COVID Deaths]
group by Location, population
order by PopulationPercentageHavingCovid desc

--Showing countries with highest death count per population
--I have added the 'where continent is not null" to show data of countries only, and not groupings of countries found in specific continnents such as Africa,World etc.
--The SQL CAST function is mainly used to convert the expression from one data type to another data type. In our case, the data type was varchar, and I have converted it into Int.
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[COVID Deaths]
where continent is not null
group by Location
order by TotalDeathCount desc



--Looking at total death count in every country location
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[COVID Deaths]
where continent is not null
group by location
order by TotalDeathCount desc

--Showing total death count in kenya
--The SQL CAST function is mainly used to convert the expression from one data type to another data type. In our case, the data type was varchar, and I have converted it into Int.
--The GROUP BY statement groups rows that have the same values into summary rows.
--The GROUP BY statement is often used with aggregate functions ( COUNT() , MAX() , MIN() , SUM() , AVG() ) to group the result-set by one or more columns.
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[COVID Deaths]
where location= 'kenya'
group by location

--LET'S BREAK THINGS DOWN BY CONTINENT
--lOOKING AT TOTAL DEATH COUNT IN EACH CONTINENT
--Shows contintents with highest death counts
--Now, let's break things down by continent, instead of countries as above. 
--The GROUP BY statement groups rows that have the same values into summary rows.
--The GROUP BY statement is often used with aggregate functions ( COUNT() , MAX() , MIN() , SUM() , AVG() ) to group the result-set by one or more columns.
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[COVID Deaths]
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS
--This shows the GLOBAL total cases, GLOBAL total deaths, and GLOBAL Daily Death percentage recorded each day. 
Select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..[COVID Deaths]
where continent is not null
group by date
order by 1,2

--Showing only the GLOBAL Total Cases, GLOBAL Total Deaths, and Global Death percentage recorded so far( as per the data set)
Select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..[COVID Deaths]
where continent is not null
order by 1,2

--Showing total cases and total deaths recorded daily in Kenya.
Select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths-- sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..[COVID Deaths]
where location= 'Kenya' 
group by date
order by 1,2

--JOINING THE TABLES COVID DEATHS AND COVID VACCINATIONS TABLES
Select *
from PortfolioProject..[COVID Deaths] dea
join PortfolioProject..[COVID Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date 

--Looking at total population vs vaccination
--i.e whats the total amount of people in the world that have been vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccinations
from PortfolioProject..[COVID Deaths] dea
join PortfolioProject..[COVID Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--To know the percentage of people who are vaccinated in each country, i'll use a CTE and  TEMP table.(both can work)
--CTE/TEMP table is used because you cant use a column you just created, to use in the next one.


--USING CTE
--1st specifying the columns we're going to input
--Number of columns in CTE should be the same as number of columns in Select section.
With PopVsVac (continent, location, date, population,new_vaccinations, TotalVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccinations
from PortfolioProject..[COVID Deaths] dea
join PortfolioProject..[COVID Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
)
Select *, (TotalVaccinations/population)*100
from PopVsVac 


--ALTERNATIVELY USING A TEMP TABLE INSTEAD OF CTE
--First create a table and define the columns. 
--When you run this query the 2nd time, it will bring an error " There is already an object named '#percentPopulationVaccinated'. 
--To mitigate this, I have used Drop Table if exists


DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccinations
from PortfolioProject..[COVID Deaths] dea
join PortfolioProject..[COVID Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null

Select *, (TotalVaccinations/population)*100
from  #PercentPopulationVaccinated


----creating view to store data for later visualizations

--create view #PercentPopulationVaccinated as
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccinations
--from PortfolioProject..[COVID Deaths] dea
--join PortfolioProject..[COVID Vaccinations] vac
--	on dea.location = vac.location
--	and dea.date = vac.date 
--where dea.continent is not null

--select *
--from #PercentPopulationVaccinated