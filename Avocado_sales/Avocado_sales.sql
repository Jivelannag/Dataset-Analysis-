SELECT *
FROM avocado_updated_2020;

UPDATE avocado_updated_2020
SET geography = trim(geography);


-- CHECK THE DIFFERENCE BETWEEN FIRST AND SECOND DATE.
-- The DIFFERENCE 7 days

SELECT CAST(STR_TO_DATE(DATE,'%Y-%m-%d') AS DATE) as new_date,
       ROUND(SUM(total_bags),0) as total_per_day
FROM avocado_updated_2020
WHERE CAST(STR_TO_DATE(DATE,'%Y-%m-%d') AS DATE) BETWEEN '2016-01-03' AND '2016-12-01'
GROUP BY new_date;

-- Rolling_total VS Running_total

SELECT new_date,total_bags,type,
       ROUND(SUM(total_bags) over(order by new_date),1) as running_total,
       ROUND(sum(total_bags) over(order by new_date rows between 3 preceding and current row ),1) as rolling_total
    FROM(
SELECT CAST(STR_TO_DATE(DATE,'%Y-%m-%d') AS DATE) as new_date, total_bags,type
FROM avocado_updated_2020) AS date_query
where type = 'Conventional';


-- Moving average

SELECT new_date,total_bags,geography,
       ROUND(AVG(total_bags) over (PARTITION BY geography),1) as avg_by_geograhy,
       ROUND(AVG(total_bags) over (PARTITION BY geography order by new_date),1) as moving_avg
    FROM(
SELECT CAST(STR_TO_DATE(DATE,'%Y-%m-%d') AS DATE) as new_date, total_bags,geography
FROM avocado_updated_2020) AS date_query;


-- Comparing sales of avocado by each month during 3 years(2015-2020)
SELECT DISTINCT EXTRACT(MONTH FROM new_date) as month_number,DATE_FORMAT(new_date,'%M') AS month_name,
    MAX(CASE WHEN EXTRACT(YEAR FROM new_date) = 2015 THEN total_sales end) as sales_2015,
    MAX(CASE WHEN EXTRACT(YEAR FROM new_date) = 2016 THEN total_sales end) as sales_2016,
    MAX(CASE WHEN EXTRACT(YEAR FROM new_date) = 2017 then total_sales end) as sales_2017,
    MAX(CASE WHEN EXTRACT(YEAR FROM new_date) = 2018 then total_sales end) as sales_2018,
    MAX(CASE WHEN EXTRACT(YEAR FROM new_date) = 2019 then total_sales end) as sales_2019,
    MAX(CASE WHEN EXTRACT(YEAR FROM new_date) = 2020 then total_sales end) as sales_2020
FROM(
SELECT distinct str_to_date(date,'%Y-%m-%d') as new_date,
    ROUND(SUM(total_bags) OVER (PARTITION BY STR_TO_DATE(date,'%Y-%m-%d')),0) as total_sales
FROM avocado_updated_2020) as sales_queries
GROUP BY month_number,month_name;

-- Task: Compare total_sales of each month from 2015 to 2020
--
SELECT DISTINCT EXTRACT(MONTH FROM new_date) as month_number,DATE_FORMAT(new_date,'%M') AS month_name,
    SUM(CASE WHEN EXTRACT(YEAR FROM new_date) = 2015 THEN total_sales end) as sales_2015,
    SUM(CASE WHEN EXTRACT(YEAR FROM new_date) = 2016 THEN total_sales end) as sales_2016,
    SUM(CASE WHEN EXTRACT(YEAR FROM new_date) = 2017 then total_sales end) as sales_2017,
    SUM(CASE WHEN EXTRACT(YEAR FROM new_date) = 2018 then total_sales end) as sales_2018,
    SUM(CASE WHEN EXTRACT(YEAR FROM new_date) = 2019 then total_sales end) as sales_2019,
    SUM(CASE WHEN EXTRACT(YEAR FROM new_date) = 2020 then total_sales end) as sales_2020
