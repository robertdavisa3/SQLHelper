
/*
EXAMPLE EXECUTION
DECLARE @Columns TABLE
(
    ColumnName sysname
    ,ColumnDefinition sysname
    ,IsNullable BIT
    ,is_identity BIT
    ,column_id INT
    ,IgnoreInsert BIT
    ,IgnoreUpdate BIT
    ,DataType sysname
    ,ExampleValue NVARCHAR(400)
    ,DefaultValue NVARCHAR(400)
);

INSERT INTO @Columns
(
    ColumnName
    ,ColumnDefinition
    ,IsNullable
    ,is_identity
    ,column_id
    ,IgnoreInsert
    ,IgnoreUpdate
    ,DataType
    ,ExampleValue
    ,DefaultValue
)
EXEC ProcHelper.Private_GetColumns
    @DBName = 'DBName'
    ,@TableName = 'Table'

SELECT
    *
FROM
    @Columns AS C
*/
CREATE   PROCEDURE ProcHelper.Private_GetColumns
(
    @DBName sysname
    ,@TableName sysname
)
AS
BEGIN
    BEGIN TRY
        DECLARE @SQL NVARCHAR(MAX) = '
        USE'+QUOTENAME(@DBName)+';

        SELECT
            C.name AS ColumnName
            ,UPPER(TP.name) + CASE
                                  WHEN TP.name IN
                                  (
                                      ''varchar''
                                      ,''char''
                                      ,''varbinary''
                                      ,''binary''
                                      ,''text''
                                  ) THEN ''('' + CASE
                                                   WHEN C.max_length = -1 THEN ''MAX''
                                                   ELSE CAST(C.max_length AS VARCHAR(5))
                                               END + '')''
                                  WHEN TP.name IN
                                  (
                                      ''nvarchar''
                                      ,''nchar''
                                      ,''ntext''
                                  ) THEN ''('' + CASE
                                                   WHEN C.max_length = -1 THEN ''MAX''
                                                   ELSE CAST(C.max_length / 2 AS VARCHAR(5))
                                               END + '')''
                                  WHEN TP.name IN
                                  (
                                      ''datetime2''
                                      ,''time2''
                                      ,''datetimeoffset''
                                  ) THEN ''('' + CAST(C.scale AS VARCHAR(5)) + '')''
                                  WHEN TP.name = ''decimal'' THEN ''('' + CAST(C.[precision] AS VARCHAR(5)) + '','' + CAST(C.scale AS VARCHAR(5)) + '')''
                                  ELSE ''''
                              END AS ColumnDefinition
            ,IIF(C.is_nullable = 1, ''1'', ''0'') AS Nullable
            ,C.is_identity
            ,C.column_id
            ,ISNULL(IL.IsActive,0) AS IgnoreInsert
            ,ISNULL(UL.IsActive,0) AS IgnoreUpdate
            ,TP.name AS DataType
            ,EV.Value AS ExampleValue
            ,DV.Value AS DefaultValue
        FROM
            sys.columns AS C
            INNER JOIN sys.types AS TP ON TP.system_type_id = C.system_type_id
                                           AND  TP.user_type_id = C.user_type_id
            INNER JOIN sys.tables AS T ON T.object_id = C.object_id
            LEFT OUTER JOIN Personal.ProcHelper.ExampleValues AS EV ON EV.DataTypeName = TP.name
            LEFT OUTER JOIN Personal.ProcHelper.DefaultValues AS DV ON DV.ColumnName = C.name
            OUTER APPLY
            (
                SELECT
                    *
                FROM
                    Personal.ProcHelper.InsertIgnoreList AS IIL
                WHERE
                    IIL.ColumnName = C.name
            ) AS IL
            OUTER APPLY
            (
                SELECT
                    *
                FROM
                    Personal.ProcHelper.UpdateIgnoreList AS UIL
                WHERE
                    UIL.ColumnName = C.name
            ) AS UL
        WHERE
            T.name = @TableName
            AND C.is_hidden = 0
            AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    Personal.ProcHelper.AlwaysIgnoreList AS AIL
                WHERE
                    AIL.ColumnName = C.name
            );

        '

        EXECUTE sys.sp_executesql @SQL
            ,N'@DBName sysname
            ,@TableName sysname'
            ,@DBName = @DBName
            ,@TableName = @TableName;
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;