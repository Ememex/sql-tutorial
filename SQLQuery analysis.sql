--check data
select * from portfolio..covid_deaths
order by location desc;


--select data we are using;

select location, date,total_cases,new_cases,total_deaths,population
from portfolio..covid_deaths
order by 1,2

--looking at total cases

select location, date, total_cases, total_deaths,
((convert(float,total_deaths))/nullif((convert(float, total_cases)),0) *100) as deathpercentage
from portfolio..covid_deaths
where location ='Nigeria'
order by 1,2

--cases vs  population
--shows percentage of population that have covid
select location, convert(datetime,date) as date,convert(bigint,population) as population,CONVERT(bigint, total_cases)as totalcases,
((convert(float,total_cases ))/nullif((convert(float, population)),0) *100) as percentage_of_population_with_covid
from portfolio..covid_deaths
where location ='Nigeria'
group by date,location,population,total_cases
order by 1,2

--COUNTRY WITH HIGHEST INFECTION RATE BY POPULTION
select location, convert(bigint,population) as population,MAX(CONVERT(bigint, total_cases))as HIGHEST_INFECTION_COUNT,
MAX(((convert(float,total_cases ))/nullif((convert(float, population)),0) *100)) as percentage_of_population_with_covid
from portfolio..covid_deaths
group by location,population
order by percentage_of_population_with_covid DESC;


-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
select location, MAX(convert(bigint, total_deaths)) as total_death_counts
from portfolio..covid_deaths
where continent != ' '
group by location
order by total_death_counts DESC;

-- show data by continent
--showing continent with highest death count
select location, MAX(convert(bigint, total_deaths)) as total_death_counts
from portfolio..covid_deaths
where continent = ' ' and location not in ('World','high income','Upper middle income','lower middle income', 'European union','low income','international')
group by location
order by total_death_counts DESC;

--global numbers
select CAST(DATE AS date) AS DATE_, sum(cast(new_cases as float)) as totalcases, sum(cast(new_deaths as int))as 
totaldeath, ( sum(cast(new_deaths as int)) /(sum(cast(new_cases as float)))) *100 as deathpercent
from portfolio..covid_deaths
where  continent != ' '  and new_deaths !=0
group by date
order by 1,2

-- looking at total populatuon by vaccination
SELECT dea.continent, dea.location, cast(dea.date as date) as date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.Date ) count_of_people_vacinated
FROM portfolio..covid_deaths dea
join portfolio..covid_vacine vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ' ' and vac.new_vaccinations is not null 
--group by dea.date,dea.continent, dea.location,dea.population,vac.new_vaccinations

order by 1,2,3;

--cte 
with popvsvac (continent, location , date , pop , new_vaccinations, count_of_people)
AS
(
SELECT dea.continent, dea.location, cast(dea.date as date)  as date, cast(dea.population as float)as pop, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.Date ) as  count_of_people
FROM portfolio..covid_deaths dea
join portfolio..covid_vacine vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ' ' 
)
select *, (count_of_people / Pop) *100
FROM popvsvac

--creating view to store data  for visualization
create view percentvalue as
SELECT dea.continent, dea.location, cast(dea.date as date)  as date, cast(dea.population as float)as pop, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.Date ) as  count_of_people
FROM portfolio..covid_deaths dea
join portfolio..covid_vacine vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ' ' 
