
SELECT
raw_payload:account_id::varchar(10) as ACCOUNT_ID,
raw_payload:amount::number(12,2) as amount,
raw_payload:status::varchar(10) as status,
raw_payload:txn_id::varchar(10) as txn_id,
raw_payload:updated_at::TIMESTAMP_NTZ  as updated_at,
LOAD_TS,
item.value:code::varchar(10) as code,
COALESCE(item.value:val::number(10,2),0) as fee_amount
FROM {{source('banking_raw','raw_transactions')}} r,
lateral flatten(input=>(r.raw_payload:items),outer=>true) as  item 
where 
{% if var('load_mode', 'DAILY') == 'HISTORY' and var('run_date', none) is not none %}
  -- History Mode: Loads full year (e.g., 2024-01-01 to 2024-12-31)
   LOAD_TS::DATE  >= DATE_TRUNC('year', '{{ var("run_date") }}'::DATE)
  AND LOAD_TS::DATE  <  DATEADD('year', 1, DATE_TRUNC('year', '{{ var("run_date") }}'::DATE))
{% elif var('run_date', none) is not none %}
  -- Daily Control-M Mode: Loads last 3 days up to ODATE
   LOAD_TS::DATE >= DATEADD('day', -3, '{{ var("run_date") }}'::DATE)
  AND LOAD_TS::DATE <= '{{ var("run_date") }}'::DATE
{% else %}
  -- Default interactive dev run (when no --vars passed)
 LOAD_TS::DATE >= DATEADD('day', -3, CURRENT_DATE())
{% endif %}
