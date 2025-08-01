CREATE TABLE fact_loan (
    loan_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    amount DECIMAL(18, 2) NOT NULL,
    start_date DATE NOT NULL,
    maturity_date DATE NOT NULL,
    interest_rate DECIMAL(5, 2),
    CONSTRAINT fk_loan_customer FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    CONSTRAINT fk_loan_product FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);
