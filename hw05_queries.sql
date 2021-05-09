-----------------------------------------------------------------------------
-- 1. In an SQL comment below, describe the relationship (one-to-one,
--    many-to-one, or many-to-many) between the pairs of tables listed
--    (note that you may need to look at a third table to determine the
--    relationship).
--
--    Additionally, add the queries you used to arrive at your answers.
--
--    a. countries and country_stats
--    b. languages and countries
--    c. continents and regions
-----------------------------------------------------------------------------
-- a. one to many 

select count(*) from country_stats;
select count(*) from countries;
describe countries;
describe country_stats;

--b. many languages to a country 
select * from country_languages limit 3;
describe country_languages ;

--c. one to many 
select * from regions, continents where continents.continent_id = regions.continent_id;
-----------------------------------------------------------------------------
-- 2. Create a report displaying every name and population of every
--    continent in the database from the year 2018 with millions as units
--
--    For example:
--
-- Asia           4376.9086
-- Africa         1259.7617
-- Europe          717.2167
-- North America   569.6298
-- South America   394.5288
-- Oceania          40.9416
--
--     Write your query below.
-----------------------------------------------------------------------------

select c.name, round(sum(tmp.s)/1000000,4) as population_2018
from (
select c.region_id, sum(cs.population) as s, r.continent_id as ci
from country_stats cs
inner join countries c on c.country_id=cs.country_id
inner join regions r on r.region_id=c.region_id
where cs.year=2018
group by c.region_id ) as tmp 
inner join continents c on c.continent_id=tmp.ci
group by c.continent_id
order by c.name;


-----------------------------------------------------------------------------
-- 3. List the names of all of the countries that do not have a language.
--    Write your answer in an SQL comment below along with the original
--    query that you used to arrive at your answer.
-----------------------------------------------------------------------------

select name 
from countries
where name not in (select distinct name 
from countries 
inner join country_languages cl on cl.country_id=countries.country_id); 
-----------------------------------------------------------------------------
-- 4. Show the country name and total number of languages of the top 10
--    countries with the most languages in descending order (according to the
--    data in this data set). Write your query below.
-----------------------------------------------------------------------------

select cc.name, cnt.c 
from (select country_id,count(language_id) as c from country_languages group by country_id) as cnt 
inner join countries cc 
on cc.country_id=cnt.country_id 
order by c desc limit 10;


-----------------------------------------------------------------------------
-- 5. Repeat your previous query, but with a comma separated list of 
--    languages rather than a count. For example:
--
--     name   | languages
--     -------+---------------------------------
--     Canada |  "Dutch,English,Spanish,French,Portuguese,Italian,German,Polish,Ukrainian,Chinese,Eskimo Languages,Punjabi"
--
--    Hint: use the aggregate function, group_concat to do this
--
--    Write your code below
-----------------------------------------------------------------------------

select cc.name, cnt.languages 
from (
	select country_id,group_concat(l.language order by l.language) as languages, count(country_languages.language_id) as c
from country_languages
inner join languages l on l.language_id=country_languages.language_id 
group by country_id) as cnt 
inner join countries cc 
on cc.country_id=cnt.country_id 
order by cnt.c desc limit 10;


-----------------------------------------------------------------------------
-- 6. What's the average number of languages in every country in a region in
--    the dataset? Show both the region's name and the average. Make sure to
--    include countries that don't have a language in your calculations.
--
--    Hint: using your previous queries and additional subqueries may
--    help
--
--    Write your query below.
-----------------------------------------------------------------------------


select r.name,round(sum(cnt_lang.num_of_lang)/count(cnt_lang.country_id),2) as average_number_of_languages
from (select c.region_id as ri, c.country_id,count(cl.language_id) as num_of_lang
from country_languages cl
inner join countries c on c.country_id=cl.country_id
group by c.country_id ) as cnt_lang
inner join regions r on r.region_id=cnt_lang.ri
group by cnt_lang.ri;


-----------------------------------------------------------------------------
-- 7. Show the country name and its "national day" for the country with
--    the most recent national day and the country with the oldest national
--    day. Do this with a *single query*.
--
--    Hint: both subqueries and union may be helpful here
--
--    The output may look like this:
--
--   name      | national_day
-- ------------+--------
-- East Timor  | 2002-05-20
-- Switzerland | 1291-08-01
--
-----------------------------------------------------------------------------

--BOTH OKAY

select c.name, c.national_day
from (
select name, min(national_day) as o from countries union
select name, max(national_day) as o from countries ) as sp
inner join countries c on c.national_day=sp.o
order by c.national_day desc;



select name, national_day 
from countries 
where national_day = (select max(national_day) as nd from countries) 
UNION 
select name, national_day 
from countries where national_day = (select min(national_day) as ndd from countries)


-----------------------------------------------------------------------------
-- 8. In an SQL comment below, formulate your own question about this data
--    set and write a query to answer it.
-----------------------------------------------------------------------------

--Show country name and its continent and year with the largest gdp in the dataset  





select con.name, c.name, t.gdp,t.year
from (select country_id, gdp,year from country_stats order by gdp desc limit 1)
as t
inner join countries c on c.country_id=t.country_id
inner join regions r on r.region_id=c.region_id
inner join continents con on con.continent_id=r.continent_id;

