USE HiSUP_DB;
GO

-- SAVEPOINT: Partial Rollback in Bulk Result Upload
CREATE OR ALTER PROCEDURE BulkUploadResultsWithSavepoint
    @SectionID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ErrorCount INT = 0;
    DECLARE @SuccessCount INT = 0;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Student 1 ka result (valid)
        SAVE TRANSACTION SavePoint1;
        BEGIN TRY
            INSERT INTO Results (ExamID, StudentID, MarksObtained, IsAbsent, PublishedDate)
            SELECT TOP 1 
                es.ExamID, 
                e.StudentID, 
                75.00, 
                0, 
                GETDATE()
            FROM ExamSchedule es
            JOIN Enrollments e ON es.SectionID = e.SectionID
            WHERE es.SectionID = @SectionID 
              AND e.Status = 'Active';
            
            SET @SuccessCount = @SuccessCount + 1;
        END TRY
        BEGIN CATCH
            -- Sirf yeh ek row rollback karo, poora transaction nahi
            ROLLBACK TRANSACTION SavePoint1;
            SET @ErrorCount = @ErrorCount + 1;
        END CATCH

        -- Student 2 ka result (valid)
        SAVE TRANSACTION SavePoint2;
        BEGIN TRY
            INSERT INTO Results (ExamID, StudentID, MarksObtained, IsAbsent, PublishedDate)
            SELECT TOP 1
                es.ExamID,
                e.StudentID,
                85.00,
                0,
                GETDATE()
            FROM ExamSchedule es
            JOIN Enrollments e ON es.SectionID = e.SectionID
            WHERE es.SectionID = @SectionID
              AND e.Status = 'Active'
            ORDER BY e.StudentID DESC;

            SET @SuccessCount = @SuccessCount + 1;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION SavePoint2;
            SET @ErrorCount = @ErrorCount + 1;
        END CATCH

        COMMIT TRANSACTION;

        SELECT 
            @SuccessCount AS SuccessfulInserts,
            @ErrorCount AS FailedInserts;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Test SAVEPOINT
EXEC BulkUploadResultsWithSavepoint @SectionID = 1;
GO

-- =============================================
-- ISOLATION LEVELS TEST
-- =============================================

-- Test 1: READ COMMITTED (Default)
-- Dirty reads nahi hoti -- sirf committed data dikhta hai
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    SELECT StudentID, FirstName, LastName 
    FROM Students 
    WHERE IsActive = 1;
COMMIT TRANSACTION;
GO

-- Test 2: SERIALIZABLE (Strictest)
-- Phantom reads bhi nahi hoti -- poora range lock ho jata hai
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
    SELECT StudentID, FirstName, LastName 
    FROM Students 
    WHERE IsActive = 1;
    
    -- Doosra transaction is range mein INSERT nahi kar sakta
    -- jab tak yeh transaction complete na ho
COMMIT TRANSACTION;
GO

-- Wapas default par
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO