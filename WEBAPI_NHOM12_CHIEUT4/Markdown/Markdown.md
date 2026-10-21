# TÀI LIỆU THIẾT KẾ & TOÀN BỘ MÃ NGUỒN BACKEND ASP.NET CORE WEB API (.NET 8)
## ĐỒ ÁN: HỆ THỐNG QUẢN LÝ ĐIỆN THOẠI TRẺ EM (CHILD SAFETY SYSTEM)

---

## 1. CẤU TRÚC THƯ MỤC DỰ ÁN

```text
ChildSafetyAPI
│
├── Controllers
│   ├── AdminController.cs
│   ├── AlertsController.cs
│   ├── AppLimitsController.cs
│   ├── AuthController.cs
│   ├── ChildrenController.cs
│   ├── StaffController.cs
│   └── TrackingController.cs
│
├── Data
│   └── AppDbContext.cs
│
├── DTOs
│   ├── AlertDTOs.cs
│   ├── AppLimitDTOs.cs
│   ├── AuthDTOs.cs
│   ├── ChildDTOs.cs
│   └── TrackingDTOs.cs
│
├── Models
│   ├── AppLimit.cs
│   ├── ChildrenDevice.cs
│   ├── LocationLog.cs
│   ├── OtpCode.cs
│   ├── SensorAlert.cs
│   └── User.cs
│
├── Services
│   ├── EmailService.cs
│   ├── IEmailService.cs
│   ├── IJwtService.cs
│   └── JwtService.cs
│
├── appsettings.json
└── Program.cs
```

---

## 2. GIẢI THÍCH CHỨC NĂNG TỪNG FILE

* `Models/User.cs`: Thực thể lưu thông tin tài khoản người dùng và vai trò phân quyền (`Admin`, `Staff`, `Parent`).
* `Models/OtpCode.cs`: Thực thể lưu mã xác thực OTP 6 chữ số, thời hạn hiệu lực (5 phút) và trạng thái đã sử dụng để phục vụ đăng nhập bảo mật 2 lớp.
* `Models/ChildrenDevice.cs`: Thực thể hồ sơ máy của con, quản lý mã ghép nối QR (`PairingCode`), cờ khóa máy từ xa (`IsLocked`) và thời điểm hoạt động gần nhất.
* `Models/LocationLog.cs`: Thực thể lưu trữ lịch sử tọa độ GPS (kinh độ, vĩ độ) gửi từ thiết bị của con.
* `Models/AppLimit.cs`: Thực thể quy định thời gian tối đa được dùng ứng dụng trong ngày và cờ chặn trực tiếp theo từng app.
* `Models/SensorAlert.cs`: Thực thể lưu trữ các cảnh báo gửi về từ cảm biến trên máy con (độ ồn vượt ngưỡng nguy hiểm, phát hiện té ngã).
* `DTOs/AuthDTOs.cs`: Các lớp truyền nhận dữ liệu Đăng ký, Đăng nhập, Xác thực OTP và trả về Token/Role.
* `DTOs/ChildDTOs.cs`: Các lớp truyền nhận dữ liệu tạo mới hồ sơ máy con và hiển thị danh sách máy con.
* `DTOs/AppLimitDTOs.cs`: Các lớp truyền nhận dữ liệu thêm mới và cập nhật quy tắc giới hạn ứng dụng.
* `DTOs/TrackingDTOs.cs`: Các lớp truyền nhận dữ liệu ghi nhận tọa độ GPS và truy vấn vị trí mới nhất.
* `DTOs/AlertDTOs.cs`: Lớp truyền nhận dữ liệu gửi cảnh báo từ cảm biến thiết bị con.
* `Data/AppDbContext.cs`: Lớp ngữ cảnh cơ sở dữ liệu Entity Framework Core, ánh xạ các Entity vào các bảng trong SQL Server và cấu hình các chỉ mục Unique.
* `Services/IEmailService.cs`: Interface định nghĩa phương thức gửi email thông báo mã OTP.
* `Services/EmailService.cs`: Service thực thi việc kết nối máy chủ SMTP và gửi email tự động.
* `Services/IJwtService.cs`: Interface định nghĩa phương thức sinh mã JSON Web Token (JWT).
* `Services/JwtService.cs`: Service mã hóa thông tin người dùng (UserId, Email, FullName, Role) thành chuỗi JWT Token có gắn chữ ký điện tử.
* `Controllers/AuthController.cs`: Controller tiếp nhận yêu cầu Đăng ký, Đăng nhập bước 1 (tạo mã OTP và gửi mail), Xác thực OTP bước 2 và cấp chuỗi JWT Token.
* `Controllers/ChildrenController.cs`: Controller xử lý CRUD danh sách máy con và bật/tắt khóa máy từ xa.
* `Controllers/AppLimitsController.cs`: Controller xử lý CRUD các quy tắc giới hạn sử dụng app theo từng thiết bị con.
* `Controllers/TrackingController.cs`: Controller tiếp nhận tọa độ GPS từ máy con và trả về vị trí mới nhất cho máy phụ huynh.
* `Controllers/AlertsController.cs`: Controller tiếp nhận các cảnh báo âm thanh/cảm biến từ máy con và trả về lịch sử cảnh báo.
* `Controllers/AdminController.cs`: Controller cung cấp số liệu thống kê tổng quan (Dashboard) dành riêng cho người dùng quyền `Admin`.
* `Controllers/StaffController.cs`: Controller cung cấp danh sách thiết bị đang bị khóa và sự cố tiếng ồn bất thường dành cho `Staff`.
* `appsettings.json`: File cấu hình lưu chuỗi kết nối SQL Server, thông số mã hóa JWT và thông số gửi mail SMTP.
* `Program.cs`: File khởi chạy của dự án, thiết lập Dependency Injection, cấu hình DbContext, JWT Bearer Authentication, Swagger UI và kích hoạt CORS.

---

## 3. CÁC GÓI NUGET CẦN CÀI ĐẶT

Mở **Package Manager Console** trong Visual Studio và chạy các lệnh sau:

```powershell
Install-Package Microsoft.EntityFrameworkCore -Version 8.0.3
Install-Package Microsoft.EntityFrameworkCore.SqlServer -Version 8.0.3
Install-Package Microsoft.EntityFrameworkCore.Tools -Version 8.0.3
Install-Package Microsoft.AspNetCore.Authentication.JwtBearer -Version 8.0.3
Install-Package System.IdentityModel.Tokens.Jwt -Version 8.0.0
Install-Package MailKit -Version 4.4.0
Install-Package MimeKit -Version 4.4.0
```

---

## 4. TOÀN BỘ MÃ NGUỒN CHI TIẾT (FULL CODE 100%)

### 4.1. Nhóm thư mục Models/

#### File: `Models/User.cs`
```csharp
using System.ComponentModel.DataAnnotations;

namespace ChildSafetyAPI.Models
{
    public class User
    {
        [Key]
        public int UserId { get; set; }

        [Required]
        [MaxLength(100)]
        public string FullName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        [MaxLength(100)]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MaxLength(256)]
        public string PasswordHash { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        public string Role { get; set; } = "Parent"; // "Admin", "Staff", "Parent"

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public List<ChildrenDevice> ChildrenDevices { get; set; } = new List<ChildrenDevice>();
    }
}
```

#### File: `Models/OtpCode.cs`
```csharp
using System.ComponentModel.DataAnnotations;

namespace ChildSafetyAPI.Models
{
    public class OtpCode
    {
        [Key]
        public int OtpId { get; set; }

        [Required]
        [EmailAddress]
        [MaxLength(100)]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MaxLength(6)]
        public string Code { get; set; } = string.Empty;

        public DateTime ExpiryTime { get; set; }

        public bool IsUsed { get; set; } = false;
    }
}
```

#### File: `Models/ChildrenDevice.cs`
```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChildSafetyAPI.Models
{
    public class ChildrenDevice
    {
        [Key]
        public int DeviceId { get; set; }

        [Required]
        public int ParentId { get; set; }

        [ForeignKey("ParentId")]
        public User? Parent { get; set; }

        [Required]
        [MaxLength(100)]
        public string ChildName { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        public string PairingCode { get; set; } = string.Empty;

        public bool IsLocked { get; set; } = false;

        public DateTime? LastActive { get; set; }

        public List<LocationLog> LocationLogs { get; set; } = new List<LocationLog>();
        public List<AppLimit> AppLimits { get; set; } = new List<AppLimit>();
        public List<SensorAlert> SensorAlerts { get; set; } = new List<SensorAlert>();
    }
}
```

