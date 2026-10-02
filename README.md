# Stock Market Analysis

## Project Overview

This project analyzes historical closing prices for six companies loaded from the existing MySQL database table `stock_market_analysis.master_table`. All calculations are generated dynamically from the loaded pandas DataFrame.

The repository also includes the original SQL task work, source stock CSV files, generated analysis outputs, written insights, and a presentation. The Python script is the runnable analysis pipeline documented below.

## Dataset

The source table contains daily records from 2015-01-01 to 2018-07-31 with these columns:

- `date`
- `bajaj_close`
- `eicher_close`
- `hero_close`
- `infosys_close`
- `tcs_close`
- `tvs_close`

The companies are displayed as Bajaj Auto, Eicher Motors, Hero Motocorp, Infosys, TCS, and TVS Motors.

## Technologies Used

- Python
- pandas
- MySQL Connector/Python
- Matplotlib
- Seaborn

## Database Structure

The script connects to the MySQL database `stock_market_analysis` and reads the existing `master_table`. It does not create or modify database tables.

The database password is read from the `MYSQL_PASSWORD` environment variable when it is set; otherwise, the script requests it interactively with a hidden prompt. It is never printed or stored in the project files.

The companion `stock_market_analysis.sql` file contains the database schema and SQL task queries. It creates the source stock tables and the `master_table` definition, but it does not contain `INSERT` or `LOAD DATA` statements. The database must therefore be populated separately before the Python script is run.

## Repository Contents

- `stock_analysis.py`: Python analysis and chart-generation pipeline.
- `stock_market_analysis.sql`: SQL schema and analysis queries.
- `Bajaj Auto.csv`, `Eicher Motors.csv`, `Hero Motocorp.csv`, `Infosys.csv`, `TCS.csv`, `TVS Motors.csv`: source stock files.
- `stock_analysis_data.csv`: generated dataset with raw and adjusted daily-return columns.
- `stock_summary.csv`: generated summary statistics.
- `monthly_average_closing_prices.csv`: generated monthly average closing prices.
- `charts/`: generated PNG charts.
- `stock_market_insights.md`: written SQL analysis findings.
- `SQL- Stock Market Analysis.pptx`: project presentation.

## Analysis Performed

- Converts dates to pandas datetime values and sorts them.
- Reports shape, data types, missing values, duplicate rows, and descriptive statistics.
- Calculates minimum, maximum, average, standard deviation, first price, last price, and total percentage change.
- Calculates daily returns as current closing price divided by the previous closing price minus one.
- Preserves raw daily returns and marks returns whose absolute value is above 20% as adjustment-related anomalies for return analysis only.
- Reports average daily return, daily return volatility, maximum daily gain, and maximum daily loss after excluding those extreme returns.
- Calculates monthly and yearly average closing prices.
- Calculates the closing-price correlation matrix.
- Saves a final company summary and a cleaned dataset containing daily-return columns.

The dataset contains apparent price-adjustment discontinuities, including large movements around Infosys on 2015-06-15 and TCS on 2018-05-31. Daily returns with an absolute value above 20% are excluded only from return-based statistics and return-based charts. The original closing prices, raw daily returns, and all rows remain in `stock_analysis_data.csv`. These observations are not claimed to be confirmed stock splits because the dataset does not establish their cause.

## Visualizations

Charts are saved in the `charts` folder:

- Closing price trend for all companies
- Individual closing-price charts
- Closing-price correlation heatmap
- Daily-return distributions
- Average closing-price comparison
- Daily-return volatility comparison
- Yearly average closing-price trends

## Key Findings

The script prints the calculated summary, return statistics, and correlation matrix in the terminal. This keeps findings tied to the current database contents instead of embedding fixed values or investment recommendations.

## How to Run

1. Install the Python packages if needed:

   ```powershell
   pip install pandas mysql-connector-python matplotlib seaborn
   ```

2. Either set the MySQL password for the current PowerShell session without placing it in the script:

   ```powershell
   $env:MYSQL_PASSWORD = "<your-mysql-password>"
   ```

   or leave the variable unset and enter the password when the script prompts you.

3. Run the analysis from this project folder:

   ```powershell
   python stock_analysis.py
   ```

The script creates or replaces `stock_summary.csv`, `stock_analysis_data.csv`, `monthly_average_closing_prices.csv`, and the chart files in `charts`. The source CSV files, SQL file, insights document, and presentation are reference/project artifacts and are not modified by the Python script.
