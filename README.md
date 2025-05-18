## Q1: High-Value Customers with Multiple Products

I joined the users_customuser, savings_savingsaccount, and plans_plan tables, linking users to their savings transactions and the plans involved. I then filtered these transactions using `WHERE ssa.confirmed_amount > 0` ensuring I consider only 'funded' activity.




Next, I grouped the results by user ID and name to aggregate their financial activity. I obtained the full name using the `CONCAT` function to match the expected output. Within this grouping, I calculated the number of distinct regular savings plans (savings_count) and investment plans (investment_count) that received funded deposits from each user using conditional COUNT(DISTINCT pp.id). At the same time, I summed their confirmed deposit amounts (total_deposits), dividing by 100 to convert from kobo to naira. I rounded this figure to 2 decimal places to ensure the query result match the expected output.




Finally, to isolate the customers who have engaged with both product types through funded transactions, I used a HAVING clause to keep only those groups where both savings_count > 0 and investment_count > 0. The result is then ordered by total_deposits in descending order.




## Q2: Transaction Frequency Analysis

First, I created a CTE called MonthlySavingsTransactions where I calculated the number of savings transactions each customer made in every specific month they were active. The function that first came to mind to do the monthly grouping was `DATE_TRUNC` since I use MSSQL at work. Then I learnt the MYSQL equivalent is to use `DATE_FORMAT(date_column, '%Y-%m')`.




Next, using that monthly data, I built the AverageMonthlyTransactions CTE. For each customer, I averaged their transaction counts across all months they had activity, giving me a single average monthly frequency figure per customer.




Then, in the CategorizedCustomers CTE, I took these average figures and assigned each customer to a 'High', 'Medium', or 'Low' frequency category based on predefined thresholds using a CASE statement. To optimise processing and avoid unnecessary database load, I explicitly defined the conditions for 'High' and 'Medium', allowing the ELSE clause to handle all other cases.




Finally, my last step is a SELECT query on the CategorizedCustomers CTE. I group the results by the assigned frequency category and count how many customers fall into each category while also calculating the average transaction frequency within that category. 




## Q3: Account Inactivity Alert

My first step was creating a CTE called LastInflowDates, where I found the most recent transaction date for each plan that had a confirmed deposit.




Then, I joined this CTE back to the main plans_plan table, ensuring I kept all relevant active savings and investment plans, even those that might never have received a deposit. For each plan, I calculated the number of days since either its last confirmed deposit or, if it never had one, since its creation date.




Finally, I filtered the results to show only those plans where this calculated inactivity period was greater than 365 days, selecting the relevant plan details, the date I used for the calculation, and the inactivity period in days. This provides a list of active plans that appear to be dormant.




Note that I used `COALESCE(lid.last_inflow_date, pp.created_on))` which ensures that in case there is no `lid.last_inflow_date`, `pp.created_on` is used.




## Q4: Customer Lifetime Value (CLV) Estimation




I started with a CTE, AggregatedFundedSavings, where I calculated the total number and sum of confirmed savings transactions for each user. I filtered for amounts greater than zero to focus only on actual money inflows.




Next, I joined this aggregated transaction data to the users_customuser table, ensuring I included all users, even those without funded savings transactions, by using a LEFT JOIN. For each user, I calculated their tenure in months, ensuring it was at least one month, and set their transaction counts and values to zero if they had none.




Finally, I calculated the estimated CLV using a formula that annualises their total funded transaction value (converted from kobo to Naira) and applies a profit margin. I then ordered the results by this estimated CLV in descending order to highlight potentially high-value customers.





## Challenges




For one, I had to be careful about the interpretation of certain columns. While many column names were self-explanatory, some fields were less obvious (e.g., `cowry_amount`, boolean flags like `is_bloom_note`). Without a data dictionary, it can be difficult to derive the meaning of some of these columns. Online resources helped me in that regard.





Also, translating the business scenarios and the CLV formula into accurate SQL queries was a bit tricky since I have to ensure that the logic correctly reflected the intended criteria. For instance, defining what constitutes a "funded" plan based on transaction data, identifying "inflow" transactions within the available tables, and correctly implementing the multi-step calculation required for the Customer Lifetime Value (CLV) formula demanded careful attention to detail and the relationships between the `plans_plan`, `savings_savingsaccount`, and `users_customuser` tables. I also had to ensure the correct handling of units (kobo vs. naira) within calculations like CLV.




Finally, developing robust queries required anticipating and handling potential edge cases. This included scenarios like customers with no transaction history, or plans that had been created but never received an inflow. Implementing techniques like `LEFT JOIN` to include all relevant entities (like all users or all plans) and using functions such as `COALESCE` and `GREATEST` were essential to provide default values or adjust calculations (like ensuring a minimum tenure) to prevent errors and ensure the queries returned meaningful results across the entire dataset, not just for entities with activity.