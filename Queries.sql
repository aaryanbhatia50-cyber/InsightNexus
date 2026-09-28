-- What is the total actual sales across all stores and dates?

SELECT 
	SUM(sales) AS total_sales
FROM insight_predictions;

-- What is the average actual sales per record?

SELECT
	AVG(sales) AS average_sales
FROM insight_predictions;

-- What is the total predicted sales across all stores and dates?

SELECT
	SUM(predicted_sales) AS total_predicted_sales
FROM insight_predictions;

-- How many unique stores are present in the dataset?

SELECT
	COUNT (DISTINCT store) AS unique_stores
FROM insight_predictions;

-- What is the average prediction error across all records?

SELECT
	AVG(absolute_error) AS avg_prediction_error
FROM insight_predictions;

-- Which 10 stores have the highest total actual sales?

SELECT
	store,
	SUM(sales) AS highest_total_sales
FROM insight_predictions
GROUP BY store
ORDER BY highest_total_sales DESC
LIMIT 10;

-- Which 10 stores have the lowest total actual sales?

SELECT
	store,
	SUM(sales) AS lowest_total_sales
FROM insight_predictions
GROUP BY store
ORDER BY lowest_total_sales ASC
LIMIT 10;

-- What is the average actual sales for each store?

SELECT
	store,
	AVG(sales) AS avg_total_sales
FROM insight_predictions
GROUP BY store
ORDER BY avg_total_sales DESC;

-- Which 10 stores have the highest average prediction error?

SELECT
    store,
    AVG(absolute_error) AS avg_prediction_error
FROM insight_predictions
GROUP BY store
ORDER BY avg_prediction_error DESC
LIMIT 10;

-- What percentage of total sales is contributed by each store?

SELECT
	store,
	SUM(sales) /
	(
		SELECT SUM(sales)
		FROM insight_predictions
	) * 100 AS perct_total_sales
FROM insight_predictions
GROUP BY store
ORDER BY perct_total_sales DESC;

-- What is the total sales for each year?

SELECT
	EXTRACT(YEAR FROM date) AS year,
	SUM(sales) AS total_sales
FROM insight_predictions
GROUP BY year
ORDER BY year;

-- What is the total sales for each month?

SELECT
	EXTRACT(MONTH FROM date) AS month,
	SUM(sales) AS total_sales
FROM insight_predictions
GROUP BY month
ORDER BY month;

-- Which day of the week generates the highest total sales?

SELECT
	EXTRACT(DOW FROM date) AS day_of_week,
	SUM(sales) AS total_sales
FROM insight_predictions
GROUP BY day_of_week
ORDER BY day_of_week;

-- Which stores have an average sales value higher than the overall average sales?

SELECT
	store,
	AVG(sales) AS avg_sales 
FROM insight_predictions
GROUP BY store
HAVING AVG(sales) > (
	SELECT AVG(sales)
	FROM insight_predictions
);

-- Which stores contribute more than 1% of the total sales?

SELECT
    store,
    SUM(sales) / (
        SELECT SUM(sales)
        FROM insight_predictions
    ) * 100 AS pct_contribution
FROM insight_predictions
GROUP BY store
HAVING (
    SUM(sales) / (
        SELECT SUM(sales)
        FROM insight_predictions
    ) * 100
) > 1
ORDER BY pct_contribution DESC;

-- What is the monthly sales growth compared with the previous month?

WITH monthly_sales AS (
    SELECT
        EXTRACT(MONTH FROM date) AS month,
        SUM(sales) AS monthly_sales
    FROM insight_predictions
    GROUP BY month
)
SELECT
    month,
    monthly_sales,
    LAG(monthly_sales) OVER (ORDER BY month) AS previous_month_sales,
    ROUND(
        (
            (monthly_sales - LAG(monthly_sales) OVER (ORDER BY month))
            / LAG(monthly_sales) OVER (ORDER BY month)
        ) * 100,
        2
    ) AS growth_percentage
FROM monthly_sales
ORDER BY month;

-- Which 3 stores rank highest in total sales within each year?

WITH store_sales AS (
    SELECT
        EXTRACT(YEAR FROM date) AS year,
        store,
        SUM(sales) AS total_sales
    FROM insight_predictions
    GROUP BY year, store
),
ranked_stores AS (
    SELECT
        year,
        store,
        total_sales,
        RANK() OVER (
            PARTITION BY year
            ORDER BY total_sales DESC
        ) AS sales_rank
    FROM store_sales
)
SELECT
    year,
    store,
    total_sales,
    sales_rank
