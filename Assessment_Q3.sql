WITH LastInflowDates AS (
    -- Finding the date of the most recent successful inflow transaction for each plan
    SELECT
        plan_id,
        MAX(transaction_date) AS last_inflow_date
    FROM
        savings_savingsaccount
    WHERE
        confirmed_amount > 0 -- Filtering for inflow transactions
    GROUP BY
        plan_id
)
SELECT
    pp.id AS plan_id,
    pp.owner_id,
    CASE
        WHEN pp.is_regular_savings = 1 THEN 'Savings'
        WHEN pp.is_a_fund = 1 THEN 'Investment'
        ELSE 'Other'
    END AS type,
    COALESCE(lid.last_inflow_date, pp.created_on) AS last_transaction_date, -- Using last inflow date or creation date if no inflow
    DATEDIFF(CURRENT_DATE(), COALESCE(lid.last_inflow_date, pp.created_on)) AS inactivity_days -- Calculating days since last inflow or creation
FROM
    plans_plan pp
LEFT JOIN
    LastInflowDates lid ON pp.id = lid.plan_id
WHERE
    pp.status_id = 1 -- Filtering for active plans 
    AND (pp.is_regular_savings = 1 OR pp.is_a_fund = 1) -- Filtering for savings or investment plans
    AND DATEDIFF(CURRENT_DATE(), COALESCE(lid.last_inflow_date, pp.created_on)) > 365; -- Filtering for plans with no inflow in the last 365 days