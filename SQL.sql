-- Business Question
-- Which actors movies are rented most?

-- film contains rental_rate film_id and title
-- film_actor contains actor_id and film_id 
-- actor contains actor_id and first_name and last_name
-- custom function returns first and last name of actor together (actor_name)

-- detailed table contains everything in all 3 tables
-- summary table contains film_title actor_name and rental_rate

-- summary is important for identifying several aspects such as description, year etc.
-- detailed table is important for quick assessment of specific information

-- report should be refreshed at least once a month to keep up with current trends in the movie industry

-- PART B: Function

CREATE OR REPLACE FUNCTION concat_name (first_name TEXT, last_name TEXT)
RETURNS TEXT
LANGUAGE plpgsql AS $$
DECLARE
actor_name TEXT;
BEGIN
actor_name := CONCAT(first_name, ' ', last_name);
RETURN actor_name;
END;
$$;

--TEST FUNCTION
SELECT concat_name('Jimmy', 'Fallon');

-- PART C: detailed and summary tables
-- DETAILED REPORT
CREATE TABLE detailed_report (
actor_id INT,
film_id INT,
title VARCHAR(50),
release_year SMALLINT,
rating VARCHAR(7),
actor_name VARCHAR(100),
rental_rate SMALLINT
);

-- SUMMARY REPORT
CREATE TABLE summary_report (
actor_name VARCHAR(100),
rental_rate SMALLINT,
title VARCHAR(50)
);

SELECT * FROM detailed_report;
SELECT * FROM summary_report



-- PART E: create a trigger function

CREATE OR REPLACE FUNCTION populate_summary ()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
DELETE FROM summary_report;
INSERT INTO summary_report (
    SELECT DISTINCT actor_name, rental_rate, title
    FROM detailed_report
    WHERE rental_rate > 4
);
RETURN NEW;
END;
$$;

CREATE TRIGGER updated_details
AFTER INSERT
ON detailed_report
FOR EACH STATEMENT
EXECUTE PROCEDURE populate_summary();


-- PART D: extract raw data for detailed report (place after part E)
INSERT INTO detailed_report (
SELECT actor.actor_id, film.film_id, film.title, film.release_year, film.rating, concat_name(first_name, last_name), film.rental_rate
FROM film
JOIN film_actor ON (film.film_id = film_actor.film_id)
JOIN actor ON (film_actor.actor_id = actor.actor_id)
ORDER BY rental_rate
);

SELECT * FROM detailed_report;
SELECT * FROM summary_report

-- insert addition data for testing

INSERT INTO detailed_report
VALUES ('0','248','Spongebob','2010','PG-13','Drake Radcliff','5');



-- PART F: stored procedure to refresh the data

CREATE OR REPLACE PROCEDURE refresh_data() 
LANGUAGE plpgsql AS $$
BEGIN
	DELETE FROM detailed_report;
	DELETE FROM summary_report;
	INSERT INTO detailed_report 
        SELECT
        actor.actor_id, 
        film.film_id, 
        film.title, 
        film.release_year, 
        film.rating, 
        concat(first_name, last_name),
        film.rental_rate
    FROM film
    JOIN film_actor ON film.film_id = film_actor.film_id
    JOIN actor ON film_actor.actor_id = actor.actor_id
    ORDER BY rental_rate;
END;
$$;

-- Call procedure
CALL refresh_data();

-- Check tables

SELECT * FROM detailed_report
SELECT * FROM summary report


-- 1. pgAgent is distributed by a third party but is able to be downloaded and used by Postgre SQL to automate scripts / tasks on a schedule