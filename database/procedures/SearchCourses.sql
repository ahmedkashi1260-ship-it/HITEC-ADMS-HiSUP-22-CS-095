USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE SearchCourses
    @Keyword NVARCHAR(100) = NULL,
    @DepartmentID INT = NULL,
    @Semester INT = NULL,
    @ProgramID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @SQL NVARCHAR(MAX);
        DECLARE @Params NVARCHAR(500);

        SET @SQL = N'
        SELECT 
            c.CourseID, c.CourseCode, c.CourseTitle, 
            c.CreditHours, c.Semester,
            p.ProgramName, d.DeptName,
            COUNT(sec.SectionID) AS AvailableSections
        FROM Courses c
        JOIN Programs p ON c.ProgramID = p.ProgramID
        JOIN Departments d ON p.DepartmentID = d.DepartmentID
        LEFT JOIN Sections sec ON c.CourseID = sec.CourseID
        WHERE c.IsActive = 1';

        IF @Keyword IS NOT NULL
            SET @SQL = @SQL + N' AND (c.CourseTitle LIKE ''%'' + @Keyword + ''%'' 
                               OR c.CourseCode LIKE ''%'' + @Keyword + ''%'')';

        IF @DepartmentID IS NOT NULL
            SET @SQL = @SQL + N' AND d.DepartmentID = @DepartmentID';

        IF @Semester IS NOT NULL
            SET @SQL = @SQL + N' AND c.Semester = @Semester';

        IF @ProgramID IS NOT NULL
            SET @SQL = @SQL + N' AND c.ProgramID = @ProgramID';

        SET @SQL = @SQL + N' GROUP BY c.CourseID, c.CourseCode, c.CourseTitle, 
                            c.CreditHours, c.Semester, p.ProgramName, d.DeptName
                            ORDER BY d.DeptName, c.Semester, c.CourseCode';

        SET @Params = N'@Keyword NVARCHAR(100), @DepartmentID INT, 
                        @Semester INT, @ProgramID INT';

        EXEC sp_executesql @SQL, @Params,
            @Keyword = @Keyword,
            @DepartmentID = @DepartmentID,
            @Semester = @Semester,
            @ProgramID = @ProgramID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO