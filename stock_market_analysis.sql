-- ============================================
-- STOCK MARKET ANALYSIS IN SQL
-- Labmentix Internship Project
-- ============================================

CREATE DATABASE IF NOT EXISTS stock_market_analysis;

USE stock_market_analysis;

-- ============================================
-- 1. CREATE STOCK TABLES
-- ============================================

CREATE TABLE bajaj_auto (
    `date` DATE PRIMARY KEY,
    open_price DECIMAL(12,2),
    high_price DECIMAL(12,2),
    low_price DECIMAL(12,2),
    close_price DECIMAL(12,2),
    wap DECIMAL(16,4),
    no_of_shares BIGINT,
    no_of_trades BIGINT,
    total_turnover DECIMAL(20,2),
    deliverable_qty BIGINT,
    pct_deli_qty DECIMAL(6,2),
    spread_high_low DECIMAL(12,2),
    spread_close_open DECIMAL(12,2)
);

CREATE TABLE eicher_motors (
    `date` DATE PRIMARY KEY,
    open_price DECIMAL(12,2),
    high_price DECIMAL(12,2),
    low_price DECIMAL(12,2),
    close_price DECIMAL(12,2),
    wap DECIMAL(16,4),
    no_of_shares BIGINT,
    no_of_trades BIGINT,
    total_turnover DECIMAL(20,2),
    deliverable_qty BIGINT,
    pct_deli_qty DECIMAL(6,2),
    spread_high_low DECIMAL(12,2),
    spread_close_open DECIMAL(12,2)
);

CREATE TABLE hero_motocorp (
    `date` DATE PRIMARY KEY,
    open_price DECIMAL(12,2),
    high_price DECIMAL(12,2),
    low_price DECIMAL(12,2),
    close_price DECIMAL(12,2),
    wap DECIMAL(16,4),
    no_of_shares BIGINT,
    no_of_trades BIGINT,
    total_turnover DECIMAL(20,2),
    deliverable_qty BIGINT,
    pct_deli_qty DECIMAL(6,2),
    spread_high_low DECIMAL(12,2),
    spread_close_open DECIMAL(12,2)
);

CREATE TABLE infosys (
    `date` DATE PRIMARY KEY,
    open_price DECIMAL(12,2),
    high_price DECIMAL(12,2),
    low_price DECIMAL(12,2),
    close_price DECIMAL(12,2),
    wap DECIMAL(16,4),
    no_of_shares BIGINT,
    no_of_trades BIGINT,
    total_turnover DECIMAL(20,2),
    deliverable_qty BIGINT,
    pct_deli_qty DECIMAL(6,2),
    spread_high_low DECIMAL(12,2),
    spread_close_open DECIMAL(12,2)
);

CREATE TABLE tcs (
    `date` DATE PRIMARY KEY,
    open_price DECIMAL(12,2),
    high_price DECIMAL(12,2),
    low_price DECIMAL(12,2),
    close_price DECIMAL(12,2),
    wap DECIMAL(16,4),
    no_of_shares BIGINT,
    no_of_trades BIGINT,
    total_turnover DECIMAL(20,2),
    deliverable_qty BIGINT,
    pct_deli_qty DECIMAL(6,2),
    spread_high_low DECIMAL(12,2),
    spread_close_open DECIMAL(12,2)
);

CREATE TABLE tvs_motors (
    `date` DATE PRIMARY KEY,
    open_price DECIMAL(12,2),
    high_price DECIMAL(12,2),
    low_price DECIMAL(12,2),
    close_price DECIMAL(12,2),
    wap DECIMAL(16,4),
    no_of_shares BIGINT,
    no_of_trades BIGINT,
    total_turnover DECIMAL(20,2),
    deliverable_qty BIGINT,
    pct_deli_qty DECIMAL(6,2),
    spread_high_low DECIMAL(12,2),
    spread_close_open DECIMAL(12,2)
);


-- ============================================
-- 2. TASK 1: TRADING HISTORY
-- ============================================

SELECT
    COUNT(*) AS trading_days,
    MIN(date) AS first_day,
    MAX(date) AS last_day
FROM bajaj_auto;


