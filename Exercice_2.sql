-- 1) How many stores there are, and in which city and country they are located.

SELECT COUNT(store.store_id) FROM store;

SELECT
    store.*,
    city.city,
    country.country
FROM store
    INNER JOIN address ON address.address_id = store.address_id
    INNER JOIN city ON city.city_id = address.city_id
    INNER JOIN country ON country.country_id = city.country_id
GROUP BY (
        store.store_id,
        city.city,
        country.country
    );

-- 2) How many hours of viewing time there are in total in each store –

-- in other words, the sum of the length of every inventory item in each store.

SELECT
    store.store_id,
    SUM(film.length) AS total_viewing
FROM film
    INNER JOIN inventory ON inventory.film_id = film.film_id
    INNER JOIN store ON store.store_id = inventory.store_id
GROUP BY(store.store_id);

-- 3) Make sure to exclude any inventory items which are not yet returned.

-- (Yes, even in the time of zombies there are people who do not return their DVDs)

SELECT
    store.store_id,
    SUM(film.length) AS total_viewing
FROM film
    INNER JOIN inventory ON inventory.film_id = film.film_id
    INNER JOIN store ON store.store_id = inventory.store_id
    INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
WHERE
    rental.return_date IS NULL
GROUP BY(store.store_id);

-- 4) A list of all customers in the cities where the stores are located.

SELECT
    store.store_id,
    city.city,
    customer.first_name || ' ' || customer.last_name AS "customer"
FROM customer
    INNER JOIN store ON store.store_id = customer.store_id
    INNER JOIN address ON address.address_id = store.address_id
    INNER JOIN city ON city.city_id = address.city_id
ORDER BY
    store.store_id -- 5) A list of all customers in the countries where the stores are located.
SELECT
    store.store_id,
    country.country,
    customer.first_name || ' ' || customer.last_name AS "customer"
FROM customer
    INNER JOIN store ON store.store_id = customer.store_id
    INNER JOIN address ON address.address_id = store.address_id
    INNER JOIN city ON city.city_id = address.city_id
    INNER JOIN country ON country.country_id = city.country_id
ORDER BY store.store_id;

/*
 6) Some people will be frightened by watching scary movies while 
 zombies walk the streets. Create a ‘safe list’ of all movies which do not 
 include the ‘Horror’ category, or contain the words ‘beast’, ‘monster’, 
 ‘ghost’, ‘dead’, ‘zombie’, or ‘undead’ in their titles or descriptions… 
 Get the sum of their viewing time (length).
 Hint : use the CHECK contraint
 */

CREATE VIEW SAFE_FILM_LIST AS 
	SELECT
	    film.*,
	    category.category_id,
	    category.name
	FROM film
	    INNER JOIN film_category ON film_category.film_id = film.film_id
	    INNER JOIN category ON category.category_id = film_category.category_id
	WHERE
	    category.category_id != 11
	    AND (
	        film.title NOT ILIKE '%beast%'
	        OR film.title NOT ILIKE '%monster%'
	        OR film.title NOT ILIKE '%ghost%'
	        OR film.title NOT ILIKE '%dead%'
	        OR film.title NOT LIKE '%zombie%'
	        OR film.title NOT LIKE '%undead%'
	        OR film.description NOT LIKE '%beast%'
	        OR film.description NOT ILIKE '%monster%'
	        OR film.description NOT ILIKE '%ghost%'
	        OR film.description NOT ILIKE '%dead%'
	        OR film.description NOT LIKE '%zombie%'
	        OR film.description NOT LIKE '%undead%'
	    )
	SELECT
	    SUM(safe_film_list.length) AS viewing_time
	FROM safe_film_list
; 

-- 7) For both the ‘general’ and the ‘safe’ lists above,

-- also calculate the time in hours and days (not just minutes).

-- safe list

SELECT
    SUM(safe_film_list.length) AS viewing_time,
    CEIL(
        SUM(safe_film_list.length) / (24 * 60)
    ) AS "jour(s)",
    CEIL( (
            SUM(safe_film_list.length) % (24 * 60)
        ) / 60
    ) AS "heure(s)",
    CEIL( (
            SUM(safe_film_list.length) - (
                CEIL(
                    SUM(safe_film_list.length) / (24 * 60)
                ) * 24 * 60 + CEIL( (
                        SUM(safe_film_list.length) % (24 * 60)
                    ) / 60
                ) * 60
            )
        )
    ) AS "minutes(s)"
FROM safe_film_list;

--unsafe list

SELECT
    SUM(film.length) AS viewing_time,
    CEIL(SUM(film.length) / (24 * 60)) AS "jour(s)",
    CEIL( (SUM(film.length) % (24 * 60)) / 60
    ) AS "heure(s)",
    CEIL( (
            SUM(film.length) - (
                CEIL(SUM(film.length) / (24 * 60)) * 24 * 60 + CEIL( (SUM(film.length) % (24 * 60)) / 60
                ) * 60
            )
        )
    ) AS "minutes(s)"
FROM film
WHERE film.film_id NOT IN (
        SELECT
            safe_film_list.film_id
        FROM safe_film_list
    )