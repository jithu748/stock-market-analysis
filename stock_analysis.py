import os
import getpass
from pathlib import Path

import matplotlib.pyplot as plt
import mysql.connector
import pandas as pd
import seaborn as sns


STOCK_COLUMNS = {
    "Bajaj Auto": "bajaj_close",
    "Eicher Motors": "eicher_close",
    "Hero Motocorp": "hero_close",
    "Infosys": "infosys_close",
    "TCS": "tcs_close",
    "TVS Motors": "tvs_close",
}
PRICE_COLUMN_LABELS = {
    stock_column: company for company, stock_column in STOCK_COLUMNS.items()
}
ADJUSTED_RETURN_LABELS = {
    f"{stock_column}_adjusted_daily_return": company
    for company, stock_column in STOCK_COLUMNS.items()
}
CHART_DIRECTORY = Path("charts")
SUMMARY_FILE = Path("stock_summary.csv")
CLEANED_DATA_FILE = Path("stock_analysis_data.csv")
MONTHLY_AVERAGE_FILE = Path("monthly_average_closing_prices.csv")
EXTREME_RETURN_THRESHOLD = 0.20


def load_data():
    """Load the existing master table without changing the database."""
    password = os.getenv("MYSQL_PASSWORD")
    if not password:
        password = getpass.getpass("MySQL password: ")

    query = """
    SELECT
        date,
        bajaj_close,
        eicher_close,
        hero_close,
        infosys_close,
        tcs_close,
        tvs_close
    FROM master_table
    ORDER BY date;
    """

    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password=password,
        database="stock_market_analysis",
    )
    try:
        return pd.read_sql(query, conn)
    finally:
        conn.close()


def prepare_data(df):
    """Convert dates, sort rows, and add raw and adjusted daily returns."""
    prepared = df.copy()
    prepared["date"] = pd.to_datetime(prepared["date"])
    prepared = prepared.sort_values("date").reset_index(drop=True)

    for stock_column in STOCK_COLUMNS.values():
        raw_return_column = f"{stock_column}_daily_return"
        adjusted_return_column = f"{stock_column}_adjusted_daily_return"
        excluded_column = f"{stock_column}_return_excluded"
        prepared[raw_return_column] = (
            prepared[stock_column] / prepared[stock_column].shift(1) - 1
        )
        prepared[excluded_column] = (
            prepared[raw_return_column].abs() > EXTREME_RETURN_THRESHOLD
        )
        prepared[adjusted_return_column] = prepared[raw_return_column].mask(
            prepared[excluded_column]
        )
    return prepared


def inspect_data(df):
    print("\n=== Basic Data Inspection ===")
    print("Shape:")
    print(df.shape)
    print("\nData types:")
    print(df.dtypes)
    print("\nMissing values:")
    print(df.isna().sum())
    print("\nDuplicate rows:")
    print(df.duplicated().sum())
    print("\nDescriptive statistics:")
    print(df.describe())


def calculate_price_summary(df):
    prices = df[list(STOCK_COLUMNS.values())]
    summary = pd.DataFrame(index=list(STOCK_COLUMNS))
    summary["Average Price"] = prices.mean().values
    summary["Minimum Price"] = prices.min().values
    summary["Maximum Price"] = prices.max().values
    summary["Volatility"] = prices.std().values
    summary["First Price"] = prices.iloc[0].values
    summary["Last Price"] = prices.iloc[-1].values
    summary["Total Change %"] = (
        (summary["Last Price"] - summary["First Price"])
        / summary["First Price"]
        * 100
    )
    return summary


def calculate_return_statistics(df):
    adjusted_return_columns = [
        f"{stock_column}_adjusted_daily_return"
        for stock_column in STOCK_COLUMNS.values()
    ]
    returns = df[adjusted_return_columns]
    statistics = pd.DataFrame(index=list(STOCK_COLUMNS))
    statistics["Average Daily Return %"] = returns.mean().values * 100
    statistics["Daily Return Volatility %"] = returns.std().values * 100
    statistics["Maximum Daily Gain %"] = returns.max().values * 100
    statistics["Maximum Daily Loss %"] = returns.min().values * 100
    excluded_counts = {
        company: int(df[f"{stock_column}_return_excluded"].sum())
        for company, stock_column in STOCK_COLUMNS.items()
    }
    return statistics, excluded_counts


def create_summary(price_summary, return_statistics):
    summary = price_summary.join(return_statistics)
    return summary.reset_index(names="Company")


def save_time_period_averages(df):
    price_data = df.set_index("date")[list(STOCK_COLUMNS.values())]
    monthly_average = price_data.resample("ME").mean()
    yearly_average = price_data.resample("YE").mean()
    return monthly_average, yearly_average


