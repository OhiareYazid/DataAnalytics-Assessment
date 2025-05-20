-- CTE to classify plans as either 'Savings' or 'Investments'
WITH plan_fixed AS (
  SELECT 
    owner_id,    -- ID of the user who owns the plan
    id,          -- Unique ID of the plan
    
    -- Determine plan type based on is_regular_savings and is_a_fund flags
    CASE 
      WHEN (CASE 
              WHEN is_a_fund = 1 THEN 2
              ELSE 0
            END + is_regular_savings) = 2 THEN 'Investments'
      ELSE 'Savings' 
    END AS type
  FROM plans_plan 
  -- Only include plans marked as either regular savings or investment
  WHERE is_regular_savings = 1 OR is_a_fund = 1
),
-- Calculate the most recent transaction date and inactivity period for each plan
savings_fixed AS (
  SELECT
    owner_id,
    plan_id,
    DATE(MAX(transaction_date)) AS last_transaction_date,
    
    -- Calculate inactivity days as the difference between the most recent transaction
    -- in the entire system and this plan's most recent transaction
    DATEDIFF(
      (SELECT DATE(MAX(transaction_date)) FROM savings_savingsaccount),
      DATE(MAX(transaction_date))
    ) AS inactivity_days
  FROM savings_savingsaccount
  GROUP BY owner_id, plan_id
)
--  Join the datasets and filter inactive accounts for more than a year
SELECT 
  p.id AS plan_id,
  p.owner_id AS owner_id,
  p.type,
  s.last_transaction_date,
  s.inactivity_days
FROM plan_fixed p
JOIN savings_fixed s 
  ON p.owner_id = s.owner_id AND p.id = s.plan_id
WHERE s.inactivity_days >= 366;  -- More than 365 days (over a year)
