<?xml version="1.0" encoding="UTF-8"?><sqlb_project><db path="Retail_Analysis.db" readonly="0" foreign_keys="1" case_sensitive_like="0" temp_store="0" wal_autocheckpoint="1000" synchronous="2"/><attached/><window><main_tabs open="structure browser pragmas query" current="3"/></window><tab_structure><column_width id="0" width="300"/><column_width id="1" width="0"/><column_width id="2" width="100"/><column_width id="3" width="2563"/><column_width id="4" width="0"/><expanded_item id="0" parent="1"/><expanded_item id="1" parent="1"/><expanded_item id="2" parent="1"/><expanded_item id="3" parent="1"/></tab_structure><tab_browse><table title="orders" custom_title="0" dock_id="1" table="4,6:mainorders"/><dock_state state="000000ff00000000fd00000001000000020000000000000000fc0100000001fb000000160064006f0063006b00420072006f00770073006500310100000000ffffffff0000011300ffffff000000000000000000000004000000040000000800000008fc00000000"/><default_encoding codec=""/><browse_table_settings/></tab_browse><tab_sql><sql name="SQL 1*">-- ============================================================
-- RETAIL BUSINESS PERFORMANCE ANALYSIS
-- SQL QUERIES
-- ============================================================


-- 1. CHECK ORIGINAL TABLE
SELECT *
FROM orders
LIMIT 10;


-- 2. CHECK TOTAL ROWS
SELECT COUNT(*) AS total_rows
FROM orders;


-- 3. CHECK MISSING VALUES
SELECT
    SUM(CASE WHEN &quot;Order ID&quot; IS NULL THEN 1 ELSE 0 END) AS order_id_missing,
    SUM(CASE WHEN &quot;Product ID&quot; IS NULL THEN 1 ELSE 0 END) AS product_id_missing,
    SUM(CASE WHEN &quot;Sales&quot; IS NULL THEN 1 ELSE 0 END) AS sales_missing,
    SUM(CASE WHEN &quot;Profit&quot; IS NULL THEN 1 ELSE 0 END) AS profit_missing,
    SUM(CASE WHEN &quot;Quantity&quot; IS NULL THEN 1 ELSE 0 END) AS quantity_missing,
    SUM(CASE WHEN &quot;Discount&quot; IS NULL THEN 1 ELSE 0 END) AS discount_missing
FROM orders;


-- 4. CHECK DUPLICATE RECORDS
SELECT
    &quot;Order ID&quot;,
    &quot;Product ID&quot;,
    &quot;Order Date&quot;,
    &quot;Sales&quot;,
    &quot;Quantity&quot;,
    &quot;Discount&quot;,
    &quot;Profit&quot;,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY
    &quot;Order ID&quot;,
    &quot;Product ID&quot;,
    &quot;Order Date&quot;,
    &quot;Sales&quot;,
    &quot;Quantity&quot;,
    &quot;Discount&quot;,
    &quot;Profit&quot;
HAVING COUNT(*) &gt; 1;


-- 5. CREATE CLEAN TABLE
DROP TABLE IF EXISTS orders_clean;

CREATE TABLE orders_clean AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY
                   &quot;Order ID&quot;,
                   &quot;Product ID&quot;,
                   &quot;Order Date&quot;,
                   &quot;Sales&quot;,
                   &quot;Quantity&quot;,
                   &quot;Discount&quot;,
                   &quot;Profit&quot;
               ORDER BY rowid
           ) AS rn
    FROM orders
)
WHERE rn = 1;


-- 6. CHECK CLEAN TABLE
SELECT COUNT(*) AS clean_rows
FROM orders_clean;


-- 7. VIEW CLEAN DATA
SELECT *
FROM orders_clean
LIMIT 10;


-- ============================================================
-- BUSINESS PERFORMANCE ANALYSIS
-- ============================================================


-- 8. OVERALL KPI ANALYSIS
SELECT
    ROUND(SUM(&quot;Sales&quot;), 2) AS total_sales,
    ROUND(SUM(&quot;Profit&quot;), 2) AS total_profit,
    ROUND(
        (SUM(&quot;Profit&quot;) / SUM(&quot;Sales&quot;)) * 100,
        2
    ) AS profit_margin_percentage,
    SUM(&quot;Quantity&quot;) AS total_quantity,
    COUNT(DISTINCT &quot;Order ID&quot;) AS total_orders,
    COUNT(DISTINCT &quot;Customer ID&quot;) AS total_customers
