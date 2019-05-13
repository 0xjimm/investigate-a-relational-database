--How many inactive customers do we have across all stores?

SELECT
  COUNT(*) AS inactive_customers
FROM
(

  SELECT
    c.customer_id,
	c.first_name || ' ' || c.last_name AS full_name,
    a.address,
    ci.city,
    a.district,
    co.country,
    a.postal_code
  FROM customer c
  JOIN address a
    ON c.address_id = a.address_id
  JOIN city ci
    ON a.city_id = ci.city_id
  JOIN country co
    ON ci.country_id = co.country_id
  WHERE c.active = 0
) sub