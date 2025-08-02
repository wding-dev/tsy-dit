CREATE TABLE tblHedgeEffectiveness (
    hedge_effectiveness_id INT PRIMARY KEY IDENTITY(1,1),
    hedge_relationship_id INT NOT NULL,
    test_date DATE NOT NULL,
    test_period_start DATE NOT NULL,
    test_period_end DATE NOT NULL,
    test_type VARCHAR(50) NOT NULL, -- 'Prospective', 'Retrospective', 'Both'
    test_method VARCHAR(50) NOT NULL, -- 'Dollar Offset', 'Regression Analysis', 'Ratio Analysis'
    
    -- Hedged Item Details
    hedged_item_id VARCHAR(50) NOT NULL,
    hedged_item_type VARCHAR(50) NOT NULL, -- 'Asset', 'Liability', 'Forecast Transaction'
    hedged_item_fair_value_change DECIMAL(18,4) NULL,
    hedged_item_cash_flow_change DECIMAL(18,4) NULL,
    
    -- Hedging Instrument Details
    hedging_instrument_id VARCHAR(50) NOT NULL,
    hedging_instrument_type VARCHAR(50) NOT NULL, -- 'Derivative', 'Non-derivative'
    hedging_instrument_fair_value_change DECIMAL(18,4) NULL,
    hedging_instrument_cash_flow_change DECIMAL(18,4) NULL,
    
    -- Effectiveness Test Results
    effectiveness_ratio DECIMAL(10,6) NULL, -- Should be between 0.80 and 1.25 for effective hedge
    dollar_offset DECIMAL(18,4) NULL,
    regression_r_squared DECIMAL(10,6) NULL,
    regression_slope DECIMAL(10,6) NULL,
    regression_intercept DECIMAL(18,4) NULL,
    
    -- Test Results
    is_effective BIT NOT NULL DEFAULT 0,
    effectiveness_status VARCHAR(20) NOT NULL DEFAULT 'Ineffective', -- 'Effective', 'Ineffective', 'Highly Effective'
    ineffectiveness_amount DECIMAL(18,4) NULL,
    
    -- Documentation and Audit
    test_performed_by VARCHAR(100) NOT NULL,
    test_reviewed_by VARCHAR(100) NULL,
    documentation_reference VARCHAR(255) NULL,
    comments TEXT NULL,
    
    -- System Fields
    is_active BIT DEFAULT 1,
    created_date DATETIME DEFAULT GETDATE(),
    created_by VARCHAR(100) DEFAULT SYSTEM_USER,
    modified_date DATETIME DEFAULT GETDATE(),
    modified_by VARCHAR(100) DEFAULT SYSTEM_USER,
    
    -- Constraints
    CONSTRAINT CK_tblHedgeEffectiveness_TestType 
        CHECK (test_type IN ('Prospective', 'Retrospective', 'Both')),
    CONSTRAINT CK_tblHedgeEffectiveness_TestMethod 
        CHECK (test_method IN ('Dollar Offset', 'Regression Analysis', 'Ratio Analysis', 'Statistical Analysis')),
    CONSTRAINT CK_tblHedgeEffectiveness_HedgedItemType 
        CHECK (hedged_item_type IN ('Asset', 'Liability', 'Forecast Transaction', 'Net Investment')),
    CONSTRAINT CK_tblHedgeEffectiveness_HedgingInstrumentType 
        CHECK (hedging_instrument_type IN ('Derivative', 'Non-derivative')),
    CONSTRAINT CK_tblHedgeEffectiveness_EffectivenessStatus 
        CHECK (effectiveness_status IN ('Effective', 'Ineffective', 'Highly Effective')),
    CONSTRAINT CK_tblHedgeEffectiveness_EffectivenessRatio 
        CHECK (effectiveness_ratio IS NULL OR (effectiveness_ratio >= 0 AND effectiveness_ratio <= 10))
);

-- Create indexes for performance
CREATE INDEX IX_tblHedgeEffectiveness_HedgeRelationshipId 
    ON tblHedgeEffectiveness (hedge_relationship_id);

CREATE INDEX IX_tblHedgeEffectiveness_TestDate 
    ON tblHedgeEffectiveness (test_date);

CREATE INDEX IX_tblHedgeEffectiveness_HedgedItemId 
    ON tblHedgeEffectiveness (hedged_item_id);

CREATE INDEX IX_tblHedgeEffectiveness_HedgingInstrumentId 
    ON tblHedgeEffectiveness (hedging_instrument_id);

CREATE INDEX IX_tblHedgeEffectiveness_IsEffective 
    ON tblHedgeEffectiveness (is_effective, test_date);

-- Insert sample data for testing
INSERT INTO tblHedgeEffectiveness (
    hedge_relationship_id, test_date, test_period_start, test_period_end,
    test_type, test_method, hedged_item_id, hedged_item_type,
    hedged_item_fair_value_change, hedging_instrument_id, hedging_instrument_type,
    hedging_instrument_fair_value_change, effectiveness_ratio, is_effective,
    effectiveness_status, test_performed_by
)
VALUES 
(1, '2025-01-31', '2025-01-01', '2025-01-31', 'Retrospective', 'Dollar Offset', 
 'BOND-001', 'Asset', -50000.00, 'IRS-001', 'Derivative', 
 48000.00, 0.96, 1, 'Effective', 'Risk Management Team'),

(1, '2025-02-28', '2025-02-01', '2025-02-28', 'Retrospective', 'Dollar Offset', 
 'BOND-001', 'Asset', -75000.00, 'IRS-001', 'Derivative', 
 72500.00, 0.97, 1, 'Effective', 'Risk Management Team'),

(2, '2025-01-31', '2025-01-01', '2025-01-31', 'Both', 'Regression Analysis', 
 'LOAN-PORT-001', 'Asset', 125000.00, 'FUT-001', 'Derivative', 
 -118000.00, 0.94, 1, 'Effective', 'Risk Management Team');