-- Treasury Funding Sources Table
-- Tracks various funding sources and their characteristics

CREATE TABLE [dbo].[TreasuryFundingSources] (
    [FundingSourceID] INT IDENTITY(1,1) PRIMARY KEY,
    [FundingType] NVARCHAR(50) NOT NULL, -- Deposits, Wholesale, Capital Markets, etc.
    [FundingSubType] NVARCHAR(50) NOT NULL,
    [CounterpartyName] NVARCHAR(100) NOT NULL,
    [CounterpartyRating] NVARCHAR(10) NULL,
    [FundingAmount] DECIMAL(18,2) NOT NULL,
    [FundingRate] DECIMAL(7,4) NOT NULL,
    [StartDate] DATE NOT NULL,
    [MaturityDate] DATE NOT NULL,
    [CallableFlag] BIT DEFAULT 0,
    [CallDate] DATE NULL,
    [CurrencyCode] NCHAR(3) NOT NULL DEFAULT 'USD',
    [CollateralRequired] BIT DEFAULT 0,
    [CollateralType] NVARCHAR(50) NULL,
    [FundingCost] DECIMAL(18,2) NOT NULL,
    [RegulatoryTreatment] NVARCHAR(50) NOT NULL,
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [LastModifiedDate] DATETIME2 DEFAULT GETDATE(),
    [LastModifiedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [IsActive] BIT DEFAULT 1
);

-- Create indexes
CREATE NONCLUSTERED INDEX IX_TreasuryFundingSources_Type_Maturity 
ON [dbo].[TreasuryFundingSources] ([FundingType], [MaturityDate]);

CREATE NONCLUSTERED INDEX IX_TreasuryFundingSources_Counterparty 
ON [dbo].[TreasuryFundingSources] ([CounterpartyName]);
