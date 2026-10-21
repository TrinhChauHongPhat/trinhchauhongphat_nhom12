using Microsoft.EntityFrameworkCore;
using ChildSafetyAPI.Models;

namespace ChildSafetyAPI.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<OtpCode> OtpCodes { get; set; }
        public DbSet<ChildrenDevice> ChildrenDevices { get; set; }
        public DbSet<LocationLog> LocationLogs { get; set; }
        public DbSet<AppLimit> AppLimits { get; set; }
        public DbSet<SensorAlert> SensorAlerts { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<ChildrenDevice>()
                .HasIndex(c => c.PairingCode)
                .IsUnique();
        }
    }
}

