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

