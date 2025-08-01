-- Treasury Cash Flow Projections Table
-- Tracks projected cash flows for liquidity management

CREATE TABLE [dbo].[TreasuryCashFlowProjections] (
    [CashFlowProjectionID] INT IDENTITY(1,1) PRIMARY KEY,
    [ProjectionDate] DATE NOT NULL,
    [CashFlowDate] DATE NOT NULL,
    [CashFlowType] NVARCHAR(50) NOT NULL, -- Inflow, Outflow
    [CashFlowCategory] NVARCHAR(50) NOT NULL, -- Operating, Investing, Financing
    [CashFlowSubCategory] NVARCHAR(100) NOT NULL,
    [ProjectedAmount] DECIMAL(18,2) NOT NULL,
    [ConfidenceLevel] DECIMAL(5,2) NOT NULL, -- 0-100%
    [ScenarioType] NVARCHAR(50) NOT NULL, -- Base, Stress, Optimistic
    [BusinessUnit] NVARCHAR(50) NOT NULL,
    [CounterpartyName] NVARCHAR(100) NULL,
    [CurrencyCode] NCHAR(3) NOT NULL DEFAULT 'USD',
    [IsContractual] BIT DEFAULT 0,
    [ContractReference] NVARCHAR(50) NULL,
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [LastModifiedDate] DATETIME2 DEFAULT GETDATE(),
    [LastModifiedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [IsActive] BIT DEFAULT 1
);

-- Create indexes
CREATE NONCLUSTERED INDEX IX_TreasuryCashFlowProjections_Date_Type 
ON [dbo].[TreasuryCashFlowProjections] ([CashFlowDate], [CashFlowType]);

CREATE NONCLUSTERED INDEX IX_TreasuryCashFlowProjections_Scenario 
ON [dbo].[TreasuryCashFlowProjections] ([ScenarioType]);
