# Virtual Retail Database - Data Model & Architecture (Week 1)

SQL Developer Internship (YuvaIntern) - Week 1: Data Modeling and Architecture Design  
Author: Akarapu Madhu Shalini

## Overview
Relational data model for a virtual retail business with an online store, physical outlets,
suppliers, customers, orders, payments and per-location inventory. Designed in Third Normal Form
for MySQL 8.0.

## Contents
| File | Description |
|---|---|
| `schema.sql` | Full DDL: 11 tables, primary/foreign keys, CHECK/UNIQUE constraints, indexes |
| `erd.png` | Entity-relationship diagram |
| `architecture.png` | Layered architecture: source > staging > core OLTP > reporting |

## Entities
`customers`, `customer_addresses`, `categories`, `suppliers`, `products`, `product_suppliers`,
`stores`, `inventory`, `orders`, `order_items`, `payments`

## How to run
```sql
SOURCE schema.sql;   -- creates the virtual_retail database and all tables
```

## Design highlights
- 3NF with controlled denormalization (price snapshot in `order_items`)
- Junction tables resolve M:N relationships (`product_suppliers`, `inventory`)
- Composite indexes chosen from expected query patterns
- Partitioning, archiving and read-replica plan for scalability

## Roadmap
Week 2 ETL plan - Week 3 query optimization - Week 4 reporting - Week 5 automation
