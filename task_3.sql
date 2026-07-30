WITH account_stats AS (
    SELECT
        client_id,
        COUNT(*) AS total_accounts,
        SUM(balance) AS total_balance
    FROM accounts
    GROUP BY client_id
),

transaction_stats AS (
    SELECT
        a.client_id,
        COUNT(*) FILTER (
            WHERE t.transaction_type = 'deposit'
        ) AS total_deposits,
        COUNT(*) FILTER (
            WHERE t.transaction_type = 'withdrawal'
        ) AS total_withdrawals
    FROM accounts a
    LEFT JOIN transactions t
        ON a.account_id = t.account_id
    GROUP BY a.client_id
)

SELECT
    c.client_id,
    c.name,
    c.age,
    COALESCE(ac.total_accounts, 0) AS total_accounts,
    COALESCE(ac.total_balance, 0) AS total_balance,
    COALESCE(ts.total_deposits, 0) AS total_deposits,
    COALESCE(ts.total_withdrawals, 0) AS total_withdrawals
FROM clients c
LEFT JOIN account_stats ac
    ON c.client_id = ac.client_id
LEFT JOIN transaction_stats ts
    ON c.client_id = ts.client_id
WHERE c.registration_date >= '2020-01-01'
ORDER BY total_balance DESC;
