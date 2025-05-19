-- Filter only relevant plans (savings and investment types)
WITH filtered_plans AS (
    SELECT 
        id,                        -- Unique plan ID
        owner_id,                 -- ID of the user who owns the plan
        is_regular_savings,       -- Flag for savings plan
        is_a_fund                 -- Flag for investment plan
    FROM plans_plan 
    WHERE is_regular_savings = 1 OR is_a_fund = 1  -- Only keep savings or investment plans
),

-- total confirmed deposits for each user and plan
filtered_savings AS (
    SELECT 
        plan_id,                   -- Plan linked to savings
        owner_id,                  -- User who owns the savings account
        SUM(confirmed_amount) AS total_deposits -- Total confirmed deposits per plan
    FROM savings_savingsaccount
    WHERE confirmed_amount >= 1         -- Filter only actual deposits
    GROUP BY plan_id, owner_id
),

-- Join filtered plans with deposits to retain only funded plans
funded_plans AS (
    SELECT 
        fp.owner_id,
        fp.id AS plan_id,
        fp.is_regular_savings,
        fp.is_a_fund,
        fs.total_deposits
    FROM filtered_plans fp
    JOIN filtered_savings fs 
      ON fp.id = fs.plan_id AND fp.owner_id = fs.owner_id -- Match plans to confirmed deposits
),

-- Aggregate the number of each funded plan type per user
aggregated_user_plans AS (
    SELECT 
        owner_id,
        COUNT(DISTINCT CASE WHEN is_regular_savings = 1 THEN plan_id END) AS savings_count,     -- Count of funded savings plans
        COUNT(DISTINCT CASE WHEN is_a_fund = 1 THEN plan_id END) AS investment_count,           -- Count of funded investment plans
        SUM(total_deposits) AS total_deposit_sum -- Sum of all confirmed deposits per user
    FROM funded_plans
    GROUP BY owner_id
),

-- Final query joining user info and formatting
final_output AS (
    SELECT 
        u.id AS owner_id,   -- User ID
        -- Format name: Capitalize first and last name properly
        COALESCE(CONCAT(
            UPPER(LEFT(u.first_name, 1)), LOWER(SUBSTRING(u.first_name, 2)),
            ' ',
            UPPER(LEFT(u.last_name, 1)), LOWER(SUBSTRING(u.last_name, 2))
        ), 'None') AS name,
        aup.savings_count,
        aup.investment_count,
        ROUND(aup.total_deposit_sum / 100, 2) AS total_deposits -- Convert from kobo to naira
    FROM aggregated_user_plans aup
    JOIN users_customuser u ON u.id = aup.owner_id
)

-- Filter only users with both plan types and order by value
SELECT *
FROM final_output
WHERE savings_count >= 1 AND investment_count >= 1
ORDER BY total_deposits DESC;
