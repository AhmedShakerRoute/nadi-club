using NadiApp.API.Models;
using Microsoft.EntityFrameworkCore;

namespace NadiApp.API.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(AppDbContext db)
    {
        if (await db.Users.AnyAsync()) return;

        db.Users.AddRange(
            new User { Name = "مدير النادي", Email = "admin@nadi.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123"),
                Phone = "+20 100 000 0001", Role = "admin" },
            new User { Name = "أحمد حسن", Email = "ahmed@nadi.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("user123"),
                Phone = "+20 101 234 5678" },
            new User { Name = "سارة محمد", Email = "sara@nadi.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("user123"),
                Phone = "+20 102 345 6789" },
            new User { Name = "عمر خليل", Email = "omar@nadi.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("user123"),
                Phone = "+20 103 456 7890" }
        );

        db.Courts.AddRange(
            new Court { Name = "ملعب التنس ١",    Type = "Tennis",     Capacity = 4,  HourlyRate = 150, Status = "active",       Description = "أرضية كلاي احترافية" },
            new Court { Name = "ملعب التنس ٢",    Type = "Tennis",     Capacity = 4,  HourlyRate = 150, Status = "active",       Description = "أرضية كلاي احترافية" },
            new Court { Name = "ملعب البادل ١",   Type = "Padel",      Capacity = 4,  HourlyRate = 120, Status = "active",       Description = "جدران زجاجية مغلقة" },
            new Court { Name = "ملعب البادل ٢",   Type = "Padel",      Capacity = 4,  HourlyRate = 120, Status = "active",       Description = "جدران زجاجية مغلقة" },
            new Court { Name = "ملعب كرة القدم",  Type = "Football",   Capacity = 14, HourlyRate = 300, Status = "active",       Description = "أرضية عشب صناعي" },
            new Court { Name = "ملعب كرة السلة",  Type = "Basketball", Capacity = 10, HourlyRate = 200, Status = "active",       Description = "أرضية خشب كاملة" },
            new Court { Name = "ملعب كرة الطائرة ٣", Type = "Volleyball", Capacity = 12, HourlyRate = 180, Status = "active",   Description = "ملعب داخلي مجهز" }
        );

        await db.SaveChangesAsync();
    }
}