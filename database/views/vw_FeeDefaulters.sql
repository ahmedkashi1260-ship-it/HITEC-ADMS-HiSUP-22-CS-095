USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_FeeDefaulters
AS
    SELECT 
        s.StudentID,
        s.RollNumber,
        s.FirstName + ' ' + s.LastName AS StudentName,
        s.Email,
        s.Phone,
        d.DeptName,
        p.ProgramName,
        fs.Semester,
        fs.EffectiveYear,
        fs.TotalAmount AS TotalDue,
        ISNULL(SUM(fp.AmountPaid), 0) AS TotalPaid,
        fs.TotalAmount - ISNULL(SUM(fp.AmountPaid), 0) AS OutstandingBalance
    FROM Students s
    JOIN Departments d ON s.DepartmentID = d.DepartmentID
    JOIN Programs p ON d.DepartmentID = p.DepartmentID
    JOIN FeeStructure fs ON p.ProgramID = fs.ProgramID
    LEFT JOIN FeePayments fp ON s.StudentID = fp.StudentID 
        AND fp.FeeStructureID = fs.FeeStructureID
    WHERE s.IsActive = 1
    GROUP BY s.StudentID, s.RollNumber, s.FirstName, s.LastName,
             s.Email, s.Phone, d.DeptName, p.ProgramName,
             fs.Semester, fs.EffectiveYear, fs.TotalAmount
    HAVING fs.TotalAmount - ISNULL(SUM(fp.AmountPaid), 0) > 0;
GO