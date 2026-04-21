# SADDAM Zone EA V1.12 - Modification Summary

This version introduces stability fixes for the Hedging Mode and a new stacking feature for better recovery.

## 1. Panic Reset Protection (Crash Fix)
- **Problem:** In V1.11 and earlier, if one side of the market became empty (e.g., all SELL orders were closed during reduction) while the other side still had trades, the EA would panic and close everything. This caused the steep drops seen in strategy tester graphs.
- **Fix:** Added `!IsHedgingMode` guard to the reset logic. The EA will now correctly allow one side to reach zero lots during the reduction process without wiping the account.
- **Benefit:** Smooth balance curve and preserved hedge positions during recovery.

## 2. Secondary Magic Stacking (`magicNumbr2`)
- **New Feature:** You can now enable a secondary cycle that starts only when the main EA is in Hedging Mode.
- **Automatic Trigger:** The EA monitors the price from the moment Hedging Mode is activated. If the price moves by `Step2` pips (e.g., 50 pips), it opens the first trade of a new cycle with `magicNumbr2`.
- **Isolation:** This new cycle is managed separately using the `magicNumbr2` identifier. This allows you to generate new profits from the current trend while the original `MagicNumber` trades are locked in the hedge.

## 3. New Input Parameters
- **EnableMagic2:** Set to `true` to enable the stacking feature.
- **Step2:** The distance in pips required to trigger the secondary cycle.
- **magicNumbr2:** the numerical ID for the secondary trades (should be different from the main `MagicNumber`).

---
**Recommendation:** Use **SADDAM Zone EA V1.12.mq4** for all future testing. It is the most stable version and includes the protection against account wipes during hedging.
