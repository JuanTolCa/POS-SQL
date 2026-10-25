-- ============================================================
-- mini-pos-db — sample data (fictional small general store)
-- Run after schema.sql. All prices in CAD.
-- ============================================================

INSERT INTO categories (name) VALUES
    ('Electronics'),
    ('Home & Office'),
    ('Accessories');

INSERT INTO products (sku, name, category_id, price, stock) VALUES
    ('ELEC-001', 'Wireless Mouse',            1,  29.99, 42),
    ('ELEC-002', 'Mechanical Keyboard',        1,  89.99, 18),
    ('ELEC-003', 'USB-C Hub 7-in-1',           1,  49.99,  3),  -- low stock on purpose
    ('HOME-001', 'Desk Lamp LED',              2,  34.50, 25),
    ('HOME-002', 'Office Chair Ergonomic',     2, 249.00,  7),
    ('HOME-003', 'Notebook A5 (Pack of 3)',    2,  12.99, 60),
    ('ACC-001',  'Laptop Sleeve 15in',         3,  24.99, 30),
    ('ACC-002',  'Phone Stand Adjustable',     3,  19.99,  0);  -- out of stock

INSERT INTO customers (full_name, email, phone) VALUES
    ('Alex Martin', 'alex.martin@example.com', '506-555-0142'),
    ('Sara Chen',   'sara.chen@example.com',   '506-555-0117'),
    ('Tom Becker',  'tom.becker@example.com',  NULL);

-- Six tickets across a few days; one walk-in (NULL customer),
-- one refunded (excluded from revenue reports).
INSERT INTO sales (id, customer_id, sale_date, status) VALUES
    (1, 1, '2026-10-19 10:15:00-03', 'completed'),
    (2, 2, '2026-10-19 14:40:00-03', 'completed'),
    (3, NULL, '2026-10-20 09:05:00-03', 'completed'),
    (4, 3, '2026-10-21 16:20:00-03', 'completed'),
    (5, 1, '2026-10-22 11:30:00-03', 'refunded'),
    (6, 2, '2026-10-23 13:45:00-03', 'completed');
SELECT setval('sales_id_seq', 6);

INSERT INTO sale_items (sale_id, product_id, quantity, unit_price) VALUES
    (1, 1, 2, 29.99), (1, 7, 1, 24.99),
    (2, 2, 1, 89.99), (2, 6, 4, 12.99),
    (3, 4, 1, 34.50), (3, 8, 1, 19.99),
    (4, 5, 1, 249.00),
    (5, 3, 1, 49.99),
    (6, 1, 1, 29.99), (6, 2, 1, 89.99), (6, 6, 2, 12.99);

INSERT INTO payments (sale_id, method, amount) VALUES
    (1, 'card',  84.97),
    (2, 'card', 141.95),
    (3, 'cash',  54.49),
    (4, 'transfer', 249.00),
    (5, 'card',  49.99),
    (6, 'card', 145.96);
