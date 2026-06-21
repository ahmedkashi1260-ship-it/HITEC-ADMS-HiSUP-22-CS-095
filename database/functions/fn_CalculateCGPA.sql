USE HiSUP_DB;
GO

CREATE OR ALTER FUNCTION fn_CalculateCGPA(@StudentID INT)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @CGPA DECIMAL(3,2);
    
    SELECT @CGPA = ROUND(
        SUM(g.GradePoint * c.CreditHours) / NULLIF(SUM(c.CreditHours), 0),
        2)
    FROM Enrollments e
    JOIN Sections sec ON e.SectionID = sec.SectionID
    JOIN Courses c ON sec.CourseID = c.CourseID
    JOIN Grades g ON g.EnrollmentID = e.EnrollmentID
    WHERE e.StudentID = @StudentID 
      AND g.GradePoint IS NOT NULL;

    RETURN ISNULL(@CGPA, 0.00);
END;
GO