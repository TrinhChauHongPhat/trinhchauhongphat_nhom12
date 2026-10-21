using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ChildSafetyAPI.Data;
using ChildSafetyAPI.DTOs;
using ChildSafetyAPI.Models;

namespace ChildSafetyAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ChildrenController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ChildrenController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("my-kids/{parentId}")]
        public async Task<IActionResult> GetMyKids(int parentId)
        {
            var kids = await _context.ChildrenDevices
                .Where(c => c.ParentId == parentId)
                .Select(c => new ChildResponse
                {
                    DeviceId = c.DeviceId,
                    ParentId = c.ParentId,
                    ChildName = c.ChildName,
                    PairingCode = c.PairingCode,
                    IsLocked = c.IsLocked,
                    LastActive = c.LastActive
                })
                .ToListAsync();

            return Ok(kids);
        }

        [HttpGet("{deviceId}")]
        public async Task<IActionResult> GetChildById(int deviceId)
        {
            var child = await _context.ChildrenDevices.FindAsync(deviceId);
            if (child == null)
            {
                return NotFound(new { Message = "Không tìm thấy thiết bị của con." });
            }

            return Ok(new ChildResponse
            {
                DeviceId = child.DeviceId,
                ParentId = child.ParentId,
                ChildName = child.ChildName,
                PairingCode = child.PairingCode,
                IsLocked = child.IsLocked,
                LastActive = child.LastActive
            });
        }

        [HttpPost("create")]
        public async Task<IActionResult> CreateChild([FromBody] CreateChildRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var parentExists = await _context.Users.AnyAsync(u => u.UserId == request.ParentId);
            if (!parentExists)
            {
                return NotFound(new { Message = "Phụ huynh không tồn tại." });
            }

            var pairingCode = "KID-" + Guid.NewGuid().ToString().Substring(0, 6).ToUpper();

            var child = new ChildrenDevice
            {
                ParentId = request.ParentId,
                ChildName = request.ChildName,
                PairingCode = pairingCode,
                IsLocked = false,
                LastActive = DateTime.Now
            };

            _context.ChildrenDevices.Add(child);
            await _context.SaveChangesAsync();

            return Ok(new ChildResponse
            {
                DeviceId = child.DeviceId,
                ParentId = child.ParentId,
                ChildName = child.ChildName,
                PairingCode = child.PairingCode,
                IsLocked = child.IsLocked,
                LastActive = child.LastActive
            });
        }

        [HttpPost("toggle-lock/{deviceId}")]
        public async Task<IActionResult> ToggleLock(int deviceId)
        {
            var child = await _context.ChildrenDevices.FindAsync(deviceId);
            if (child == null)
            {
                return NotFound(new { Message = "Không tìm thấy thiết bị." });
            }

            child.IsLocked = !child.IsLocked;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                Success = true,
                DeviceId = child.DeviceId,
                IsLocked = child.IsLocked,
                Message = child.IsLocked ? "Đã khóa máy con thành công." : "Đã mở khóa máy con thành công."
            });
        }

        [HttpDelete("{deviceId}")]
        public async Task<IActionResult> DeleteChild(int deviceId)
        {
            var child = await _context.ChildrenDevices.FindAsync(deviceId);
            if (child == null)
            {
                return NotFound(new { Message = "Không tìm thấy thiết bị." });
            }

            _context.ChildrenDevices.Remove(child);
            await _context.SaveChangesAsync();

            return Ok(new { Success = true, Message = "Xóa hồ sơ con thành công." });
        }
    }
}

