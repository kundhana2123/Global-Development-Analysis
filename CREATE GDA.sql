
-- Normalization was achieved by designing a structured schema that reduced redundancy and ensured data consistency:

-- Logical Table Division: Data was split into related tables (Country, Economy, Health, Social, Corruption), each focusing on specific attributes.
-- Avoiding Redundancy: Attributes were stored in one table, with relationships established through country_id as a foreign key.
-- Functional Dependency: All attributes in a table depend only on the primary key, ensuring data integrity.
-- Minimizing Anomalies: Separation of data prevented update or deletion anomalies across unrelated attributes.

-- COUNTRY
CREATE TABLE Country (
    country_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL,
    population BIGINT,
    -- population_density FLOAT,
    land_area BIGINT
    CHECK (land_area > 0)
);

ALTER TABLE Country
ADD COLUMN population_density FLOAT GENERATED ALWAYS AS (population / land_area) STORED;

-- ECONOMY
CREATE TABLE Economy (
    economy_id INT PRIMARY KEY AUTO_INCREMENT,
    country_id INT,
    gdp FLOAT NOT NULL,
    income_class VARCHAR(50) NOT NULL,
    FOREIGN KEY (country_id) REFERENCES Country(country_id) ON DELETE CASCADE -- Ensures dependent records are deleted
);

CREATE VIEW EconomyWithGDPPerCapita AS
SELECT 
    e.economy_id,
    e.country_id,
    e.gdp,
    e.income_class,
    e.gdp / c.population AS gdp_per_capita
FROM Economy e
JOIN Country c ON e.country_id = c.country_id;


SELECT 
    economy_id,
    country_id,
    gdp,
    income_class,
    gdp_per_capita
FROM EconomyWithGDPPerCapita;

-- SOCIAL   
CREATE TABLE Social (
    social_id INT PRIMARY KEY AUTO_INCREMENT,
    country_id INT,
    social_support FLOAT,
    freedom FLOAT,
    generosity FLOAT,
    adult_literacy FLOAT,
    FOREIGN KEY (country_id) REFERENCES Country(country_id) ON DELETE CASCADE -- Ensures dependent records are deleted
);
-- LABOR   
CREATE TABLE Labor (
    labor_id INT PRIMARY KEY AUTO_INCREMENT,
    country_id INT,
    labor_force BIGINT,
    labor_rate FLOAT,
    unemployment_rate FLOAT,
    FOREIGN KEY (country_id) REFERENCES Country(country_id) ON DELETE CASCADE -- Ensures dependent records are deleted
);

-- HEALTH   
CREATE TABLE Health (
    health_id INT PRIMARY KEY AUTO_INCREMENT,
    country_id INT,
    life_expectancy FLOAT,
    alcohol_consumption FLOAT,
    air_pollution FLOAT,
    FOREIGN KEY (country_id) REFERENCES Country(country_id) ON DELETE CASCADE -- Ensures dependent records are deleted
);
-- AMENITIES
CREATE TABLE Amenities (
    amenities_id INT PRIMARY KEY AUTO_INCREMENT,
    country_id INT,
    electricity_access FLOAT,
    water_access FLOAT,
    FOREIGN KEY (country_id) REFERENCES Country(country_id) ON DELETE CASCADE -- Ensures dependent records are deleted
);

-- CORRUPTION      
CREATE TABLE Corruption (
    corruption_id INT PRIMARY KEY AUTO_INCREMENT,
    country_id INT,
    cpi FLOAT NOT NULL,  -- Corruption Perception Index (CPI)
    FOREIGN KEY (country_id) REFERENCES Country(country_id) ON DELETE CASCADE -- Ensures dependent records are deleted
);