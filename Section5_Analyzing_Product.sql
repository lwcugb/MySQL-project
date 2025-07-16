USE mavenfuzzyfactory;

-- Assignment 1: monthly trend of orders, total revenue and total margin
SELECT 
	YEAR(created_at) AS yr, 
    MONTH(created_at) AS mo,
    COUNT(DISTINCT order_id) AS orders,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM orders
WHERE created_at < '2013-01-01'
GROUP BY YEAR(created_at), MONTH(created_at);

-- Assignment 2: monthly trend of orders, conversion rate, revenue per session, product 1 and 2 orders
SELECT 
	YEAR(website_sessions.created_at) AS yr, 
    MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    SUM(price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session,
    COUNT(CASE WHEN primary_product_id = 1 THEN order_id ELSE NULL END) AS product1_orders,
    COUNT(CASE WHEN primary_product_id = 2 THEN order_id ELSE NULL END) AS product2_orders
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2013-04-01' AND website_sessions.created_at > '2012-04-01'
GROUP BY YEAR(website_sessions.created_at), MONTH(website_sessions.created_at);

-- Assignment 3: Product level website pathing: clickthrough rate of /product page 
SELECT 
	time_period,
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS w_next_page,
    COUNT(DISTINCT CASE WHEN pageview_url IS NOT NULL THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_w_next_page,
    COUNT(DISTINCT CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_lovebear,
    COUNT(DISTINCT CASE WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_to_lovebear
FROM
(
	SELECT
		pv1.website_session_id,
		pv2.pageview_url,
		CASE WHEN pv1.created_at < '2013-01-06' THEN 'Pre_product2' ELSE 'Post_product2' END AS time_period 
	FROM website_pageviews AS pv1
	LEFT JOIN website_pageviews AS pv2
		ON pv1.website_session_id = pv2.website_session_id AND pv1.website_pageview_id < pv2.website_pageview_id
	WHERE pv1.created_at > '2012-10-06' AND pv1.created_at < '2013-04-06' AND pv1.pageview_url = '/products' 
) AS product_view
GROUP BY time_period ;

-- Assignment 4: conversion tunnel from each product page until 'thank you for your order'
WITH 
product_tunnel AS (
SELECT 
	product_seen,
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN pageview_url = '/cart' THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN pageview_url = '/shipping' THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN pageview_url = '/billing-2' THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN pageview_url = '/thank-you-for-your-order' THEN website_session_id ELSE NULL END) AS to_thankyou
FROM
(
	SELECT
		pv1.website_session_id,
		pv2.pageview_url,
		CASE WHEN pv1.pageview_url = '/the-original-mr-fuzzy' THEN 'mrfuzzy' ELSE 'lovebear' END AS product_seen
	FROM website_pageviews AS pv1
	LEFT JOIN website_pageviews AS pv2
		ON pv1.website_session_id = pv2.website_session_id AND pv1.website_pageview_id < pv2.website_pageview_id
	WHERE pv1.created_at > '2013-01-06' AND pv1.created_at < '2013-04-10' AND 
		  pv1.pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear')
) AS product_view
GROUP BY product_seen 
)  -- product_tunnel table CTE

SELECT 
	product_seen,
    to_cart / sessions AS product_page_click_rate,
    to_shipping / to_cart AS cart_click_rate,
    to_billing / to_shipping AS shipping_click_rate,
    to_thankyou / to_billing AS billing_click_rate
FROM product_tunnel;

-- Assignment 5: cross-product sell analysis; compare CTR from /cart page, average product per order, average order value and revenue per /cart page view
-- table of pageviews with /cart and following pages
DROP TEMPORARY TABLE IF EXISTS cart_page_click;
CREATE TEMPORARY TABLE cart_page_click
SELECT 
	website_session_id,
	time_period,
    COUNT(DISTINCT CASE WHEN next_cart_page IS NOT NULL THEN website_session_id ELSE NULL END) AS next_page_view
FROM
(
	SELECT
		pv1.website_session_id,
        pv1.pageview_url AS cart_page,
		pv2.pageview_url AS next_cart_page,
		CASE WHEN pv1.created_at < '2013-09-25' THEN 'Pre_cross_sell' ELSE 'Post_cross_sell' END AS time_period 
	FROM website_pageviews AS pv1
	LEFT JOIN website_pageviews AS pv2
		ON pv1.website_session_id = pv2.website_session_id AND pv1.website_pageview_id < pv2.website_pageview_id
	WHERE pv1.created_at >= '2013-08-25' AND pv1.created_at <= '2013-10-25' AND pv1.pageview_url = '/cart' 
) AS cart_view
GROUP BY website_session_id, time_period ;

SELECT 
    time_period,
    COUNT(DISTINCT cart_page_click.website_session_id) AS cart_sessions,
    SUM(next_page_view) AS clickthroughs,
    SUM(next_page_view)/COUNT(DISTINCT cart_page_click.website_session_id) AS cart_ctr,
    SUM(items_purchased) / COUNT(DISTINCT order_id) AS products_per_order,
    SUM(price_usd) / COUNT(DISTINCT order_id) AS aov,
    SUM(price_usd) / COUNT(DISTINCT cart_page_click.website_session_id) AS rev_per_cart_session
FROM cart_page_click
LEFT JOIN orders
	ON cart_page_click.website_session_id = orders.website_session_id
GROUP BY time_period ;

-- Assignment 5: compare conversion rate, average order price value, products per order and revenue per session one month before and after
SELECT 
	time_period,
	COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS conv_rate,
	SUM(price_usd) / COUNT(DISTINCT order_id) AS aov,
	SUM(items_purchased) / COUNT(DISTINCT order_id) AS products_per_order,
	SUM(price_usd) / COUNT(DISTINCT website_session_id) AS revenue_per_session
FROM
(
	SELECT
		CASE WHEN website_sessions.created_at < '2013-12-12' THEN 'Pre_birthday_bear' ELSE 'Post_birthday_bear' END AS time_period ,
        website_sessions.website_session_id,
        order_id,
        items_purchased,
        price_usd
	FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
	WHERE website_sessions.created_at >= '2013-11-12' AND website_sessions.created_at <= '2014-01-12'
) AS website_session_w_order
GROUP BY time_period ;

-- Assignment 7: product refund analysis; 
SELECT
	YEAR(order_items.created_at) AS yr,
    MONTH(order_items.created_at) AS mon,
	COUNT(DISTINCT CASE WHEN product_id =1 THEN order_items.order_id ELSE NULL END) AS p1_orders,
    IFNULL(COUNT(DISTINCT CASE WHEN product_id =1 THEN order_item_refunds.order_id ELSE NULL END) /
    COUNT(DISTINCT CASE WHEN product_id =1 THEN order_items.order_id ELSE NULL END), 0) AS p1_refund_rate,
    
    COUNT(DISTINCT CASE WHEN product_id =2 THEN order_items.order_id ELSE NULL END) AS p2_orders,
    IFNULL(COUNT(DISTINCT CASE WHEN product_id =2 THEN order_item_refunds.order_id ELSE NULL END) /
    COUNT(DISTINCT CASE WHEN product_id =2 THEN order_items.order_id ELSE NULL END), 0) AS p2_refund_rate,
    
    COUNT(DISTINCT CASE WHEN product_id =3 THEN order_items.order_id ELSE NULL END) AS p3_orders,
    IFNULL(COUNT(DISTINCT CASE WHEN product_id =3 THEN order_item_refunds.order_id ELSE NULL END) /
    COUNT(DISTINCT CASE WHEN product_id =3 THEN order_items.order_id ELSE NULL END), 0 ) AS p3_refund_rate,
    
    COUNT(DISTINCT CASE WHEN product_id =4 THEN order_items.order_id ELSE NULL END) AS p4_orders,
    IFNULL(COUNT(DISTINCT CASE WHEN product_id =4 THEN order_item_refunds.order_id ELSE NULL END) /
    COUNT(DISTINCT CASE WHEN product_id =4 THEN order_items.order_id ELSE NULL END), 0 ) AS p4_refund_rate
FROM order_items
LEFT JOIN order_item_refunds
	ON order_items.order_item_id = order_item_refunds.order_item_id
GROUP BY 1, 2 ;





