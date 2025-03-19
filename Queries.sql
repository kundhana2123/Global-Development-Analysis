-- 1. How can labor force indicators be used to identify labor market health?

-- Query to find the average and standard deviation of the labor force participation rate
SELECT AVG(labor_rate) AS avg_labor_rate , STDDEV(labor_rate) AS std_dev_labor_rate
FROM Labor;

-- Query to get a list of countries with labor force participation rate below (avg - 2*std_dev)
SELECT c.name, l.labor_rate
FROM Labor l
JOIN Country c ON l.country_id = c.country_id
WHERE l.labor_rate < (SELECT AVG(labor_rate) - 2*STDDEV(labor_rate) FROM Labor)
ORDER BY l.labor_rate;

-- Query to find the average and standard deviation of unemployment rate
SELECT AVG(unemployment_rate) AS avg_unemployment_rate , STDDEV(unemployment_rate) AS std_dev_unemployment_rate
FROM Labor;

-- Query to get a list of countries with unemployment rate above (avg + 1.5*std_dev)
SELECT c.name, l.unemployment_rate
FROM Labor l
JOIN Country c ON l.country_id = c.country_id
WHERE l.unemployment_rate > (SELECT AVG(unemployment_rate) + 1.5*STDDEV(unemployment_rate) FROM Labor)
ORDER BY l.unemployment_rate DESC;

-- Query to list countries with their unemployment rate and adult literacy rate for further analysis
SELECT c.name, l.unemployment_rate , s.adult_literacy 
FROM Labor l 
JOIN Country c 
JOIN Social s ON c.country_id = l.country_id AND l.country_id = s.country_id
WHERE l.unemployment_rate IS NOT NULL 
ORDER BY l.unemployment_rate;

-- 2. Does a higher GDP per capita lead to increased social support and freedom to make life choices?

-- Query to get GDP per capita along with social support and freedom for each country
SELECT e.country_id , e.gdp_per_capita, s.social_support, s.freedom
FROM EconomyWithGDPPerCapita e
JOIN Social s ON e.country_id = s.country_id
ORDER BY e.gdp_per_capita;

-- Query to calculate the average and standard deviation of GDP per capita
SELECT 
    AVG(gdp_per_capita) AS avg_gdp_per_capita,
    STDDEV(gdp_per_capita) AS stddev_gdp_per_capita
FROM EconomyWithGDPPerCapita
WHERE gdp_per_capita IS NOT NULL;

-- Query to get countries with GDP per capita below (avg - std_dev)
SELECT gdp_per_capita 
FROM EconomyWithGDPPerCapita
WHERE gdp_per_capita IS NOT NULL
  AND gdp_per_capita < (SELECT AVG(gdp_per_capita) - STDDEV(gdp_per_capita) FROM EconomyWithGDPPerCapita WHERE gdp_per_capita IS NOT NULL);

-- Query to categorize GDP per capita into Low, Medium, and High, and find the average social support and freedom for each category
SELECT 
    CASE 
        WHEN e.gdp_per_capita < (SELECT AVG(gdp_per_capita) - STDDEV(gdp_per_capita) FROM EconomyWithGDPPerCapita WHERE gdp_per_capita IS NOT NULL) THEN 'Low GDP'
        WHEN e.gdp_per_capita BETWEEN (SELECT AVG(gdp_per_capita) - STDDEV(gdp_per_capita) FROM EconomyWithGDPPerCapita WHERE gdp_per_capita IS NOT NULL)
            AND (SELECT AVG(gdp_per_capita) + STDDEV(gdp_per_capita) FROM EconomyWithGDPPerCapita WHERE gdp_per_capita IS NOT NULL) THEN 'Medium GDP'
        WHEN e.gdp_per_capita > (SELECT AVG(gdp_per_capita) + STDDEV(gdp_per_capita) FROM EconomyWithGDPPerCapita WHERE gdp_per_capita IS NOT NULL) THEN 'High GDP'
        ELSE 'Unknown' -- To handle cases where gdp_per_capita is null
    END AS gdp_category,
    AVG(s.social_support) AS avg_social_support,
    AVG(s.freedom) AS avg_freedom
