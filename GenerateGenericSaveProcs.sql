USE SQLHelper;
GO

DECLARE
    @DBName sysname = 'DatabaseName'
    ,@TableName sysname = 'TableName'
    ,@Schema sysname = 'dbo'
    ,@TableAlias VARCHAR(10) = 'TN'
    ,@Ticket NVARCHAR(10) = 'TICKET-123';

DROP TABLE IF EXISTS #Columns;

 DECLARE
    @SQL VARCHAR(MAX)
    ,@CRLF CHAR(2) = CHAR(10)
    ,@Date VARCHAR(10) = CONVERT(VARCHAR,CONVERT(DATE,GETDATE()), 101)
    ,@PrimaryKey sysname;

SET NOCOUNT ON

DECLARE @Columns ColumnInformation;

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
    @DBName = @DBName
    ,@TableName = @TableName

SELECT
    @PrimaryKey = C.ColumnName
FROM
    @Columns AS C
WHERE
    C.is_identity = 1
    AND c.column_id = 1

SET @SQL = '
USE '+@DBName+';
GO
/******************************************************************************************************************************
© <COMPANY NAME> '+CONVERT(CHAR(4),YEAR(GETDATE()))+', all rights reserved 

Description: Save information to the ' + @TableName + ' table

Revision History
ChangeDate      ChangedBy                   Ticket#         Comments
'+ProcHelper.Private_CreateRevisionLine(@Ticket,'Initial Creation')+'

Sample execution
EXEC '+@Schema+'.' + @TableName + '_Save
' + ProcHelper.Private_FormatParamsWithExampleValues(@Columns,4) + ';
GO
******************************************************************************************************************************/
CREATE OR ALTER PROCEDURE '+@Schema+'.' + @TableName + '_Save
(
' + ProcHelper.Private_FormatParamsWithDataTypes(@Columns,4) + ')
AS
BEGIN
    BEGIN TRY

        DECLARE @Output TABLE (' + ProcHelper.GetPrimaryKeyDefinition(@Columns) + ');

        BEGIN TRANSACTION;

        MERGE '+@Schema+'.' + @TableName + ' AS TARGET
            USING 
            (
                SELECT
' + STUFF((
    SELECT
        CONCAT('                    ',IIF(C.column_id=1,'  ',','),'@',C.ColumnName,' AS ',C.ColumnName,@CRLF)
    FROM
        @Columns AS C
    WHERE
        C.IgnoreInsert = 0
        AND C.DefaultValue IS NULL
    FOR XML PATH('')
),1,1,'')
+ '            ) AS SOURCE ON SOURCE.'+@PrimaryKey+' = TARGET.'+@PrimaryKey+'
            WHEN MATCHED 
                AND 
                (
                    BINARY_CHECKSUM
                    (
' + STUFF((
    SELECT
        CONCAT('                        ',IIF(C.column_id=2,'  ',','),'SOURCE.',C.ColumnName,@CRLF)
    FROM
        @Columns AS C
    WHERE
        C.column_id <> 1
        AND C.is_identity <> 1
        AND C.IgnoreInsert = 0
        AND C.IgnoreUpdate = 0
        AND C.DefaultValue IS NULL
    FOR XML PATH('')
),1,1,'')
+ '                    )
                    <>
                    BINARY_CHECKSUM
                    (
' + STUFF((
    SELECT
        CONCAT('                        ',IIF(C.column_id=2,'  ',','),'TARGET.',C.ColumnName,@CRLF)
    FROM
        @Columns AS C
    WHERE
        C.column_id <> 1
        AND C.is_identity <> 1
        AND C.IgnoreInsert = 0
        AND C.IgnoreUpdate = 0
        AND C.DefaultValue IS NULL
    FOR XML PATH('')
),1,1,'')
+ '                    )
                )THEN
                UPDATE
                SET
' + STUFF((
    SELECT
        CONCAT('                    ',IIF(C.column_id=2,'  ',','),C.ColumnName,' = ',
            IIF(C.DefaultValue IS NOT NULL
                ,C.DefaultValue 
                ,CONCAT('ISNULL(SOURCE.',C.ColumnName,',TARGET.',C.ColumnName,')')),@CRLF
            )
    FROM
        @Columns AS C
    WHERE
        C.column_id <> 1
        AND C.is_identity <> 1
        AND C.IgnoreUpdate = 0
    FOR XML PATH('')
),1,1,'')
+ '            WHEN NOT MATCHED THEN
                INSERT
                (
' + STUFF((
    SELECT
        CONCAT('                    ',IIF(C.column_id=2,'  ',','),C.ColumnName,@CRLF)
    FROM
        @Columns AS C
    WHERE
        C.column_id <> 1
        AND C.is_identity <> 1
        AND C.IgnoreInsert = 0
    FOR XML PATH('')
),1,1,'')
+ '                )
                VALUES
                (
' + STUFF((
    SELECT
        CONCAT('                    ',IIF(C.column_id=2,'  ',','),
        IIF(C.DefaultValue IS NOT NULL
            ,C.DefaultValue
            ,CONCAT('SOURCE.',C.ColumnName))
        ,@CRLF)
    FROM
        @Columns AS C
    WHERE
        C.column_id <> 1
        AND C.is_identity <> 1
        AND C.IgnoreInsert = 0
    FOR XML PATH('')
),1,1,'')
+ '                )
                OUTPUT
                    Inserted.'+@PrimaryKey+'
                INTO
                    @Output;

                SELECT
                    @'+@PrimaryKey+' = ISNULL(O.'+@PrimaryKey+',@'+@PrimaryKey+')
                FROM
                    @Output AS O;

                SELECT
' + STUFF((
    SELECT
        CONCAT('                   ',IIF(C.column_id=1,'  ',','),@TableAlias,'.',C.ColumnName,@CRLF)
    FROM
        @Columns AS C
    FOR XML PATH('')
),1,1,'')
+ '                FROM
                    '+@Schema+'.' + @TableName + ' AS '+@TableAlias+'
                WHERE
                    '+@TableAlias+'.'+@PrimaryKey+' = @'+@PrimaryKey+';
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
            
        THROW;
    END CATCH
END;
GO
/* ADD SOME PERMISSIONS
GRANT EXECUTE ON '+@Schema+'.' + @TableName + '_Save TO --ROLE;
GO
*/'



--PRINT CAST(@SQL AS NTEXT)

--SELECT @SQL FOR XML PATH('')

EXEC Personal.dbo.LongPrint @String = @SQL


--SELECT
--    *
--FROM
--    #Columns AS C