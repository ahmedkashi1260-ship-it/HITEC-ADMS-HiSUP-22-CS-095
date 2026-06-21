using HiSUP.Data;
using HiSUP.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HiSUP.Controllers;

public class ReportController : Controller
{
    private readonly ApplicationDbContext _context;

    public ReportController(ApplicationDbContext context)
    {
        _context = context;
    }

    // GET: /Report/Attendance
    public async Task<IActionResult> Attendance()
    {
        var records = await _context.AttendanceRecords
            .Include(a => a.Student)
            .Include(a => a.Section)
                .ThenInclude(s => s!.Course)
            .OrderByDescending(a => a.AttendanceDate)
            .ToListAsync();

        // Group by student to show a simple summary
        var summary = records
            .GroupBy(a => a.StudentID)
            .Select(g => new
            {
                StudentName = g.First().Student != null ? g.First().Student!.FirstName + " " + g.First().Student!.LastName : "Unknown",
                RollNumber = g.First().Student?.RollNumber,
                TotalClasses = g.Count(),
                Present = g.Count(a => a.Status == "Present"),
                Absent = g.Count(a => a.Status == "Absent"),
                Leave = g.Count(a => a.Status == "Leave"),
                Percentage = g.Count() > 0 ? Math.Round((double)g.Count(a => a.Status == "Present") / g.Count() * 100, 2) : 0
            })
            .ToList();

        return View(summary);
    }

    // GET: /Report/Results
    public async Task<IActionResult> Results()
    {
        var results = await _context.Grades
            .Include(g => g.Enrollment)
                .ThenInclude(e => e!.Student)
            .Include(g => g.Enrollment)
                .ThenInclude(e => e!.Section)
                    .ThenInclude(s => s!.Course)
            .Where(g => g.GradePoint != null)
            .OrderByDescending(g => g.GradePoint)
            .ToListAsync();

        return View(results);
    }
}