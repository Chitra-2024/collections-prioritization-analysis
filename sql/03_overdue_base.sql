DROP TABLE IF EXISTS overdue_base;
CREATE TABLE overdue_base AS
SELECT p.sk_id_prev, p.sk_id_curr, p.months_balance, p.sk_dpd, p.bucket,
       CASE WHEN p.sk_dpd <= 30 AND p.next_dpd > 30 THEN 1
            WHEN p.sk_dpd <= 60 AND p.next_dpd > 60 THEN 1
            WHEN p.sk_dpd <= 90 AND p.next_dpd > 90 THEN 1
            ELSE 0 END AS bad_next,
       a.amt_credit AS exposure
FROM paired p
JOIN prev a ON a.sk_id_prev = p.sk_id_prev
WHERE p.name_contract_status = 'Active'
  AND p.sk_dpd BETWEEN 1 AND 90
  AND p.next_month = p.months_balance + 1;