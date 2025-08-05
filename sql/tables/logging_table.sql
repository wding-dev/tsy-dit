-- =============================================
-- Logging Table for System Monitoring and Application Logs
-- Created: 2025-08-05
-- Purpose: Store system performance metrics and application log entries
-- =============================================

CREATE TABLE [dbo].[logging] (
    [log_id] BIGINT IDENTITY(1,1) NOT NULL,
    [timestamp] DATETIME2(3) NOT NULL DEFAULT GETUTCDATE(),
    [log_level] VARCHAR(10) NOT NULL,
    [category] VARCHAR(50) NOT NULL,
    [source] VARCHAR(100) NOT NULL,
    [message] NVARCHAR(MAX) NULL,
    [cpu_percentage] DECIMAL(5,2) NULL,
    [memory_percentage] DECIMAL(5,2) NULL,
    [additional_data] NVARCHAR(MAX) NULL,
    [created_by] VARCHAR(100) NOT NULL DEFAULT SYSTEM_USER,
    [created_date] DATETIME2(3) NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT [PK_logging] PRIMARY KEY CLUSTERED ([log_id] ASC),
    CONSTRAINT [CK_logging_log_level] CHECK ([log_level] IN ('DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL')),
    CONSTRAINT [CK_logging_cpu_percentage] CHECK ([cpu_percentage] >= 0 AND [cpu_percentage] <= 100),
    CONSTRAINT [CK_logging_memory_percentage] CHECK ([memory_percentage] >= 0 AND [memory_percentage] <= 100)
);

-- Create indexes for better query performance
CREATE NONCLUSTERED INDEX [IX_logging_timestamp] ON [dbo].[logging] ([timestamp] DESC);
CREATE NONCLUSTERED INDEX [IX_logging_level_category] ON [dbo].[logging] ([log_level], [category]);
CREATE NONCLUSTERED INDEX [IX_logging_source] ON [dbo].[logging] ([source]);

-- Add table description
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Stores system monitoring data and application log entries with performance metrics',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'logging';

-- Add column descriptions
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Unique identifier for each log entry',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'logging',
    @level2type = N'COLUMN', @level2name = N'log_id';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Timestamp when the log entry was created',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'logging',
    @level2type = N'COLUMN', @level2name = N'timestamp';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Log level: DEBUG, INFO, WARN, ERROR, FATAL',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'logging',
    @level2type = N'COLUMN', @level2name = N'log_level';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Category of the log entry (e.g., SYSTEM, APPLICATION, PERFORMANCE)',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'logging',
    @level2type = N'COLUMN', @level2name = N'category';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Source system or application generating the log',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'logging',
    @level2type = N'COLUMN', @level2name = N'source';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Log message content',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'logging',
    @level2type = N'COLUMN', @level2name = N'message';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', @value = N'CPU usage percentage at time of logging',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'logging',
    @level2type = N'COLUMN', @level2name = N'cpu_percentage';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Memory usage percentage at time of logging',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'logging',
    @level2type = N'COLUMN', @level2name = N'memory_percentage';

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Additional data in JSON format for extended logging information',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'logging',
    @level2type = N'COLUMN', @level2name = N'additional_data';

-- Sample insert statements for testing
/*
-- Example: System performance log
INSERT INTO [dbo].[logging] ([log_level], [category], [source], [message], [cpu_percentage], [memory_percentage])
VALUES ('INFO', 'PERFORMANCE', 'SYSTEM_MONITOR', 'System performance metrics captured', 12.3, 53.4);

-- Example: Application log
INSERT INTO [dbo].[logging] ([log_level], [category], [source], [message], [additional_data])
VALUES ('ERROR', 'APPLICATION', 'MCP_SERVER', 'Failed to connect to database', '{"error_code": "DB001", "retry_count": 3}');

-- Example: Docker container log
INSERT INTO [dbo].[logging] ([log_level], [category], [source], [message], [additional_data])
VALUES ('INFO', 'CONTAINER', 'DOCKER', 'Container started successfully', '{"container_id": "abc123", "image": "mcp-server:latest"}');
*/