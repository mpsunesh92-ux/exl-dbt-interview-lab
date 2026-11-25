
{{
    config(materialized='table',
    transient='true')
}}

SELECT
    txn_id,
    account_id,
    amount,
    status,
    updated_at,
    LOAD_TS,
    SUM(fee_amount) AS total_fees
FROM {{ ref('src_transactions') }}
GROUP BY 1, 2, 3, 4, 5, 6
QUALIFY ROW_NUMBER() OVER (PARTITION BY txn_id ORDER BY updated_at DESC) = 1