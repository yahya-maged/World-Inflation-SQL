-- The First step to be done is transforming the data
-- From "Wide data" form to "Long data" form

-- The database dialect used in this project is Postgres DB,
-- So the Unpivot function is not available unlike Microsoft Sql server,
-- But the following query will transform the table perfectly.

SELECT country, y.*,
        NULLIF(inflation, 'no data') AS inflation
        -- Note : the Nullif function checks for the value you insert,
        -- If the value is there it will change it to Null.
        -- it will be used because the inflation column contains a 'no data' string,
        -- instead of Null Value which causes errors

-- Cross Join Lateral,  and Values function will transform  the data from Wide to Long
--  at the end of query data will be inserted in column called year, and another called inflation
FROM "world-inflation" i
     CROSS JOIN LATERAL (
     VALUES
        ('2005', i."2005"), ('2006', i."2006"),('2007', i."2007"),
        ('2008', i."2008"), ('2009', i."2009"),('2010', i."2010"),
        ('2011', i."2011"), ('2012', i."2012"),('2013', i."2013"),
        ('2014', i."2014"), ('2015', i."2015"),('2016', i."2016"),
        ('2017', i."2017"), ('2018', i."2018"),('2019', i."2019"),
        ('2020', i."2020"), ('2021', i."2021"),('2022', i."2022")
        ) as y(year, inflation);


----------------------------------------
-- NOTE: After transforming the data, we exported it to another table called "wide-data"
-- After running the NullIf function we will be left with additional column named y.inflation
-- So the following query will drop it
ALTER TABLE "wide-data"
DROP COLUMN "y.inflation";

-- Changing the inflation column type, from string to float
ALTER TABLE "wide-data"
ALTER COLUMN "inflation" TYPE FLOAT USING ("inflation"::float);

-- Seeing all the countries that have null value and taking note of them
-- Knowing this information will help us be more cautious when using aggregation functions,
-- such as the AVG function, because it will skew the data
SELECT *
FROM "wide-data"
WHERE "inflation" IS NULL;

-- Showing only Non Null values in the table
SELECT *
FROM "wide-data"
WHERE "inflation" IS NOT NULL;

-- Calculating the Average inflation rate for each country, from 2005 till 2022
SELECT country,
    AVG(inflation) AS avg_inflation
FROM "wide-data"
GROUP BY country;

--  Comparing the inflation rates of all the countries only in 2022, From highest to lowest
SELECT *
FROM "wide-data"
WHERE "year" IN ('2022') AND "inflation" IS NOT NULL
ORDER BY "inflation" DESC;

SELECT *
FROM "wide-data"
