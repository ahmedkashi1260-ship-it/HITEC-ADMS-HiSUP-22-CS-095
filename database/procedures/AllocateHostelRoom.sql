USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE AllocateHostelRoom
    @StudentID INT,
    @HostelID INT,
    @RoomNumber NVARCHAR(10),
    @NewAllotmentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID AND IsActive = 1)
            THROW 50060, 'Student does not exist or is not active.', 1;

        IF NOT EXISTS (SELECT 1 FROM Hostels WHERE HostelID = @HostelID)
            THROW 50061, 'Hostel does not exist.', 1;

        IF EXISTS (SELECT 1 FROM HostelAllotments WHERE StudentID = @StudentID AND Status = 'Active')
            THROW 50062, 'Student already has an active hostel allotment.', 1;

        DECLARE @TotalRooms INT, @OccupiedRooms INT;
        SELECT @TotalRooms = TotalRooms FROM Hostels WHERE HostelID = @HostelID;
        SELECT @OccupiedRooms = COUNT(DISTINCT RoomNumber) 
        FROM HostelAllotments WHERE HostelID = @HostelID AND Status = 'Active';

        IF @OccupiedRooms >= @TotalRooms
            THROW 50063, 'No rooms available in this hostel.', 1;

        BEGIN TRANSACTION;
        INSERT INTO HostelAllotments (StudentID, HostelID, RoomNumber, Status)
        VALUES (@StudentID, @HostelID, @RoomNumber, 'Active');
        SET @NewAllotmentID = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO