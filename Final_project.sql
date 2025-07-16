USE mavenfuzzyfactory;

-- Assignment 1: First, I’d like to show our volume growth. Can you pull overall session and order volume, trended by quarter
-- for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it.
SELECT
	YEAR(website_sessions.created_at) AS yr, 
	QUARTER(website_sessions.created_at) AS quat,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2015-01-01'
GROUP BY 1, 2 ;

-- Assignment 2: Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures since we
-- launched, for session to order conversion rate, revenue per order, and revenue per session.
SELECT
	YEAR(website_sessions.created_at) AS yr, 
	QUARTER(website_sessions.created_at) AS quat,
	COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    SUM(price_usd) / COUNT(DISTINCT orders.order_id) AS revenue_per_order,
    SUM(price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2015-01-01'
GROUP BY 1, 2 ;

-- Assignment 3: I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders from Gsearch
-- nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type in?
SELECT
	YEAR(website_sessions.created_at) AS yr, 
	QUARTER(website_sessions.created_at) AS quat,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END) AS gsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END) AS bsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END) AS brand_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN order_id ELSE NULL END) AS organic_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN order_id ELSE NULL END) AS direct_typein_orders
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2015-01-01'
GROUP BY 1, 2 ;

-- Assignment 4: Next, let’s show the overall session to order conversion rate trends for those same channels, by quarter.
-- Please also make a note of any periods where we made major improvements or optimizations.
SELECT
	YEAR(website_sessions.created_at) AS yr, 
	QUARTER(website_sessions.created_at) AS quat,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END) /
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_nonbrand_conv,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END) /
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_nonbrand_conv,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END) / 
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_conv,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN order_id ELSE NULL END) /
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_conv,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN order_id ELSE NULL END) /
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_typein_conv
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2015-01-01'
GROUP BY 1, 2 ;

-- Assignment 5: We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue
-- and margin by product, along with total sales and revenue. Note anything you notice about seasonality.
SELECT 
	YEAR(orders.created_at) AS yr, 
	MONTH(orders.created_at) AS mon,
	SUM( CASE WHEN product_id = 1 THEN order_items.price_usd ELSE NULL END ) AS p1_revenue,
    SUM( CASE WHEN product_id = 1 THEN (order_items.price_usd - order_items.cogs_usd) ELSE NULL END ) AS p1_margin,
    SUM( CASE WHEN product_id = 2 THEN order_items.price_usd ELSE NULL END ) AS p2_revenue,
    SUM( CASE WHEN product_id = 2 THEN (order_items.price_usd - order_items.cogs_usd) ELSE NULL END ) AS p2_margin,
    SUM( CASE WHEN product_id = 3 THEN order_items.price_usd ELSE NULL END ) AS p3_revenue,
    SUM( CASE WHEN product_id = 3 THEN (order_items.price_usd - order_items.cogs_usd) ELSE NULL END ) AS p3_margin,
    SUM( CASE WHEN product_id = 4 THEN order_items.price_usd ELSE NULL END ) AS p4_revenue,
    SUM( CASE WHEN product_id = 4 THEN (order_items.price_usd - order_items.cogs_usd) ELSE NULL END ) AS p4_margin,
    COUNT(DISTINCT orders.order_id) AS total_orders,
    SUM(order_items.price_usd) AS total_revenue
FROM orders
LEFT JOIN order_items
	ON orders.order_id = order_items.order_id
WHERE orders.created_at < '2015-03-01'
GROUP BY 1, 2 ;

-- Assignment 6: Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to the /products
-- page, and show how the % of those sessions clicking through another page has changed over time, along with
-- a view of how conversion from /products to placing an order has improved.
SELECT 
	YEAR(created_at) AS yr, 
	MONTH(created_at) AS mon,
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) /
    COUNT(DISTINCT website_session_id) AS product_clickthrough_rate,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS product_to_order_rate
FROM
(
	SELECT
		pv1.website_session_id,
        pv1.created_at,
		pv2.pageview_url,
        orders.order_id
	FROM website_pageviews AS pv1
	LEFT JOIN website_pageviews AS pv2
		ON pv1.website_session_id = pv2.website_session_id AND pv1.website_pageview_id < pv2.website_pageview_id
	LEFT JOIN orders
		ON pv1.website_session_id = orders.website_session_id
	WHERE  pv1.created_at < '2015-03-01' AND pv1.pageview_url = '/products'
) AS product_view
GROUP BY 1,2;

-- Assignment 7: We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross sell
-- item). Could you please pull sales data since then, and show how well each product cross sells from one another?
WITH
primarry_cross_table AS ( 
	SELECT 
		ot1.primary_product_id AS primary_pd_id,
		ot2.product_id AS cross_pd_id,
		COUNT(DISTINCT ot1.order_id) AS orders
	FROM orders AS ot1
	LEFT JOIN  order_items AS ot2
		ON ot1.order_id = ot2.order_id AND ot2.is_primary_item = 0
	WHERE ot1.created_at > '2014-12-05'
	GROUP BY 1, 2
)
SELECT 
	primary_pd_id,
    cross_pd_id,
    orders,
    SUM(orders) OVER(PARTITION BY primary_pd_id) AS total_order,
    orders / SUM(orders) OVER(PARTITION BY primary_pd_id) AS cross_total_percent
FROM primarry_cross_table;

-- Note the difference below (where to put the ot2.is_primary_item = 0 is very important here)
-- The conditions need to run before join should be put in the 'JOIN ON' cluase
SELECT 
    ot1.primary_product_id AS primary_pd_id,
    -- COUNT(DISTINCT ot1.order_id) AS total_orders
    ot2.product_id AS cross_pd_id,
    COUNT(DISTINCT ot1.order_id) AS orders
FROM orders AS ot1
LEFT JOIN  order_items AS ot2
	ON ot1.order_id = ot2.order_id 
WHERE ot1.created_at > '2014-12-05' AND ot2.is_primary_item = 0
GROUP BY 1, 2;

-- Assignment 8: In addition to telling investors about what we’ve already achieved, let’s show them that we still have plenty of
-- gas in the tank. Based on all the analysis you’ve done, could you share some recommendations and
-- opportunities for us going forward? No right or wrong answer here I’d just like to hear your perspective!








