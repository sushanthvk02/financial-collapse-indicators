# Predicting Economic Strength Using Macroeconomic Indicators

This project investigates whether a combination of traditional and alternative macroeconomic indicators can reliably predict a country's economic strength. The analysis was completed as part of the requirements for DATA 467: Applied Linear Regression and GLMs at the University of Arizona.

## 📘 Project Summary

Our original goal was to model economic collapses, but due to the rarity of sharp declines, we instead developed a continuous **economic_index** (0–100) reflecting overall national economic performance. We also defined a binary indicator, **drop7**, for years where a country's index dropped by ≥7 points — used for logistic modeling.

We explored both linear regression and logistic regression approaches and found that:
- **Black market activity (shadow economy)** was the strongest and most stable predictor.
- Traditional indicators such as **GDP growth** and **interest rates** showed minimal impact.
- Models remained robust across Box-Cox transformations, outlier removal, and M-estimation.

The final recommended model excludes GDP growth and interest rates due to their weak and inconsistent contribution.

---

## 📂 Repository Structure

```plaintext
financial-collapse-indicators/
│
├── scripts/        # R scripts for data cleaning, modeling, and plotting
├── figs/           # Plots used in diagnostics and visual summaries
├── data/           # Raw input, cleaned, and final merged datasets
├── tables/         # Model outputs, coefficients, VIFs, test metrics, F-test results, etc.
