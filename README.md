# 🌍 Economic Collapse & Performance Prediction

This project investigates the economic performance and potential collapse risk of countries using financial, inflationary, and market indicators from 1990 to 2023. The primary goal is to model and understand what drives a country’s **economic strength**, using both regression and (eventually) classification techniques.

---

## 🎯 Project Objectives

- Predict a country's **economic_index** (0–100 scale) using key macroeconomic indicators.
- Identify the most influential predictors of economic stability and performance.
- Explore a potential **collapse_score** or **collapse_risk** metric in future stages.
- Visualize trends, outliers, and relationships in macroeconomic data.
- Build interpretable models that can aid in early warning or policy evaluation.

---

## 🧠 Why This Project?

While GDP growth and inflation are often cited in isolation, real-world economic collapse tends to be driven by a complex mix of government debt, black market activity, interest rates, and inflation shocks. This project attempts to capture that complexity using a consolidated **economic_index** along with additional modeling layers.

---

---

## 📊 Variables Used

| Variable         | Description                                              |
|------------------|----------------------------------------------------------|
| `economic_index` | Composite index (0–100) measuring economic performance   |
| `gdp_growth`     | Annual GDP growth rate (%)                               |
| `gov_debt`       | Government debt as % of GDP                              |
| `inflation_rate` | Annual inflation rate (%)                                |
| `interest_rates` | National interest rate (%)                               |
| `black_market`   | Black market activity index                              |
| `cpi`            | Consumer Price Index (general price level)               |

Future stages may include:
- A derived `collapse_score = 100 - economic_index`
- A binary `collapse_risk` flag based on a threshold

---

## ✅ Current Progress

- ✅ Data cleaning, merging, and imputation complete  
- ✅ Exploratory data analysis (EDA) completed  
- ✅ Multiple linear regression fitted  
- ✅ Model comparison using F-test  
- ✅ Diagnostic plots and assumptions evaluated  
- ✅ Report written and submitted for the “Data Analysis & Linear Model” milestone

---

## 🚧 What’s Next?

- Design and compute a `collapse_score` and binary `collapse_risk`
- Explore logistic regression or tree-based models
- Evaluate predictive performance with training/testing splits or cross-validation

---

## 👥 Authors

- **Viswa Sushanth Karuturi** — Data science, modeling, analysis, documentation  
- **Naeem Almohtaseb** — Data sourcing, writing support, planning, interpretation

---

