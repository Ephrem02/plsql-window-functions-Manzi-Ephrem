-- Customers Table: stores basic info for Customers
CREATE TABLE customers (
    customer_id     NUMBER PRIMARY KEY,
    name            VARCHAR(30) NOT NULL,
    region          VARCHAR(30)  NOT NULL
);

-- Products Table: catalog of coffee products
CREATE TABLE products (
    product_id      NUMBER PRIMARY KEY,
    product_name    VARCHAR(30) NOT NULL,
    category        VARCHAR(30)  NOT NULL
);

-- Transactions Table: Records each Transaction performed
CREATE TABLE transactions (
    transaction_id  NUMBER PRIMARY KEY,
    customer_id     NUMBER REFERENCES customers(customer_id),
    product_id      NUMBER REFERENCES products(product_id),
    sale_date       DATE NOT NULL,
    amount          NUMBER(10,2) NOT NULL
);
-- Let's insert values into tables
-- Customers
INSERT INTO customers VALUES (1001, 'Manzi Ephrem', 'Kigali');
INSERT INTO customers VALUES (1002, 'Jabo Elvis', 'Gicumbi');
INSERT INTO customers VALUES (1003, 'Ndamira Josias', 'Ngoma');
INSERT INTO customers VALUES (1004, 'Niyitegeka JD', 'Gashyekero');
INSERT INTO customers VALUES (1005, 'Bisamaza Prince','Califonia');

-- Products
INSERT INTO products VALUES (2001, 'Classic Beans', 'Beans');
INSERT INTO products VALUES (2002, 'Premium Roast', 'Roast');
INSERT INTO products VALUES (2003, 'Espresso Pack', 'Nuts');
INSERT INTO products VALUES (2004, 'Pure Roast', 'Nuts');

-- Trasanctions
INSERT INTO transactions VALUES (3001, 1001, 2001, DATE '2025-08-14', 18500);
INSERT INTO transactions VALUES (3002, 1001, 2002, DATE '2025-08-20', 12500);
INSERT INTO transactions VALUES (3003, 1002, 2003, DATE '2025-09-01', 21000);
INSERT INTO transactions VALUES (3004, 1003, 2001, DATE '2025-09-05', 18500);
INSERT INTO transactions VALUES (3005, 1002, 2002, DATE '2025-09-08', 12500);

-- Top products by total sales amount
SELECT p.product_name,
       SUM(t.amount) AS total_sales,
       RANK() OVER (ORDER BY SUM(t.amount) DESC) AS product_rank
FROM products p
JOIN transactions t ON p.product_id = t.product_id
GROUP BY p.product_name;

-- Running total of sales by date
SELECT sale_date,
       SUM(amount) OVER (ORDER BY sale_date
                         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM transactions;

-- Month-over-month growth
SELECT DISTINCT
       TO_CHAR(sale_date,'YYYY-MM') AS sales_month,
       SUM(amount) OVER (PARTITION BY TO_CHAR(sale_date,'YYYY-MM')) AS monthly_total,
       LAG(SUM(amount)) OVER (ORDER BY TO_CHAR(sale_date,'YYYY-MM')) AS prev_month,
       ( (SUM(amount) OVER (PARTITION BY TO_CHAR(sale_date,'YYYY-MM')))
         - LAG(SUM(amount)) OVER (ORDER BY TO_CHAR(sale_date,'YYYY-MM')) )
         / LAG(SUM(amount)) OVER (ORDER BY TO_CHAR(sale_date,'YYYY-MM')) * 100 AS growth_pct
FROM transactions
GROUP BY TO_CHAR(sale_date,'YYYY-MM');

-- Customer Quartiles
SELECT customer_id,
       SUM(amount) AS total_spent,
       NTILE(4) OVER (ORDER BY SUM(amount) DESC) AS spending_quartile
FROM transactions
GROUP BY customer_id;



