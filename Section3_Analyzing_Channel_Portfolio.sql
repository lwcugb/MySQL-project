USE mavenfuzzyfactory;

-- Assignment 1: weekly trend of gsearch and bsearch sessions (channel portfolios)
SELECT 
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(CASE WHEN utm_source ='gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(CASE WHEN utm_source ='bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions
WHERE created_at > '2012-08-22' AND created_at < '2012-11-30' AND utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at) ;

-- Assignment 2: compare gsearch and bsearch regarding the percentage of traffic coming from mobile
SELECT 
	utm_source,
    COUNT(DISTINCT website_session_id ) AS sessions,
    COUNT(CASE WHEN device_type ='mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(CASE WHEN device_type ='mobile' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id ) AS pct_mobile
FROM website_sessions
WHERE created_at > '2012-08-22' AND created_at < '2012-11-30' AND utm_campaign = 'nonbrand' AND utm_source IN ('gsearch', 'bsearch')
GROUP BY utm_source ;

-- Assignment 3: sessions to order conversion rate for gsearch and bsearch further separating to device type
SELECT 
	device_type,
	utm_source,
    COUNT(DISTINCT website_sessions.website_session_id ) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
	COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id ) AS conv_rate
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id  = orders.website_session_id 
WHERE website_sessions.created_at > '2012-08-22' AND website_sessions.created_at < '2012-09-19' AND utm_campaign = 'nonbrand'
GROUP BY device_type, utm_source ;

-- Assignment 4: weekly trend of gsearch and bsearch sessions by device types after bidding down bsearch nonbrand on DEC. 2nd.
SELECT 
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(CASE WHEN utm_source ='gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS g_desktop_sessions,
    COUNT(CASE WHEN utm_source ='bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS b_desktop_sessions,
    COUNT(CASE WHEN utm_source ='bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) / 
    COUNT(CASE WHEN utm_source ='gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS b_pct_g_desktop,
    COUNT(CASE WHEN utm_source ='gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS g_mobile_sessions,
    COUNT(CASE WHEN utm_source ='bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS b_mobile_sessions,
    COUNT(CASE WHEN utm_source ='bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) / 
    COUNT(CASE WHEN utm_source ='gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS b_pct_g_mobile
FROM website_sessions
WHERE created_at > '2012-11-04' AND created_at < '2012-12-23' AND utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at) ;


-- Assignment 5: monthly trend of organic search, direct type in, and paid brand sessions as well as their percentage relative to paid nonbrand sessions
SELECT 
	YEAR(created_at) AS yr,
    MONTH(created_at) AS moths,
    COUNT(CASE WHEN utm_source IS NOT NULL AND utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS nonbrand,
    COUNT(CASE WHEN utm_source IS NOT NULL AND utm_campaign = 'brand' THEN website_session_id ELSE NULL END) AS brand,
    COUNT(CASE WHEN utm_source IS NOT NULL AND utm_campaign = 'brand' THEN website_session_id ELSE NULL END) / 
    COUNT(CASE WHEN utm_source IS NOT NULL AND utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS brand_pct_of_nonbrand,
    COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END) AS direct,
    COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END) /
    COUNT(CASE WHEN utm_source IS NOT NULL AND utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS direct_pct_of_nonbrand,
    COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS organic,
    COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) /
    COUNT(CASE WHEN utm_source IS NOT NULL AND utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS organic_pct_of_nonbrand
FROM website_sessions
WHERE created_at > '2012-03-01' AND created_at < '2012-12-23'
GROUP BY YEAR(created_at), MONTH(created_at) ;





