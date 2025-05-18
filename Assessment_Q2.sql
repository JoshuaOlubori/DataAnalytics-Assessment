WITH MonthlySavingsTransactions AS (
    -- Calculating the number of savings transactions for each customer in each month
    SELECT
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS transaction_month,
        COUNT(*) AS monthly_transaction_count
    FROM
        savings_savingsaccount
    GROUP BY
        owner_id,
        transaction_month
),
AverageMonthlyTransactions AS (
    -- Calculating the average number of monthly transactions for each customer
    SELECT
        owner_id,
        AVG(monthly_transaction_count) AS avg_monthly_transactions
    FROM
        MonthlySavingsTransactions
    GROUP BY
        owner_id
),
CategorizedCustomers AS (
    -- Categorizing each customer based on their average monthly transaction frequency
    SELECT
        owner_id,
        avg_monthly_transactions,
        CASE
            WHEN avg_monthly_transactions >= 10 THEN 'High Frequency'
            WHEN avg_monthly_transactions >= 3 AND avg_monthly_transactions < 10 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM
        AverageMonthlyTransactions
)
-- Final aggregation: Counting customers and calculate the average of their average monthly transactions per category
SELECT
    frequency_category,
    COUNT(owner_id) AS customer_count,
    ROUND(AVG(avg_monthly_transactions), 1) AS avg_transactions_per_month -- Rounding to 1 decimal place to match expected output
FROM
    CategorizedCustomers
GROUP BY
    frequency_category
;