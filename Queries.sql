-- What is the total actual sales generated during the validation period?

SELECT
    SUM(sales) AS total_sales
FROM insight_predictions;

-- What is the average actual sales per store-day record?
SELECT
    AVG(sales) AS average_sales
FROM insight_predictions;

-- Which 10 stores generated the highest total actual sales during the validation period?
SELECT
    store,
    SUM(sales) AS total_sales
FROM insight_predictions
GROUP BY store
ORDER BY total_sales DESC
LIMIT 10;

-- Which stores have the highest average prediction error?
SELECT
    store,
    AVG(absolute_error) AS average_error
FROM insight_predictions
GROUP BY store
ORDER BY average_error DESC
LIMIT 10;

--What is the sales ranking of each store based on total actual sales?
SELECT
    store,
    SUM(sales) AS total_sales,
    RANK() OVER (
        ORDER BY SUM(sales) DESC
    ) AS sales_rank
FROM insight_predictions
GROUP BY store
ORDER BY sales_rank;