USE HiSUP_DB;
GO

CREATE NONCLUSTERED INDEX IX_Enrollments_Active_Filtered
ON Enrollments(StudentID, SectionID)
INCLUDE (EnrollmentDate, Status)
WHERE Status = 'Active';
GO