FROM ranked_stores
WHERE sales_rank <= 3
ORDER BY year, sales_rank;

-- What percentage of predictions were over-predictions, under-predictions, and exact predictions?

SELECT
    COUNT(*) AS total_predictions,

    COUNT(
        CASE
            WHEN prediction_status = 'Over Prediction' THEN 1
        END
    ) * 100.0 / COUNT(*) AS over_predictions,

    COUNT(
        CASE
            WHEN prediction_status = 'Under Prediction' THEN 1
        END
    ) * 100.0 / COUNT(*) AS under_predictions

FROM insight_predictions;

-- Which store types have the highest total sales?

SELECT
	s.storetype,
	SUM(i.sales) AS total_sales
FROM insight_predictions AS i
JOIN stores AS s
	ON i.store = s.store
GROUP BY s.storetype
ORDER BY total_sales DESC;

-- What is the average prediction error for each store type?

SELECT
	s.storetype,
	AVG(i.absolute_error) AS avg_pred_error
FROM insight_predictions AS i
JOIN stores AS s
	ON i.store = s.store
GROUP BY s.storetype;

-- Which store types have an average prediction error greater than the overall average prediction error?

SELECT
	s.storetype,
	AVG(i.absolute_error) AS avg_pred_error
FROM insight_predictions AS i
JOIN stores AS s
	ON i.store = s.store
GROUP BY s.storetype
HAVING AVG(i.absolute_error) > (
	SELECT
	AVG(absolute_error)
	FROM insight_predictions
);

-- For each store type, what percentage of its predictions were over-predictions?

SELECT
	s.storetype,
	COUNT (*) AS total_predcitions,
	COUNT (
		CASE WHEN i.prediction_status = 'Over Prediction' THEN 1
	END) * 100.0 / COUNT (*) AS over_predictions
FROM insight_predictions AS i
JOIN stores AS s
	ON i.store = s.store
GROUP BY s.storetype;

-- Rank the stores by total sales within each store type.

WITH store_sales AS (
    SELECT
        s.storetype,
        i.store,
        SUM(i.sales) AS total_sales
    FROM insight_predictions AS i
    JOIN stores AS s
        ON i.store = s.store
    GROUP BY s.storetype, i.store
)
SELECT
    storetype,
    store,
    total_sales,
    RANK() OVER (
        PARTITION BY storetype
        ORDER BY total_sales DESC
    ) AS sales_rank
FROM store_sales;

-- Which stores have both high total sales and high average prediction error within their respective store types?

WITH store_sales AS (
    SELECT
        s.storetype,
        i.store,
        SUM(i.sales) AS total_sales,
        AVG(i.absolute_error) AS avg_prediction_error
    FROM insight_predictions AS i
    JOIN stores AS s
        ON i.store = s.store
    GROUP BY s.storetype, i.store
),
type_average AS (
    SELECT
        storetype,
        AVG(total_sales) AS avg_type_sales,
        AVG(avg_prediction_error) AS avg_type_error
    FROM store_sales
    GROUP BY storetype
)
SELECT
    s.storetype,
    s.store,
    s.total_sales,
    s.avg_prediction_error
FROM store_sales AS s
JOIN type_average AS t
    ON s.storetype = t.storetype
WHERE s.total_sales > t.avg_type_sales
  AND s.avg_prediction_error > t.avg_type_error
ORDER BY s.total_sales DESC;

-- For each store type, find the top 3 stores by total sales.

WITH store_sales AS (
    SELECT
        s.storetype,
        i.store,
        SUM(i.sales) AS total_sales
    FROM insight_predictions AS i
    JOIN stores AS s
        ON i.store = s.store
    GROUP BY s.storetype, i.store
),
ranked_stores AS (
    SELECT
        storetype,
        store,
        total_sales,
        RANK() OVER (
            PARTITION BY storetype
            ORDER BY total_sales DESC
        ) AS sales_rank
    FROM store_sales
)
SELECT
    storetype,
    store,
    total_sales,
    sales_rank
FROM ranked_stores
WHERE sales_rank <= 3
ORDER BY storetype, sales_rank;

-- For each store, calculate the percentage of predictions that were within 10% of the actual sales.