#### File: `Models/LocationLog.cs`
```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChildSafetyAPI.Models
{
    public class LocationLog
    {
        [Key]
        public int LogId { get; set; }

        [Required]
        public int DeviceId { get; set; }

        [ForeignKey("DeviceId")]
        public ChildrenDevice? Device { get; set; }

        [Required]
        public double Latitude { get; set; }

        [Required]
        public double Longitude { get; set; }

        public DateTime RecordedAt { get; set; } = DateTime.Now;
    }
}
```

#### File: `Models/AppLimit.cs`
```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChildSafetyAPI.Models
{
    public class AppLimit
    {
        [Key]
        public int LimitId { get; set; }

        [Required]
        public int DeviceId { get; set; }

        [ForeignKey("DeviceId")]
        public ChildrenDevice? Device { get; set; }

        [Required]
        [MaxLength(100)]
        public string AppName { get; set; } = string.Empty;

        [Required]
        [MaxLength(150)]
        public string PackageName { get; set; } = string.Empty;

        public int AllowedMinutesPerDay { get; set; } = 60;

        public bool IsBlocked { get; set; } = false;
    }
}
```

#### File: `Models/SensorAlert.cs`
```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChildSafetyAPI.Models
{
    public class SensorAlert
    {
        [Key]
        public int AlertId { get; set; }

        [Required]
        public int DeviceId { get; set; }

        [ForeignKey("DeviceId")]
        public ChildrenDevice? Device { get; set; }

        [Required]
        [MaxLength(50)]
        public string AlertType { get; set; } = string.Empty; // "HIGH_NOISE", "FALL_DETECTED"

        public double ValueRecorded { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
```

---

### 4.2. Nhóm thư mục DTOs/

#### File: `DTOs/AuthDTOs.cs`
```csharp
using System.ComponentModel.DataAnnotations;

namespace ChildSafetyAPI.DTOs
{
    public class RegisterRequest
    {
        [Required]
        public string FullName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MinLength(6)]
        public string Password { get; set; } = string.Empty;

        public string Role { get; set; } = "Parent"; // "Admin", "Staff", "Parent"
    }

    public class LoginRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string Password { get; set; } = string.Empty;
    }

    public class VerifyOtpRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [StringLength(6, MinimumLength = 6)]
        public string OtpCode { get; set; } = string.Empty;
    }

    public class AuthResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public int? UserId { get; set; }
        public string? FullName { get; set; }
        public string? Email { get; set; }
        public string? Role { get; set; }
        public string? Token { get; set; }
    }
}
```

#### File: `DTOs/ChildDTOs.cs`
```csharp
using System.ComponentModel.DataAnnotations;

namespace ChildSafetyAPI.DTOs
{
    public class CreateChildRequest
    {
        [Required]
        public int ParentId { get; set; }

        [Required]
        [MaxLength(100)]
        public string ChildName { get; set; } = string.Empty;
    }

    public class ChildResponse
    {
        public int DeviceId { get; set; }
        public int ParentId { get; set; }
        public string ChildName { get; set; } = string.Empty;
        public string PairingCode { get; set; } = string.Empty;
        public bool IsLocked { get; set; }
        public DateTime? LastActive { get; set; }
    }
}
```

#### File: `DTOs/AppLimitDTOs.cs`
```csharp
using System.ComponentModel.DataAnnotations;

namespace ChildSafetyAPI.DTOs
{
    public class CreateAppLimitRequest
    {
        [Required]
        public int DeviceId { get; set; }

        [Required]
        public string AppName { get; set; } = string.Empty;

        [Required]
        public string PackageName { get; set; } = string.Empty;

        public int AllowedMinutesPerDay { get; set; } = 60;

        public bool IsBlocked { get; set; } = false;
    }

    public class UpdateAppLimitRequest
    {
        public int AllowedMinutesPerDay { get; set; }
        public bool IsBlocked { get; set; }
    }
}
```