FROM(
SELECT distinct str_to_date(date,'%Y-%m-%d') as new_date,
    ROUND(SUM(total_bags) OVER (PARTITION BY STR_TO_DATE(date,'%Y-%m-%d')),0) as total_sales
FROM avocado_updated_2020) as sales_queries
GROUP BY month_number,month_name;

SELECT new_date,total_sales,
    LAG(new_date) over (partition by extract(MONTH FROM new_date) order by new_date) as prev_year,
    LAG(total_sales) over (partition by extract(month from new_date) order by new_date) as prev_year_sales,
    total_sales - LAG(total_sales) over (partition by extract(month from new_date) order by new_date) as difference
FROM(
SELECT distinct str_to_date(date,'%Y-%m-%d') as new_date,
    ROUND(SUM(total_bags) OVER (PARTITION BY STR_TO_DATE(date,'%Y-%m-%d')),0) as total_sales
FROM avocado_updated_2020) as sales_queries;

--
SELECT DISTINCT str_to_date(date,'%Y-%m-%d') as new_date,geography,
    ROUND(SUM(total_bags) OVER (PARTITION BY geography),0) as total_sales
FROM avocado_updated_2020
order by new_date desc;

SELECT distinct type,
       ROUND(SUM(total_bags) OVER (PARTITION BY type),0) AS TOTAL_SALES
FROM avocado_updated_2020;

-- moving average (First one gives us moving avg by dividing total sales of number of previous and current rows)
                   -- Second month return us moving avg with 4 rows only.

SELECT new_date, total_bags, geography,
       ROUND(avg(total_bags) over (partition by geography),0) as avg_sales,
       ROUND(avg(total_bags) over (partition by geography order by new_date),0) as mov_average
FROM(
SELECT STR_TO_DATE(DATE,'%Y-%m-%d') as new_date, type, total_bags,geography
from avocado_updated_2020) as subquery
WHERE type = 'conventional'
AND geography = 'Albany'
AND new_date between '2015-01-04' and '2015-12-27';


SELECT new_date, total_bags,
       ROUND(avg(total_bags) over (order by new_date rows between 3 preceding and current row ),0) as moving_avg,
       count(total_bags) over (order by new_date rows between 3 preceding and current row ) as records_count
FROM(
SELECT str_to_date(date,'%Y-%m-%d') AS new_date,total_bags,geography,type
FROM avocado_updated_2020) as subquery
WHERE geography = 'Albany'
AND type = 'Conventional';

-- Using self-join in order to return moving avg
-- Test if SQL returns right value
SELECT av1.type, av1.geography, av1.new_date,av1.total_bags,av2.new_date as rolling_week, av2.total_bags as rolling_sales
FROM(
SELECT STR_TO_DATE(DATE,'%Y-%m-%d') as new_date, type, geography,total_bags
FROM avocado_updated_2020) AV1
JOIN (SELECT STR_TO_DATE(date,'%Y-%m-%d') as new_date,type,geography,total_bags FROM avocado_updated_2020) AV2
    ON AV1.type = AV2.type AND AV1.geography = AV2.geography
and av2.new_date between av1.new_date - INTERVAL '51' WEEK AND AV1.new_date
and av1.geography = 'Albany'
and av1.type = 'Conventional'
where av2.geography = 'Albany'
and av2.type = 'Conventional'
AND AV1.new_date = '2015-12-27';

--
SELECT
       av1.new_date,
       av1.total_bags,
       ROUND(avg(av2.total_bags),0) as moving_avg,
       count(AV2.total_bags) as record_count
FROM(
SELECT STR_TO_DATE(DATE,'%Y-%m-%d') as new_date, type, geography,total_bags
FROM avocado_updated_2020) AV1
JOIN (SELECT STR_TO_DATE(date,'%Y-%m-%d') as new_date,type,geography,total_bags FROM avocado_updated_2020) AV2
    ON AV1.type = AV2.type AND AV1.geography = AV2.geography
and av2.new_date between av1.new_date - INTERVAL '51' WEEK AND AV1.new_date
and av1.geography = 'Albany'
and av1.type = 'Conventional'
where av2.geography = 'Albany'
and av2.type = 'Conventional'
AND AV1.new_date >= '2015-01-04'
group by 1,2
LIMIT 52