{{
    config(
        materialized='incrimental',
        unique_key='txn_id',
        incrimental_strategy='merge',
        on_schema_change='append_new_columns',
        transient='false',
        )
}}

SELECT
    txn_id,
    account_id,
    amount,
    total_fees,
    net_amount,
    status,
    updated_at,
    CURRENT_TIMESTAMP() AS dbt_updated_at
FROM {{ ref('int_transactions_enriched') }}

{% if is_incremental()%}
 where updated_at >= (select DATEADD('day',-3,max(updated_at))
 from {{this}}
 )

 {%end if%}
