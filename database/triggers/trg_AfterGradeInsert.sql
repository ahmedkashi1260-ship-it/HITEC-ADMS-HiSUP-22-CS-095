USE HiSUP_DB;
GO

CREATE OR ALTER TRIGGER trg_AfterGradeInsert
ON Grades
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE g
    SET g.LetterGrade = dbo.fn_GetLetterGrade(i.MarksObtained)
    FROM Grades g
    JOIN inserted i ON g.GradeID = i.GradeID
    WHERE i.MarksObtained IS NOT NULL;
END;
GO