CREATE TABLE fact_deposit (
    deposit_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    amount DECIMAL(18, 2) NOT NULL,
    open_date DATE NOT NULL,
    interest_rate DECIMAL(5, 2),
    CONSTRAINT fk_deposit_customer FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    CONSTRAINT fk_deposit_product FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);
