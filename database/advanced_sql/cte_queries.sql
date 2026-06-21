USE HiSUP_DB;
GO

-- CTE 1: Recursive CTE -- Course Prerequisites Chain
WITH RecursivePrerequisites AS (
    -- Base case: starting course
    SELECT 
        c.CourseID,
        c.CourseCode,
        c.CourseTitle,
        c.PrerequisiteCourseID,
        0 AS Level,
        CAST(c.CourseCode AS NVARCHAR(MAX)) AS PrerequisiteChain
    FROM Courses c
    WHERE c.PrerequisiteCourseID IS NULL

    UNION ALL

    -- Recursive case: courses that have prerequisites
    SELECT 
        c.CourseID,
        c.CourseCode,
        c.CourseTitle,
        c.PrerequisiteCourseID,
        rp.Level + 1,
        rp.PrerequisiteChain + N' -> ' + c.CourseCode
    FROM Courses c
    JOIN RecursivePrerequisites rp ON c.PrerequisiteCourseID = rp.CourseID
)
SELECT * FROM RecursivePrerequisites
ORDER BY Level, CourseCode;
GO

-- CTE 2: Regular CTE -- Top Student per Department
WITH StudentGPA AS (
    SELECT 
        s.StudentID,
        s.RollNumber,
        s.FirstName + ' ' + s.LastName AS StudentName,
        s.DepartmentID,
        d.DeptName,
        ROUND(SUM(g.GradePoint * c.CreditHours) / 
            NULLIF(SUM(c.CreditHours), 0), 2) AS CGPA
    FROM Students s
    JOIN Departments d ON s.DepartmentID = d.DepartmentID
    JOIN Enrollments e ON s.StudentID = e.StudentID
    JOIN Sections sec ON e.SectionID = sec.SectionID
    JOIN Courses c ON sec.CourseID = c.CourseID
    JOIN Grades g ON e.EnrollmentID = g.EnrollmentID
    WHERE g.GradePoint IS NOT NULL
    GROUP BY s.StudentID, s.RollNumber, s.FirstName, 
             s.LastName, s.DepartmentID, d.DeptName
),
RankedStudents AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY DepartmentID 
            ORDER BY CGPA DESC
        ) AS DeptRank
    FROM StudentGPA
)
SELECT 
    DeptName,
    StudentName,
    RollNumber,
    CGPA,
    DeptRank
FROM RankedStudents
WHERE DeptRank <= 3
ORDER BY DeptName, DeptRank;
GO