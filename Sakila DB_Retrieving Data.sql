########################## SQL ##############################

# Name: Jane Lee
# Date: 10/29/2024

# Refer to the Sakila documentation for further information about the tables, views, and columns: https://dev.mysql.com/doc/sakila/en/

##########################################################################

## Desc: Joining Data, Nested Queries, Views and Indexes, Transforming Data

############################ PREREQUESITES ###############################

SET SQL_SAFE_UPDATES=0;
UPDATE sakila.film SET language_id=6 WHERE title LIKE "%ACADEMY%";

############ Executing targeted SQL queries to retrieve and organize data from the Sakila database. ############

# List the actors (first_name, last_name, actor_id) who acted in more then 25 movies.  Also return the count of movies they acted in, aliased as movie_count. Order by first and last name alphabetically.
SELECT actor.first_name, actor.last_name, actor.actor_id, COUNT(film_actor.film_id) AS movie_count
FROM sakila.actor
JOIN sakila.film_actor ON actor.actor_id = film_actor.actor_id
GROUP BY actor.actor_id
HAVING movie_count > 25
ORDER BY actor.first_name, actor.last_name;

# List the actors (first_name, last_name, actor_id) who have worked in German language movies. Order by first and last name alphabetically.
SELECT actor.first_name, actor.last_name, actor.actor_id
FROM sakila.actor
JOIN sakila.film_actor ON actor.actor_id = film_actor.actor_id
JOIN sakila.film ON film_actor.film_id = film.film_id
JOIN sakila.language ON film.language_id = language.language_id
WHERE language.name = 'German'
GROUP BY actor.actor_id
ORDER BY actor.first_name, actor.last_name;

# List the actors (first_name, last_name, actor_id) who acted in horror movies and the count of horror movies by each actor.  Alias the count column as horror_movie_count. Order by first and last name alphabetically.
SELECT actor.first_name, actor.last_name, actor.actor_id, COUNT(film_actor.film_id) AS horror_movie_count
FROM sakila.actor
JOIN sakila.film_actor ON actor.actor_id = film_actor.actor_id
JOIN sakila.film ON film_actor.film_id = film.film_id
JOIN sakila.film_category ON film.film_id = film_category.film_id
JOIN sakila.category ON film_category.category_id = category.category_id
WHERE category.name = 'Horror'
GROUP BY actor.actor_id
ORDER BY actor.first_name, actor.last_name;


# List the customers who rented more than 3 horror movies.  Return the customer first and last names, customer IDs, and the horror movie rental count (aliased as horror_movie_count). Order by first and last name alphabetically.
SELECT customer.first_name, customer.last_name, customer.customer_id, COUNT(rental.rental_id) AS horror_movie_count
FROM sakila.customer
JOIN sakila.rental ON customer.customer_id = rental.customer_id
JOIN sakila.inventory ON rental.inventory_id = inventory.inventory_id
JOIN sakila.film ON inventory.film_id = film.film_id
JOIN sakila.film_category ON film.film_id = film_category.film_id
JOIN sakila.category ON film_category.category_id = category.category_id
WHERE category.name = 'Horror'
GROUP BY customer.customer_id
HAVING horror_movie_count > 3
ORDER BY customer.first_name, customer.last_name;

# List the customers who rented a movie which starred Scarlett Bening.  Return the customer first and last names and customer IDs. Order by first and last name alphabetically.
SELECT customer.first_name, customer.last_name, customer.customer_id
FROM sakila.customer
JOIN sakila.rental ON customer.customer_id = rental.customer_id
JOIN sakila.inventory ON rental.inventory_id = inventory.inventory_id
JOIN sakila.film_actor ON inventory.film_id = film_actor.film_id
JOIN sakila.actor ON film_actor.actor_id = actor.actor_id
WHERE actor.first_name = 'Scarlett' AND actor.last_name = 'Bening'
GROUP BY customer.customer_id
ORDER BY customer.first_name, customer.last_name;

# Which customers residing at postal code 62703 rented movies that were Documentaries?  Return their first and last names and customer IDs.  Order by first and last name alphabetically.
SELECT customer.first_name, customer.last_name, customer.customer_id
FROM sakila.customer
JOIN sakila.address ON customer.address_id = address.address_id
JOIN sakila.rental ON customer.customer_id = rental.customer_id
JOIN sakila.inventory ON rental.inventory_id = inventory.inventory_id
JOIN sakila.film_category ON inventory.film_id = film_category.film_id
JOIN sakila.category ON film_category.category_id = category.category_id
WHERE category.name = 'Documentary' AND address.postal_code = '62703'
GROUP BY customer.customer_id
ORDER BY customer.first_name, customer.last_name;

