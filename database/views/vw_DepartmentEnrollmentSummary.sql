USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_DepartmentEnrollmentSummary
AS
    SELECT 
        d.DepartmentID,
        d.DeptName,
        d.DeptCode,
        d.EstablishedYear,
        COUNT(DISTINCT s.StudentID) AS TotalStudents,
        COUNT(DISTINCT f.FacultyID) AS TotalFaculty,
        COUNT(DISTINCT p.ProgramID) AS TotalPrograms,
        COUNT(DISTINCT c.CourseID) AS TotalCourses,
        COUNT(DISTINCT e.EnrollmentID) AS ActiveEnrollments
    FROM Departments d
    LEFT JOIN Students s ON d.DepartmentID = s.DepartmentID 
        AND s.IsActive = 1
    LEFT JOIN Faculty f ON d.DepartmentID = f.DepartmentID 
        AND f.IsActive = 1
    LEFT JOIN Programs p ON d.DepartmentID = p.DepartmentID
    LEFT JOIN Courses c ON p.ProgramID = c.ProgramID 
        AND c.IsActive = 1
    LEFT JOIN Sections sec ON c.CourseID = sec.CourseID
    LEFT JOIN Enrollments e ON sec.SectionID = e.SectionID 
        AND e.Status = 'Active'
    GROUP BY d.DepartmentID, d.DeptName, d.DeptCode, d.EstablishedYear;
GO