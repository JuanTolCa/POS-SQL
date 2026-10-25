-- ============================================================
-- mini-pos-db — reporting queries
-- Conventions: revenue reports count only 'completed' sales,
-- so refunded and voided tickets never inflate the numbers.
-- ============================================================

-- 1. Daily sales summary (completed sales only)
SELECT
    DATE(s.sale_date) AS day,
    COUNT(DISTINCT s.id) AS tickets,
    SUM(i.quantity * i.unit_price) AS revenue
FROM sales s
JOIN sale_items i ON i.sale_id = s.id
WHERE s.status = 'completed'
GROUP BY DATE(s.sale_date)
ORDER BY day;

-- 2. Top 5 best-selling products by revenue
SELECT
    p.sku,
    p.name,
    SUM(i.quantity) AS units_sold,
    SUM(i.quantity * i.unit_price) AS revenue
FROM sale_items i
JOIN sales s ON s.id = i.sale_id
JOIN products p ON p.id = i.product_id
WHERE s.status = 'completed'
GROUP BY p.sku, p.name
ORDER BY revenue DESC
LIMIT 5;

-- 3. Revenue by category
SELECT
    c.name AS category,
    SUM(i.quantity * i.unit_price) AS revenue
FROM sale_items i
JOIN sales s ON s.id = i.sale_id
JOIN products p ON p.id = i.product_id
JOIN categories c ON c.id = p.category_id
WHERE s.status = 'completed'
GROUP BY c.name
ORDER BY revenue DESC;

-- 4. Low-stock alert (active products with fewer than 5 units)
SELECT sku, name, stock
FROM products
WHERE active AND stock < 5
ORDER BY stock;

-- 5. Customer purchase history (completed sales only)
SELECT
    COALESCE(c.full_name, 'Walk-in') AS customer,
    COUNT(DISTINCT s.id) AS tickets,
    SUM(i.quantity * i.unit_price) AS total_spent
FROM sales s
LEFT JOIN customers c ON c.id = s.customer_id
JOIN sale_items i ON i.sale_id = s.id
WHERE s.status = 'completed'
GROUP BY c.full_name
ORDER BY total_spent DESC;

-- 6. Monthly revenue trend
SELECT
    DATE_TRUNC('month', s.sale_date) AS month,
    SUM(i.quantity * i.unit_price) AS revenue
FROM sales s
JOIN sale_items i ON i.sale_id = s.id
WHERE s.status = 'completed'
GROUP BY DATE_TRUNC('month', s.sale_date)
ORDER BY month;