# Find all the addresses (if any) where the second address line is not empty and is not NULL (i.e., contains some text).  Return the address_id and address_2, sorted by address_2 in ascending order.
SELECT address_id, address2
FROM sakila.address
WHERE address2 IS NOT NULL AND address2 <> ''
ORDER BY address2 ASC;

# List the actors (first_name, last_name, actor_id)  who played in a film involving a “Crocodile” and a “Shark” (in the same movie).  Also include the title and release year of the movie.  Sort the results by the actors’ last name then first name, in ascending order.
SELECT actor.first_name, actor.last_name, actor.actor_id, film.title, film.release_year
FROM sakila.actor
JOIN sakila.film_actor ON actor.actor_id = film_actor.actor_id
JOIN sakila.film ON film_actor.film_id = film.film_id
WHERE film.title LIKE '%Crocodile%' AND film.title LIKE '%Shark%'
ORDER BY actor.last_name, actor.first_name ASC;

# Find all the film categories in which there are between 55 and 65 films. Return the category names and the count of films per category, sorted from highest to lowest by the number of films.  Alias the count column as count_movies. Order the results alphabetically by category.
SELECT category.name, COUNT(film_category.film_id) AS count_movies
FROM sakila.category
JOIN sakila.film_category ON category.category_id = film_category.category_id
GROUP BY category.category_id
HAVING count_movies BETWEEN 55 AND 65
ORDER BY count_movies DESC, category.name;

# In which of the film categories is the average difference between the film replacement cost and the rental rate larger than $17?  Return the film categories and the average cost difference, aliased as mean_diff_replace_rental.  Order the results alphabetically by category.
SELECT category.name, AVG(film.replacement_cost - film.rental_rate) AS mean_diff_replace_rental
FROM sakila.category
JOIN sakila.film_category ON category.category_id = film_category.category_id
JOIN sakila.film ON film_category.film_id = film.film_id
GROUP BY category.category_id
HAVING mean_diff_replace_rental > 17
ORDER BY category.name;

# Create a list of overdue rentals so that customers can be contacted and asked to return their overdue DVDs. Return the title of the  film, the customer first name and last name, customer phone number, and the number of days overdue, aliased as days_overdue.  Order the results by first and last name alphabetically.
SELECT film.title, customer.first_name, customer.last_name, address.phone, DATEDIFF(CURDATE(), DATE_ADD(rental.rental_date, INTERVAL film.rental_duration DAY)) AS days_overdue
FROM sakila.rental
JOIN sakila.customer ON rental.customer_id = customer.customer_id
JOIN sakila.address ON customer.address_id = address.address_id
JOIN sakila.inventory ON rental.inventory_id = inventory.inventory_id
JOIN sakila.film ON inventory.film_id = film.film_id
WHERE rental.return_date IS NULL AND CURDATE() > DATE_ADD(rental.rental_date, INTERVAL film.rental_duration DAY)
ORDER BY customer.first_name, customer.last_name;

# Find the list of all customers and staff for store_id 1.  Return the first and last names, as well as a column indicating if the name is "staff" or "customer", aliased as person_type.  Order results by first name and last name alphabetically.
SELECT customer.first_name, customer.last_name, 'customer' AS person_type
FROM sakila.customer
WHERE store_id = 1
UNION ALL
SELECT staff.first_name, staff.last_name, 'staff' AS person_type
FROM sakila.staff
WHERE store_id = 1
ORDER BY first_name, last_name;

# List the first and last names of both actors and customers whose first names are the same as the first name of the actor with actor_id 8.  Order in alphabetical order by last name.
SELECT actor.first_name, actor.last_name
FROM sakila.actor
WHERE actor.first_name = (SELECT first_name FROM sakila.actor WHERE actor_id = 8)
UNION ALL
SELECT customer.first_name, customer.last_name
FROM sakila.customer
WHERE customer.first_name = (SELECT first_name FROM sakila.actor WHERE actor_id = 8)
ORDER BY last_name;

