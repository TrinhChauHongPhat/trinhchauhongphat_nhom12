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

