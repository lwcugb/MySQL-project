USE mavenfuzzyfactory;

-- Assignment 1: monthly and weekly trend for sessions and orders
SELECT 
	YEAR(website_sessions.created_at) AS yr, 
    MONTH(website_sessions.created_at) AS moths,
    COUNT(DISTINCT website_sessions.website_session_id ) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
	COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id ) AS conv_rate
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id  = orders.website_session_id 
WHERE website_sessions.created_at < '2013-01-01'
GROUP BY YEAR(website_sessions.created_at), MONTH(website_sessions.created_at);

SELECT 
	MIN(DATE(website_sessions.created_at)) AS week_start_date, 
    COUNT(DISTINCT website_sessions.website_session_id ) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
	COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id ) AS conv_rate
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id  = orders.website_session_id 
WHERE website_sessions.created_at < '2013-01-01'
GROUP BY YEARWEEK(website_sessions.created_at);


-- Assignment 2: average website sessionss by hour of day(rows) and by day of week (columns)
SELECT
	hr, 
    AVG(CASE WHEN wkday = 0 THEN website_session ELSE NULL END) AS mon,
	AVG(CASE WHEN wkday = 1 THEN website_session ELSE NULL END) AS tue,
	AVG(CASE WHEN wkday = 2 THEN website_session ELSE NULL END) AS wed,
	AVG(CASE WHEN wkday = 3 THEN website_session ELSE NULL END) AS thu,
	AVG(CASE WHEN wkday = 4 THEN website_session ELSE NULL END) AS fri,
	AVG(CASE WHEN wkday = 5 THEN website_session ELSE NULL END) AS sat,
	AVG(CASE WHEN wkday = 6 THEN website_session ELSE NULL END) AS sun
FROM 
(
	SELECT 
		DATE(created_at) AS created_date,
        WEEKDAY(created_at) AS wkday,
		HOUR(created_at) AS hr,
		COUNT(DISTINCT website_session_id) AS website_session
	FROM website_sessions
	WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
	GROUP BY 1, 2, 3
) AS daily_hourly_sessions 
GROUP BY hr
ORDER BY hr;






