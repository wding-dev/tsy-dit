-- Core Non-Rate Sensitive Deposits Table
-- Tracks deposits that are not sensitive to interest rate changes

CREATE TABLE [dbo].[CoreNonRateSensitiveDeposits] (
    [DepositID] INT IDENTITY(1,1) PRIMARY KEY,
    [AccountNumber] NVARCHAR(20) NOT NULL,
    [CustomerID] INT NOT NULL,
    [DepositType] NVARCHAR(50) NOT NULL,
    [DepositAmount] DECIMAL(18,2) NOT NULL,
    [OpenDate] DATE NOT NULL,
    [MaturityDate] DATE NULL,
    [InterestRate] DECIMAL(5,4) NOT NULL,
    [CoreDepositFlag] BIT DEFAULT 1,
    [StabilityScore] DECIMAL(3,2) NOT NULL,
    [BranchCode] NVARCHAR(10) NOT NULL,
    [ProductCode] NVARCHAR(20) NOT NULL,
    [RiskWeighting] DECIMAL(5,4) DEFAULT 0.0000,
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [LastModifiedDate] DATETIME2 DEFAULT GETDATE(),
    [LastModifiedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [IsActive] BIT DEFAULT 1
);

-- Create indexes
CREATE NONCLUSTERED INDEX IX_CoreNonRateSensitiveDeposits_Customer 
ON [dbo].[CoreNonRateSensitiveDeposits] ([CustomerID]);

CREATE NONCLUSTERED INDEX IX_CoreNonRateSensitiveDeposits_Branch_Product 
ON [dbo].[CoreNonRateSensitiveDeposits] ([BranchCode], [ProductCode]);
