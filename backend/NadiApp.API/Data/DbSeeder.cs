using NadiApp.API.Models;
using Microsoft.EntityFrameworkCore;
namespace NadiApp.API.Data;
public static class DbSeeder{
  public static async Task SeedAsync(AppDbContext db){
    if(await db.Users.AnyAsync())return;
    db.Users.AddRange(
      new User{Name="مدير النادي",Email="admin@nadi.com",PasswordHash=BCrypt.Net.BCrypt.HashPassword("admin123"),Phone="+20 100 000 0001",Role="admin"},
      new User{Name="أحمد حسن",Email="ahmed@nadi.com",PasswordHash=BCrypt.Net.BCrypt.HashPassword("user123"),Phone="+20 101 234 5678"},
      new User{Name="سارة محمد",Email="sara@nadi.com",PasswordHash=BCrypt.Net.BCrypt.HashPassword("user123"),Phone="+20 102 345 6789"},
      new User{Name="عمر خليل",Email="omar@nadi.com",PasswordHash=BCrypt.Net.BCrypt.HashPassword("user123"),Phone="+20 103 456 7890"}
    );
    db.Courts.AddRange(
      new Court{Name="ملعب أ - التنس",Type="Tennis",Capacity=4,HourlyRate=150,Status="active",Description="أرضية كلاي احترافية"},
      new Court{Name="ملعب ب - البادل",Type="Padel",Capacity=4,HourlyRate=120,Status="active",Description="جدران زجاجية مغلقة"},
      new Court{Name="ملعب ج - الإسكواش",Type="Squash",Capacity=2,HourlyRate=100,Status="active",Description="مستوى أولمبي"},
      new Court{Name="ملعب د - كرة السلة",Type="Basketball",Capacity=10,HourlyRate=200,Status="maintenance",Description="أرضية خشب كاملة"}
    );
    await db.SaveChangesAsync();
  }
}