#### File: `DTOs/TrackingDTOs.cs`
```csharp
using System.ComponentModel.DataAnnotations;

namespace ChildSafetyAPI.DTOs
{
    public class UpdateLocationRequest
    {
        [Required]
        public int DeviceId { get; set; }

        [Required]
        public double Latitude { get; set; }

        [Required]
        public double Longitude { get; set; }
    }

    public class LocationResponse
    {
        public int DeviceId { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public DateTime RecordedAt { get; set; }
    }
}
```

#### File: `DTOs/AlertDTOs.cs`
```csharp
using System.ComponentModel.DataAnnotations;

namespace ChildSafetyAPI.DTOs
{
    public class ReportAlertRequest
    {
        [Required]
        public int DeviceId { get; set; }

        [Required]
        public string AlertType { get; set; } = string.Empty;

        [Required]
        public double ValueRecorded { get; set; }
    }
}
```

---

### 4.3. Nhóm thư mục Data/

#### File: `Data/AppDbContext.cs`
```csharp
using Microsoft.EntityFrameworkCore;
using ChildSafetyAPI.Models;

namespace ChildSafetyAPI.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<OtpCode> OtpCodes { get; set; }
        public DbSet<ChildrenDevice> ChildrenDevices { get; set; }
        public DbSet<LocationLog> LocationLogs { get; set; }
        public DbSet<AppLimit> AppLimits { get; set; }
        public DbSet<SensorAlert> SensorAlerts { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<ChildrenDevice>()
                .HasIndex(c => c.PairingCode)
                .IsUnique();
        }
    }
}
```

---

### 4.4. Nhóm thư mục Services/

#### File: `Services/IEmailService.cs`
```csharp
namespace ChildSafetyAPI.Services
{
    public interface IEmailService
    {
        Task SendEmailAsync(string toEmail, string subject, string body);
    }
}
```

#### File: `Services/EmailService.cs`
```csharp
using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;

namespace ChildSafetyAPI.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;

        public EmailService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task SendEmailAsync(string toEmail, string subject, string body)
        {
            var host = _configuration["SmtpSettings:Host"];
            var port = int.Parse(_configuration["SmtpSettings:Port"] ?? "587");
            var senderEmail = _configuration["SmtpSettings:SenderEmail"];
            var password = _configuration["SmtpSettings:Password"];

            var emailMessage = new MimeMessage();
            emailMessage.From.Add(new MailboxAddress("Child Safety System", senderEmail));
            emailMessage.To.Add(new MailboxAddress(toEmail, toEmail));
            emailMessage.Subject = subject;

            var bodyBuilder = new BodyBuilder { HtmlBody = body };
            emailMessage.Body = bodyBuilder.ToMessageBody();

            using var client = new SmtpClient();
            try
            {
                await client.ConnectAsync(host, port, SecureSocketOptions.StartTls);
                await client.AuthenticateAsync(senderEmail, password);
                await client.SendAsync(emailMessage);
                await client.DisconnectAsync(true);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SMTP Error] Không thể gửi email: {ex.Message}");
            }
        }
    }
}
```

#### File: `Services/IJwtService.cs`
```csharp
using ChildSafetyAPI.Models;

namespace ChildSafetyAPI.Services
{
    public interface IJwtService
    {
        string GenerateToken(User user);
    }
}
```

#### File: `Services/JwtService.cs`
```csharp
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using ChildSafetyAPI.Models;

namespace ChildSafetyAPI.Services
{
    public class JwtService : IJwtService
    {
        private readonly IConfiguration _configuration;

        public JwtService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public string GenerateToken(User user)
        {
            var jwtSettings = _configuration.GetSection("JWTKey");
            var secret = jwtSettings["Secret"]!;
            var issuer = jwtSettings["ValidIssuer"];
            var audience = jwtSettings["ValidAudience"];
            var expiryHours = Convert.ToDouble(jwtSettings["TokenExpiryTimeInHour"] ?? "24");

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
                new Claim(ClaimTypes.Name, user.FullName),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, user.Role),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddHours(expiryHours),
                Issuer = issuer,
                Audience = audience,
                SigningCredentials = credentials
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);

            return tokenHandler.WriteToken(token);
        }
    }
}
```

