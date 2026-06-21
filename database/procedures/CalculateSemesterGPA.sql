USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE CalculateSemesterGPA
    @StudentID INT,
    @SemesterTerm NVARCHAR(20),
    @AcademicYear NVARCHAR(10),
    @SemesterGPA DECIMAL(3,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
        BEGIN
            THROW 50040, 'Student does not exist.', 1;
        END

        DECLARE @TotalQualityPoints DECIMAL(10,2);
        DECLARE @TotalCreditHours INT;

        SELECT
            @TotalQualityPoints = SUM(g.GradePoint * c.CreditHours),
            @TotalCreditHours = SUM(c.CreditHours)
        FROM Enrollments e
        JOIN Sections sec ON e.SectionID = sec.SectionID
        JOIN Courses c ON sec.CourseID = c.CourseID
        JOIN Grades g ON g.EnrollmentID = e.EnrollmentID
        WHERE e.StudentID = @StudentID
          AND sec.SemesterTerm = @SemesterTerm
          AND sec.AcademicYear = @AcademicYear
          AND g.GradePoint IS NOT NULL;

        IF @TotalCreditHours IS NULL OR @TotalCreditHours = 0
        BEGIN
            SET @SemesterGPA = 0;
        END
        ELSE
        BEGIN
            SET @SemesterGPA = ROUND(@TotalQualityPoints / @TotalCreditHours, 2);
        END

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO