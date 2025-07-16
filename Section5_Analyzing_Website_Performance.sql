USE mavenfuzzyfactory; 

-- most viewed website page
SELECT 
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY sessions DESC ;

-- find top entry/landing page
-- 1, find the pageview_id of a landing page for each website_session
DROP TEMPORARY TABLE IF EXISTS first_pv_session_id;
CREATE TEMPORARY TABLE first_pv_session_id
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS first_pv_id
FROM website_pageviews
GROUP BY website_session_id;
-- 2, join back to webpageview and count the website_session_id
SELECT 
	website_pageviews.pageview_url AS landing_page_url,
    COUNT(DISTINCT first_pv_session_id.website_session_id) as sessions_hitting_page
FROM first_pv_session_id
LEFT JOIN website_pageviews
	ON first_pv_session_id.first_pv_id = website_pageviews.website_pageview_id
WHERE website_pageviews.created_at < '2012-06-12'
GROUP BY  website_pageviews.pageview_url
ORDER BY sessions_hitting_page; 

-- %%%%calculate the bounce rate (website_sessions with only one click on the landing page and leave / website_sessions with one or more clicks)
-- 1, find the pageview_id of a landing page for each website_session
DROP TEMPORARY TABLE IF EXISTS first_pv_session_id;
CREATE TEMPORARY TABLE first_pv_session_id
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS first_pv_id
FROM website_pageviews
GROUP BY website_session_id;

-- 2, join back to webpageview and select the /home landing page
DROP TEMPORARY TABLE IF EXISTS first_pv_session;
CREATE TEMPORARY TABLE first_pv_session
SELECT 
	first_pv_session_id.website_session_id,
    first_pv_session_id.first_pv_id,
	website_pageviews.pageview_url AS landing_page_url
FROM first_pv_session_id
LEFT JOIN website_pageviews
	ON first_pv_session_id.first_pv_id = website_pageviews.website_pageview_id
WHERE website_pageviews.created_at < '2012-06-14' and website_pageviews.pageview_url = '/home';

-- 3, Crate a table contains whether website sessions with /home landing page only have one click
DROP TEMPORARY TABLE IF EXISTS website_sessions_bounce;
CREATE TEMPORARY TABLE website_sessions_bounce
SELECT 
	first_pv_session.website_session_id,
    COUNT(DISTINCT website_pageviews.website_pageview_id) AS pv_count
FROM first_pv_session
LEFT JOIN website_pageviews
	ON first_pv_session.website_session_id = website_pageviews.website_session_id
GROUP BY first_pv_session.website_session_id
HAVING pv_count = 1; 

-- 4 join landing page table with bounce table and calculate the bounce rate
SELECT 
	-- first_pv_session.website_session_id,
    -- website_sessions_bounce.website_session_id
	COUNT(DISTINCT first_pv_session.website_session_id) AS sessions,
    COUNT(DISTINCT website_sessions_bounce.website_session_id) AS bounce_sessions,
    COUNT(DISTINCT website_sessions_bounce.website_session_id) / COUNT(DISTINCT first_pv_session.website_session_id) AS bounce_rate
FROM first_pv_session
LEFT JOIN website_sessions_bounce
	ON first_pv_session.website_session_id = website_sessions_bounce.website_session_id ; 

-- %%%%%%compare bounce rate of /home and a new landing page /lander-1
-- 1, find the pageview_id of a landing page for each website_session
DROP TEMPORARY TABLE IF EXISTS first_pv_session_id;
CREATE TEMPORARY TABLE first_pv_session_id
SELECT 
	website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pv_id
FROM website_pageviews
INNER JOIN website_sessions
	ON website_sessions.website_session_id = website_pageviews.website_session_id
    AND website_sessions.utm_source = 'gsearch'       -- note: this could be put in JOIN conditions too
    AND website_sessions.utm_campaign = 'nonbrand'
WHERE 
	website_sessions.created_at >= 
		(
		SELECT MIN(created_at) 
        FROM website_pageviews 
        WHERE pageview_url = '/lander-1' AND created_at IS NOT NULL 
        ) AND 
    website_sessions.created_at < '2012-07-28' AND 
    website_pageviews.pageview_url IN ('/home', '/lander-1')
GROUP BY website_sessions.website_session_id;

-- 2, join back to webpageview and select the /home landing page
DROP TEMPORARY TABLE IF EXISTS first_pv_session;
CREATE TEMPORARY TABLE first_pv_session
SELECT 
	first_pv_session_id.website_session_id,
    first_pv_session_id.first_pv_id,
	website_pageviews.pageview_url AS landing_page_url
FROM first_pv_session_id
LEFT JOIN website_pageviews
	ON first_pv_session_id.first_pv_id = website_pageviews.website_pageview_id;
-- SELECT * FROM first_pv_session;

-- 3, Crate a table contains whether website sessions with /home landing page only have one click
DROP TEMPORARY TABLE IF EXISTS website_sessions_bounce;
CREATE TEMPORARY TABLE website_sessions_bounce
SELECT 
	first_pv_session.website_session_id,
    COUNT(DISTINCT website_pageviews.website_pageview_id) AS pv_count
FROM first_pv_session
LEFT JOIN website_pageviews
	ON first_pv_session.website_session_id = website_pageviews.website_session_id
GROUP BY first_pv_session.website_session_id
HAVING pv_count = 1; 
-- SELECT * FROM website_sessions_bounce;