# List customers (first name, last name, customer ID) and payment amounts of customer payments that were greater than average the payment amount.  Sort in descending order by payment amount.
SELECT customer.first_name, customer.last_name, customer.customer_id, payment.amount
FROM sakila.customer
JOIN sakila.payment ON customer.customer_id = payment.customer_id
WHERE payment.amount > (SELECT AVG(amount) FROM sakila.payment)
ORDER BY payment.amount DESC;

# List customers (first name, last name, customer ID) who have rented movies at least once.  Order results by first name, lastname alphabetically.
SELECT customer.first_name, customer.last_name, customer.customer_id
FROM sakila.customer
WHERE customer.customer_id IN (SELECT customer_id FROM sakila.rental)
ORDER BY customer.first_name, customer.last_name;

# Find the floor of the maximum, minimum and average payment amount.  Alias the result columns as max_payment, min_payment, avg_payment.
SELECT FLOOR(MAX(amount)) AS max_payment, FLOOR(MIN(amount)) AS min_payment, FLOOR(AVG(amount)) AS avg_payment
FROM sakila.payment;

# Create a view called actors_portfolio which contains the following columns of information about actors and their films: actor_id, first_name, last_name, film_id, title, category_id, category_name
CREATE VIEW actors_portfolio AS
SELECT actor.actor_id, actor.first_name, actor.last_name, film.film_id, film.title, category.category_id, category.name AS category_name
FROM sakila.actor
JOIN sakila.film_actor ON actor.actor_id = film_actor.actor_id
JOIN sakila.film ON film_actor.film_id = film.film_id
JOIN sakila.film_category ON film.film_id = film_category.film_id
JOIN sakila.category ON film_category.category_id = category.category_id;

# Describe (using a SQL command) the structure of the view.
DESCRIBE actors_portfolio;

# Query the view to get information (all columns) on the actor ADAM GRANT
SELECT *
FROM actors_portfolio
WHERE first_name = 'ADAM' AND last_name = 'GRANT';

# Insert a new movie titled Data Hero in Sci-Fi Category starring ADAM GRANT
INSERT INTO sakila.film (title, description, language_id, rental_duration, rental_rate, replacement_cost)
VALUES ('Data Hero', 'A sci-fi adventure', 1, 3, 2.99, 20.99);
SET @new_film_id = LAST_INSERT_ID();
SET @sci_fi_category_id = (SELECT category_id FROM sakila.category WHERE name = 'Sci-Fi');

INSERT INTO sakila.film_category (film_id, category_id)
VALUES (@new_film_id, @sci_fi_category_id);
SET @adam_grant_actor_id = (SELECT actor_id FROM sakila.actor WHERE first_name = 'ADAM' AND last_name = 'GRANT');
INSERT INTO sakila.film_actor (actor_id, film_id)
VALUES (@adam_grant_actor_id, @new_film_id);

# Extract the street number (numbers at the beginning of the address) from the customer address in the customer_list view.  Return the original address column, and the street number column (aliased as street_number).  Order the results in ascending order by street number.
SELECT address, CAST(REGEXP_SUBSTR(address, '^[0-9]+') AS UNSIGNED) AS street_number
FROM sakila.customer_list
WHERE REGEXP_SUBSTR(address, '^[0-9]+') IS NOT NULL
ORDER BY street_number ASC;

# List actors (first name, last name, actor id) whose last name starts with characters A, B or C.  Order by first_name, last_name in ascending order.
SELECT first_name, last_name, actor_id
FROM sakila.actor
WHERE LEFT(last_name, 1) IN ('A', 'B', 'C')
ORDER BY first_name, last_name;

# List film titles that contain exactly 10 characters.  Order titles in ascending alphabetical order.
SELECT title
FROM sakila.film
WHERE CHAR_LENGTH(title) = 10
ORDER BY title ASC;

# Return a list of distinct payment dates formatted in the date pattern that matches "22/01/2016" (2 digit day, 2 digit month, 4 digit year).  Alias the formatted column as payment_date.  Retrn the formatted dates in ascending order.
SELECT DISTINCT DATE_FORMAT(payment_date, '%d/%m/%Y') AS payment_date
FROM sakila.payment
ORDER BY payment_date ASC;

# Find the number of days each rental was out (days between rental_date & return_date), for all returned rentals.  Return the rental_id, rental_date, return_date, and alias the days between column as days_out.  Order with the longest number of days_out first.
SELECT rental_id, rental_date, return_date, DATEDIFF(return_date, rental_date) AS days_out
FROM sakila.rental
WHERE return_date IS NOT NULL
ORDER BY days_out DESC;
