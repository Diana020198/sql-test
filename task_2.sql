WITH exact_match AS (
    SELECT DISTINCT tr.doc_id
    FROM tranches tr
    JOIN transactions t
        ON CAST(tr.inn AS BIGINT) = t.inn
        AND tr.account = t.account
        AND t.operation_datetime
            BETWEEN tr.operation_datetime
            AND tr.operation_datetime + INTERVAL '10 days'
        AND tr.operation_sum = t.operation_sum
),

candidate_transactions AS (
    SELECT
        tr.doc_id AS tranche_id,
        t.doc_id AS transaction_id,
        tr.operation_sum AS tranche_sum,
        t.operation_sum,
        t.operation_datetime,
        SUM(t.operation_sum) OVER (
            PARTITION BY tr.doc_id
            ORDER BY t.operation_datetime
        ) AS cumulative_sum
    FROM tranches tr
    JOIN transactions t
        ON CAST(tr.inn AS BIGINT) = t.inn
        AND tr.account = t.account
        AND t.operation_datetime
            BETWEEN tr.operation_datetime
            AND tr.operation_datetime + INTERVAL '10 days'
    WHERE tr.doc_id NOT IN (
        SELECT doc_id
        FROM exact_match
    )
)

SELECT *
FROM candidate_transactions
WHERE cumulative_sum - operation_sum < tranche_sum;
