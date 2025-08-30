-- 1st Ad hoc analysis request
SELECT product_code, base_price, promo_type
FROM fact_events
WHERE base_price >= 500 AND promo_type = "BOGOF";


-- 2nd Ad hoc analysis request
SELECT city, COUNT(store_id) AS total_stores
FROM dim_stores
GROUP BY city
ORDER BY total_stores DESC;


-- 3rd Ad hoc analysis request
SELECT c.campaign_id, c.campaign_name, ROUND(SUM(f.revenue_before_promo)/1000000,2) AS revenue_before_promo_mlns, 
ROUND(SUM(f.revenue_after_promo)/1000000,2) AS revenue_after_promo_mlns
FROM dim_campaigns c
JOIN fact_events f ON c.campaign_id = f.campaign_id
GROUP BY c.campaign_id, c.campaign_name;


-- 4th Ad hoc analysis request
WITH CategoryISU AS (
	SELECT 
		p.category,
		ROUND(SUM(f.quantity_lift) / 100, 2) AS total_isu_pct
	FROM dim_products p
	JOIN fact_events f ON p.product_code = f.product_code
	GROUP BY p.category
)
SELECT 
	category,
	total_isu_pct,
	RANK() OVER (ORDER BY total_isu_pct DESC) AS category_rank
FROM CategoryISU;


-- 5th Ad hoc analysis request
WITH Ir_pct AS( 
	SELECT p.product_name, p.category, 
	ROUND(SUM(f.revenue_after_promo - f.revenue_before_promo)*100 /SUM(f.revenue_before_promo),2) AS ir_pct
	FROM dim_products p
	JOIN fact_events f ON p.product_code = f.product_code
	GROUP BY p.product_name, p.category
	)
    SELECT product_name, category, ir_pct 
    FROM Ir_pct
    ORDER BY ir_pct DESC
    LIMIT 5;