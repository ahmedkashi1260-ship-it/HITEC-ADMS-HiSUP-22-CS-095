USE HiSUP_DB;
GO

CREATE OR ALTER TRIGGER trg_PreventDuplicateEnrollment
ON Enrollments
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check duplicate enrollment
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN Enrollments e ON i.StudentID = e.StudentID 
            AND i.SectionID = e.SectionID 
            AND e.Status = 'Active'
    )
    BEGIN
        THROW 50200, 'Duplicate enrollment: student is already enrolled in this section.', 1;
        RETURN;
    END

    -- Agar duplicate nahi to actual insert karo
    INSERT INTO Enrollments (StudentID, SectionID, EnrollmentDate, Status)
    SELECT 
        StudentID, 
        SectionID, 
        ISNULL(EnrollmentDate, GETDATE()), 
        ISNULL(Status, 'Active')
    FROM inserted;
END;
GO