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

