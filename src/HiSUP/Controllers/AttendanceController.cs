using HiSUP.Data;
using HiSUP.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;

namespace HiSUP.Controllers;

public class AttendanceController : Controller
{
    private readonly ApplicationDbContext _context;
    private readonly IConfiguration _config;

    public AttendanceController(ApplicationDbContext context, IConfiguration config)
    {
        _context = context;
        _config = config;
    }

    // GET: /Attendance
    public async Task<IActionResult> Index()
    {
        var records = await _context.AttendanceRecords
            .Include(a => a.Student)
            .Include(a => a.Section)
            .OrderByDescending(a => a.AttendanceDate)
            .Take(50)
            .ToListAsync();
        return View(records);
    }

    // GET: /Attendance/Mark
    public async Task<IActionResult> Mark()
    {
        ViewBag.Students = await _context.Students
            .Where(s => s.IsActive)
            .ToListAsync();
        ViewBag.Sections = await _context.Sections
            .Include(s => s.Course)
            .ToListAsync();
        return View();
    }

    // POST: /Attendance/Mark
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Mark(int studentId, int sectionId, DateTime attendanceDate, string status, int markedBy)
    {
        try
        {
            var connStr = _config.GetConnectionString("HiSUP_DB");
            using var conn = new SqlConnection(connStr);
            await conn.OpenAsync();

            var cmd = new SqlCommand("MarkAttendance", conn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@StudentID", studentId);
            cmd.Parameters.AddWithValue("@SectionID", sectionId);
            cmd.Parameters.AddWithValue("@AttendanceDate", attendanceDate);
            cmd.Parameters.AddWithValue("@Status", status);
            cmd.Parameters.AddWithValue("@MarkedBy", markedBy);

            var outputParam = new SqlParameter("@NewAttendanceID", System.Data.SqlDbType.Int)
            {
                Direction = System.Data.ParameterDirection.Output
            };
            cmd.Parameters.Add(outputParam);
            await cmd.ExecuteNonQueryAsync();

            TempData["Success"] = "Attendance marked successfully!";
            return RedirectToAction(nameof(Index));
        }
        catch (Exception ex)
        {
            TempData["Error"] = "Error: " + ex.Message;
            ViewBag.Students = await _context.Students.Where(s => s.IsActive).ToListAsync();
            ViewBag.Sections = await _context.Sections.Include(s => s.Course).ToListAsync();
            return View();
        }
    }
}