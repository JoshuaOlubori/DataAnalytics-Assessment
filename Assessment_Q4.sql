WITH AggregatedFundedSavings AS (
    -- Aggregating total funded savings transactions and value per customer
    SELECT
        owner_id,
        COUNT(id) AS total_transactions,
        SUM(confirmed_amount) AS total_transaction_value_kobo
    FROM
        savings_savingsaccount
    WHERE
        confirmed_amount > 0 -- Considering only successful inflows for transaction volume
    GROUP BY
        owner_id
)
SELECT
    uc.id AS customer_id,
    CONCAT(uc.first_name,' ', uc.last_name) AS name,
    GREATEST(1, TIMESTAMPDIFF(MONTH, uc.date_joined, CURRENT_DATE())) AS tenure_months, -- Calculating tenure in full months, ensuring a minimum of 1 to avoid division by zero
    COALESCE(afs.total_transactions, 0) AS total_transactions, -- Total funded savings transactions (0 if none)
    -- Calculating Estimated CLV using the formula: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction
    ROUND(((COALESCE(afs.total_transaction_value_kobo, 0) / 100) / GREATEST(1, TIMESTAMPDIFF(MONTH, uc.date_joined, CURRENT_DATE()))) * 12 * 0.001, 2) AS estimated_clv -- Converting kobo value to Naira before applying profit margin and rounding to 2 decimal places to match expected output
FROM
    users_customuser uc
LEFT JOIN
    AggregatedFundedSavings afs ON uc.id = afs.owner_id
ORDER BY
    estimated_clv DESC;