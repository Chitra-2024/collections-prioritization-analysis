# Collections Prioritization Analysis

**Status: in progress.** The SQL pipeline, roll-rate analysis and backtest are complete. The Excel summary and Power BI dashboard are being built.

## Problem
A lender has more overdue accounts than collection agents can contact. This project asks: if only a fraction of overdue accounts can be contacted, which should come first? It compares simple prioritization rules on historical data.

## Data
Kaggle *Home Credit Default Risk* (not included in this repo). Files used: `POS_CASH_balance.csv` (monthly loan status and days past due) and `previous_application.csv` (loan amount). Download them from Kaggle and place them in a `data/` folder.

## Approach
1. Sampled 30,000 customers at random (seed 42), keeping each loan's full monthly history.
2. Cleaned the data in pandas (duplicates, missing values, invalid amounts).
3. Loaded it into SQLite and used SQL window functions (`LEAD ... PARTITION BY ... ORDER BY`) to compute each loan's next-month delinquency bucket and the roll-rate matrix.
4. Scoped the analysis to early-stage collections (1-90 days past due). Accounts at 90+ days are treated as non-performing and left out, because including them inflated the outcome through persistence.
5. Defined `bad_next` as rolling into a worse bucket the following month.
6. Split customers into train (even IDs) and test (odd IDs) to avoid leakage, then compared ranking policies by capture rate: the share of rolling-forward exposure that falls inside the accounts each policy picks.

## Results
- 91.1% of current accounts stay current next month.
- Of accounts 1-30 days late, 45.8% return to current and about 4.6% roll past 30 days. Of accounts 61-90 days late, 91.4% roll into 90+.
- Within the 1-30 bucket, the chance of rolling forward rises from 2.8% (1-5 days late) to 22.7% (26-30 days late).

| Capacity | Oldest first | v1: bucket x amount | v2: DPD band x amount | v3: DPD band, then amount |
|---|---|---|---|---|
| 5% | 0.457 | 0.390 | 0.437 | 0.453 |
| 10% | 0.597 | 0.488 | 0.522 | 0.590 |
| 20% | 0.686 | 0.577 | 0.632 | 0.685 |
| 30% | 0.807 | 0.627 | 0.689 | 0.797 |
| 50% | 0.890 | 0.724 | 0.793 | 0.886 |

Oldest-first matched or beat every variant. At 10% capacity it captures about 6x what random picking would. Loan amount did not improve the ranking.

## Decision log
- Sampling: 30,000 customers, seed 42, for speed.
- Duplicate loan-month rows removed: <number from notebook 01>.
- Loans with missing or non-positive amounts removed: <number from notebook 01>.
- Only consecutive months used for transitions, so gaps in history do not create false transitions.
- Variants v2 and v3 were designed after seeing v1's result and evaluated on the same test split.

## Limitations
- No contact log, so the analysis shows targeting quality, not that contact improves outcomes.
- Original loan amount is a proxy for exposure (outstanding balance is not available).
- Public data, not any lender's own. One train/test split and about 1,300 roll-forward events, so small gaps between policies are not reliable.
- Months are pooled for simplicity.

## How to run
1. Put the two CSV files in `data/`.
2. Run `notebooks/01_prepare.ipynb` (sample, clean, build `collections.db`).
3. Run `notebooks/02_analysis.ipynb` (SQL files in `sql/`, roll rates, backtest).

## Roadmap
- [ ] Excel summary workbook (pivots, SUMIFS, XLOOKUP)
- [ ] Power BI dashboard
- [ ] Confidence intervals via bootstrap
- [ ] Design of a controlled test for a new policy