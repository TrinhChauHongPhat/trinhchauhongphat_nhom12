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

