CREATE TABLE Staging (
    name VARCHAR(100) ,
    population BIGINT,
    land_area BIGINT,
    gdp FLOAT,
    income_class VARCHAR(50),
    cpi FLOAT,
    adult_literacy FLOAT,
    generosity FLOAT,
    freedom FLOAT,
    social_support FLOAT,
    life_expectancy FLOAT,
    alcohol_consumption FLOAT,
    air_pollution FLOAT,
    labor_force BIGINT,
    labor_rate FLOAT,
    unemployment_rate FLOAT,
    electricity_access FLOAT,
    water_access FLOAT
);


select count(*) from staging;
select * from staging limit 10;

-- TRUNCATE TABLE Staging;

