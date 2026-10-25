-- ============================================================
-- mini-pos-db — Point-of-sale database schema (PostgreSQL 14+)
-- A small, realistic POS schema: catalog, customers, sales,
-- sale items and payments, with constraints that protect data
-- integrity the way a production system must.
-- ============================================================

-- Reference data: product categories
CREATE TABLE categories (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(60) NOT NULL UNIQUE
);

-- Product catalog
CREATE TABLE products (
    id          SERIAL PRIMARY KEY,
    sku         VARCHAR(20) NOT NULL UNIQUE,
    name        VARCHAR(120) NOT NULL,
    category_id INTEGER NOT NULL REFERENCES categories (id) ON DELETE RESTRICT,
    price       NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    stock       INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    active      BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE INDEX idx_products_category ON products (category_id);

-- Customers (sale.customer_id is nullable: walk-in sales have none)
CREATE TABLE customers (
    id        SERIAL PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email     VARCHAR(120) UNIQUE,
    phone     VARCHAR(30)
);

-- One row per sale (ticket). Totals are derived, never stored,
-- so they can never drift out of sync with the items.
CREATE TABLE sales (
    id          SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers (id) ON DELETE SET NULL,
    sale_date   TIMESTAMPTZ NOT NULL DEFAULT now(),
    status      VARCHAR(20) NOT NULL DEFAULT 'completed'
                CHECK (status IN ('completed', 'refunded', 'voided'))
);
CREATE INDEX idx_sales_date ON sales (sale_date);

-- One row per product on a ticket. unit_price is copied from the
-- catalog at sale time, so later price changes never rewrite history.
CREATE TABLE sale_items (
    id         SERIAL PRIMARY KEY,
    sale_id    INTEGER NOT NULL REFERENCES sales (id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products (id) ON DELETE RESTRICT,
    quantity   INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    UNIQUE (sale_id, product_id)
);
CREATE INDEX idx_sale_items_sale ON sale_items (sale_id);

-- Payments applied to a sale (a sale may be split across methods)
CREATE TABLE payments (
    id      SERIAL PRIMARY KEY,
    sale_id INTEGER NOT NULL REFERENCES sales (id) ON DELETE CASCADE,
    method  VARCHAR(20) NOT NULL CHECK (method IN ('cash', 'card', 'transfer')),
    amount  NUMERIC(10, 2) NOT NULL CHECK (amount > 0)
);
CREATE INDEX idx_payments_sale ON payments (sale_id);

-- Convenience view: one row per sale with its computed total
CREATE VIEW vw_sale_totals AS
SELECT
    s.id          AS sale_id,
    s.sale_date,
    s.status,
    c.full_name   AS customer,
    COUNT(i.id)   AS item_count,
    COALESCE(SUM(i.quantity * i.unit_price), 0) AS total
FROM sales s
LEFT JOIN customers c ON c.id = s.customer_id
LEFT JOIN sale_items i ON i.sale_id = s.id
GROUP BY s.id, s.sale_date, s.status, c.full_name;
