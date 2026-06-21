USE HiSUP_DB;
GO

-- Pehle agar pehle wali policies bani hoon to drop karo
IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'EnrollmentAccessPolicy')
    DROP SECURITY POLICY EnrollmentAccessPolicy;
IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'GradeAccessPolicy')
    DROP SECURITY POLICY GradeAccessPolicy;
IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'FeePaymentAccessPolicy')
    DROP SECURITY POLICY FeePaymentAccessPolicy;
IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'fn_StudentAccessPredicate')
    DROP FUNCTION Security.fn_StudentAccessPredicate;
GO

-- Predicate function for StudentID columns
CREATE OR ALTER FUNCTION Security.fn_StudentAccessPredicate(@StudentID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS AccessResult
    WHERE 
        IS_MEMBER('db_admin') = 1
        OR IS_MEMBER('db_finance') = 1
        OR IS_MEMBER('db_faculty') = 1
        OR (
            IS_MEMBER('db_student') = 1
            AND @StudentID = CAST(SESSION_CONTEXT(N'StudentID') AS INT)
        );
GO

-- Predicate function for Grades (EnrollmentID se StudentID check karna hoga)
CREATE OR ALTER FUNCTION Security.fn_GradeAccessPredicate(@EnrollmentID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS AccessResult
    WHERE
        IS_MEMBER('db_admin') = 1
        OR IS_MEMBER('db_finance') = 1
        OR IS_MEMBER('db_faculty') = 1
        OR (
            IS_MEMBER('db_student') = 1
            AND EXISTS (
                SELECT 1 FROM dbo.Enrollments e
                WHERE e.EnrollmentID = @EnrollmentID
                AND e.StudentID = CAST(SESSION_CONTEXT(N'StudentID') AS INT)
            )
        );
GO

-- RLS Policies
CREATE SECURITY POLICY EnrollmentAccessPolicy
ADD FILTER PREDICATE Security.fn_StudentAccessPredicate(StudentID)
ON dbo.Enrollments
WITH (STATE = ON);
GO

CREATE SECURITY POLICY GradeAccessPolicy
ADD FILTER PREDICATE Security.fn_GradeAccessPredicate(EnrollmentID)
ON dbo.Grades
WITH (STATE = ON);
GO

CREATE SECURITY POLICY FeePaymentAccessPolicy
ADD FILTER PREDICATE Security.fn_StudentAccessPredicate(StudentID)
ON dbo.FeePayments
WITH (STATE = ON);
GO