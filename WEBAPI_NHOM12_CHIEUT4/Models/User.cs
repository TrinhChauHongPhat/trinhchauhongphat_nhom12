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