-- ============================================
-- 3. TASK 2: TOP 5 EICHER CLOSING PRICES
-- ============================================

SELECT
    date,
    close_price
FROM eicher_motors
ORDER BY close_price DESC
LIMIT 5;


-- ============================================
-- 4. TASK 3: TCS YEARLY AVERAGE CLOSE
-- ============================================

SELECT
    YEAR(date) AS year,
    ROUND(AVG(close_price), 2) AS avg_close
FROM tcs
GROUP BY YEAR(date)
ORDER BY year;


-- ============================================
-- 5. TASK 4: MISSING DELIVERABLE QUANTITY
-- ============================================

SELECT 'Bajaj Auto' AS stock, date, deliverable_qty
FROM bajaj_auto
WHERE deliverable_qty IS NULL

UNION ALL

SELECT 'Eicher Motors', date, deliverable_qty
FROM eicher_motors
WHERE deliverable_qty IS NULL

UNION ALL

SELECT 'Hero Motocorp', date, deliverable_qty
FROM hero_motocorp
WHERE deliverable_qty IS NULL

UNION ALL

SELECT 'Infosys', date, deliverable_qty
FROM infosys
WHERE deliverable_qty IS NULL

UNION ALL

SELECT 'TCS', date, deliverable_qty
FROM tcs
WHERE deliverable_qty IS NULL

UNION ALL

SELECT 'TVS Motors', date, deliverable_qty
FROM tvs_motors
WHERE deliverable_qty IS NULL

ORDER BY date, stock;


-- ============================================
-- 6. TASK 5: BAJAJ MOVING AVERAGES
-- ============================================

DROP TABLE IF EXISTS bajaj1;

CREATE TABLE bajaj1 AS
SELECT
    date,
    close_price,

    CASE
        WHEN ROW_NUMBER() OVER (ORDER BY date) >= 20
        THEN ROUND(
            AVG(close_price) OVER (
                ORDER BY date
                ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
            ), 2
        )
    END AS ma20,

    CASE
        WHEN ROW_NUMBER() OVER (ORDER BY date) >= 50
        THEN ROUND(
            AVG(close_price) OVER (
                ORDER BY date
                ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
            ), 2
        )
    END AS ma50

FROM bajaj_auto;


-- ============================================
-- 7. TASK 6: MASTER TABLE
-- ============================================

DROP TABLE IF EXISTS master_table;

CREATE TABLE master_table AS
SELECT
    b.date,
    b.close_price AS bajaj_close,
    e.close_price AS eicher_close,
    h.close_price AS hero_close,
    i.close_price AS infosys_close,
    t.close_price AS tcs_close,
    v.close_price AS tvs_close
FROM bajaj_auto b
LEFT JOIN eicher_motors e ON b.date = e.date
LEFT JOIN hero_motocorp h ON b.date = h.date
LEFT JOIN infosys i ON b.date = i.date
LEFT JOIN tcs t ON b.date = t.date
LEFT JOIN tvs_motors v ON b.date = v.date;


-- ============================================
-- 8. TASK 7: BAJAJ GOLDEN CROSS SIGNALS
-- ============================================

DROP TABLE IF EXISTS bajaj2;

CREATE TABLE bajaj2 AS
WITH signals AS (
    SELECT
        date,
        close_price,
        ma20,
        ma50,
        LAG(ma20) OVER (ORDER BY date) AS prev_ma20,
        LAG(ma50) OVER (ORDER BY date) AS prev_ma50
    FROM bajaj1
)
SELECT
    date,
    close_price,
    ma20,
    ma50,
    CASE
        WHEN ma20 IS NULL OR ma50 IS NULL THEN 'Hold'
        WHEN ma20 > ma50
             AND prev_ma20 <= prev_ma50 THEN 'Buy'
        WHEN ma20 < ma50
             AND prev_ma20 >= prev_ma50 THEN 'Sell'
        ELSE 'Hold'
    END AS trade_signal
FROM signals;


-- ============================================
-- 9. TASK 8: BAJAJ SIGNAL COUNTS
-- ============================================

SELECT
    trade_signal,
    COUNT(*) AS signal_count
