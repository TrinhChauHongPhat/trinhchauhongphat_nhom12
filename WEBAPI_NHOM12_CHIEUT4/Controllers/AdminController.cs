using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ChildSafetyAPI.Data;

namespace ChildSafetyAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AdminController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AdminController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("dashboard-summary")]
        public async Task<IActionResult> GetSummary()
        {
            var totalUsers = await _context.Users.CountAsync();
            var totalParents = await _context.Users.CountAsync(u => u.Role == "Parent");
            var totalStaff = await _context.Users.CountAsync(u => u.Role == "Staff");
            var totalChildrenDevices = await _context.ChildrenDevices.CountAsync();
            var totalAlerts = await _context.SensorAlerts.CountAsync();

            var recentUsers = await _context.Users
                .OrderByDescending(u => u.CreatedAt)
                .Take(5)
                .Select(u => new
                {
                    u.UserId,
                    u.FullName,
                    u.Email,
                    u.Role,
                    u.CreatedAt
                })
                .ToListAsync();

            return Ok(new
            {
                TotalUsers = totalUsers,
                TotalParents = totalParents,
                TotalStaff = totalStaff,
                TotalChildrenDevices = totalChildrenDevices,
                TotalAlerts = totalAlerts,
                RecentUsers = recentUsers
            });
        }
    }
}

