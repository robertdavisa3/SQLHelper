CREATE   FUNCTION ProcHelper.GetPrimaryKeyDefinition
(
    @ColumnInfomation ColumnInformation READONLY
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE
        @ReturnValue NVARCHAR(MAX);

    SELECT
        @ReturnValue = CONCAT(C.ColumnName,' ',C.ColumnDefinition)
    FROM
        @ColumnInfomation AS C
    WHERE
        C.column_id = 1
        AND C.is_identity = 1

    RETURN @ReturnValue;
END;