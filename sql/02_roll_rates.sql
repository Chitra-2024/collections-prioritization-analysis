SELECT bucket, next_bucket, COUNT(*) AS n,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY bucket), 1) AS pct
FROM paired
WHERE next_month = months_balance + 1 AND bucket <> 'Closed'
GROUP BY bucket, next_bucket
ORDER BY bucket, next_bucket;