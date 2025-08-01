CREATE TABLE ft_ftp_rates (
    rate_id INT PRIMARY KEY IDENTITY(1,1),
    product_type VARCHAR(50) NOT NULL,
    rate_type_id INT NOT NULL,
    ftp_rate DECIMAL(5, 2) NOT NULL,
    effective_date DATE NOT NULL,
    FOREIGN KEY (rate_type_id) REFERENCES dim_rate_type(rate_type_id)
);