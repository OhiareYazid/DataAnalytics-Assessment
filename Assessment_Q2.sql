WITH customer_monthly_transactions AS (
    -- Get monthly transaction counts per customer
    SELECT 
        s.owner_id,
        DATE_FORMAT(s.transaction_date, '%Y-%m') AS transaction_month,
        COUNT(*) AS transaction_count
    FROM 
        savings_savingsaccount s
    WHERE 
        s.owner_id IS NOT NULL  -- Ensure we have valid owners
        -- Not filtering by transaction_status yet as it might not exist or have different values
    GROUP BY 
        s.owner_id, 
        DATE_FORMAT(s.transaction_date, '%Y-%m')
),
customer_avg_transactions AS (
    -- Calculate average transactions per month for each customer
    SELECT 
        owner_id,
        AVG(transaction_count) AS avg_transactions_per_month,
        CASE
            WHEN AVG(transaction_count) >= 10 THEN 'High Frequency'
            WHEN AVG(transaction_count) >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM 
        customer_monthly_transactions
    GROUP BY 
        owner_id
)
-- Final aggregation by frequency category
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM 
    customer_avg_transactions
GROUP BY 
    frequency_category
ORDER BY 
    CASE 
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        WHEN frequency_category = 'Low Frequency' THEN 3
    END;
