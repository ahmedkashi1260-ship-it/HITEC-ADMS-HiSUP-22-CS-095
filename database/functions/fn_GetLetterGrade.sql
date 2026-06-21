USE HiSUP_DB;
GO

CREATE OR ALTER FUNCTION fn_GetLetterGrade(@Marks DECIMAL(5,2))
RETURNS NVARCHAR(2)
AS
BEGIN
    RETURN CASE
        WHEN @Marks >= 90 THEN 'A+'
        WHEN @Marks >= 85 THEN 'A'
        WHEN @Marks >= 80 THEN 'A-'
        WHEN @Marks >= 75 THEN 'B+'
        WHEN @Marks >= 70 THEN 'B'
        WHEN @Marks >= 65 THEN 'B-'
        WHEN @Marks >= 60 THEN 'C+'
        WHEN @Marks >= 55 THEN 'C'
        WHEN @Marks >= 50 THEN 'C-'
        WHEN @Marks >= 45 THEN 'D'
        ELSE 'F'
    END;
END;
GO