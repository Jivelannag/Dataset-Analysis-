SELECT *
FROM Taxi_Trips_2024_20240408;

SELECT COUNT(*) AS all_records
FROM Taxi_Trips_2024_20240408;

-- COVERT trip start timestamp and end timestamp into datetime data type
SELECT cast(str_to_date(`Trip Start Timestamp`,'%m/%e/%Y %r')as datetime) as start_trip,
       cast(str_to_date(`Trip End Timestamp`,'%m/%e/%Y %r')as datetime) as end_trip
from Taxi_Trips_2024_20240408; -- I could not convert am/pm so I change the hour format. It is now 00 to 23

-- see the duration of each trip

SELECT timestampdiff(minute,start_trip,end_trip)as duration_in_minute
FROM (
SELECT cast(str_to_date(`Trip Start Timestamp`,'%m/%e/%Y %I:%i:%s')as datetime) as start_trip,
       cast(str_to_date(`Trip End Timestamp`,'%m/%e/%Y %I:%i:%s')as datetime) as end_trip
FROM Taxi_Trips_2024_20240408) as trip_duration;

-- see the duration of each trip by using trip seconds column

SELECT  `Trip Seconds`,ROUND(`Trip Seconds`/60,0) as duration_in_minute
FROM Taxi_Trips_2024_20240408;

-- NOTE when I subtract one date from another, I received '0' because start and end trip time is the same 00:00:00 in 3d column
-- But when I use trip seconds column, I get 12 minutes trip in 3d row.
-- My question is: If start trip and end trip is the same how is it possible for trip seconds column to have value in it?
-- Update: If a trip was not long than 15 minutes start time and end time will be the same so I cant used start and end time stamp as duration

-- How many trips have same start and end timestamp
-- Answer: 214,970 trips has the same start and end timestamp (These trips fall under 15 minutes duration)
SELECT COUNT(*) as the_same_start_end
FROM(SELECT cast(str_to_date(`Trip Start Timestamp`,'%m/%e/%Y %I:%i:%s')as datetime) as start_trip,
       cast(str_to_date(`Trip End Timestamp`,'%m/%e/%Y %I:%i:%s')as datetime) as end_trip
from Taxi_Trips_2024_20240408) as new_date
WHERE start_trip = end_trip;

-- What is payment type here
-- Payment type: Credit card, Cash, Mobile, Prcard, Unknown, No Charge, Dispute

SELECT `Payment Type`, COUNT(*) as Payment_type
FROM Taxi_Trips_2024_20240408
GROUP BY `Payment Type`;

-- How mane taxi companies are presented here
-- There are 37 companies here

SELECT DISTINCT Company
FROM Taxi_Trips_2024_20240408;

-- Task: Num_trip_per_company
-- Answer: Flash cab, Taxi Affiliation Services, Sun Taxi, Taxican Insurance Agency Llc

SELECT Company,COUNT(*) num_trip_per_copmany
FROM Taxi_Trips_2024_20240408
GROUP BY Company
ORDER BY num_trip_per_copmany DESC;

-- To find peak time
-- Since there is many trips that were ended under one hour.

SELECT CONCAT(start_hour,' ','to',' ',end_hour) as period,count(*) as num_trip
FROM(
SELECT  EXTRACT(HOUR FROM CAST(str_to_date(`Trip Start Timestamp`,'%m/%e/%Y %r') AS DATETIME )) as start_hour,
        EXTRACT(HOUR FROM CAST(str_to_date(`Trip End Timestamp`,'%m/%e/%Y %r') AS DATETIME )) as end_hour
FROM Taxi_Trips_2024_20240408) as concat_quieries
GROUP BY period
ORDER BY num_trip DESC;

-- CHECK null values in  timestamps

SELECT *
FROM Taxi_Trips_2024_20240408
WHERE `Trip End Timestamp` IS NULL;

-- REMOVE VALUES
SELECT *, NULLIF(`Trip Start Timestamp`,`Trip End Timestamp`) as null_end_time
FROM Taxi_Trips_2024_20240408;

--
SELECT `Trip ID`
FROM Taxi_Trips_2024_20240408
    WHERE `Trip ID` IS null; -- there is no NULL in TAXI ID
SELECT Company
FROM Taxi_Trips_2024_20240408
WHERE Company IS NULL; -- THERE IS NO NULL in Taxi ID

-- FIND REVENUE BY EACH COMPANY
-- ANSWER: Flash cab earned the most revenue
SELECT `Trip Total`, COUNT(*) AS num_null
FROM Taxi_Trips_2024_20240408
WHERE `Trip Total` IS NULL
GROUP BY `Trip Total`; -- 2045 trips have NULLs in TRIP TOTAL

SELECT DISTINCT Company,
      ROUND(SUM(`Trip Total`) OVER (PARTITION BY Company),0 )as revenue
FROM Taxi_Trips_2024_20240408
WHERE `Trip Total` IS NOT NULL
ORDER BY revenue DESC;

-- FIND MAX AND MIN REVENUE
SELECT Company, ROUND(SUM(`Trip Total`),0) AS sum_per_company
from Taxi_Trips_2024_20240408
WHERE `Trip Total` IS NOT NULL
GROUP BY Company
order by sum_per_company DESC;

-- USED first value in order to get name of companies who has highest and lowest revenue
-- I did not manage to show only two companies. It shows me all companies.

SELECT  Company, revenue,
        first_value(Company) over (order by revenue DESC) as highst_revenue,
        FIRST_VALUE(Company) over (ORDER BY revenue) as lowest_revenue
FROM (
SELECT DISTINCT Company,
      ROUND(SUM(`Trip Total`) OVER (PARTITION BY Company),0 )as revenue
FROM Taxi_Trips_2024_20240408
WHERE `Trip Total` IS NOT NULL) as revenue_query;

-- CTE table

WITH calculation_table AS (SELECT distinct Company,
       ROUND(SUM(`Trip Total`) OVER (PARTITION BY Company ),0 )AS TOTAL_SUM,
       ROUND(SUM(Fare) OVER (PARTITION BY Company),0 )as total_fare,
       ROUND(sum(Tips) OVER(PARTITION BY Company),0) AS total_tips,
       ROUND(SUM(Tolls) OVER (PARTITION BY Company),0 )AS total_tolls
FROM Taxi_Trips_2024_20240408)

SELECT Company, TOTAL_SUM,
       LAG(TOTAL_SUM) OVER(ORDER BY TOTAL_SUM DESC) as previous_value,
       TOTAL_SUM - LAG(TOTAL_SUM) OVER(ORDER BY TOTAL_SUM DESC) as difference
FROM calculation_table;

-- Retrieve information about revenue of the most profitable taxi company "Flash Cab"

SELECT Company, EXTRACT(MONTH FROM CAST(STR_TO_DATE(`Trip Start Timestamp`, '%m/%e/%Y %r' ) AS DATETIME )) as trip_month,
       ROUND(SUM(`Trip Total`),0) as total_per_month
FROM Taxi_Trips_2024_20240408
WHERE Company = 'Flash cab'
GROUP BY Company,trip_month
ORDER BY trip_month;

