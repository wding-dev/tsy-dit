-- Interest Rate Risk Metrics Table
-- Tracks various interest rate risk measurements and sensitivities

CREATE TABLE [dbo].[InterestRateRiskMetrics] (
    [RiskMetricID] INT IDENTITY(1,1) PRIMARY KEY,
    [MetricType] NVARCHAR(50) NOT NULL, -- Duration, Convexity, VaR, etc.
    [AssetLiabilityType] NVARCHAR(20) NOT NULL, -- Asset, Liability, Net
    [TimeHorizon] NVARCHAR(20) NOT NULL, -- 1M, 3M, 6M, 1Y, etc.
    [MetricValue] DECIMAL(18,6) NOT NULL,
    [BaseScenario] NVARCHAR(50) NOT NULL,
    [StressScenario] NVARCHAR(50) NULL,
    [CalculationDate] DATE NOT NULL,
    [CurrencyCode] NCHAR(3) NOT NULL DEFAULT 'USD',
    [BusinessLine] NVARCHAR(50) NOT NULL,
    [RiskLimit] DECIMAL(18,6) NULL,
    [LimitUtilization] DECIMAL(5,2) NULL,
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [LastModifiedDate] DATETIME2 DEFAULT GETDATE(),
    [LastModifiedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [IsActive] BIT DEFAULT 1
);

-- Create indexes
CREATE NONCLUSTERED INDEX IX_InterestRateRiskMetrics_Type_Date 
ON [dbo].[InterestRateRiskMetrics] ([MetricType], [CalculationDate]);

CREATE NONCLUSTERED INDEX IX_InterestRateRiskMetrics_BusinessLine 
ON [dbo].[InterestRateRiskMetrics] ([BusinessLine]);
