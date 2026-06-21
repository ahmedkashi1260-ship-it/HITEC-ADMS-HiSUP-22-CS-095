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