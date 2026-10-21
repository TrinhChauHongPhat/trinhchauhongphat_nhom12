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

