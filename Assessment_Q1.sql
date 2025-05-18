SELECT
    uc.id AS owner_id,
    CONCAT(uc.first_name,' ', uc.last_name) AS name,
    COUNT(DISTINCT CASE WHEN pp.is_regular_savings = 1 THEN pp.id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN pp.is_a_fund = 1 THEN pp.id END) AS investment_count,
    SUM(ss.confirmed_amount) / 100 AS total_deposits -- Converting amount from kobo to naira
FROM
    users_customuser uc
LEFT JOIN
    savings_savingsaccount ss ON uc.id = ss.owner_id
LEFT JOIN
    plans_plan pp ON ss.plan_id = pp.id
WHERE
    ss.confirmed_amount > 0 -- Filtering for transactions where money was actually deposited
GROUP BY
    uc.id, CONCAT(uc.first_name,' ', uc.last_name)
HAVING
    COUNT(DISTINCT CASE WHEN pp.is_regular_savings = 1 THEN pp.id END) > 0 -- Ensuring the user has at least one funded regular savings plan
    AND COUNT(DISTINCT CASE WHEN pp.is_a_fund = 1 THEN pp.id END) > 0 -- Ensuring the user has at least one funded investment plan
ORDER BY
    total_deposits DESC;