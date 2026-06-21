USE HiSUP_DB;
GO

CREATE OR ALTER TRIGGER trg_AfterEnrollment
ON Enrollments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Sections
    SET SeatsFilled = SeatsFilled + 1
    WHERE SectionID IN (
        SELECT SectionID 
        FROM inserted 
        WHERE Status = 'Active'
    );
END;
GO