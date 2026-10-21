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

