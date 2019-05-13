--Revenue generation of the top 10 actors per day
SELECT DISTINCT a.first_name || ' ' || a.last_name AS full_name,
                Date_trunc('day', p.payment_date) AS payment_day,
                SUM(p.amount) OVER (partition BY a.first_name || ' ' || a.last_name ORDER BY date_trunc('day', p.payment_date)) AS revenue_over_time
FROM actor a
JOIN film_actor fa
ON   a.actor_id = fa.actor_id
JOIN film f
ON   fa.film_id = f.film_id
JOIN inventory i
ON   f.film_id = i.film_id
JOIN rental r
ON   i.inventory_id = r.inventory_id
JOIN payment p
ON   r.customer_id = p.customer_id

--Subquery to find top 10 grossing actors
JOIN (SELECT a.first_name || ' ' || a.last_name AS full_name,
             SUM(p.amount) AS total_revenue
      FROM   actor a
      JOIN   film_actor fa
      ON     a.actor_id = fa.actor_id 
      JOIN   film f
      ON     fa.film_id = f.film_id
      JOIN   inventory i
      ON     f.film_id = i.film_id
      JOIN   rental r
      ON     i.inventory_id = r.inventory_id
      JOIN   payment p
      ON     r.customer_id = p.customer_id
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT  10) sub
ON    sub.full_name = a.first_name || ' ' || a.last_name

GROUP BY 1,
         p.payment_date,
         p.amount
ORDER BY 1
