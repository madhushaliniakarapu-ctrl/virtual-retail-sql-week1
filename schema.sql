-- =====================================================================
-- Virtual Retail Database - Week 1: Data Model (MySQL 8.0)
-- Author: Akarapu Madhu Shalini | YuvaIntern SQL Developer Internship
-- =====================================================================
DROP DATABASE IF EXISTS virtual_retail;
CREATE DATABASE virtual_retail CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE virtual_retail;

-- ---------- Reference / master tables ----------
CREATE TABLE categories (
    category_id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_name      VARCHAR(80)  NOT NULL UNIQUE,
    parent_category_id INT UNSIGNED NULL,
    CONSTRAINT fk_cat_parent FOREIGN KEY (parent_category_id)
        REFERENCES categories(category_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE suppliers (
    supplier_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    supplier_name  VARCHAR(120) NOT NULL,
    contact_email  VARCHAR(150) UNIQUE,
    phone          VARCHAR(20),
    city           VARCHAR(80),
    is_active      TINYINT(1) NOT NULL DEFAULT 1,
    created_at     TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sku            VARCHAR(40)  NOT NULL UNIQUE,
    product_name   VARCHAR(150) NOT NULL,
    category_id    INT UNSIGNED NOT NULL,
    unit_price     DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    unit_cost      DECIMAL(10,2) NOT NULL CHECK (unit_cost  >= 0),
    is_active      TINYINT(1) NOT NULL DEFAULT 1,
    created_at     TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prod_cat FOREIGN KEY (category_id) REFERENCES categories(category_id)
) ENGINE=InnoDB;

-- Resolves the many-to-many between products and suppliers
CREATE TABLE product_suppliers (
    product_id      INT UNSIGNED NOT NULL,
    supplier_id     INT UNSIGNED NOT NULL,
    supply_price    DECIMAL(10,2) NOT NULL CHECK (supply_price >= 0),
    lead_time_days  SMALLINT UNSIGNED NOT NULL DEFAULT 7,
    is_preferred    TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (product_id, supplier_id),
    CONSTRAINT fk_ps_prod FOREIGN KEY (product_id)  REFERENCES products(product_id)   ON DELETE CASCADE,
    CONSTRAINT fk_ps_supp FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE stores (
    store_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    store_name  VARCHAR(100) NOT NULL,
    store_type  ENUM('ONLINE','PHYSICAL','WAREHOUSE') NOT NULL,
    city        VARCHAR(80),
    state       VARCHAR(80)
) ENGINE=InnoDB;

CREATE TABLE inventory (
    store_id        INT UNSIGNED NOT NULL,
    product_id      INT UNSIGNED NOT NULL,
    quantity_on_hand INT NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
    reorder_level   INT NOT NULL DEFAULT 10,
    last_restocked  DATE NULL,
    PRIMARY KEY (store_id, product_id),
    CONSTRAINT fk_inv_store FOREIGN KEY (store_id)   REFERENCES stores(store_id),
    CONSTRAINT fk_inv_prod  FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

-- ---------- Customer domain ----------
CREATE TABLE customers (
    customer_id   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(60)  NOT NULL,
    last_name     VARCHAR(60)  NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    loyalty_tier  ENUM('BRONZE','SILVER','GOLD') NOT NULL DEFAULT 'BRONZE',
    registered_on DATE NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB;

CREATE TABLE customer_addresses (
    address_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT UNSIGNED NOT NULL,
    address_type  ENUM('BILLING','SHIPPING') NOT NULL,
    street        VARCHAR(200) NOT NULL,
    city          VARCHAR(80)  NOT NULL,
    state         VARCHAR(80)  NOT NULL,
    postal_code   VARCHAR(12)  NOT NULL,
    country       VARCHAR(60)  NOT NULL DEFAULT 'India',
    is_default    TINYINT(1)   NOT NULL DEFAULT 0,
    CONSTRAINT fk_addr_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- Sales domain ----------
CREATE TABLE orders (
    order_id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id         INT UNSIGNED NOT NULL,
    store_id            INT UNSIGNED NOT NULL,
    shipping_address_id INT UNSIGNED NULL,
    order_date          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_status        ENUM('PLACED','PAID','SHIPPED','DELIVERED','CANCELLED','RETURNED') NOT NULL DEFAULT 'PLACED',
    total_amount        DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    CONSTRAINT fk_ord_cust  FOREIGN KEY (customer_id)         REFERENCES customers(customer_id),
    CONSTRAINT fk_ord_store FOREIGN KEY (store_id)            REFERENCES stores(store_id),
    CONSTRAINT fk_ord_addr  FOREIGN KEY (shipping_address_id) REFERENCES customer_addresses(address_id)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    order_id    BIGINT UNSIGNED NOT NULL,
    line_no     SMALLINT UNSIGNED NOT NULL,
    product_id  INT UNSIGNED NOT NULL,
    quantity    INT UNSIGNED NOT NULL CHECK (quantity > 0),
    unit_price  DECIMAL(10,2) NOT NULL,          -- price captured at time of sale
    discount_pct DECIMAL(5,2) NOT NULL DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 100),
    PRIMARY KEY (order_id, line_no),
    CONSTRAINT fk_oi_order FOREIGN KEY (order_id)   REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_oi_prod  FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

CREATE TABLE payments (
    payment_id     BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id       BIGINT UNSIGNED NOT NULL,
    payment_method ENUM('UPI','CARD','NETBANKING','COD','WALLET') NOT NULL,
    amount         DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
    payment_status ENUM('PENDING','SUCCESS','FAILED','REFUNDED') NOT NULL DEFAULT 'PENDING',
    paid_at        DATETIME NULL,
    CONSTRAINT fk_pay_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=InnoDB;

-- ---------- Indexing strategy ----------
CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date);
CREATE INDEX idx_orders_date_status   ON orders (order_date, order_status);
CREATE INDEX idx_oi_product           ON order_items (product_id);
CREATE INDEX idx_products_category    ON products (category_id);
CREATE INDEX idx_inventory_product    ON inventory (product_id);
CREATE INDEX idx_payments_order       ON payments (order_id, payment_status);
CREATE INDEX idx_addr_customer        ON customer_addresses (customer_id);
