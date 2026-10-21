using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ChildSafetyAPI.Data;

namespace ChildSafetyAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class StaffController : ControllerBase
    {
        private readonly AppDbContext _context;

        public StaffController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("support-dashboard")]
        public async Task<IActionResult> GetSupportDashboard()
        {
            var highNoiseAlerts = await _context.SensorAlerts
                .Include(a => a.Device)
                .Where(a => a.AlertType == "HIGH_NOISE")
                .OrderByDescending(a => a.CreatedAt)
                .Take(10)
                .Select(a => new
                {
                    a.AlertId,
                    ChildName = a.Device != null ? a.Device.ChildName : "Không xác định",
                    a.AlertType,
                    a.ValueRecorded,
                    a.CreatedAt
                })
                .ToListAsync();

            var lockedDevices = await _context.ChildrenDevices
                .Where(d => d.IsLocked)
                .Select(d => new
                {
                    d.DeviceId,
                    d.ChildName,
                    d.PairingCode,
                    d.LastActive
                })
                .ToListAsync();

            return Ok(new
            {
                Message = "Dữ liệu vận hành dành cho Nhân viên hỗ trợ.",
                LockedDevicesCount = lockedDevices.Count,
                RecentHighNoiseAlerts = highNoiseAlerts,
                CurrentlyLockedDevices = lockedDevices
            });
        }
    }
}

