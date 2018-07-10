CREATE TYPE [dbo].[ColumnInformation] AS TABLE (
    [ColumnName]       [sysname]      NOT NULL,
    [ColumnDefinition] [sysname]      NOT NULL,
    [IsNullable]       BIT            NULL,
    [is_identity]      BIT            NULL,
    [column_id]        INT            NULL,
    [IgnoreInsert]     BIT            NULL,
    [IgnoreUpdate]     BIT            NULL,
    [DataType]         [sysname]      NOT NULL,
    [ExampleValue]     NVARCHAR (400) NULL,
    [DefaultValue]     NVARCHAR (400) NULL);

