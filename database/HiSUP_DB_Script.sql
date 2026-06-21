-- ============================================
-- HiSUP_DB: Full Database Schema
-- This file will grow as we add more tables,
-- procedures, functions, triggers, views, etc.
-- Run this entire file in SSMS to recreate the database.
-- ============================================

CREATE DATABASE HiSUP_DB;
GO

USE HiSUP_DB;
GO

-- ============================================
-- Table: Departments
-- ============================================
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DeptName NVARCHAR(100) NOT NULL UNIQUE,
    DeptCode NVARCHAR(10) NOT NULL UNIQUE,
    EstablishedYear INT CHECK (EstablishedYear >= 1990),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- ============================================
-- Table: Students
-- ============================================
CREATE TABLE Students (
    StudentID INT PRIMARY KEY IDENTITY(1,1),
    RollNumber NVARCHAR(20) NOT NULL UNIQUE,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    CNIC NVARCHAR(20) NULL,
    Phone NVARCHAR(20) NULL,
    DateOfBirth DATE NULL,
    Gender NVARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other')),
    DepartmentID INT NOT NULL,
    EnrollmentYear INT CHECK (EnrollmentYear >= 2000),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Students_Department FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

-- ============================================
-- Table: Faculty
-- ============================================
CREATE TABLE Faculty (
    FacultyID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeCode NVARCHAR(20) NOT NULL UNIQUE,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Phone NVARCHAR(20) NULL,
    Designation NVARCHAR(50) CHECK (Designation IN ('Lecturer', 'Assistant Professor', 'Associate Professor', 'Professor')),
    DepartmentID INT NOT NULL,
    HireDate DATE NOT NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Faculty_Department FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

-- ============================================
-- Table: Staff
-- ============================================
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeCode NVARCHAR(20) NOT NULL UNIQUE,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Phone NVARCHAR(20) NULL,
    JobRole NVARCHAR(50) NOT NULL,
    DepartmentID INT NULL,
    HireDate DATE NOT NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Staff_Department FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

-- ============================================
-- Table: Programs
-- ============================================
CREATE TABLE Programs (
    ProgramID INT PRIMARY KEY IDENTITY(1,1),
    ProgramName NVARCHAR(100) NOT NULL,
    ProgramCode NVARCHAR(10) NOT NULL UNIQUE,
    DepartmentID INT NOT NULL,
    DegreeLevel NVARCHAR(20) CHECK (DegreeLevel IN ('Bachelors', 'Masters', 'PhD')),
    DurationYears INT CHECK (DurationYears > 0 AND DurationYears <= 6),
    TotalCreditHours INT CHECK (TotalCreditHours > 0),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Programs_Department FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

-- ============================================
-- Table: Courses
-- ============================================
CREATE TABLE Courses (
    CourseID INT PRIMARY KEY IDENTITY(1,1),
    CourseCode NVARCHAR(15) NOT NULL UNIQUE,
    CourseTitle NVARCHAR(150) NOT NULL,
    ProgramID INT NOT NULL,
    CreditHours INT CHECK (CreditHours > 0 AND CreditHours <= 6),
    PrerequisiteCourseID INT NULL,
    Semester INT CHECK (Semester BETWEEN 1 AND 8),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Courses_Program FOREIGN KEY (ProgramID)
        REFERENCES Programs(ProgramID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT FK_Courses_Prerequisite FOREIGN KEY (PrerequisiteCourseID)
        REFERENCES Courses(CourseID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- ============================================
-- Table: Sections
-- ============================================
CREATE TABLE Sections (
    SectionID INT PRIMARY KEY IDENTITY(1,1),
    CourseID INT NOT NULL,
    FacultyID INT NOT NULL,
    SectionName NVARCHAR(10) NOT NULL,
    SemesterTerm NVARCHAR(20) NOT NULL,
    AcademicYear NVARCHAR(10) NOT NULL,
    MaxSeats INT CHECK (MaxSeats > 0) DEFAULT 40,
    SeatsFilled INT DEFAULT 0 CHECK (SeatsFilled >= 0),
    Schedule NVARCHAR(100) NULL,
    RoomNumber NVARCHAR(20) NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Sections_Course FOREIGN KEY (CourseID)
        REFERENCES Courses(CourseID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Sections_Faculty FOREIGN KEY (FacultyID)
        REFERENCES Faculty(FacultyID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT CHK_SeatsNotExceeded CHECK (SeatsFilled <= MaxSeats)
);
GO

-- ============================================
-- Table: Enrollments
-- ============================================
CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    SectionID INT NOT NULL,
    EnrollmentDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (Status IN ('Active', 'Dropped', 'Completed')),
    CONSTRAINT FK_Enrollments_Student FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Enrollments_Section FOREIGN KEY (SectionID)
        REFERENCES Sections(SectionID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT UQ_Student_Section UNIQUE (StudentID, SectionID)
);
GO

-- ============================================
-- Table: Grades
-- ============================================
CREATE TABLE Grades (
    GradeID INT PRIMARY KEY IDENTITY(1,1),
    EnrollmentID INT NOT NULL UNIQUE,
    MarksObtained DECIMAL(5,2) NULL CHECK (MarksObtained >= 0 AND MarksObtained <= 100),
    LetterGrade NVARCHAR(2) NULL,
    GradePoint DECIMAL(3,2) NULL CHECK (GradePoint >= 0 AND GradePoint <= 4.0),
    GradedDate DATETIME NULL,
    GradedBy INT NULL,
    CONSTRAINT FK_Grades_Enrollment FOREIGN KEY (EnrollmentID)
        REFERENCES Enrollments(EnrollmentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Grades_Faculty FOREIGN KEY (GradedBy)
        REFERENCES Faculty(FacultyID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- ============================================
-- Table: AttendanceRecords
-- ============================================
CREATE TABLE AttendanceRecords (
    AttendanceID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    SectionID INT NOT NULL,
    AttendanceDate DATE NOT NULL,
    Status NVARCHAR(10) NOT NULL CHECK (Status IN ('Present', 'Absent', 'Leave')),
    MarkedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Attendance_Student FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Attendance_Section FOREIGN KEY (SectionID)
        REFERENCES Sections(SectionID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Attendance_Faculty FOREIGN KEY (MarkedBy)
        REFERENCES Faculty(FacultyID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT UQ_Student_Section_Date UNIQUE (StudentID, SectionID, AttendanceDate)
);
GO


-- ============================================
-- Table: FeeStructure
-- ============================================
CREATE TABLE FeeStructure (
    FeeStructureID INT PRIMARY KEY IDENTITY(1,1),
    ProgramID INT NOT NULL,
    Semester INT CHECK (Semester BETWEEN 1 AND 8),
    TuitionFee DECIMAL(10,2) NOT NULL CHECK (TuitionFee >= 0),
    ExamFee DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (ExamFee >= 0),
    LibraryFee DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (LibraryFee >= 0),
    OtherCharges DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (OtherCharges >= 0),
    TotalAmount AS (TuitionFee + ExamFee + LibraryFee + OtherCharges),
    EffectiveYear INT NOT NULL,
    CONSTRAINT FK_FeeStructure_Program FOREIGN KEY (ProgramID)
        REFERENCES Programs(ProgramID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- ============================================
-- Table: FeePayments
-- ============================================
CREATE TABLE FeePayments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    FeeStructureID INT NOT NULL,
    AmountPaid DECIMAL(10,2) NOT NULL CHECK (AmountPaid > 0),
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(30) CHECK (PaymentMethod IN ('Cash', 'Bank Transfer', 'Online', 'Cheque')),
    TransactionReference NVARCHAR(50) NULL,
    ProcessedBy INT NULL,
    CONSTRAINT FK_FeePayments_Student FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_FeePayments_FeeStructure FOREIGN KEY (FeeStructureID)
        REFERENCES FeeStructure(FeeStructureID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_FeePayments_Staff FOREIGN KEY (ProcessedBy)
        REFERENCES Staff(StaffID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- ============================================
-- Table: LibraryItems
-- ============================================
CREATE TABLE LibraryItems (
    ItemID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(200) NOT NULL,
    Author NVARCHAR(150) NOT NULL,
    ISBN NVARCHAR(20) NULL UNIQUE,
    ItemType NVARCHAR(20) NOT NULL CHECK (ItemType IN ('Book', 'Journal', 'Thesis', 'Magazine')),
    TotalCopies INT NOT NULL CHECK (TotalCopies >= 0),
    CopiesAvailable INT NOT NULL CHECK (CopiesAvailable >= 0),
    Publisher NVARCHAR(100) NULL,
    PublishedYear INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT CHK_CopiesAvailable CHECK (CopiesAvailable <= TotalCopies)
);
GO

-- ============================================
-- Table: LibraryIssues
-- ============================================
CREATE TABLE LibraryIssues (
    IssueID INT PRIMARY KEY IDENTITY(1,1),
    ItemID INT NOT NULL,
    StudentID INT NOT NULL,
    IssueDate DATETIME DEFAULT GETDATE(),
    DueDate DATE NOT NULL,
    ReturnDate DATETIME NULL,
    FineAmount DECIMAL(8,2) DEFAULT 0 CHECK (FineAmount >= 0),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Issued' CHECK (Status IN ('Issued', 'Returned', 'Overdue', 'Lost')),
    CONSTRAINT FK_LibraryIssues_Item FOREIGN KEY (ItemID)
        REFERENCES LibraryItems(ItemID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_LibraryIssues_Student FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- ============================================
-- Table: Hostels
-- ============================================
CREATE TABLE Hostels (
    HostelID INT PRIMARY KEY IDENTITY(1,1),
    HostelName NVARCHAR(100) NOT NULL UNIQUE,
    HostelType NVARCHAR(10) NOT NULL CHECK (HostelType IN ('Boys', 'Girls')),
    TotalRooms INT NOT NULL CHECK (TotalRooms > 0),
    RoomCapacity INT NOT NULL CHECK (RoomCapacity > 0),
    Warden NVARCHAR(100) NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- ============================================
-- Table: HostelAllotments
-- ============================================
CREATE TABLE HostelAllotments (
    AllotmentID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL UNIQUE,
    HostelID INT NOT NULL,
    RoomNumber NVARCHAR(10) NOT NULL,
    AllotmentDate DATETIME DEFAULT GETDATE(),
    VacateDate DATETIME NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (Status IN ('Active', 'Vacated')),
    CONSTRAINT FK_HostelAllotments_Student FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_HostelAllotments_Hostel FOREIGN KEY (HostelID)
        REFERENCES Hostels(HostelID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- ============================================
-- Table: ExamSchedule
-- ============================================
CREATE TABLE ExamSchedule (
    ExamID INT PRIMARY KEY IDENTITY(1,1),
    SectionID INT NOT NULL,
    ExamType NVARCHAR(20) NOT NULL CHECK (ExamType IN ('Midterm', 'Final', 'Quiz', 'Assignment')),
    ExamDate DATETIME NOT NULL,
    DurationMinutes INT NOT NULL CHECK (DurationMinutes > 0),
    RoomNumber NVARCHAR(20) NULL,
    TotalMarks INT NOT NULL CHECK (TotalMarks > 0),
    CONSTRAINT FK_ExamSchedule_Section FOREIGN KEY (SectionID)
        REFERENCES Sections(SectionID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

-- ============================================
-- Table: Results
-- ============================================
CREATE TABLE Results (
    ResultID INT PRIMARY KEY IDENTITY(1,1),
    ExamID INT NOT NULL,
    StudentID INT NOT NULL,
    MarksObtained DECIMAL(6,2) NOT NULL CHECK (MarksObtained >= 0),
    IsAbsent BIT DEFAULT 0,
    PublishedDate DATETIME NULL,
    CONSTRAINT FK_Results_Exam FOREIGN KEY (ExamID)
        REFERENCES ExamSchedule(ExamID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Results_Student FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT UQ_Exam_Student UNIQUE (ExamID, StudentID)
);
GO

-- ============================================
-- Table: UserAccounts
-- ============================================
CREATE TABLE UserAccounts (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL CHECK (Role IN ('Student', 'Faculty', 'Admin', 'Finance')),
    StudentID INT NULL,
    FacultyID INT NULL,
    LastLogin DATETIME NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_UserAccounts_Student FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_UserAccounts_Faculty FOREIGN KEY (FacultyID)
        REFERENCES Faculty(FacultyID)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT CHK_OneRoleLink CHECK (
        (Role = 'Student' AND StudentID IS NOT NULL AND FacultyID IS NULL) OR
        (Role = 'Faculty' AND FacultyID IS NOT NULL AND StudentID IS NULL) OR
        (Role IN ('Admin', 'Finance') AND StudentID IS NULL AND FacultyID IS NULL)
    )
);
GO

-- ============================================
-- Table: AuditLog
-- ============================================
CREATE TABLE AuditLog (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    TableName NVARCHAR(50) NOT NULL,
    OperationType NVARCHAR(10) NOT NULL CHECK (OperationType IN ('INSERT', 'UPDATE', 'DELETE')),
    RecordID INT NULL,
    OldValue NVARCHAR(MAX) NULL,
    NewValue NVARCHAR(MAX) NULL,
    ChangedBy NVARCHAR(100) NOT NULL,
    ChangedAt DATETIME DEFAULT GETDATE()
);
GO

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE RegisterStudent
    @RollNumber NVARCHAR(20),
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @CNIC NVARCHAR(20),
    @Phone NVARCHAR(20),
    @DateOfBirth DATE,
    @Gender NVARCHAR(10),
    @DepartmentID INT,
    @EnrollmentYear INT,
    @NewStudentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @DepartmentID NOT IN (SELECT DepartmentID FROM Departments)
        BEGIN
            THROW 50001, 'Invalid DepartmentID: department does not exist.', 1;
        END

        IF EXISTS (SELECT 1 FROM Students WHERE Email = @Email)
        BEGIN
            THROW 50002, 'A student with this email already exists.', 1;
        END

        IF EXISTS (SELECT 1 FROM Students WHERE RollNumber = @RollNumber)
        BEGIN
            THROW 50003, 'A student with this roll number already exists.', 1;
        END

        BEGIN TRANSACTION;

        INSERT INTO Students (RollNumber, FirstName, LastName, Email, CNIC, Phone, DateOfBirth, Gender, DepartmentID, EnrollmentYear)
        VALUES (@RollNumber, @FirstName, @LastName, @Email, @CNIC, @Phone, @DateOfBirth, @Gender, @DepartmentID, @EnrollmentYear);

        SET @NewStudentID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE EnrollInCourse
    @StudentID INT,
    @SectionID INT,
    @NewEnrollmentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID AND IsActive = 1)
        BEGIN
            THROW 50010, 'Student does not exist or is not active.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM Sections WHERE SectionID = @SectionID)
        BEGIN
            THROW 50011, 'Section does not exist.', 1;
        END

        IF EXISTS (SELECT 1 FROM Enrollments WHERE StudentID = @StudentID AND SectionID = @SectionID AND Status = 'Active')
        BEGIN
            THROW 50012, 'Student is already enrolled in this section.', 1;
        END

        IF EXISTS (SELECT 1 FROM Sections WHERE SectionID = @SectionID AND SeatsFilled >= MaxSeats)
        BEGIN
            THROW 50013, 'No seats available in this section.', 1;
        END

        BEGIN TRANSACTION;

        INSERT INTO Enrollments (StudentID, SectionID, Status)
        VALUES (@StudentID, @SectionID, 'Active');

        SET @NewEnrollmentID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE ProcessFeePayment
    @StudentID INT,
    @FeeStructureID INT,
    @AmountPaid DECIMAL(10,2),
    @PaymentMethod NVARCHAR(30),
    @TransactionReference NVARCHAR(50) = NULL,
    @ProcessedBy INT = NULL,
    @NewPaymentID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID AND IsActive = 1)
        BEGIN
            THROW 50020, 'Student does not exist or is not active.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM FeeStructure WHERE FeeStructureID = @FeeStructureID)
        BEGIN
            THROW 50021, 'Fee structure does not exist.', 1;
        END

        IF @AmountPaid <= 0
        BEGIN
            THROW 50022, 'Payment amount must be greater than zero.', 1;
        END

        IF @PaymentMethod NOT IN ('Cash', 'Bank Transfer', 'Online', 'Cheque')
        BEGIN
            THROW 50023, 'Invalid payment method.', 1;
        END

        BEGIN TRANSACTION;

        INSERT INTO FeePayments (StudentID, FeeStructureID, AmountPaid, PaymentMethod, TransactionReference, ProcessedBy)
        VALUES (@StudentID, @FeeStructureID, @AmountPaid, @PaymentMethod, @TransactionReference, @ProcessedBy);

        SET @NewPaymentID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE GenerateTranscript
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
        BEGIN
            THROW 50030, 'Student does not exist.', 1;
        END

        ;WITH TranscriptCTE AS (
            SELECT
                s.StudentID,
                s.RollNumber,
                s.FirstName + ' ' + s.LastName AS StudentName,
                c.CourseCode,
                c.CourseTitle,
                c.CreditHours,
                sec.SemesterTerm,
                sec.AcademicYear,
                g.MarksObtained,
                g.LetterGrade,
                g.GradePoint
            FROM Enrollments e
            JOIN Students s ON e.StudentID = s.StudentID
            JOIN Sections sec ON e.SectionID = sec.SectionID
            JOIN Courses c ON sec.CourseID = c.CourseID
            LEFT JOIN Grades g ON g.EnrollmentID = e.EnrollmentID
            WHERE e.StudentID = @StudentID
        )
        SELECT
            StudentID,
            RollNumber,
            StudentName,
            CourseCode,
            CourseTitle,
            CreditHours,
            SemesterTerm,
            AcademicYear,
            MarksObtained,
            LetterGrade,
            GradePoint,
            (GradePoint * CreditHours) AS QualityPoints
        FROM TranscriptCTE
        ORDER BY AcademicYear, SemesterTerm;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO