CREATE TABLE dim_rate_type (
    rate_type_id INT PRIMARY KEY IDENTITY(1,1),
    rate_type_name VARCHAR(50) NOT NULL,
    description VARCHAR(255) NULL,
    is_active BIT DEFAULT 1,
    created_date DATETIME DEFAULT GETDATE(),
    modified_date DATETIME DEFAULT GETDATE()
);

-- Insert initial rate types
INSERT INTO dim_rate_type (rate_type_name, description)
VALUES 
('Fixed', 'Fixed interest rate'),
('Variable', 'Variable interest rate'),
('Overnight', 'Overnight rate'),
('Term', 'Term deposit rate'),
('Base', 'Base lending rate');