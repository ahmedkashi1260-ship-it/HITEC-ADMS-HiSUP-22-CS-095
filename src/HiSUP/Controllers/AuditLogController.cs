using HiSUP.Data;
using HiSUP.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HiSUP.Controllers;

public class AuditLogController : Controller
{
    private readonly ApplicationDbContext _context;

    public AuditLogController(ApplicationDbContext context)
    {
        _context = context;
    }

    // GET: /AuditLog
    public async Task<IActionResult> Index(string? tableFilter)
    {
        var query = _context.AuditLogs.AsQueryable();

        if (!string.IsNullOrEmpty(tableFilter))
        {
            query = query.Where(a => a.TableName == tableFilter);
        }

        var logs = await query
            .OrderByDescending(a => a.ChangedAt)
            .Take(100)
            .ToListAsync();

        ViewBag.TableFilter = tableFilter;
        return View(logs);
    }
}