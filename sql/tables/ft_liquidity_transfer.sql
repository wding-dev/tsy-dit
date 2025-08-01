CREATE TABLE ft_liquidity_transfer (
    transfer_id INT PRIMARY KEY IDENTITY(1,1),
    source_product VARCHAR(50) NOT NULL,
    destination_product VARCHAR(50) NOT NULL,
    rate_type_id INT NOT NULL,
    transfer_amount DECIMAL(18, 2) NOT NULL,
    transfer_date DATE NOT NULL,
    FOREIGN KEY (rate_type_id) REFERENCES dim_rate_type(rate_type_id)
);