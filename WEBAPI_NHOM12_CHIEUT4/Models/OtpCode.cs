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

