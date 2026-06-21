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