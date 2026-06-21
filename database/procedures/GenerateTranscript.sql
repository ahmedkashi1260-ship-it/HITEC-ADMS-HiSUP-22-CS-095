USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE GenerateTranscript
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
        BEGIN
            THROW 50030, 'Student does not exist.', 1;
        END

        ;WITH TranscriptCTE AS (
            SELECT
                s.StudentID,
                s.RollNumber,
                s.FirstName + ' ' + s.LastName AS StudentName,
                c.CourseCode,
                c.CourseTitle,
                c.CreditHours,
                sec.SemesterTerm,
                sec.AcademicYear,
                g.MarksObtained,
                g.LetterGrade,
                g.GradePoint
            FROM Enrollments e
            JOIN Students s ON e.StudentID = s.StudentID
            JOIN Sections sec ON e.SectionID = sec.SectionID
            JOIN Courses c ON sec.CourseID = c.CourseID
            LEFT JOIN Grades g ON g.EnrollmentID = e.EnrollmentID
            WHERE e.StudentID = @StudentID
        )
        SELECT
            StudentID,
            RollNumber,
            StudentName,
            CourseCode,
            CourseTitle,
            CreditHours,
            SemesterTerm,
            AcademicYear,
            MarksObtained,
            LetterGrade,
            GradePoint,
            (GradePoint * CreditHours) AS QualityPoints
        FROM TranscriptCTE
        ORDER BY AcademicYear, SemesterTerm;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO