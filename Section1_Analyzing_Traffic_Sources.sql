USE mavenfuzzyfactory;

SELECT
	utm_source, 
    utm_campaign, 
    http_referer,
	COUNT(DISTINCT website_session_id) as sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY utm_source, utm_campaign, http_referer
ORDER BY sessions DESC ;

SELECT
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_order_conv_rt
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-04-14' and utm_source = 'gsearch' and utm_campaign = 'nonbrand';

SELECT 
	-- WEEK(created_at) AS weeks,
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-05-12' and utm_source='gsearch' and utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), WEEK(created_at);

SELECT
	website_sessions.device_type,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_order_conv_rt
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-05-11' and utm_source = 'gsearch' and utm_campaign = 'nonbrand'
GROUP BY website_sessions.device_type;

SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS dtop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_sessions
FROM website_sessions
WHERE created_at > '2012-04-15' and created_at < '2012-06-09' and utm_source='gsearch' and utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), WEEK(created_at);




