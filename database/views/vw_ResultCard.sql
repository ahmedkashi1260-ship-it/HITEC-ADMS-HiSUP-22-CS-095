USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_ResultCard
WITH SCHEMABINDING
AS
    SELECT 
        e.EnrollmentID,
        s.StudentID,
        s.RollNumber,
        s.FirstName + ' ' + s.LastName AS StudentName,
        d.DeptName,
        p.ProgramName,
        c.CourseCode,
        c.CourseTitle,
        c.CreditHours,
        sec.SemesterTerm,
        sec.AcademicYear,
        g.MarksObtained,
        g.LetterGrade,
        g.GradePoint,
        g.GradePoint * c.CreditHours AS QualityPoints
    FROM dbo.Enrollments e
    JOIN dbo.Students s ON e.StudentID = s.StudentID
    JOIN dbo.Sections sec ON e.SectionID = sec.SectionID
    JOIN dbo.Courses c ON sec.CourseID = c.CourseID
    JOIN dbo.Departments d ON s.DepartmentID = d.DepartmentID
    JOIN dbo.Programs p ON c.ProgramID = p.ProgramID
    LEFT JOIN dbo.Grades g ON g.EnrollmentID = e.EnrollmentID;
GO