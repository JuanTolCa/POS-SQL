# mini-pos-db

A small point-of-sale database in PostgreSQL, built as a portfolio project
to demonstrate relational design, data-integrity constraints, and
reporting queries — the kind of data-layer work behind the business
systems I have built throughout my career (POS and CRM).

## What's inside

| File           | Contents                                                     |
| -------------- | ------------------------------------------------------------ |
| `schema.sql`   | Tables, constraints, indexes, and a sale-totals view         |
| `seed.sql`     | Fictional sample data for a small general store (CAD prices) |
| `queries.sql`  | Six reporting queries used by a store manager                |

Schema: `categories` → `products` → `sale_items` ← `sales` →
`payments`, with `customers` linked to sales.

## Design decisions

- **Totals are derived, never stored.** Sale totals come from a view
  over `sale_items`, so they can never drift out of sync with the items.
- **Prices are frozen at sale time.** `sale_items.unit_price` is copied
  from the catalog when the ticket is created, so later price changes
  never rewrite history.
- **Walk-in sales are supported.** `sales.customer_id` is nullable.
- **Reports count completed sales only.** Refunded and voided tickets
  are excluded, so revenue figures stay honest.
- **Integrity is enforced by the database**, not by application code:
  foreign keys, `CHECK` constraints (non-negative prices and stock,
  positive quantities), and unique constraints.

## How to run it

Requires PostgreSQL 14+.

```bash
createdb minipos
psql -d minipos -f schema.sql
psql -d minipos -f seed.sql
psql -d minipos -f queries.sql
```

## Sample output (verified against PostgreSQL)

Daily sales summary:

```
    day     | tickets | revenue
------------+---------+---------
 2026-10-19 |       2 |  226.92
 2026-10-20 |       1 |   54.49
 2026-10-21 |       1 |  249.00
 2026-10-23 |       1 |  145.96
```

Top products by revenue:

```
        sku        |          name          | units_sold | revenue
-------------------+------------------------+------------+---------
 HOME-002          | Office Chair Ergonomic |          1 |  249.00
 ELEC-002          | Mechanical Keyboard    |          2 |  179.98
 ELEC-001          | Wireless Mouse         |          3 |   89.97
```

Note the refunded ticket from 2026-10-22 is correctly absent from
both reports.

## Author

Juan Toledo — software developer, Moncton, New Brunswick, Canada.
