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

CREATE FUNCTION concat_name (first_name TEXT, last_name TEXT)
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
SELECT actor_name('Jimmy', 'Fallon');

-- PART C: detailed and summary tables
-- DETAILED REPORT
CREATE TABLE detailed_report (
actor_id int,
film_id int,
title varchar(50),
release_year smallint,
rating varchar(7),
actor_name VARCHAR(100),
rental_rate smallint
);

-- SUMMARY REPORT
CREATE TABLE summary_report (
actor_name varchar(100),
rental_rate smallint,
title varchar(50)
);

select * from detailed_report;
select * from summary_report



-- PART E: create a trigger function

CREATE FUNCTION populate_summary ()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
BEGIN
DELETE FROM summary_report;
INSERT INTO summary_report (
    SELECT actor_name, rental_rate, title
    FROM detailed_report
    ORDER BY rental_rate
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
insert into detailed_report (
select actor.actor_id, film.film_id, film.title, film.release_year, film.rating, actor_name, film.rental_rate
from film
join film_actor on (film.film_id = film_actor.film_id)
join actor on (film_actor.actor_id = actor.actor_id)
order by rental_rate
);

select * from detailed_report;
select * from summary_report

-- insert addition data for testing

INSERT INTO detailed_report
VALUES ('0','248','Spongebob','2010','PG-13','Lindsay','Lohan','4');



-- PART F: stored procedure to refresh the data

CREATE PROCEDURE refresh_data() AS $$
BEGIN
	TRUNCATE TABLE detailed_report;
	TRUNCATE TABLE summary_report;
	INSERT INTO detailed_report (
        actor_id int, 
        film_id int, 
        title varchar(50), 
        release_year smallint, 
        rating varchar(50), 
        concat_name(first_name, last_name) varchar(100),
        rental_rate smallint
        );
    select actor.actor_id, film.film_id, film.title, film.release_year, film.rating, concat_name(first_name, last_name), film.rental_rate
    from film
    join film_actor on (film.film_id = film_actor.film_id)
    join actor on (film_actor.actor_id = actor.actor_id)
    order by rental_rate
END;
$$ LANGUAGE plpgsql;

-- Call procedure
CALL refresh_data();

-- Check tables

SELECT * FROM detailed_report
ORDER BY rental_rate

SELECT * FROM summary report
ORDER BY rental_rate


-- 1. pgAgent is distributed by a third party but is able to be downloaded and used by Postgre SQL to automate scripts / tasks on a schedule