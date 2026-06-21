USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_LibraryOverdue
AS
    SELECT 
        li.IssueID,
        s.StudentID,
        s.RollNumber,
        s.FirstName + ' ' + s.LastName AS StudentName,
        s.Email,
        s.Phone,
        litem.ItemID,
        litem.Title,
        litem.Author,
        litem.ItemType,
        li.IssueDate,
        li.DueDate,
        DATEDIFF(DAY, li.DueDate, GETDATE()) AS DaysOverdue,
        DATEDIFF(DAY, li.DueDate, GETDATE()) * 10.00 AS EstimatedFine
    FROM LibraryIssues li
    JOIN Students s ON li.StudentID = s.StudentID
    JOIN LibraryItems litem ON li.ItemID = litem.ItemID
    WHERE li.Status = 'Issued' 
      AND li.DueDate < CAST(GETDATE() AS DATE);
GO