FROM bajaj2
GROUP BY trade_signal
ORDER BY trade_signal;


-- ============================================
-- 10. TASK 9: BAJAJ SIGNAL ON 2018-06-21
-- ============================================

SELECT
    date,
    close_price,
    ma20,
    ma50,
    trade_signal
FROM bajaj2
WHERE date = '2018-06-21';

-- ============================================
-- 11. TASK 10: GOLDEN CROSS SIGNALS FOR ALL STOCKS
-- ============================================

WITH all_stocks AS (
    SELECT 'Bajaj Auto' AS stock, date, close_price FROM bajaj_auto
    UNION ALL
    SELECT 'Eicher Motors', date, close_price FROM eicher_motors
    UNION ALL
    SELECT 'Hero Motocorp', date, close_price FROM hero_motocorp
    UNION ALL
    SELECT 'Infosys', date, close_price FROM infosys
    UNION ALL
    SELECT 'TCS', date, close_price FROM tcs
    UNION ALL
    SELECT 'TVS Motors', date, close_price FROM tvs_motors
),
moving_avg AS (
    SELECT
        stock,
        date,
        close_price,
        AVG(close_price) OVER (
            PARTITION BY stock
            ORDER BY date
            ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
        ) AS ma20,
        AVG(close_price) OVER (
            PARTITION BY stock
            ORDER BY date
            ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
        ) AS ma50
    FROM all_stocks
),
signals AS (
    SELECT
        stock,
        date,
        ma20,
        ma50,
        LAG(ma20) OVER (
            PARTITION BY stock
            ORDER BY date
        ) AS prev_ma20,
        LAG(ma50) OVER (
            PARTITION BY stock
            ORDER BY date
        ) AS prev_ma50
    FROM moving_avg
)
SELECT
    stock,
    SUM(
        CASE
            WHEN ma20 > ma50
                 AND prev_ma20 <= prev_ma50
            THEN 1 ELSE 0
        END
    ) AS buy_count,
    SUM(
        CASE
            WHEN ma20 < ma50
                 AND prev_ma20 >= prev_ma50
            THEN 1 ELSE 0
        END
    ) AS sell_count
FROM signals
GROUP BY stock
ORDER BY stock;


-- ============================================
-- 12. TASK 11: FULL-PERIOD RETURN
-- ============================================

SELECT
    'Bajaj Auto' AS stock,
    ROUND(
        (
            (
                SELECT close_price
                FROM bajaj_auto
                ORDER BY date DESC
                LIMIT 1
            )
            -
            (
                SELECT close_price
                FROM bajaj_auto
                ORDER BY date
                LIMIT 1
            )
        )
        /
        (
            SELECT close_price
            FROM bajaj_auto
            ORDER BY date
            LIMIT 1
        ) * 100,
        2
    ) AS return_pct

UNION ALL

SELECT
    'Eicher Motors',
    ROUND(
        (
            (
                SELECT close_price
                FROM eicher_motors
                ORDER BY date DESC
                LIMIT 1
            )
            -
            (
                SELECT close_price
                FROM eicher_motors
                ORDER BY date
                LIMIT 1
            )
        )
        /
        (
            SELECT close_price
            FROM eicher_motors
            ORDER BY date
            LIMIT 1
        ) * 100,
        2
    )

UNION ALL

SELECT
    'Hero Motocorp',
    ROUND(
        (
            (
                SELECT close_price
                FROM hero_motocorp
                ORDER BY date DESC
                LIMIT 1
            )
            -
            (
                SELECT close_price
                FROM hero_motocorp
                ORDER BY date
                LIMIT 1
            )
        )
        /
        (
            SELECT close_price
            FROM hero_motocorp
            ORDER BY date
            LIMIT 1
        ) * 100,
        2
    )

UNION ALL

SELECT
    'Infosys',
    ROUND(
        (
            (
                SELECT close_price
                FROM infosys
                ORDER BY date DESC
                LIMIT 1
            )
            -
            (
                SELECT close_price
                FROM infosys
                ORDER BY date
                LIMIT 1
            )
        )
        /
        (
            SELECT close_price
            FROM infosys
            ORDER BY date
            LIMIT 1
        ) * 100,
        2
    )