def save_chart(filename):
    CHART_DIRECTORY.mkdir(exist_ok=True)
    plt.tight_layout()
    plt.savefig(CHART_DIRECTORY / filename, dpi=150, bbox_inches="tight")
    plt.close()


def create_visualizations(df, yearly_average):
    sns.set_theme(style="whitegrid")
    prices = df.set_index("date")[list(STOCK_COLUMNS.values())]
    returns = df[
        [
            f"{column}_adjusted_daily_return"
            for column in STOCK_COLUMNS.values()
        ]
    ]

    prices.rename(columns=PRICE_COLUMN_LABELS).plot(
        figsize=(14, 7)
    )
    plt.title("Closing Price Trends")
    plt.xlabel("Date")
    plt.ylabel("Closing Price")
    plt.legend(title="Company")
    save_chart("closing_price_trends.png")

    for company, stock_column in STOCK_COLUMNS.items():
        prices[stock_column].plot(figsize=(12, 6), label=company)
        plt.title(f"{company} Closing Price")
        plt.xlabel("Date")
        plt.ylabel("Closing Price")
        plt.legend()
        save_chart(f"{stock_column}_closing_price.png")

    plt.figure(figsize=(10, 8))
    sns.heatmap(prices.rename(columns=PRICE_COLUMN_LABELS).corr(),
                annot=True, cmap="coolwarm", fmt=".2f")
    plt.title("Stock Closing Price Correlation Matrix")
    save_chart("correlation_heatmap.png")

    plt.figure(figsize=(14, 7))
    for company, stock_column in STOCK_COLUMNS.items():
        sns.histplot(returns[f"{stock_column}_adjusted_daily_return"].dropna(),
                     bins=40, kde=True, element="step", fill=False, label=company)
    plt.title("Distribution of Daily Returns")
    plt.xlabel("Daily Return")
    plt.ylabel("Frequency")
    plt.legend(title="Company")
    save_chart("daily_return_distribution.png")

    average_prices = prices.mean().rename(index=PRICE_COLUMN_LABELS)
    average_prices.sort_values().plot(kind="bar", figsize=(12, 6), color="steelblue")
    plt.title("Comparison of Average Closing Prices")
    plt.xlabel("Company")
    plt.ylabel("Average Closing Price")
    plt.xticks(rotation=30, ha="right")
    save_chart("average_closing_prices.png")

    volatility = returns.std().rename(index=ADJUSTED_RETURN_LABELS)
    volatility.sort_values().plot(kind="bar", figsize=(12, 6), color="darkorange")
    plt.title("Comparison of Daily Return Volatility")
    plt.xlabel("Company")
    plt.ylabel("Standard Deviation of Daily Return")
    plt.xticks(rotation=30, ha="right")
    save_chart("daily_return_volatility.png")

    yearly_average.rename(columns=PRICE_COLUMN_LABELS).plot(
        figsize=(14, 7), marker="o"
    )
    plt.title("Yearly Average Closing Price Trends")
    plt.xlabel("Year")
    plt.ylabel("Average Closing Price")
    plt.legend(title="Company")
    save_chart("yearly_average_closing_prices.png")


def main():
    df = prepare_data(load_data())
    inspect_data(df)

    price_summary = calculate_price_summary(df)
    return_statistics, excluded_counts = calculate_return_statistics(df)
    final_summary = create_summary(price_summary, return_statistics)
    monthly_average, yearly_average = save_time_period_averages(df)

    print("\n=== Daily Return Statistics ===")
    print(return_statistics.round(4).to_string())
    print("\n=== Extreme Daily Returns Excluded (absolute return > 20%) ===")
    for company, count in excluded_counts.items():
        print(f"{company}: {count}")
    print("\n=== Correlation Matrix ===")
    print(df[list(STOCK_COLUMNS.values())].corr().round(4).to_string())
    print("\n=== Final Stock Summary ===")
    print(final_summary.round(4).to_string(index=False))

    final_summary.to_csv(SUMMARY_FILE, index=False)
    df.to_csv(CLEANED_DATA_FILE, index=False)
    monthly_average.to_csv(MONTHLY_AVERAGE_FILE)
    create_visualizations(df, yearly_average)
    print(f"\nSaved summary to {SUMMARY_FILE}")
    print(f"Saved cleaned data to {CLEANED_DATA_FILE}")
    print(f"Saved monthly averages to {MONTHLY_AVERAGE_FILE}")
    print(f"Saved charts to {CHART_DIRECTORY.resolve()}")


if __name__ == "__main__":
    main()