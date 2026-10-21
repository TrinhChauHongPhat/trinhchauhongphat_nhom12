using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ChildSafetyAPI.Data;
using ChildSafetyAPI.DTOs;
using ChildSafetyAPI.Models;

namespace ChildSafetyAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TrackingController : ControllerBase
    {
        private readonly AppDbContext _context;

        public TrackingController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost("update-location")]
        public async Task<IActionResult> UpdateLocation([FromBody] UpdateLocationRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var child = await _context.ChildrenDevices.FindAsync(request.DeviceId);
            if (child == null)
            {
                return NotFound(new { Message = "Thiết bị không tồn tại." });
            }

            var log = new LocationLog
            {
                DeviceId = request.DeviceId,
                Latitude = request.Latitude,
                Longitude = request.Longitude,
                RecordedAt = DateTime.Now
            };

            child.LastActive = DateTime.Now;

            _context.LocationLogs.Add(log);
            await _context.SaveChangesAsync();

            return Ok(new { Success = true, Message = "Cập nhật vị trí thành công." });
        }

        [HttpGet("latest/{deviceId}")]
        public async Task<IActionResult> GetLatestLocation(int deviceId)
        {
            var latestLog = await _context.LocationLogs
                .Where(l => l.DeviceId == deviceId)
                .OrderByDescending(l => l.RecordedAt)
                .Select(l => new LocationResponse
                {
                    DeviceId = l.DeviceId,
                    Latitude = l.Latitude,
                    Longitude = l.Longitude,
                    RecordedAt = l.RecordedAt
                })
                .FirstOrDefaultAsync();

            if (latestLog == null)
            {
                return NotFound(new { Message = "Chưa có dữ liệu vị trí của thiết bị này." });
            }

            return Ok(latestLog);
        }
    }
}

