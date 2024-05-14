SELECT *
FROM Electric_Vehicle_Population_Data1;

-- Question: Count how many types was registered certain type of electrical vehicle
-- Answer: Plug-in Hybrid Electric Vehicle - 39,485
--         Battery Electric Vehicle - 141,973
SELECT Electric_Vehicle_Population_Data1.`Electric Vehicle Type`,COUNT(*) AS types
FROM Electric_Vehicle_Population_Data1
GROUP BY `Electric Vehicle Type`;

-- Question: how many cars were registered per state
-- Answer: (Visualisation board), 3-top WA - 181,060, CA - 102, VA - 47

SELECT State, COUNT(`Electric Vehicle Type`) AS num_vehicle
    FROM Electric_Vehicle_Population_Data1
GROUP BY State
ORDER BY num_vehicle DESC ;

-- Question: What type of vehicle is registered the most in each state
-- Answer:

SELECT State, Electric_Vehicle_Population_Data1.`Electric Vehicle Type`, COUNT(*) as types
FROM Electric_Vehicle_Population_Data1
GROUP BY  State, Electric_Vehicle_Population_Data1.`Electric Vehicle Type`;

-- Question: How many cars with CAFV (WA)
-- Answer: I have chosen only one state since there is more of half vehicle has been registered there.
--         In WA state there is 94 567 cars with unknown eligibility (BEV type) (There are 181060 have been registered in WA)

SELECT State, `Electric Vehicle Type`, `Clean Alternative Fuel Vehicle (CAFV) Eligibility`, COUNT(*) as CAFV_num
FROM Electric_Vehicle_Population_Data1
WHERE State = 'WA'
GROUP BY State, `Electric Vehicle Type`, `Clean Alternative Fuel Vehicle (CAFV) Eligibility`
ORDER BY `Electric Vehicle Type`;

-- Question: What models are the most registered (TOP 10)
-- Answer: 1. MODEL Y, 2.MODEL 3, 3.LEAF, 4.MODEL S, 5.BOLT EV, 6.MODEL X, 7. VOLT, 8. ID.4, 9.WRANGLER, 10. MUSTANG MACH-E

SELECT Model, COUNT(*) as model_type
FROM Electric_Vehicle_Population_Data1
GROUP BY Model
ORDER BY model_type DESC
LIMIT 10;

-- QUESTION: WHAT MODEL IS THE MOST REGISTERED IN EACH STATE
-- ANSWER: TOP MODEL IN WA - MODEL Y(36937), CA - MODEL 3(28), CA - MODEL 3(10), MD -  MODEL Y (7)
SELECT State, Model,num_vehicle, rank_
       FROM (
SELECT State, Model,num_vehicle,
       RANK() OVER (partition by State ORDER BY  num_vehicle DESC) as rank_
FROM(
SELECT state, model, COUNT(*) as num_vehicle
FROM Electric_Vehicle_Population_Data1
GROUP BY state, model
order by num_vehicle desc) AS num) as num2
WHERE rank_ = 1
ORDER BY num_vehicle DESC;

-- QUESTION: What maker represents how many models
-- ANSWER: 40 maker in total,  BMW - 15, AUDI - 12, MERCEDES- BENZ - 10, FORD - 8, HYUNDAI - 8, KIA - 8, VOLVO - 7, CHEVROLET - 7, TOYOTA - 6

SELECT MAKE, count(DISTINCT Model) as types
FROM Electric_Vehicle_Population_Data1
GROUP BY MAKE
ORDER BY TYPES DESC;

-- QUESTION: What model is the most popular by each maker
-- ANSWER: TESLA - MODEL Y (37007), NISSAN - LEAF(13560), CHEVROLET - BOLT EV (6935), VOLKSWAGEN - ID.4 (4091),
--          JEEP - WRANGLER (3543),FORD - MUSTANG MACH-E(3487),KIA - NIRO(3200),CHRYSLER - PACIFICA (3059), TOYOTA - PRIUS PRIME(2810)
--          HYUNDAI - IONIQ 5 (2515), BMW - X5 (2425),RIVIAN - R1S(2184)

SELECT MAKE, MODEL, num_model ,top_model
       FROM (
SELECT MAKE, MODEL, num_model,
       RANK() OVER (PARTITION BY Make order by num_model DESC ) as top_model
FROM(
SELECT MAKE, MODEL, COUNT(*) as num_model
FROM Electric_Vehicle_Population_Data1
GROUP BY MAKE, MODEL) as model_subquery) as top_model_subquery
WHERE top_model = 1
ORDER BY num_model DESC;

-- Question: Since Model Y is the most popular. OF what year the model is registered the most.
-- Answer: 2023 model is the most popular 19062 ea
    SELECT `Model Year`, Model, count(*) as year
        FROM Electric_Vehicle_Population_Data1
    WHERE MODEL = 'MODEL Y'
    GROUP BY Model, `Model Year`;

-- Task: Find the most popular year model of each maker
-- Answer: TESLA MODEL Y (2023), VOLKSWAGEN - ID.4 (2023), NISSAN - LEAF (2013),HYUNDAI - IONIQ 5 (2023), CHEVROLET BOLT EV - 2023

SELECT MAKE, `Model Year`, Model,num_year, top_reg
FROM (
  SELECT Make, `Model Year`, model, num_year,
        rank() over (partition by Make ORDER BY num_year DESC ) as top_reg
  FROM (
    SELECT Make,`Model Year`, Model, COUNT(*) as num_year
    FROM Electric_Vehicle_Population_Data1
    GROUP BY Make, Model, `Model Year`) as year_query) as top_rank
    WHERE top_reg =1
    ORDER BY num_year DESC;

-- To see how many Providers
SELECT DISTINCT  `Electric Utility`,COUNT(*) as num_provider
FROM Electric_Vehicle_Population_Data1
GROUP BY `Electric Utility`
ORDER BY num_provider DESC
LIMIT 10;

-- CASE STATEMENT 이용해서 PIVOT TABLE 만들기
-- 조건: 각모델이 생산하는 해에 해당하는 등록된 자동차 개수

SELECT `Model Year`,
       COUNT(IF(Make = 'Nissan',1,NULL)) as NISSAN,
       COUNT(IF(Make = 'Hyundai',1,NULL)) as HYUNDAI,
       COUNT(IF(MAKE = 'Tesla',1,NULL)) as TESLA,
       COUNT(IF(Make = 'Volkswagen',1,NULL)) as VOLKSWAGEN,
       COUNT(IF(MAKE = 'Chevrolet',1, NULL)) as CHEVROLET,
       COUNT(IF(MAKE = 'JEEP',1,NULL)) as JEEP
FROM Electric_Vehicle_Population_Data1
GROUP BY `Model Year`
ORDER BY `Model Year` DESC;

-- 위의 query 결과를  확인하기 위한 query
Select make,count(*)
from Electric_Vehicle_Population_Data1
where make = 'tesla'
and `Model Year` = 2022



