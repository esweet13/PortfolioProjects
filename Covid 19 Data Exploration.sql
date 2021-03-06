/* Covid 19 Data Exploration

Skills Used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject.coviddeath1
Where continent != ''
ORDER BY 3, 4;

 /* Select Data that we are going to be starting with */

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.coviddeath1
Order By 1, 2;

/* Looking at Total Cases vs Total Deaths 

Shows likelihood of dying if you contract covid in your country  (using united states in example) */

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From PortfolioProject.coviddeath1
Where location like 'United States'
Order By 1, 2;

/* Total Cases vs Population 
Shows what percentage of population infected with Covid */

Select location, date, total_cases, population, (total_cases/population)*100 AS percent_population_infected
From PortfolioProject.coviddeath1
Where location like 'United States'
Order By 1, 2;

/* Countries with Highest Infection Rate compared to Population */

Select location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
From PortfolioProject.coviddeath1
Group By location, population
Order By percent_population_infected desc;

/* Showing Countries with Highest Death Count per Population */

Select location, MAX(cast(total_deaths as unsigned)) as total_death_count
From PortfolioProject.coviddeath1
Where continent != ''
Group By location
Order By total_death_count desc;

/* BREAKING THINGS DOWN BY CONTINENT */


/* Showing the continents with the highest death count per population */


Select continent, MAX(cast(total_deaths as unsigned)) as total_death_count
From PortfolioProject.coviddeath1
Where continent != ''
Group By continent
Order By total_death_count desc;


/* Global Numbers */

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as unsigned)) as total_deaths, SUM(new_deaths)/SUM(cast(new_cases as unsigned))*100  AS death_percentage
From PortfolioProject.coviddeath1
/* Where location like 'United States' */
Where continent != ''
Order By 1, 2;



/* Total Population vs Vaccinations 
Shows Percentage of Population that has received at least one Covid Vaccine */


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as unsigned)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as rolling_people_vac 
From PortfolioProject.coviddeath1 dea
JOIN PortfolioProject.covidvaccinations1 vac
	ON dea.location = vac.location
    and dea.date = vac.date
Where dea.continent != ''
Order BY 2,3;

/* Use CTE to perform Calculation on Partition By in previous query */

WITH popvsvac (continent, location, date, population,new_vaccinations, rolling_people_vac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as unsigned)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as rolling_people_vac 
From PortfolioProject.coviddeath1 dea
JOIN PortfolioProject.covidvaccinations1 vac
	ON dea.location = vac.location
    and dea.date = vac.date
Where dea.continent != ''
)
SELECT *, (rolling_people_vac/population)*100 as rolling_percentage_vac
FROM popvsvac;


/* Creating View to Store data for later visualizations */

Create View percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as unsigned)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as rolling_people_vac 
From PortfolioProject.coviddeath1 dea
JOIN PortfolioProject.covidvaccinations1 vac
	ON dea.location = vac.location
    and dea.date = vac.date
Where dea.continent != ''

SELECT *
From percentpopulationvaccinated;
