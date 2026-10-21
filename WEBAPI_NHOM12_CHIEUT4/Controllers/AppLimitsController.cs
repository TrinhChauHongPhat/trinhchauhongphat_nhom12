using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ChildSafetyAPI.Data;
using ChildSafetyAPI.DTOs;
using ChildSafetyAPI.Models;

namespace ChildSafetyAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AppLimitsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AppLimitsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("{deviceId}")]
        public async Task<IActionResult> GetLimitsByDevice(int deviceId)
        {
            var limits = await _context.AppLimits
                .Where(a => a.DeviceId == deviceId)
                .ToListAsync();

            return Ok(limits);
        }

        [HttpPost]
        public async Task<IActionResult> CreateLimit([FromBody] CreateAppLimitRequest request)
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

            var limit = new AppLimit
            {
                DeviceId = request.DeviceId,
                AppName = request.AppName,
                PackageName = request.PackageName,
                AllowedMinutesPerDay = request.AllowedMinutesPerDay,
                IsBlocked = request.IsBlocked
            };

            _context.AppLimits.Add(limit);
            await _context.SaveChangesAsync();

            return Ok(limit);
        }

        [HttpPut("{limitId}")]
        public async Task<IActionResult> UpdateLimit(int limitId, [FromBody] UpdateAppLimitRequest request)
        {
            var limit = await _context.AppLimits.FindAsync(limitId);
            if (limit == null)
            {
                return NotFound(new { Message = "Không tìm thấy quy tắc giới hạn." });
            }

            limit.AllowedMinutesPerDay = request.AllowedMinutesPerDay;
            limit.IsBlocked = request.IsBlocked;

            await _context.SaveChangesAsync();
            return Ok(limit);
        }

        [HttpDelete("{limitId}")]
        public async Task<IActionResult> DeleteLimit(int limitId)
        {
            var limit = await _context.AppLimits.FindAsync(limitId);
            if (limit == null)
            {
                return NotFound(new { Message = "Không tìm thấy quy tắc giới hạn." });
            }

            _context.AppLimits.Remove(limit);
            await _context.SaveChangesAsync();

            return Ok(new { Success = true, Message = "Xóa quy tắc thành công." });
        }
    }
}