UNION ALL

SELECT
    'TCS',
    ROUND(
        (
            (
                SELECT close_price
                FROM tcs
                ORDER BY date DESC
                LIMIT 1
            )
            -
            (
                SELECT close_price
                FROM tcs
                ORDER BY date
                LIMIT 1
            )
        )
        /
        (
            SELECT close_price
            FROM tcs
            ORDER BY date
            LIMIT 1
        ) * 100,
        2
    )

UNION ALL

SELECT
    'TVS Motors',
    ROUND(
        (
            (
                SELECT close_price
                FROM tvs_motors
                ORDER BY date DESC
                LIMIT 1
            )
            -
            (
                SELECT close_price
                FROM tvs_motors
                ORDER BY date
                LIMIT 1
            )
        )
        /
        (
            SELECT close_price
            FROM tvs_motors
            ORDER BY date
            LIMIT 1
        ) * 100,
        2
    );
    


-- ============================================
-- 13. TASK 12: WORST TRADING DAY
-- ============================================

WITH daily_changes AS (
    SELECT
        'Bajaj Auto' AS stock,
        date,
        close_price,
        LAG(close_price) OVER (ORDER BY date) AS prev_close
    FROM bajaj_auto

    UNION ALL

    SELECT
        'Eicher Motors',
        date,
        close_price,
        LAG(close_price) OVER (ORDER BY date)
    FROM eicher_motors

    UNION ALL

    SELECT
        'Hero Motocorp',
        date,
        close_price,
        LAG(close_price) OVER (ORDER BY date)
    FROM hero_motocorp

    UNION ALL

    SELECT
        'Infosys',
        date,
        close_price,
        LAG(close_price) OVER (ORDER BY date)
    FROM infosys

    UNION ALL

    SELECT
        'TCS',
        date,
        close_price,
        LAG(close_price) OVER (ORDER BY date)
    FROM tcs

    UNION ALL

    SELECT
        'TVS Motors',
        date,
        close_price,
        LAG(close_price) OVER (ORDER BY date)
    FROM tvs_motors
),
ranked AS (
    SELECT
        stock,
        date,
        close_price,
        prev_close,
        ROUND(
            ((close_price - prev_close) / prev_close) * 100,
            2
        ) AS daily_return_pct,
        ROW_NUMBER() OVER (
            PARTITION BY stock
            ORDER BY
                ((close_price - prev_close) / prev_close)
        ) AS rn
    FROM daily_changes
    WHERE prev_close IS NOT NULL
)
SELECT
    stock,
    date,
    close_price,
    prev_close,
    daily_return_pct
FROM ranked
WHERE rn = 1
ORDER BY stock;


-- ============================================
-- 14. TASK 13: CORPORATE ACTION INVESTIGATION
-- ============================================

-- TCS event-date investigation
SELECT
    date,
    close_price
FROM tcs
WHERE date BETWEEN '2018-05-29' AND '2018-06-01'
ORDER BY date;

-- Infosys event-date investigation
SELECT
    date,
    close_price
FROM infosys
WHERE date BETWEEN '2015-06-12' AND '2015-06-16'
ORDER BY date;


-- TCS adjusted return
SELECT
    ROUND(
        (
            (
                (SELECT close_price
                 FROM tcs
                 ORDER BY date DESC
                 LIMIT 1)
                -
                (SELECT close_price / 2
                 FROM tcs
                 ORDER BY date
                 LIMIT 1)
            )
            /
            (SELECT close_price / 2
             FROM tcs
             ORDER BY date
             LIMIT 1)
        ) * 100,
        2
    ) AS adjusted_tcs_return_pct;


-- Infosys adjusted return
SELECT
    ROUND(
        (
            (
                (SELECT close_price
                 FROM infosys
                 ORDER BY date DESC
                 LIMIT 1)
                -
                (SELECT close_price / 2
                 FROM infosys
                 ORDER BY date
                 LIMIT 1)
            )
            /
            (SELECT close_price / 2
             FROM infosys
             ORDER BY date
             LIMIT 1)
        ) * 100,
        2
    ) AS adjusted_infosys_return_pct;