
CREATE   FUNCTION ProcHelper.CreateStringOfLength(@Length INT,@Char CHAR)
RETURNS NVARCHAR(MAX)
AS 
BEGIN
    DECLARE 
        @String NVARCHAR(MAX) = ''
        ,@CurrentCount INT = 0;
    WHILE @CurrentCount < @Length
    BEGIN
        SET @String += @Char;
        SET @CurrentCount += 1;
    END;
    RETURN @String;
END;