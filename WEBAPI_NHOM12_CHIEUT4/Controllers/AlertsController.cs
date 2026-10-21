using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ChildSafetyAPI.Data;
using ChildSafetyAPI.DTOs;
using ChildSafetyAPI.Models;

namespace ChildSafetyAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AlertsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AlertsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost("report")]
        public async Task<IActionResult> ReportAlert([FromBody] ReportAlertRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var deviceExists = await _context.ChildrenDevices.AnyAsync(d => d.DeviceId == request.DeviceId);
            if (!deviceExists)
            {
                return NotFound(new { Message = "Thiết bị không tồn tại." });
            }

            var alert = new SensorAlert
            {
                DeviceId = request.DeviceId,
                AlertType = request.AlertType,
                ValueRecorded = request.ValueRecorded,
                CreatedAt = DateTime.Now
            };

            _context.SensorAlerts.Add(alert);
            await _context.SaveChangesAsync();

            return Ok(new { Success = true, Message = "Cảnh báo đã được ghi nhận." });
        }

        [HttpGet("by-device/{deviceId}")]
        public async Task<IActionResult> GetAlerts(int deviceId)
        {
            var alerts = await _context.SensorAlerts
                .Where(a => a.DeviceId == deviceId)
                .OrderByDescending(a => a.CreatedAt)
                .ToListAsync();

            return Ok(alerts);
        }
    }
}

