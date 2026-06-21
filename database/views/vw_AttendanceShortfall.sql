USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_AttendanceShortfall
AS
    SELECT 
        s.StudentID,
        s.RollNumber,
        s.FirstName + ' ' + s.LastName AS StudentName,
        c.CourseCode,
        c.CourseTitle,
        sec.SectionID,
        sec.SemesterTerm,
        sec.AcademicYear,
        COUNT(ar.AttendanceID) AS TotalClasses,
        SUM(CASE WHEN ar.Status = 'Present' THEN 1 ELSE 0 END) AS PresentCount,
        SUM(CASE WHEN ar.Status = 'Absent' THEN 1 ELSE 0 END) AS AbsentCount,
        ROUND(
            CAST(SUM(CASE WHEN ar.Status = 'Present' THEN 1 ELSE 0 END) AS DECIMAL)
            / NULLIF(COUNT(ar.AttendanceID), 0) * 100
        , 2) AS AttendancePct
    FROM Students s
    JOIN Enrollments e ON s.StudentID = e.StudentID
    JOIN Sections sec ON e.SectionID = sec.SectionID
    JOIN Courses c ON sec.CourseID = c.CourseID
    LEFT JOIN AttendanceRecords ar ON s.StudentID = ar.StudentID 
        AND sec.SectionID = ar.SectionID
    WHERE e.Status = 'Active'
    GROUP BY s.StudentID, s.RollNumber, s.FirstName, s.LastName,
             c.CourseCode, c.CourseTitle, sec.SectionID,
             sec.SemesterTerm, sec.AcademicYear
    HAVING 
        ROUND(
            CAST(SUM(CASE WHEN ar.Status = 'Present' THEN 1 ELSE 0 END) AS DECIMAL)
            / NULLIF(COUNT(ar.AttendanceID), 0) * 100
        , 2) < 75;
GO