SELECT
	store,
	COUNT (*) AS total_predictions,
	COUNT (
		CASE WHEN ABS(sales-predicted_sales) <= sales *0.10
		THEN 1
		END
	) AS within_10_percent,
	COUNT(
			CASE
				WHEN ABS(sales-predicted_sales) <= sales * 0.10
				THEN 1
			END
	) * 100.0/ COUNT(*) AS accuracy_wiithin_10_percent
FROM insight_predictions
GROUP BY store;

-- For each store, calculate its monthly total sales and its cumulative sales over time.

WITH monthly_sales AS (
    SELECT
        EXTRACT(YEAR FROM date) AS year,
        EXTRACT(MONTH FROM date) AS month,
        store,
        SUM(sales) AS total_sales
    FROM insight_predictions
    GROUP BY
        EXTRACT(YEAR FROM date),
        EXTRACT(MONTH FROM date),
        store
)
SELECT
    year,
    month,
    store,
    total_sales,
    SUM(total_sales) OVER (
        PARTITION BY store
        ORDER BY year, month
    ) AS cumulative_sales
FROM monthly_sales;

-- For each store, identify its total sales, average prediction error, and the percentage of predictions that were within 10% of actual sales. Then rank the stores by their total sales.

WITH store_sales AS (
	SELECT
		store,
		SUM(sales) AS total_sales,
		AVG(absolute_error) AS avg_prediction_error,
		COUNT (*) AS total_predictions,
		COUNT (
				CASE WHEN ABS(sales-predicted_sales) <= sales *0.10
			THEN 1
			END
		) AS within_10_percent
	FROM insight_predictions
	GROUP BY store
)
SELECT
	store,
	total_sales,
	avg_prediction_error,
	within_10_percent * 100.0/ total_predictions AS accuracy_within_10_percent,
	RANK() OVER(ORDER BY total_sales) AS sales_rank
FROM store_sales;

-- Find the stores whose total sales are above the overall average store sales, but whose average prediction error is also above the overall average prediction error.

WITH store_sales AS (
	SELECT
		store,
		SUM(sales) AS total_sales,
		AVG(absolute_error) AS avg_prediction_error
		FROM insight_predictions
		GROUP BY store
),
overall_average AS (
	SELECT
		AVG(total_sales) AS overall_avg_sales,
		AVG(avg_prediction_error) AS overall_avg_error
		FROM store_sales
)
SELECT
    s.store,
    s.total_sales,
    s.avg_prediction_error
FROM store_sales AS s
CROSS JOIN overall_average AS o
WHERE s.total_sales > o.overall_avg_sales
  AND s.avg_prediction_error > o.overall_avg_error;

/* For each store type, identify the top 3 stores by total sales. 
 	For those stores, calculate their average prediction error, 
	the percentage of predictions within 10% of actual sales,
	their rank within the store type, and compare each store's 
	total sales with the average total sales of its store type.
	Return only stores whose total sales are above their store-type average.
*/

WITH store_sales AS (
    SELECT
        s.storetype,
        i.store,
        SUM(i.sales) AS total_sales,
        AVG(i.absolute_error) AS avg_prediction_error,
        COUNT(*) AS total_predictions,
        COUNT(
            CASE
                WHEN ABS(i.sales - i.predicted_sales) <= i.sales * 0.10
                THEN 1
            END
        ) AS within_10_percent
    FROM insight_predictions AS i
    JOIN stores AS s
        ON i.store = s.store
    GROUP BY s.storetype, i.store
),

type_average AS (
    SELECT
        storetype,
        AVG(total_sales) AS avg_total_sales
    FROM store_sales
    GROUP BY storetype
),

ranked_stores AS (
    SELECT
        storetype,
        store,
        total_sales,
        avg_prediction_error,
        total_predictions,
        within_10_percent,
        RANK() OVER ( PARTITION BY storetype ORDER BY total_sales DESC) AS sales_rank
    FROM store_sales
)

SELECT
    r.storetype,
    r.store,
    r.total_sales,
    r.avg_prediction_error,
    r.within_10_percent * 100.0 / r.total_predictions AS accuracy_within_10_percent,
    r.sales_rank,
    t.avg_total_sales
FROM ranked_stores AS r
JOIN type_average AS t
    ON r.storetype = t.storetype
WHERE r.sales_rank <= 3
  AND r.total_sales > t.avg_total_sales;