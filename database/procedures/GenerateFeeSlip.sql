USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE GenerateFeeSlip
    @StudentID INT,
    @Semester INT,
    @AcademicYear INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
            THROW 50120, 'Student does not exist.', 1;

        SELECT 
            s.RollNumber,
            s.FirstName + ' ' + s.LastName AS StudentName,
            d.DeptName,
            p.ProgramName,
            fs.Semester,
            @AcademicYear AS AcademicYear,
            fs.TuitionFee,
            fs.ExamFee,
            fs.LibraryFee,
            fs.OtherCharges,
            fs.TotalAmount AS TotalDue,
            ISNULL(SUM(fp.AmountPaid), 0) AS TotalPaid,
            fs.TotalAmount - ISNULL(SUM(fp.AmountPaid), 0) AS OutstandingBalance,
            CASE 
                WHEN fs.TotalAmount - ISNULL(SUM(fp.AmountPaid), 0) <= 0 
                THEN 'Cleared' 
                ELSE 'Pending' 
            END AS FeeStatus
        FROM Students s
        JOIN Departments d ON s.DepartmentID = d.DepartmentID
        JOIN Programs p ON d.DepartmentID = p.DepartmentID
        JOIN FeeStructure fs ON p.ProgramID = fs.ProgramID 
            AND fs.Semester = @Semester 
            AND fs.EffectiveYear = @AcademicYear
        LEFT JOIN FeePayments fp ON s.StudentID = fp.StudentID 
            AND fp.FeeStructureID = fs.FeeStructureID
        WHERE s.StudentID = @StudentID
        GROUP BY s.RollNumber, s.FirstName, s.LastName, d.DeptName, p.ProgramName,
                 fs.Semester, fs.TuitionFee, fs.ExamFee, fs.LibraryFee, 
                 fs.OtherCharges, fs.TotalAmount;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO