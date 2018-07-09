
CREATE   FUNCTION ProcHelper.Private_CreateRevisionLine(@Ticket NVARCHAR(10), @Comment NVARCHAR(50) = 'Initial creation')
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @RevisionLine NVARCHAR(MAX)
        ,@Date NVARCHAR(10) = CONVERT(VARCHAR(MAX),GETDATE(),101);
    SET @RevisionLine = @Date
                        +ProcHelper.Private_CreateStringOfLength(16-LEN(@Date),' ')
                        +SUSER_NAME()
                        +ProcHelper.Private_CreateStringOfLength(28-LEN(SUSER_NAME()),' ')
                        +@Ticket
                        +ProcHelper.Private_CreateStringOfLength(16-LEN(@Ticket),' ')
                        +@Comment
    RETURN @RevisionLine;
END;