FROM orders_clean;


-- 9. CATEGORY ANALYSIS
SELECT
    &quot;Category&quot;,
    ROUND(SUM(&quot;Sales&quot;), 2) AS total_sales,
    ROUND(SUM(&quot;Profit&quot;), 2) AS total_profit,
    ROUND(
        (SUM(&quot;Profit&quot;) / SUM(&quot;Sales&quot;)) * 100,
        2
    ) AS profit_margin_percentage,
    SUM(&quot;Quantity&quot;) AS total_quantity,
    COUNT(DISTINCT &quot;Order ID&quot;) AS total_orders
FROM orders_clean
GROUP BY &quot;Category&quot;
ORDER BY total_profit DESC;


-- 10. SUB-CATEGORY ANALYSIS
SELECT
    &quot;Category&quot;,
    &quot;Sub-Category&quot;,
    ROUND(SUM(&quot;Sales&quot;), 2) AS total_sales,
    ROUND(SUM(&quot;Profit&quot;), 2) AS total_profit,
    ROUND(
        (SUM(&quot;Profit&quot;) / SUM(&quot;Sales&quot;)) * 100,
        2
    ) AS profit_margin_percentage,
    SUM(&quot;Quantity&quot;) AS total_quantity,
    COUNT(DISTINCT &quot;Order ID&quot;) AS total_orders
FROM orders_clean
GROUP BY
    &quot;Category&quot;,
    &quot;Sub-Category&quot;
ORDER BY total_profit DESC;


-- 11. REGION ANALYSIS
SELECT
    &quot;Region&quot;,
    ROUND(SUM(&quot;Sales&quot;), 2) AS total_sales,
    ROUND(SUM(&quot;Profit&quot;), 2) AS total_profit,
    ROUND(
        (SUM(&quot;Profit&quot;) / SUM(&quot;Sales&quot;)) * 100,
        2
    ) AS profit_margin_percentage,
    SUM(&quot;Quantity&quot;) AS total_quantity,
    COUNT(DISTINCT &quot;Order ID&quot;) AS total_orders,
    COUNT(DISTINCT &quot;Customer ID&quot;) AS total_customers
FROM orders_clean
GROUP BY &quot;Region&quot;
ORDER BY total_profit DESC;


-- 12. SEGMENT ANALYSIS
SELECT
    &quot;Segment&quot;,
    ROUND(SUM(&quot;Sales&quot;), 2) AS total_sales,
    ROUND(SUM(&quot;Profit&quot;), 2) AS total_profit,
    ROUND(
        (SUM(&quot;Profit&quot;) / SUM(&quot;Sales&quot;)) * 100,
        2
    ) AS profit_margin_percentage,
    SUM(&quot;Quantity&quot;) AS total_quantity,
    COUNT(DISTINCT &quot;Order ID&quot;) AS total_orders,
    COUNT(DISTINCT &quot;Customer ID&quot;) AS total_customers
FROM orders_clean
GROUP BY &quot;Segment&quot;
ORDER BY total_profit DESC;


-- 13. DISCOUNT ANALYSIS
SELECT
    &quot;Discount&quot;,
    COUNT(*) AS transaction_count,
    ROUND(SUM(&quot;Sales&quot;), 2) AS total_sales,
    ROUND(SUM(&quot;Profit&quot;), 2) AS total_profit,
    ROUND(
        (SUM(&quot;Profit&quot;) / SUM(&quot;Sales&quot;)) * 100,
        2
    ) AS profit_margin_percentage
FROM orders_clean
GROUP BY &quot;Discount&quot;
ORDER BY &quot;Discount&quot;;


-- 14. YEARLY ANALYSIS
SELECT
    &quot;Year&quot;,
    ROUND(SUM(&quot;Sales&quot;), 2) AS total_sales,
    ROUND(SUM(&quot;Profit&quot;), 2) AS total_profit,
    SUM(&quot;Quantity&quot;) AS total_quantity,
    COUNT(DISTINCT &quot;Order ID&quot;) AS total_orders,
    ROUND(
        (SUM(&quot;Profit&quot;) / SUM(&quot;Sales&quot;)) * 100,
        2
    ) AS profit_margin_percentage
FROM orders_clean
GROUP BY &quot;Year&quot;
ORDER BY &quot;Year&quot;;


