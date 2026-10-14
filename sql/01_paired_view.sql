DROP VIEW IF EXISTS paired;
CREATE VIEW paired AS
WITH monthly AS (
  SELECT sk_id_prev, sk_id_curr, months_balance, sk_dpd, name_contract_status,
    CASE WHEN name_contract_status = 'Completed' THEN 'Closed'
         WHEN sk_dpd = 0   THEN '0 Current'
         WHEN sk_dpd <= 30 THEN '1-30'
         WHEN sk_dpd <= 60 THEN '31-60'
         WHEN sk_dpd <= 90 THEN '61-90'
         ELSE '90+' END AS bucket
  FROM pos
)
SELECT *,
  LEAD(bucket)         OVER (PARTITION BY sk_id_prev ORDER BY months_balance) AS next_bucket,
  LEAD(sk_dpd)         OVER (PARTITION BY sk_id_prev ORDER BY months_balance) AS next_dpd,
  LEAD(months_balance) OVER (PARTITION BY sk_id_prev ORDER BY months_balance) AS next_month
FROM monthly;