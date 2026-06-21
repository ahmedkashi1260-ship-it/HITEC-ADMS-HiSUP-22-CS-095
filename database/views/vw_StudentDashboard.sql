USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_StudentDashboard
AS
    SELECT 
        s.StudentID,
        s.RollNumber,
        s.FirstName + ' ' + s.LastName AS FullName,
        s.Email,
        s.EnrollmentYear,
        s.IsActive,
        d.DeptName,
        d.DeptCode,
        dbo.fn_CalculateCGPA(s.StudentID) AS CGPA,
        COUNT(DISTINCT e.EnrollmentID) AS TotalEnrollments,
        COUNT(DISTINCT CASE WHEN e.Status = 'Active' 
              THEN e.EnrollmentID END) AS ActiveEnrollments
    FROM Students s
    JOIN Departments d ON s.DepartmentID = d.DepartmentID
    LEFT JOIN Enrollments e ON s.StudentID = e.StudentID
    GROUP BY s.StudentID, s.RollNumber, s.FirstName, s.LastName,
             s.Email, s.EnrollmentYear, s.IsActive,
             d.DeptName, d.DeptCode;
GO