-- 4 join landing page table with bounce table and calculate the bounce rate
SELECT 
	-- first_pv_session.website_session_id,
    -- website_sessions_bounce.website_session_id,
    -- first_pv_session.landing_page_url,
	COUNT(DISTINCT first_pv_session.website_session_id) AS sessions,
    COUNT(DISTINCT website_sessions_bounce.website_session_id) AS bounce_sessions,
    COUNT(DISTINCT website_sessions_bounce.website_session_id) / COUNT(DISTINCT first_pv_session.website_session_id) AS bounce_rate
FROM first_pv_session
LEFT JOIN website_sessions_bounce
	ON first_pv_session.website_session_id = website_sessions_bounce.website_session_id 
GROUP BY first_pv_session.landing_page_url ; 

-- %%%calculate the weekly trend of landing page traffic and bounce rate
-- 1, find the pageview_id of a landing page for each website_session
DROP TEMPORARY TABLE IF EXISTS first_pv_session_id;
CREATE TEMPORARY TABLE first_pv_session_id
SELECT 
	website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pv_id
FROM website_pageviews
INNER JOIN website_sessions
	ON website_sessions.website_session_id = website_pageviews.website_session_id
    AND website_sessions.utm_source = 'gsearch'       -- note: this could be put in JOIN conditions too
    AND website_sessions.utm_campaign = 'nonbrand'
WHERE 
	website_sessions.created_at >= '2012-06-01' AND 
    website_sessions.created_at < '2012-08-31'  AND 
    website_pageviews.pageview_url IN ('/home', '/lander-1')
GROUP BY website_sessions.website_session_id;

-- 2, join back to webpageview and get the landing page timeseries
DROP TEMPORARY TABLE IF EXISTS first_pv_session;
CREATE TEMPORARY TABLE first_pv_session
SELECT 
	website_pageviews.created_at,
    YEAR (website_pageviews.created_at) AS years,
    WEEK (website_pageviews.created_at) AS weeks,
	first_pv_session_id.website_session_id,
    first_pv_session_id.first_pv_id,
	website_pageviews.pageview_url AS landing_page_url
FROM first_pv_session_id
LEFT JOIN website_pageviews
	ON first_pv_session_id.first_pv_id = website_pageviews.website_pageview_id;

-- 3, Crate a table contains whether website sessions with /home landing page only have one click
DROP TEMPORARY TABLE IF EXISTS website_sessions_bounce;
CREATE TEMPORARY TABLE website_sessions_bounce
SELECT 
	first_pv_session.website_session_id,
    COUNT(DISTINCT website_pageviews.website_pageview_id) AS pv_count
FROM first_pv_session
LEFT JOIN website_pageviews
	ON first_pv_session.website_session_id = website_pageviews.website_session_id
GROUP BY first_pv_session.website_session_id
HAVING pv_count = 1; 

-- 4, calculate the weekly trend
SELECT 
	-- years, weeks, landing_page_url,
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_sessions_bounce.website_session_id) / COUNT(DISTINCT first_pv_session.website_session_id) AS bounce_rate,
    COUNT(DISTINCT CASE WHEN landing_page_url = '/home' THEN first_pv_session.website_session_id ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN landing_page_url = '/lander-1' THEN first_pv_session.website_session_id ELSE NULL END) AS lander1_sessions
FROM first_pv_session
LEFT JOIN website_sessions_bounce
	ON first_pv_session.website_session_id = website_sessions_bounce.website_session_id 
GROUP BY years, weeks ;

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% build conversion funnel 
DROP TEMPORARY TABLE IF EXISTS pageview_made;
CREATE TEMPORARY TABLE pageview_made
SELECT 
	website_sessions.created_at,
    website_sessions.website_session_id,
    website_pageviews.pageview_url,
    CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE 0 END AS to_products,
    CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS to_mrfuzzy,
    CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS to_cart,
    CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS to_shipping,
    CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE 0 END AS to_billing,
    CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS to_thankyou
FROM website_sessions
JOIN website_pageviews
	ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE 	website_sessions.utm_source = 'gsearch' AND
		website_sessions.utm_campaign = 'nonbrand' AND
		website_sessions.created_at > '2012-08-05' AND
		website_sessions.created_at < '2012-09-05' ;

SELECT 
	to_products/sessions AS lander_click_rt,
    to_mrfuzzy/to_products AS products_click_rt,
    to_cart/to_mrfuzzy AS mrfuzzy_click_rt,
    to_shipping/to_cart AS cart_click_rt,
    to_billing/to_shipping AS shipping_click_rt,
    to_thankyou/to_billing AS billing_click_rt
FROM
	(
	SELECT 
		COUNT(DISTINCT website_session_id) AS sessions,
		SUM(to_products) AS to_products,
		SUM(to_mrfuzzy) AS to_mrfuzzy,
		SUM(to_cart) AS to_cart,
		SUM(to_shipping) AS to_shipping,
		SUM(to_billing) AS to_billing,
		SUM(to_thankyou) AS to_thankyou
	FROM pageview_made
	) AS pv_count ;

-- %%%%%%%%%%%%%%%%%%%%%%%%billing-2 test results
-- get the date when billing-2 started (2012-09-10)
SELECT MIN(created_at)
FROM website_pageviews
WHERE pageview_url ='/billing-2' ;

SELECT 
	bill_page_url,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id)  AS bill_to_order_rt
FROM 
	(
	SELECT 
		pv1.website_session_id,
		pv1.pageview_url AS bill_page_url,
		orders.order_id AS order_id
	FROM website_pageviews pv1
	LEFT JOIN  orders
		ON pv1.website_session_id = orders.website_session_id
	WHERE pv1.created_at >= '2012-09-10' AND pv1.created_at < '2012-11-10' AND pv1.pageview_url IN ('/billing','/billing-2')
    ) AS bill_order_page
GROUP BY bill_page_url


