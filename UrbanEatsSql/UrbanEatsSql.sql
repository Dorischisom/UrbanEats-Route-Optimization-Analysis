-- Creating database

CREATE SCHEMA UrbanEats;
SHOW DATABASES;
USE UrbanEats;

SELECT * FROM customer_orders;
SELECT * FROM drivers_realistic;
SELECT * FROM restaurants_data;
SELECT * FROM traffic_data;

-- Data Exploration
SHOW TABLES;

DESCRIBE customer_orders;
DESCRIBE traffic_data;
DESCRIBE drivers_realistic;
DESCRIBE restaurants_data;

SET SQL_SAFE_UPDATES = 0;


UPDATE customer_orders
SET order_time = STR_TO_DATE(order_time, '%d/%m/%Y %H:%i');

ALTER TABLE customer_orders
MODIFY order_time DATETIME;

ALTER TABLE customer_orders
MODIFY latitude DECIMAL(10,7);

ALTER TABLE customer_orders
MODIFY longitude DECIMAL(10,7);

ALTER TABLE customer_orders
MODIFY address VARCHAR(255);

ALTER TABLE customer_orders
MODIFY distance_km DECIMAL(8,3);

ALTER TABLE customer_orders
MODIFY delivery_hrs DECIMAL(5,2);

ALTER TABLE customer_orders
MODIFY time_taken TIME;

UPDATE customer_orders
SET delivery_time = STR_TO_DATE(delivery_time, '%d/%m/%Y %H:%i')
WHERE delivery_time IS NOT NULL AND delivery_time <> '';

UPDATE customer_orders
SET delivery_time = NULL
WHERE delivery_time = '2099-12-31 23:59:59';

ALTER TABLE customer_orders
MODIFY delivery_time DATETIME;

ALTER TABLE customer_orders
MODIFY status VARCHAR(50);

UPDATE drivers_realistic
SET Shiftstart = STR_TO_DATE(Shiftstart, '%d/%m/%Y %H:%i');

ALTER TABLE drivers_realistic
MODIFY Shiftstart DATETIME;

UPDATE drivers_realistic
SET Shiftend = STR_TO_DATE(Shiftend, '%d/%m/%Y %H:%i');

ALTER TABLE drivers_realistic
MODIFY Shiftend DATETIME;

SELECT COUNT(*) AS Totalordercount FROM customer_orders ;
SELECT COUNT(*) AS driverscount FROM drivers_realistic;
SELECT COUNT(*) AS Restaurantcount FROM restaurants_data;
SELECT COUNT(*) AS Trafficcount FROM traffic_data;

-- Feature Engineering
-- How Long does it take to travel from point of order to delivery
-- Estimated travel time

SELECT o.order_id,
o.distance_km,
ROUND(o.distance_km * (1 + t.trafficdensity / 100)) AS Estimatedtraveltime_min
FROM customer_orders AS o
JOIN traffic_data AS t ON o.location_ID = t.locationid;

-- Drivers shift lengths since drivers are complaning
-- Range of hrs is 6-8 hrs



SELECT Driverid,
shiftstart,
shiftend,
TIMESTAMPDIFF(HOUR, shiftstart, shiftend) AS shiftlength_hr
FROM drivers_realistic;

-- Average delivery time
SELECT r.Restaurantid,
r.restaurantname,
AVG(o.delivery_hrs) AS avgdeliverytime_hrs
FROM restaurants_data r
JOIN customer_orders o ON r.restaurantid = o.restaurant_id
GROUP BY r.Restaurantid, r.restaurantname;

-- Busy periods for driver

SELECT driver_id,
EXTRACT( HOUR FROM order_time) AS orderhour,
COUNT(*) AS numberoforders
FROM customer_orders
GROUP BY driver_id, orderhour;

-- Order volume by area
SELECT location_id,
COUNT(*) AS total_orders
FROM customer_orders
GROUP BY location_id;

-- Preliminary Analysis
-- Average, Min, MAX delivery time

SELECT AVG(delivery_hrs) AS Deliverytime,
MIN(delivery_hrs) AS Mindeliverytime,
MAX(delivery_hrs) AS Maxdeliverytime
FROM customer_orders;

-- 0.150810	0.01	0.32

-- Frequency in delivery Status
SELECT `status`,
COUNT(*) AS Statuscount
FROM customer_orders
GROUP BY `status`;

-- Delivered	347
-- Pending	653

-- Shift lengths and count of drivers

SELECT driverid, 
drivername,
ROUND(AVG(TIMESTAMPDIFF(HOUR, shiftstart, shiftend))) AS avgshiftlength,
COUNT(*) AS Numberofshift
FROM drivers_realistic
GROUP BY driverid, drivername;

-- Number of orders by restaurant
SELECT restaurant_id,
COUNT(*) AS Totalorders
FROM customer_orders
GROUP BY restaurant_id
ORDER BY Totalorders DESC;

-- Traffic density statistic
SELECT AVG(Trafficdensity) AS Avgtrafficdensity,
MIN(Trafficdensity) AS MinTrafficdensity,
MAX(Trafficdensity) AS MaxTrafficdensity
FROM traffic_data;

-- 69.8533	1.94	194.22

-- Identify peak delivery time

SELECT EXTRACT(HOUR FROM order_time) AS hourofday,
COUNT(*) AS ordercount
FROM customer_orders
GROUP BY hourofday
ORDER BY ordercount DESC;

SELECT DAYNAME(order_time) AS dayofweek,
COUNT(*) AS ordercount
FROM customer_orders
GROUP BY dayofweek
ORDER BY ordercount DESC;


-- analyze driver shift and delivery times

SELECT d.shiftid, AVG(o.Delivery_hrs) AS avgdeliverytime
FROM Customer_orders o
JOIN drivers_realistic d ON d.driverid = o.driver_id
GROUP BY d.shiftid;

-- 3	0.148135
-- 1	0.153011
-- 2	0.151381

-- Corelation between traffic density and delivery time
SELECT t.trafficdensity,
AVG(o.delivery_hrs) AS avgdeliverytime
FROM customer_orders o
JOIN traffic_data t ON o.location_id = t.locationid
GROUP BY t.trafficdensity;

-- restaurant order pattern
SELECT r.restaurantid,
AVG(o.delivery_hrs) AS averagedeliverytime
FROM customer_orders o
JOIN restaurants_data r ON o.restaurant_id = r.restaurantid
GROUP BY r.restaurantid;

UPDATE customer_orders
SET time_taken = CONCAT('00:', SUBSTRING_INDEX(time_taken, ':', 2))
WHERE time_taken IS NOT NULL;

ALTER TABLE customer_orders
MODIFY time_taken TIME;