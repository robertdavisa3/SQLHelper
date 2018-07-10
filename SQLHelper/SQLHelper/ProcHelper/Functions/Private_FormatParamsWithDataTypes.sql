
CREATE   FUNCTION ProcHelper.Private_FormatParamsWithDataTypes
(
    @ColumnInfomation ColumnInformation READONLY
    ,@NumberOfSpacesToIndent INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE
        @CRLF CHAR(2) = CHAR(10)
        ,@ReturnValue NVARCHAR(MAX);

    SELECT
        @ReturnValue = CONCAT(@ReturnValue, ProcHelper.Private_CreateStringOfLength(@NumberOfSpacesToIndent, ' '), IIF(C.column_id = 1, ' ', ','), '@', C.ColumnName, ' ', C.ColumnDefinition, ' ', IIF(C.IsNullable = 0, 'NOT NULL', ''), @CRLF)
    FROM
        @ColumnInfomation AS C
    WHERE
        C.IgnoreInsert = 0
        AND C.DefaultValue IS NULL

    RETURN @ReturnValue;
END;