
SELECT
raw_payload:account_id::varchar(10) as ACCOUNT_ID,
raw_payload:amount::number(12,2) as amount,
raw_payload:status::varchar(10) as status,
raw_payload:txn_id::varchar(10) as txn_id,
raw_payload:updated_at::TIMESTAMP_NTZ  as updated_at
LOAD_TS,
item.value:code::varchar(10) as code,
COALESCE(item.value:val::number(10,2),0) as val
FROM {{source('banking_raw','raw_transactions')}} r
lateral flatten(input=>(r.raw_payload:items),outer=>true) as  item 
