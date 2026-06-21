USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE ReturnLibraryBook
    @IssueID INT,
    @ReturnDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @ReturnDate IS NULL SET @ReturnDate = GETDATE();

        IF NOT EXISTS (SELECT 1 FROM LibraryIssues WHERE IssueID = @IssueID AND Status = 'Issued')
            THROW 50080, 'Issue record not found or already returned.', 1;

        DECLARE @DueDate DATE, @ItemID INT, @Fine DECIMAL(8,2);
        SELECT @DueDate = DueDate, @ItemID = ItemID 
        FROM LibraryIssues WHERE IssueID = @IssueID;

        SET @Fine = CASE 
            WHEN @ReturnDate > @DueDate
            THEN DATEDIFF(DAY, @DueDate, @ReturnDate) * 10.00
            ELSE 0 
        END;

        BEGIN TRANSACTION;
        UPDATE LibraryIssues
        SET ReturnDate = @ReturnDate, Status = 'Returned', FineAmount = @Fine
        WHERE IssueID = @IssueID;

        UPDATE LibraryItems 
        SET CopiesAvailable = CopiesAvailable + 1 
        WHERE ItemID = @ItemID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO