using HiSUP.Data;
using HiSUP.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;

namespace HiSUP.Controllers;

public class StudentController : Controller
{
    private readonly ApplicationDbContext _context;
    private readonly IConfiguration _config;

    public StudentController(ApplicationDbContext context, IConfiguration config)
    {
        _context = context;
        _config = config;
    }

    // GET: /Student
    public async Task<IActionResult> Index()
    {
        var students = await _context.Students
            .Include(s => s.Department)
            .OrderByDescending(s => s.CreatedAt)
            .ToListAsync();
        return View(students);
    }

    // GET: /Student/Create
    public async Task<IActionResult> Create()
    {
        ViewBag.Departments = await _context.Departments.ToListAsync();
        return View();
    }

    // POST: /Student/Create
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(Student student)
    {
        try
        {
            var connStr = _config.GetConnectionString("HiSUP_DB");
            using var conn = new SqlConnection(connStr);
            await conn.OpenAsync();

            var cmd = new SqlCommand("RegisterStudent", conn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@FirstName", student.FirstName);
            cmd.Parameters.AddWithValue("@LastName", student.LastName);
            cmd.Parameters.AddWithValue("@Email", student.Email);
            cmd.Parameters.AddWithValue("@DeptID", student.DepartmentID);

            var outputParam = new SqlParameter("@NewStudentID", System.Data.SqlDbType.Int)
            {
                Direction = System.Data.ParameterDirection.Output
            };
            cmd.Parameters.Add(outputParam);
            await cmd.ExecuteNonQueryAsync();

            TempData["Success"] = "Student registered successfully!";
            return RedirectToAction(nameof(Index));
        }
        catch (Exception ex)
        {
            TempData["Error"] = "Error: " + ex.Message;
            ViewBag.Departments = await _context.Departments.ToListAsync();
            return View(student);
        }
    }

    // GET: /Student/Details/5
    public async Task<IActionResult> Details(int id)
    {
        var student = await _context.Students
            .Include(s => s.Department)
            .Include(s => s.Enrollments)
            .FirstOrDefaultAsync(s => s.StudentID == id);

        if (student == null) return NotFound();
        return View(student);
    }

    // GET: /Student/Delete/5
    public async Task<IActionResult> Delete(int id)
    {
        var student = await _context.Students
            .Include(s => s.Department)
            .FirstOrDefaultAsync(s => s.StudentID == id);

        if (student == null) return NotFound();
        return View(student);
    }

    // POST: /Student/Delete/5
    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> DeleteConfirmed(int id)
    {
        var student = await _context.Students.FindAsync(id);
        if (student != null)
        {
            student.IsActive = false;
            await _context.SaveChangesAsync();
        }
        TempData["Success"] = "Student deactivated successfully!";
        return RedirectToAction(nameof(Index));
    }
}