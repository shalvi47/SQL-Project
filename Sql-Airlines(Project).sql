 use  airlines;
 
 show columns from maindata;
-- Question 1 ( calculate year, monthno,monthfull name, quater, yearmonth, weekdayno, weekdayname, fsinancialmonth ,financialquater.
 SELECT 
    Year, 
    `Month (#)` AS Monthno,
    MONTHNAME(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d')) AS Monthfullname,
    CASE 
        WHEN `Month (#)` BETWEEN 1 AND 3 THEN 'Q1'
        WHEN `Month (#)` BETWEEN 4 AND 6 THEN 'Q2'
        WHEN `Month (#)` BETWEEN 7 AND 9 THEN 'Q3'
        WHEN `Month (#)` BETWEEN 10 AND 12 THEN 'Q4'
    END AS Quarter,
    CONCAT(Year, '-', DATE_FORMAT(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`), '%Y-%m'), '%b')) AS YearMonth,
    DAYOFWEEK(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d')) AS Weekdayno,
    DAYNAME(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d')) AS Weekdayname,
    CASE
        WHEN `Month (#)` BETWEEN 4 AND 6 THEN 'Q1'
        WHEN `Month (#)` BETWEEN 7 AND 9 THEN 'Q2'
        WHEN `Month (#)` BETWEEN 10 AND 12 THEN 'Q3'
        WHEN `Month (#)` = 1 OR `Month (#)` = 2 OR `Month (#)` = 3 THEN 'Q4'
    END AS FinancialQuarter,
    CASE
        WHEN `Month (#)` BETWEEN 1 AND 3 THEN 'January-March'
        WHEN `Month (#)` BETWEEN 4 AND 6 THEN 'April-June'
        WHEN `Month (#)` BETWEEN 7 AND 9 THEN 'July-September'
        WHEN `Month (#)` BETWEEN 10 AND 12 THEN 'October-December'
    END AS FinancialMonth
FROM maindata;

 
 
    
-- 2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)

SELECT 
    Year,
    SUM(`# Transported Passengers`) AS TotalTransportedPassengers,
    SUM(`# Available Seats`) AS TotalAvailableSeats,
    ROUND(SUM(`# Transported Passengers`) * 100.0 / SUM(`# Available Seats`), 2) AS LoadFactorPercentage
FROM maindata
GROUP BY Year;


-- 3. Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)


SELECT 
    `Carrier Name`,
    SUM(`# Transported Passengers`) AS TotalTransportedPassengers,
    SUM(`# Available Seats`) AS TotalAvailableSeats,
    ROUND(SUM(`# Transported Passengers`) * 100.0 / SUM(`# Available Seats`), 2) AS LoadFactorPercentage
FROM maindata
GROUP BY `Carrier Name`;

-- 4. Identify Top 10 Carrier Names based passengers preference 

SELECT 
    `Carrier Name`,
    SUM(`# Transported Passengers`) AS TotalTransportedPassengers
FROM maindata
GROUP BY `Carrier Name`
ORDER BY TotalTransportedPassengers DESC
LIMIT 10;

-- 5. Display top Routes ( from-to City) based on Number of Flights 
SELECT 
    `From - To City`,
    COUNT(*) AS NumberOfFlights
FROM maindata
GROUP BY `From - To City`
ORDER BY NumberOfFlights DESC
LIMIT 10;

-- 6. Identify the how much load factor is occupied on Weekend vs Weekdays.
SELECT 
    CASE 
        WHEN WEEKDAY(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d')) IN (5, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS DayType,
    ROUND(SUM(`# Transported Passengers`) * 100.0 / SUM(`# Available Seats`), 2) AS LoadFactorPercentage
FROM maindata
GROUP BY DayType
LIMIT 0, 1000;

-- 7. Use the filter to provide a search capability to find the flights between Source Country, Source State, Source City to Destination Country , Destination State, Destination City 
SELECT 
    `From - To City`, 
    `Origin Country`, 
    `Origin State`, 
    `Origin City`, 
    `Destination Country`, 
    `Destination State`, 
    `Destination City`,
    SUM(`# Transported Passengers`) AS TotalTransportedPassengers,
    SUM(`# Available Seats`) AS TotalAvailableSeats,
    ROUND(SUM(`# Transported Passengers`) * 100.0 / SUM(`# Available Seats`), 2) AS LoadFactorPercentage
FROM maindata
WHERE 
    `Origin Country` = 'SourceCountry' AND
    `Origin State` = 'SourceState' AND
    `Origin City` = 'SourceCity' AND
    `Destination Country` = 'DestinationCountry' AND
    `Destination State` = 'DestinationState' AND
    `Destination City` = 'DestinationCity'
GROUP BY 
    `From - To City`,
    `Origin Country`, 
    `Origin State`, 
    `Origin City`, 
    `Destination Country`, 
    `Destination State`, 
    `Destination City`
ORDER BY TotalTransportedPassengers DESC;


-- 8. Identify number of flights based on Distance groups

SELECT 
    `%Distance Group ID`, 
    COUNT(*) AS NumberOfFlights 
FROM maindata 
GROUP BY `%Distance Group ID` 
ORDER BY NumberOfFlights DESC 
LIMIT 0, 1000;







