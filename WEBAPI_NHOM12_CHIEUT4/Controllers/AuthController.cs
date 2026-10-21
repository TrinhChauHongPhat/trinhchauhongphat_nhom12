using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ChildSafetyAPI.Data;
using ChildSafetyAPI.DTOs;
using ChildSafetyAPI.Models;
using ChildSafetyAPI.Services;

namespace ChildSafetyAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IEmailService _emailService;
        private readonly IJwtService _jwtService;

        public AuthController(AppDbContext context, IEmailService emailService, IJwtService jwtService)
        {
            _context = context;
            _emailService = emailService;
            _jwtService = jwtService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var existingUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email.ToLower());
            if (existingUser != null)
            {
                return BadRequest(new AuthResponse { Success = false, Message = "Email này đã được sử dụng." });
            }

            var user = new User
            {
                FullName = request.FullName,
                Email = request.Email.ToLower(),
                PasswordHash = HashPassword(request.Password),
                Role = string.IsNullOrEmpty(request.Role) ? "Parent" : request.Role,
                CreatedAt = DateTime.Now
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return Ok(new AuthResponse
            {
                Success = true,
                Message = "Đăng ký thành công!",
                UserId = user.UserId,
                FullName = user.FullName,
                Email = user.Email,
                Role = user.Role
            });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email.ToLower());
            if (user == null || user.PasswordHash != HashPassword(request.Password))
            {
                return Unauthorized(new AuthResponse { Success = false, Message = "Email hoặc mật khẩu không chính xác." });
            }

            var random = new Random();
            var otpValue = random.Next(100000, 999999).ToString();

            var otp = new OtpCode
            {
                Email = user.Email,
                Code = otpValue,
                ExpiryTime = DateTime.Now.AddMinutes(5),
                IsUsed = false
            };

            _context.OtpCodes.Add(otp);
            await _context.SaveChangesAsync();

            string emailBody = $@"
                <div style='font-family: Arial, sans-serif; padding: 20px;'>
                    <h2 style='color: #1976D2;'>Child Safety System</h2>
                    <p>Xin chào <strong>{user.FullName}</strong>,</p>
                    <p>Mã OTP xác thực đăng nhập của bạn là:</p>
                    <div style='background: #f0f4f8; padding: 15px; border-radius: 8px; display: inline-block;'>
                        <span style='font-size: 26px; font-weight: bold; letter-spacing: 5px; color: #D32F2F;'>{otpValue}</span>
                    </div>
                    <p style='color: gray; margin-top: 15px;'>Mã có hiệu lực trong vòng 5 phút. Vui lòng không cung cấp mã này cho người khác.</p>
                </div>";

            await _emailService.SendEmailAsync(user.Email, "Child Safety App - OTP Đăng Nhập", emailBody);

            return Ok(new
            {
                Success = true,
                Message = "Mật khẩu hợp lệ. Mã OTP đã được gửi về email của bạn.",
                Email = user.Email,
                DemoOtp = otpValue
            });
        }

        [HttpPost("verify-otp")]
        public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var otpRecord = await _context.OtpCodes
                .Where(o => o.Email == request.Email.ToLower() && o.Code == request.OtpCode && !o.IsUsed)
                .OrderByDescending(o => o.ExpiryTime)
                .FirstOrDefaultAsync();

            if (otpRecord == null || otpRecord.ExpiryTime < DateTime.Now)
            {
                return BadRequest(new AuthResponse { Success = false, Message = "Mã OTP không đúng hoặc đã hết hạn." });
            }

            otpRecord.IsUsed = true;
            await _context.SaveChangesAsync();

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email.ToLower());
            if (user == null)
            {
                return NotFound(new AuthResponse { Success = false, Message = "Không tìm thấy thông tin tài khoản." });
            }

            var token = _jwtService.GenerateToken(user);

            return Ok(new AuthResponse
            {
                Success = true,
                Message = "Đăng nhập thành công!",
                UserId = user.UserId,
                FullName = user.FullName,
                Email = user.Email,
                Role = user.Role,
                Token = token
            });
        }

        private static string HashPassword(string password)
        {
            using var sha256 = SHA256.Create();
            var bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(bytes);
        }
    }
}