FROM EconomyWithGDPPerCapita e
JOIN Social s ON e.country_id = s.country_id
WHERE e.gdp_per_capita IS NOT NULL
  AND s.social_support IS NOT NULL
  AND s.freedom IS NOT NULL
GROUP BY gdp_category;

-- 3. What is the correlation between corruption perception and income class across countries?

-- Query to calculate average, minimum, maximum CPI for each income class, and the number of countries in each income class
SELECT 
    e.income_class,
    AVG(c.cpi) AS avg_cpi,
    MIN(c.cpi) AS min_cpi,
    MAX(c.cpi) AS max_cpi,
    COUNT(c.cpi) AS num_countries
FROM 
    Economy e
JOIN 
    Corruption c ON e.country_id = c.country_id
GROUP BY 
    e.income_class
ORDER BY 
    avg_cpi DESC;

-- 4. How can health-related indicators be used to assess public health and environmental sustainability?

-- Create a view to categorize health-related data based on the average and standard deviation for life expectancy, air pollution, and alcohol consumption
CREATE VIEW health_Stata AS 
SELECT 
    c.country_id,
    c.name,
    -- Life Expectancy Categories
    CASE 
        WHEN h.life_expectancy < (avg_life_expectancy - stddev_life_expectancy) THEN 'Low Life Expectancy'
        WHEN h.life_expectancy BETWEEN (avg_life_expectancy - stddev_life_expectancy) 
                                   AND (avg_life_expectancy + stddev_life_expectancy) THEN 'Medium Life Expectancy'
        WHEN h.life_expectancy > (avg_life_expectancy + stddev_life_expectancy) THEN 'High Life Expectancy'
        ELSE 'Unknown'
    END AS life_expectancy_category,

    -- Air Pollution Categories
    CASE 
        WHEN air_pollution <= 25 THEN 'Green'
        WHEN air_pollution BETWEEN 25 AND 60 THEN 'Yellow'
        WHEN air_pollution BETWEEN 60 AND 96 THEN 'Orange'
        WHEN air_pollution BETWEEN 98 AND 150.4 THEN 'Red'
        ELSE 'Purple'
    END AS air_pollution_category,

    -- Alcohol Consumption Categories
    CASE 
        WHEN h.alcohol_consumption < (avg_alcohol_consumption - stddev_alcohol_consumption) THEN 'Low Alcohol Consumption'
        WHEN h.alcohol_consumption BETWEEN (avg_alcohol_consumption - stddev_alcohol_consumption) 
                                     AND (avg_alcohol_consumption + stddev_alcohol_consumption) THEN 'Medium Alcohol Consumption'
        WHEN h.alcohol_consumption > (avg_alcohol_consumption + stddev_alcohol_consumption) THEN 'High Alcohol Consumption'
        ELSE 'Unknown'
    END AS alcohol_consumption_category
FROM 
    Country c
JOIN 
    Health h ON c.country_id = h.country_id
-- Calculate the averages and standard deviations for health indicators
JOIN (
    SELECT 
        AVG(h.life_expectancy) AS avg_life_expectancy,
        STDDEV(h.life_expectancy) AS stddev_life_expectancy,
        AVG(h.air_pollution) AS avg_air_pollution,
        STDDEV(h.air_pollution) AS stddev_air_pollution,
        AVG(h.alcohol_consumption) AS avg_alcohol_consumption,
        STDDEV(h.alcohol_consumption) AS stddev_alcohol_consumption
    FROM 
        Health h
    WHERE 
        h.life_expectancy IS NOT NULL
        AND h.air_pollution IS NOT NULL
        AND h.alcohol_consumption IS NOT NULL
) AS health_stats
ON 1=1
WHERE 
    h.life_expectancy IS NOT NULL
    AND h.air_pollution IS NOT NULL
    AND h.alcohol_consumption IS NOT NULL;
