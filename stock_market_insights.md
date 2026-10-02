# Stock Market Analysis in SQL

## Project Overview

This project analyzes historical stock market data for six companies using MySQL:

- Bajaj Auto
- Eicher Motors
- Hero Motocorp
- Infosys
- TCS
- TVS Motors

The dataset contains daily trading information from January 2015 to July 2018, including opening price, high price, low price, closing price, weighted average price, trading volume, number of trades, turnover, deliverable quantity, and related measures.

The analysis focuses on data exploration, moving averages, Golden Cross signals, stock returns, unusual price movements, and corporate-action effects.

## Dataset Summary

Each stock contains 889 trading-day records covering the period from 2015-01-01 to 2018-07-31.

All six final tables were successfully validated with 889 rows each.


## Key Findings — Tasks 1–4

### 1. Trading History

The Bajaj Auto dataset contains **889 trading days**, covering:

- First trading date: **2015-01-01**
- Last trading date: **2018-07-31**

This establishes the overall analysis period used for the stock dataset.

### 2. Eicher Motors — Top 5 Closing Prices

The five highest Eicher Motors closing prices in the dataset were:

| Date | Closing Price |
|---|---:|
| 2017-09-07 | 32,786.40 |
| 2017-09-18 | 32,763.85 |
| 2017-09-08 | 32,628.70 |
| 2017-09-12 | 32,528.30 |
| 2017-09-11 | 32,466.75 |

All five occurred during September 2017.

### 3. TCS — Yearly Average Closing Price

| Year | Average Closing Price |
|---|---:|
| 2015 | 2,537.39 |
| 2016 | 2,419.00 |
| 2017 | 2,475.36 |
| 2018 | 2,729.12 |

The 2016 average was **2,419.00**. The 2018 figure represents the available data through July 2018 rather than a complete calendar year.

### 4. Missing Deliverable Quantity

The data-quality analysis identified **six records with missing `deliverable_qty`** across the six stocks.

The affected dates were:

- **2015-12-09** — Eicher Motors, Hero Motocorp, TCS, TVS Motors
- **2017-08-30** — Bajaj Auto
- **2017-08-31** — Infosys

These missing values should be treated as data-quality observations rather than automatically replaced without a documented rule.


## Moving Average Analysis — Bajaj Auto

A 20-day and 50-day moving average were calculated using rolling closing-price windows.

### Moving Average Checkpoints

| Metric | Date | Value |
|---|---|---:|
| First 20-day moving average | 2015-01-29 | 2,415.53 |
| First 50-day moving average | 2015-03-13 | 2,283.80 |
| Last 20-day moving average | 2018-07-31 | 2,918.51 |

The moving averages provide a smoothed view of Bajaj Auto's closing-price trend and are later used to generate Golden Cross signals.


## Golden Cross Analysis — Bajaj Auto

A Golden Cross signal was defined as a transition where the 20-day moving average crosses above the 50-day moving average. A Sell signal was defined as the reverse crossover.

### Key Signal Dates

- **First Buy Signal:** 2015-05-18
- **First Sell Signal:** 2015-08-24

### Signal on 2018-06-21

| Metric | Value |
|---|---:|
| Date | 2018-06-21 |
| Closing Price | 2,832.95 |
| MA20 | 2,851.10 |
| MA50 | 2,850.61 |
| Trade Signal | Buy |

The Golden Cross analysis identifies changes in the relationship between the 20-day and 50-day moving averages. These signals are based on moving-average crossovers rather than the closing price alone.


## Golden Cross Signals — All Six Stocks

The Golden Cross logic was applied to all six stocks to count the number of Buy and Sell crossover signals during the analysis period.

| Stock | Buy Signals | Sell Signals |
|---|---:|---:|
| Bajaj Auto | 12 | 12 |
| Eicher Motors | 7 | 7 |
| Hero Motocorp | 9 | 10 |
| Infosys | 10 | 9 |
| TCS | 13 | 14 |
| TVS Motors | 9 | 9 |
| **Total** | **60** | **61** |

The results show that the six stocks generated a total of **60 Buy signals and 61 Sell signals** based on the 20-day and 50-day moving-average crossover strategy.