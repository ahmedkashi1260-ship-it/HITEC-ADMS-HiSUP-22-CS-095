using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using HiSUP.Models;

namespace HiSUP.Data;

public class ApplicationDbContext : IdentityDbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    // Tables
    public DbSet<Student> Students { get; set; }
    public DbSet<Department> Departments { get; set; }
    public DbSet<Faculty> Faculty { get; set; }
    public DbSet<Course> Courses { get; set; }
    public DbSet<Section> Sections { get; set; }
    public DbSet<Enrollment> Enrollments { get; set; }
    public DbSet<Grade> Grades { get; set; }
    public DbSet<FeePayment> FeePayments { get; set; }
    public DbSet<LibraryItem> LibraryItems { get; set; }
    public DbSet<LibraryIssue> LibraryIssues { get; set; }
    public DbSet<AttendanceRecord> AttendanceRecords { get; set; }
    public DbSet<AuditLog> AuditLogs { get; set; }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        // Student
        builder.Entity<Student>()
            .HasIndex(s => s.RollNumber)
            .IsUnique();

        builder.Entity<Student>()
            .HasIndex(s => s.Email)
            .IsUnique();

        // Enrollment composite index
        builder.Entity<Enrollment>()
            .HasIndex(e => new { e.StudentID, e.SectionID });

        // Map AuditLogs DbSet to the actual table name "AuditLog" (singular)
        builder.Entity<AuditLog>().ToTable("AuditLog");
    }
}