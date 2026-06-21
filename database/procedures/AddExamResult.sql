USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE AddExamResult
    @ExamID INT,
    @StudentID INT,
    @MarksObtained DECIMAL(6,2),
    @IsAbsent BIT = 0,
    @NewResultID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM ExamSchedule WHERE ExamID = @ExamID)
            THROW 50090, 'Exam does not exist.', 1;

        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
            THROW 50091, 'Student does not exist.', 1;

        DECLARE @TotalMarks INT;
        SELECT @TotalMarks = TotalMarks FROM ExamSchedule WHERE ExamID = @ExamID;

        IF @MarksObtained > @TotalMarks
            THROW 50092, 'Marks obtained cannot exceed total marks.', 1;

        BEGIN TRANSACTION;
        INSERT INTO Results (ExamID, StudentID, MarksObtained, IsAbsent, PublishedDate)
        VALUES (@ExamID, @StudentID, @MarksObtained, @IsAbsent, GETDATE());
        SET @NewResultID = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO