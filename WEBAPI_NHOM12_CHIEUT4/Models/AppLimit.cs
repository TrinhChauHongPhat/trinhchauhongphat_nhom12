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

