CREATE TABLE ab_test (
serial_no INT,
user_id INT,
test_group VARCHAR(6),
converted VARCHAR(6),
total_ads INT,
most_ads_day VARCHAR(10),
most_ads_hour INT
);

--Number of rows
SELECT COUNT(*) AS total_rows
FROM ab_test;

-- Two test groups present
SELECT 
    test_group,
	COUNT(*) AS users,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)
AS pct_of_total
FROM ab_test
GROUP BY test_group;

-- Converted groups
SELECT converted, COUNT(*)
FROM ab_test
GROUP BY converted

-- Do People who see ads have high conversion rate?
SELECT 
    test_group,
	COUNT(*) AS total_users,
	SUM(CASE converted WHEN 'True' THEN 1 ELSE 0 END) AS converted_users,
	ROUND(
        SUM(CASE converted WHEN 'True' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
		2
	) AS conversion_rate_pct
FROM ab_test
GROUP BY test_group;

-- People seeing more ads are more likely to get converted?
SELECT
    test_group,
	ROUND(AVG(total_ads), 1) AS avg_ads_seen,
	MIN(total_ads) AS min_ads,
	MAX(total_ads) AS max_ads,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_ads)
AS median_ads
FROM ab_test
GROUP BY test_group;

-- Conversion rate by ad volume
SELECT
    CASE
	    WHEN total_ads BETWEEN 1 AND 10 THEN '1-10 ads'
		WHEN total_ads BETWEEN 11 AND 50 THEN '11-50 ads'
		WHEN total_ads BETWEEN 51 AND 100 THEN '51-100 ads'
		ELSE '100+ ads'
	END AS ads_bucket,
	COUNT(*) AS users,
	ROUND(
        SUM(CASE WHEN converted = 'True'
		THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
		2
	) AS conversion_rate_pct
FROM ab_test
GROUP BY ads_bucket
ORDER BY ads_bucket

-- Best day and hour to show ads
SELECT 
    most_ads_day,
	COUNT(*) AS users,
	SUM(CASE WHEN converted = 'True' THEN 1 ELSE 0 END
	    ) AS conversions,
	ROUND(SUM(CASE WHEN converted = 'True' THEN 1 ELSE 0 END
	          ) * 100.0 / COUNT(*), 
	      2) AS conversion_rate_pct
FROM ab_test
WHERE test_group = 'ad'
GROUP BY most_ads_day
ORDER BY conversion_rate_pct DESC;

SELECT 
    most_ads_hour,
	COUNT(*) AS users,
	SUM(CASE WHEN converted = 'True' THEN 1 ELSE 0 END
	    ) AS conversions,
	ROUND(SUM(CASE WHEN converted = 'True' THEN 1 ELSE 0 END
	          ) * 100.0 / COUNT(*), 
	      2) AS conversion_rate_pct
FROM ab_test
WHERE test_group = 'ad'
GROUP BY most_ads_hour
ORDER BY conversion_rate_pct DESC;

-- Summary
SELECT
    test_group,
	COUNT(*) AS total_users,
	SUM(CASE WHEN converted = 'True' THEN 1 ELSE 0 END
	    ) AS conversions,
	ROUND(SUM(CASE WHEN converted = 'True' THEN 1 ELSE 0 END
	          ) * 100.0 / COUNT(*),
		  2) AS conversion_rate_pct,
    ROUND(AVG(total_ads), 1) AS avg_ads_seen
FROM ab_test
GROUP BY test_group;