-- 15. MONTHLY ANALYSIS
SELECT
    &quot;Year&quot;,
    &quot;Month&quot;,
    &quot;Month_Name&quot;,
    ROUND(SUM(&quot;Sales&quot;), 2) AS total_sales,
    ROUND(SUM(&quot;Profit&quot;), 2) AS total_profit,
    SUM(&quot;Quantity&quot;) AS total_quantity,
    COUNT(DISTINCT &quot;Order ID&quot;) AS total_orders,
    ROUND(
        (SUM(&quot;Profit&quot;) / SUM(&quot;Sales&quot;)) * 100,
        2
    ) AS profit_margin_percentage
FROM orders_clean
GROUP BY
    &quot;Year&quot;,
    &quot;Month&quot;,
    &quot;Month_Name&quot;
ORDER BY
    &quot;Year&quot;,
    &quot;Month&quot;;


-- 16. TOP 10 PRODUCTS BY SALES
SELECT
    &quot;Product ID&quot;,
    &quot;Product Name&quot;,
    &quot;Category&quot;,
    &quot;Sub-Category&quot;,
    ROUND(SUM(&quot;Sales&quot;), 2) AS total_sales,
    ROUND(SUM(&quot;Profit&quot;), 2) AS total_profit,
    SUM(&quot;Quantity&quot;) AS total_quantity
FROM orders_clean
GROUP BY
    &quot;Product ID&quot;,
    &quot;Product Name&quot;,
    &quot;Category&quot;,
    &quot;Sub-Category&quot;
ORDER BY total_sales DESC
LIMIT 10;


-- 17. TOP 10 PRODUCTS BY PROFIT
SELECT
    &quot;Product ID&quot;,
    &quot;Product Name&quot;,
    &quot;Category&quot;,
    &quot;Sub-Category&quot;,
    ROUND(SUM(&quot;Sales&quot;), 2) AS total_sales,
    ROUND(SUM(&quot;Profit&quot;), 2) AS total_profit,
    SUM(&quot;Quantity&quot;) AS total_quantity
FROM orders_clean
GROUP BY
    &quot;Product ID&quot;,
    &quot;Product Name&quot;,
    &quot;Category&quot;,
    &quot;Sub-Category&quot;
ORDER BY total_profit DESC
LIMIT 10;


-- 18. BOTTOM 10 PRODUCTS BY PROFIT
SELECT
    &quot;Product ID&quot;,
    &quot;Product Name&quot;,
    &quot;Category&quot;,
    &quot;Sub-Category&quot;,
    ROUND(SUM(&quot;Sales&quot;), 2) AS total_sales,
    ROUND(SUM(&quot;Profit&quot;), 2) AS total_profit,
    SUM(&quot;Quantity&quot;) AS total_quantity
FROM orders_clean
GROUP BY
    &quot;Product ID&quot;,
    &quot;Product Name&quot;,
    &quot;Category&quot;,
    &quot;Sub-Category&quot;
ORDER BY total_profit ASC
LIMIT 10;


-- 19. TOP 10 CUSTOMERS BY SALES
SELECT
    &quot;Customer ID&quot;,
    &quot;Customer Name&quot;,
    &quot;Segment&quot;,
    ROUND(SUM(&quot;Sales&quot;), 2) AS total_sales,
    ROUND(SUM(&quot;Profit&quot;), 2) AS total_profit,
    SUM(&quot;Quantity&quot;) AS total_quantity,
    COUNT(DISTINCT &quot;Order ID&quot;) AS total_orders
FROM orders_clean
GROUP BY
    &quot;Customer ID&quot;,
    &quot;Customer Name&quot;,
    &quot;Segment&quot;
ORDER BY total_sales DESC
LIMIT 10;


-- 20. TOP 10 CUSTOMERS BY PROFIT
SELECT
    &quot;Customer ID&quot;,
    &quot;Customer Name&quot;,
    &quot;Segment&quot;,
    ROUND(SUM(&quot;Sales&quot;), 2) AS total_sales,
    ROUND(SUM(&quot;Profit&quot;), 2) AS total_profit,
    SUM(&quot;Quantity&quot;) AS total_quantity,
    COUNT(DISTINCT &quot;Order ID&quot;) AS total_orders
FROM orders_clean
GROUP BY
    &quot;Customer ID&quot;,
    &quot;Customer Name&quot;,
    &quot;Segment&quot;
ORDER BY total_profit DESC
LIMIT 10;


-- ============================================================
-- END OF SQL FILE
-- ============================================================</sql><current_tab id="0"/></tab_sql></sqlb_project>
