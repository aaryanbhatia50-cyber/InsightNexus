# Insight Nexus — Retail Sales Intelligence & Forecasting

Insight Nexus is an end-to-end retail analytics project that combines **data analysis, machine learning, SQL, and Power BI** to analyze historical store sales, forecast sales, and identify business-level patterns in prediction performance.

## 📌 Project Overview

The project focuses on retail sales forecasting and business intelligence.

It uses historical sales data to:

- Analyze store-level sales performance
- Build a machine learning model for sales prediction
- Compare actual sales with predicted sales
- Measure forecasting accuracy
- Analyze over-prediction and under-prediction
- Identify stores and periods with higher prediction errors
- Present business insights through an interactive Power BI dashboard

## 🛠️ Tech Stack

- **Python**
- **Pandas**
- **NumPy**
- **Matplotlib**
- **Scikit-learn**
- **XGBoost**
- **PostgreSQL / SQL**
- **Power BI**
- **Jupyter Notebook**
- **VS Code**

## 🔄 Project Workflow

```text
Raw Retail Data
       ↓
Data Audit & Exploration
       ↓
Feature Engineering
       ↓
Machine Learning Model
       ↓
Sales Predictions
       ↓
Prediction Error Analysis
       ↓
SQL Business Analysis
       ↓
Power BI Dashboard
       ↓
Business Insights

## 📊 Dashboard

The Power BI dashboard is divided into three pages:

### 1. Executive Overview
Provides a high-level view of:
- Total sales
- Total predicted sales
- Average sales
- Actual vs predicted sales over time
- Top-performing stores
- Prediction status distribution

### 2. Store Performance
Provides store-level analysis of:
- Actual vs predicted sales
- Prediction error over time
- Store-level sales performance
- Average prediction error

### 3. Prediction Analysis
Focuses on:
- Mean Absolute Error (MAE)
- Root Mean Squared Error (RMSE)
- R² Score
- Sales vs prediction error
- Over-prediction and under-prediction

## 🤖 Model Performance

The forecasting model achieved:

| Metric | Value |
|---|---:|
| R² Score | 0.95 |
| Mean Absolute Error | 557.87 |
| Root Mean Squared Error | 899.52 |

## 📁 Project Files

- `01_data_audit.ipynb` — Data exploration and auditing
- `02_feature_engineering.ipynb` — Feature preparation
- `03_modeling.ipynb` — Model training and evaluation
- `Queries.sql` — SQL business analysis
- `dashboard.pbix` — Power BI dashboard
- `requirements.txt` — Python dependencies
- `store.csv` — Store information
- `xgb_sales_model.pkl` — Trained forecasting model
- `xgb_feature_columns.pkl` — Model feature configuration

## 💡 Key Business Insights

- Sales and predicted sales show a strong overall relationship.
- Forecasting errors increase around higher-sales observations.
- Prediction accuracy varies across individual stores.
- Comparing over-prediction and under-prediction helps identify where forecasting performance needs closer attention.

## 🚀 Setup

```bash
git clone <your-repository-url>
cd InsightNexus
pip install -r requirements.txt
