/*
Calculates the average amount of days for each rental, and the real
revenue per day the film is rented
*/
SELECT
  sub.title,
  DATE_PART('day', AVG(sub.rent_time)) AS avg_rent_days,
  DATE_PART('day', SUM(sub.rent_time)) AS tot_rent_days,
  SUM(sub.amount) AS tot_payment,
  SUM(sub.amount) / DATE_PART('day', SUM(sub.rent_time)) AS real_daily_rate

--Caculates total time for every rental
FROM (SELECT
  f.title,
  f.rental_rate,
  r.rental_date,
  r.return_date,
  p.amount,
  r.return_date - r.rental_date AS rent_time
FROM category c
JOIN film_category fc
  ON c.category_id = fc.category_id
JOIN film f
  ON fc.film_id = f.film_id
JOIN inventory i
  ON f.film_id = i.film_id
JOIN rental r
  ON i.inventory_id = r.inventory_id
JOIN payment p
  ON r.customer_id = p.customer_id) sub

GROUP BY 1
ORDER BY 1
