import mysql.connector

# Establish a connection
conn = mysql.connector.connect(
    host='localhost',        
    user='root',    
    password='1234', 
    database='gda' 
)

# Check if the connection is successful
if conn.is_connected():
    print("Connected to MySQL database")
else:
    print("Failed to connect")


cursor = conn.cursor()
# Example query
cursor.execute("SHOW TABLES")

# Fetch results
for table in cursor:
    print(table)


transfer_queries = [
    # Insert into Country
    "INSERT INTO Country (name, population, land_area) SELECT DISTINCT name, population, land_area FROM Staging;",
    # Insert into Economy
    """INSERT INTO Economy (country_id, gdp, income_class)
       SELECT c.country_id, s.gdp, s.income_class FROM Staging s JOIN Country c ON s.name = c.name WHERE s.gdp IS NOT NULL AND s.income_class IS NOT NULL;""",
    # Insert into Corruption
    """INSERT INTO Corruption (country_id, cpi)
        SELECT c.country_id, s.cpi FROM Staging s
        JOIN Country c ON s.name = c.name WHERE s.cpi IS NOT NULL;""",
    # Insert into Social
    """INSERT INTO Social (country_id, adult_literacy, generosity, freedom, social_support)
        SELECT c.country_id, s.adult_literacy, s.generosity, s.freedom, s.social_support FROM Staging s
        JOIN Country c ON s.name = c.name;""",
     # Insert into Health
     """INSERT INTO Health (country_id, life_expectancy, alcohol_consumption, air_pollution)
        SELECT c.country_id, s.life_expectancy, s.alcohol_consumption, s.air_pollution
        FROM Staging s JOIN Country c ON s.name = c.name;""",
      # Insert into Labour
      """INSERT INTO Labor (country_id, labor_force, labor_rate, unemployment_rate)
            SELECT c.country_id, s.labor_force, s.labor_rate, s.unemployment_rate
            FROM Staging s JOIN Country c ON s.name = c.name;""",
       # Insert into Amenities
       """INSERT INTO Amenities (country_id, electricity_access, water_access)
            SELECT c.country_id, s.electricity_access, s.water_access
            FROM Staging s JOIN Country c ON s.name = c.name;"""
]

for query in transfer_queries:
    cursor.execute(query)
    conn.commit()

print("Data successfully transferred.")




# Close the connection
conn.close()
