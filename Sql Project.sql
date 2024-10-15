-- -- Select all data from covid vaccination table
SELECT *
FROM COVIDDATA..[covid vacinnation$];

-- Select location, date, total cases, new cases, total deaths, and population from covid death rate
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVIDDATA..[covid death rate$]
ORDER BY location, date;

-- Calculate total cases vs total deaths
SELECT location, date, total_cases, total_deaths, 
       (CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)) * 100 AS DeathPercentage 
FROM COVIDDATA..[covid death rate$]
ORDER BY location, date;

-- Check data for Nigeria
SELECT location, date, total_cases, total_deaths, 
       (CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)) * 100 AS DeathPercentage 
FROM COVIDDATA..[covid death rate$]
WHERE location = 'Nigeria'
ORDER BY location;

-- Check data for India
SELECT location, date, total_cases, total_deaths, 
       (CAST(total_deaths AS FLOAT) / NULLIF(total_cases, 0)) * 100 AS DeathPercentage 
FROM COVIDDATA..[covid death rate$]
WHERE location = 'India';

-- Total cases vs population for India
SELECT location, date, total_cases, population, 
       (CAST(total_cases AS FLOAT) / NULLIF(population, 0)) * 100 AS PercentageOfPopulationAffected
FROM COVIDDATA..[covid death rate$]
WHERE location = 'India';

-- Countries with the highest infection rate vs population
SELECT location, population, 
       MAX(total_cases) AS HighestInfectionCount, 
       MAX((CAST(total_cases AS FLOAT) / NULLIF(population, 0))) * 100 AS PercentagePopulationInfected 
FROM COVIDDATA..[covid death rate$]
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC;

-- Country with the highest death per population
SELECT location, 
       MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM COVIDDATA..[covid death rate$]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- To check continent with the highest death count
SELECT SUM(new_cases) AS TotalCases, 
       SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
       (SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0)) * 100 AS DeathPercentage
FROM COVIDDATA..[covid death rate$]
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY TotalCases DESC, TotalDeaths DESC;

-- Joining covid death and vaccination together
-- Looking at total population vs vaccination
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations 
FROM COVIDDATA..[covid death rate$] AS d
JOIN COVIDDATA..[covid vacinnation$] AS v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.continent, d.location;

-- Looking at total population vs vaccination with summation of vaccinations
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
       SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location) AS SummationOfVaccinated 
FROM COVIDDATA..[covid death rate$] AS d
JOIN COVIDDATA..[covid vacinnation$] AS v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.continent, d.location;

-- Use CTE to organize data for vaccination vs population
WITH PopVsVac AS (
  SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
         SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location) AS SummationOfVaccinated 
  FROM COVIDDATA..[covid death rate$] AS d
  JOIN COVIDDATA..[covid vacinnation$] AS v
  ON d.location = v.location AND d.date = v.date
  WHERE d.continent IS NOT NULL
)
SELECT *
FROM PopVsVac
ORDER BY continent, location, date;
