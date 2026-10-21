using ChildSafetyAPI.Models;

namespace ChildSafetyAPI.Services
{
    public interface IJwtService
    {
        string GenerateToken(User user);
    }
}