---

### 4.5. Nhóm thư mục Controllers/

#### File: `Controllers/AuthController.cs`
```csharp
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
```

#### File: `Controllers/ChildrenController.cs`
```csharp
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
```

#### File: `Controllers/AppLimitsController.cs`
```csharp
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
```

#### File: `Controllers/TrackingController.cs`
```csharp
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
```

#### File: `Controllers/AlertsController.cs`
```csharp
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
```

#### File: `Controllers/AdminController.cs`
```csharp
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
```

#### File: `Controllers/StaffController.cs`
```csharp
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
```

---

### 4.6. Nhóm cấu hình và Khởi chạy

#### File: `appsettings.json`
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=MY-PC\\MRHUNG189;Database=ChildSafetyDB;Trusted_Connection=True;TrustServerCertificate=True"
  },
  "JWTKey": {
    "Secret": "ChildSafetySecretKeyForAppDemo2026SuperSecureKey!",
    "ValidIssuer": "ChildSafetyAPI",
    "ValidAudience": "ChildSafetyMobileClient",
    "TokenExpiryTimeInHour": "24"
  },
  "SmtpSettings": {
    "Host": "smtp.gmail.com",
    "Port": "587",
    "SenderEmail": "your-email@gmail.com",
    "Password": "your-app-password"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

#### File: `Program.cs`
```csharp
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using ChildSafetyAPI.Data;
using ChildSafetyAPI.Services;

var builder = WebApplication.CreateBuilder(args);

// 1. Cấu hình Database kết nối SQL Server
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// 2. Đăng ký các Service vào DI Container
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<IJwtService, JwtService>();

// 3. Cấu hình JWT Bearer Authentication
var jwtSettings = builder.Configuration.GetSection("JWTKey");
var key = Encoding.UTF8.GetBytes(jwtSettings["Secret"]!);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["ValidIssuer"],
        ValidAudience = jwtSettings["ValidAudience"],
        IssuerSigningKey = new SymmetricSecurityKey(key)
    };
});

builder.Services.AddAuthorization();

// 4. Cấu hình Controllers
builder.Services.AddControllers();

// 5. Cấu hình Swagger OpenAPI hỗ trợ nhập Bearer Token
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "ChildSafetyAPI", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "Nhập token theo định dạng: Bearer {token}",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// 6. Cấu hình CORS để máy ảo hoặc điện thoại Flutter gọi API dễ dàng
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Pipeline xử lý HTTP request
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseCors("AllowAll");

// Middleware xác thực danh tính và phân quyền
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
```

---

## 5. HƯỚNG DẪN TẠO CƠ SỞ DỮ LIỆU VÀ CHẠY THỬ (VERIFICATION)

1. Mở **Package Manager Console** trong Visual Studio và chạy lần lượt 2 lệnh:
   ```powershell
   Add-Migration InitialChildSafetyDB
   Update-Database
   ```
   *EF Core sẽ tự động khởi tạo cơ sở dữ liệu `ChildSafetyDB` trên SQL Server với đầy đủ các bảng dữ liệu.*
2. Nhấn phím **F5** để khởi chạy server.
3. Trình duyệt sẽ mở Swagger UI tại địa chỉ `https://localhost:<port>/swagger`.
4. **Quy trình kiểm tra tính năng trên Swagger:**
   * **Bước 1 (Đăng ký):** Gọi `POST /api/Auth/register` để đăng ký tài khoản (chọn vai trò `Parent`, `Admin` hoặc `Staff`).
   * **Bước 2 (Đăng nhập):** Gọi `POST /api/Auth/login` bằng email và mật khẩu vừa đăng ký. Response sẽ trả về `demoOtp` và đồng thời gửi email chứa mã OTP 6 số.
   * **Bước 3 (Xác thực OTP & Nhận JWT):** Gọi `POST /api/Auth/verify-otp` với email và mã OTP. Response trả về chuỗi `Token` chứa thông tin người dùng và vai trò phân quyền.
   * **Bước 4 (Thử nghiệm CRUD):** Dùng `userId` tạo hồ sơ con tại `POST /api/Children/create` và kiểm tra các tính năng quản lý thiết bị.