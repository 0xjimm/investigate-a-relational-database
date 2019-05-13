WITH t1 --Calculates the average amount of days per rental and real daily rate
AS (SELECT
  sub.title,
  DATE_PART('day', AVG(sub.rent_time)) AS avg_rent_days,
  COUNT(*) AS times_rented,
  DATE_PART('day', SUM(sub.rent_time)) AS tot_rent_days,
  SUM(sub.amount) AS tot_payment,
  SUM(sub.amount) / DATE_PART('day', SUM(sub.rent_time)) AS real_daily_rate
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
ORDER BY 1),

t2 --Pulls all rentals that were never returned and never paid for
AS (SELECT
  i.inventory_id,
  r.customer_id,
  f.title,
  f.rental_rate,
  r.rental_date,
  r.return_date,
  p.amount,
  p.payment_date,
  f.replacement_cost,
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
  ON r.customer_id = p.customer_id
WHERE r.return_date IS NULL
AND p.amount = 0)

SELECT --For the rentals lost, calculate the lost revenue, and how many rentals
  --to recooperate replacement cost
  t1.title,
  t2.replacement_cost,
  COUNT(*) AS times_lost,
  ((t1.avg_rent_days * t1.real_daily_rate) * COUNT(*)) AS lost_revenue,
  ((t1.avg_rent_days * t1.real_daily_rate) * COUNT(*)) + (COUNT(*) * t2.replacement_cost) AS total_loss
FROM t1
JOIN t2
  ON t1.title = t2.title
GROUP BY t1.title,
         t2.replacement_cost,
         t1.avg_rent_days,
         t1.real_daily_rate
ORDER BY 5 DESC