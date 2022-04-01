-- select * from "covidDeaths"
-- order by 3,4;

-- select location,date,total_cases,new_cases,total_deaths,population 
-- From "covidDeaths"
-- order by 1,2;

-- Total Cases vs Total Deaths by date in canada.

SELECT LOCATION,date,total_cases,total_deaths,((total_deaths/total_cases)*100) AS "DeathRate"
FROM "covidDeaths"
WHERE  "location"='Canada'
ORDER BY 1,2;

-- Total Cases vs Population in Canada
-- We can analyse Case (population)Density over time.  

SELECT LOCATION,date,total_cases,population,((total_cases/population)*100) AS "CaseDensity-Rate"
FROM "covidDeaths"
WHERE  "location"='Canada'
ORDER BY 1,2;


-- Among the countries in the dataset -> finding country/ies with highest infection rate...

SELECT LOCATION,population,max(total_cases) AS "HighestNumberOfInfection", max(((total_cases/population)*100)) AS "CaseDensity-Rate"
FROM "covidDeaths"
GROUP BY 1,2
ORDER BY "CaseDensity-Rate" DESC;

-- Among the countries in the dataset - ordering them from higest to lowest death counts/ total_death 
SELECT LOCATION,max(CAST(total_deaths AS INT)) AS HighestNumberOfDeath -- total_deaths is casted to integer because it is by default a different data type which will result in false number. 
FROM "covidDeaths"
WHERE continent IS NOT NULL 
GROUP BY LOCATION 
ORDER BY HighestNumberOfDeath DESC;

--Similar to above, but grouping by continent 

SELECT LOCATION, max(CAST(total_deaths AS INT)) AS HighestNumberOfDeath
FROM "covidDeaths"
WHERE continent IS NULL 
GROUP BY LOCATION 
ORDER BY HighestNumberOfDeath DESC;
 

-- Analyzing some statistics of the entire dataset 

SELECT date,sum(CAST(new_cases AS INT)) AS WorldWideCaseNumber ,sum(CAST(new_deaths AS INT)) AS WorldWideDeathsNumber
FROM "covidDeaths"
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY WorldWideDeathsNumber DESC;

SELECT sum(CAST(new_cases AS INT)) AS WorldWideCaseNumber ,sum(CAST(new_deaths AS INT)) AS WorldWideDeathsNumber, ((sum(CAST(new_deaths AS FLOAT)))/sum(CAST(new_cases AS FLOAT)))*100 AS DeathPercentage
FROM "covidDeaths"
WHERE continent IS NOT NULL
ORDER BY WorldWideDeathsNumber DESC;

-- Now analyzing a different dataSET -> "CovidVaccinations"

-- Looking at available columns 

SELECT column_name
FROM information_schema.columns
WHERE table_name='CovidVaccinations'
ORDER BY ordinal_position;


-- Joining two tables 

SELECT * FROM "covidDeaths" deaths 
JOIN "CovidVaccinations" vacc 
ON deaths.location = vacc.location 
AND deaths.date = vacc.date;

-- Comparing population vs new_vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations 
FROM "covidDeaths" dea
JOIN "CovidVaccinations" vacc 
ON dea.location = vacc.location 
AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL AND vacc.new_vaccinations IS NOT NULL
ORDER BY 1,2,3;

SELECT TYPE(2020-10-29);

-- Total population by date 

SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, sum(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS VaccinatedTillDate
FROM "covidDeaths" dea
JOIN "CovidVaccinations" vacc 
ON dea.location = vacc.location 
AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL AND vacc.new_vaccinations IS NOT NULL
ORDER BY dea.continent, dea.location,dea.date;

-- Using TempTable to insert and access data in preferred way..... 

DROP TABLE IF EXISTS VaccinationPercentage;
CREATE TEMPORARY TABLE VaccinationPercentage
(
    continent VARCHAR(255),
    LOCATION VARCHAR(255),
    date DATE, 
    population NUMERIC,
    new_vaccinations NUMERIC, 
    VaccinatedTillDate NUMERIC
 );
 
INSERT INTO VaccinationPercentage(continent,LOCATION,date,population,new_vaccinations,VaccinatedTillDate)
SELECT dea.continent, dea.location, CAST(dea.date AS DATE), dea.population, vacc.new_vaccinations, sum(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS VaccinatedTillDate
FROM "covidDeaths" dea
JOIN "CovidVaccinations" vacc 
ON dea.location = vacc.location 
AND dea.date = vacc.date;

SELECT *,(CAST(VaccinatedTillDate AS FLOAT)/CAST(population AS FLOAT))*100 AS VaccinationTillDateinPercentage FROM VaccinationPercentage;
