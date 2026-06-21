USE HiSUP_DB;
GO

-- MERGE: Bulk Grade Import
-- Jab grade already hai to UPDATE, nahi hai to INSERT, 
-- import mein nahi hai to DELETE

-- Step 1: Temporary staging table banao (bulk import ka data yahan aata hai)
CREATE OR ALTER PROCEDURE BulkImportGrades
    @SectionID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Staging table (real app mein CSV se fill hoti hai)
        CREATE TABLE #GradeStaging (
            StudentID INT,
            SectionID INT,
            MarksObtained DECIMAL(6,2),
            GradePoint DECIMAL(3,2)
        );

        -- Test data staging mein insert karo
        INSERT INTO #GradeStaging (StudentID, SectionID, MarksObtained, GradePoint)
        SELECT 
            e.StudentID,
            @SectionID,
            75.00,  -- Sample marks
            3.00    -- Sample grade point
        FROM Enrollments e
        WHERE e.SectionID = @SectionID 
          AND e.Status = 'Active';

        -- MERGE statement
        MERGE INTO Grades AS Target
        USING (
            SELECT 
                gs.StudentID,
                e.EnrollmentID,
                gs.MarksObtained,
                gs.GradePoint,
                dbo.fn_GetLetterGrade(gs.MarksObtained) AS LetterGrade
            FROM #GradeStaging gs
            JOIN Enrollments e ON gs.StudentID = e.StudentID 
                AND e.SectionID = gs.SectionID
        ) AS Source
        ON Target.EnrollmentID = Source.EnrollmentID

        -- Agar grade already hai to UPDATE karo
        WHEN MATCHED THEN
            UPDATE SET 
                Target.MarksObtained = Source.MarksObtained,
                Target.GradePoint = Source.GradePoint,
                Target.LetterGrade = Source.LetterGrade

        -- Agar grade nahi hai to INSERT karo
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (EnrollmentID, MarksObtained, GradePoint, LetterGrade)
            VALUES (
                Source.EnrollmentID,
                Source.MarksObtained,
                Source.GradePoint,
                Source.LetterGrade
            )

        -- Agar student staging mein nahi hai to grade DELETE karo
        WHEN NOT MATCHED BY SOURCE 
            AND Target.EnrollmentID IN (
                SELECT e.EnrollmentID 
                FROM Enrollments e 
                WHERE e.SectionID = @SectionID
            )
        THEN DELETE;

        DROP TABLE #GradeStaging;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DROP TABLE IF EXISTS #GradeStaging;
        THROW;
    END CATCH
END;
GO

-- Test karo
EXEC BulkImportGrades @SectionID = 1;

-- Result dekho
SELECT g.*, e.StudentID 
FROM Grades g
JOIN Enrollments e ON g.EnrollmentID = e.EnrollmentID
WHERE e.SectionID = 1;
GO