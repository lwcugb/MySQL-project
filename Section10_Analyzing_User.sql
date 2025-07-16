USE mavenfuzzyfactory;

-- Assignment 1: repeated users and their repeated sessions
SELECT 
	repeat_sessions,
    COUNT(DISTINCT user_id) AS users
FROM
(
	SELECT
		user_id,
		SUM(is_repeat_session) AS repeat_sessions
	FROM website_sessions
	WHERE created_at BETWEEN '2014-01-01' AND '2014-10-31'
	GROUP BY user_id
) AS user_repeat_sessions 
GROUP BY repeat_sessions
ORDER BY repeat_sessions; 

-- Assignment 2: average,min and max days between first and second session
WITH 
	fist_second_login AS(
	SELECT 
		first_session.user_id,
		first_session.website_session_id,
		first_session.created_at AS first_session_date,
		MIN(website_sessions.created_at) AS second_session_date,
		DATEDIFF(MIN(website_sessions.created_at), first_session.created_at) AS days_diff
	FROM
	(
		SELECT 
			user_id,
			website_session_id,
			created_at
		FROM website_sessions
		WHERE created_at BETWEEN '2014-01-01' AND '2014-10-31' AND is_repeat_session = 0
	) AS first_session
	JOIN website_sessions
		ON first_session.user_id = website_sessions.user_id AND
		   first_session.website_session_id < website_sessions.website_session_id AND 
           website_sessions.created_at BETWEEN '2014-01-01' AND '2014-10-31'
	GROUP BY 1, 2, 3
)
SELECT
	AVG(days_diff) AS avg_days_fist_to_second,
    MIN(days_diff) AS MIN_days_fist_to_second,
    MAX(days_diff) AS max_days_fist_to_second
FROM fist_second_login ;

-- Assignment 3: channels for fist and repeat sessions
SELECT 
	CASE WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
         WHEN utm_campaign = 'brand' THEN 'paid_brand'
         WHEN utm_source = 'socialbook' THEN 'paid_social'
         WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_on'
         WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN 'organic_search'
	END AS channel_group,
    COUNT(DISTINCT CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_session,
    COUNT(DISTINCT CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_session
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-04'
GROUP BY 1 ; 

-- Asssignment 4: 
SELECT 
	is_repeat_session,
    COUNT(DISTINCT website_sessions.website_session_id ) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
	COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id ) AS conv_rate,
    SUM(price_usd) / COUNT(DISTINCT website_sessions.website_session_id ) AS rev_per_session
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id  = orders.website_session_id 
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-11-07'
GROUP BY is_repeat_session ;
