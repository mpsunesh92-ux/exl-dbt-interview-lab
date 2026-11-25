

SELECT
    txn_id,
    account_id,
    amount,
    total_fees,
    (amount - total_fees) AS net_amount,
    status,
    updated_at
FROM {{ref('stg_transactions')}}
WHERE status = 'COMPLETED'