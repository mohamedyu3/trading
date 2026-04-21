# SADDAM Zone EA V1.11 - Modification Summary

This document describes the critical logic updates and bug fixes implemented in version 1.11.

## 1. Selective Profit Harvesting (Winner-Only Closing)
- **Previous Logic (V1.10):** When a hedge reduction was triggered, the EA would close ALL orders on the winning side (e.g., all BUY orders if the price moved up).
- **New Logic (V1.11):** The EA now only closes **profitable** orders on the leading side. Any orders currently in a temporary loss on that side are kept open.
- **Benefit:** This minimizes realized losses and ensures that every reduction step actually increases the account balance.

## 2. Robust Profit Calculation
- **Previous Logic (V1.10):** The EA looked at the MT4 "Account History" tab to see how much profit was just closed. This was sensitive to user sorting; if the history wasn't sorted by "Time", the EA would get the wrong number and potentially close too many losing trades.
- **New Logic (V1.11):** The new `CloseSelectedWinners` function returns the exact profit realized directly to the reduction logic.
- **Benefit:** Eliminates "Panic" closures caused by incorrect history data.

## 3. Fixed Partial Close Math
- **Bug Fix:** In `ClosePercentOfLoss`, the math for tracking remaining profit was incorrect, often leading to closing entire positions instead of partial lots.
- **Calculation Update:** Now uses the formula: `realizedLoss = orderProfit * (lotsToClose / totalOrderLots)`.
- **Normalization:** All partial lot requests are now normalized to the broker's minimum lot step (e.g., 0.01).
- **Benefit:** Precise recovery that respects the `PF_Percent` setting accurately.

## 4. Hedging Stability
- By keeping losing orders open on both sides, the EA's internal order counters stay above zero more often.
- **Benefit:** This prevents the "Emergency Reset" (Panic Logic) from triggering prematurely and causing a large balance drop.

---
**Note:** Version 1.10 has been restored to its original state for reference. Version 1.11 should be used for improved safety during high-volatility hedging events.
