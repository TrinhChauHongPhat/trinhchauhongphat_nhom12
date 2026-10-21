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

