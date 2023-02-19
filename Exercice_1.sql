-- 1) Get a list of all rentals which are out (have not been returned).

-- How do we identify these films in the database?

SELECT
    DISTINCT(film.film_id),
    film.*
FROM film
    INNER JOIN inventory ON inventory.film_id = film.film_id
    INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
WHERE
    rental.return_date IS NULL;

-- 2) Get a list of all customers who have not returned their rentals.

-- Make sure to group your results.

SELECT
    customer.*,
    film.title
FROM customer
    INNER JOIN rental ON rental.customer_id = customer.customer_id
    INNER JOIN inventory ON inventory.inventory_id = rental.inventory_id
    INNER JOIN film ON film.film_id = inventory.film_id
WHERE
    rental.return_date IS NULL;

-- 3) Get a list of all the Action films with Joe Swank.

-- Before you start, could there be a shortcut to getting this information? Maybe a view?

SELECT film.*
FROM film
    INNER JOIN film_category ON film_category.film_id = film.film_id
    INNER JOIN category ON category.category_id = film_category.category_id
    INNER JOIN film_actor ON film_actor.film_id = film.film_id
    INNER JOIN actor ON actor.actor_id = film_actor.actor_id
WHERE
    category.name = 'Action'
    AND actor.first_name || ' ' || actor.last_name = 'Joe Swank';