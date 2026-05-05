using NadiApp.API.Data;using NadiApp.API.DTOs;using Microsoft.EntityFrameworkCore;
namespace NadiApp.API.Services;
public interface IUserService{Task<List<UserResponse>>GetMembersAsync();Task<UserResponse?>GetByIdAsync(int id);Task<bool>ToggleAsync(int id);Task<UserResponse?>UpdateProfileAsync(int id,UpdateProfileRequest r);}
public class UserService(AppDbContext db):IUserService{
  public async Task<List<UserResponse>>GetMembersAsync()=>(await db.Users.Include(u=>u.Reservations).Where(u=>u.Role=="user").ToListAsync()).Select(D).ToList();
  public async Task<UserResponse?>GetByIdAsync(int id){var u=await db.Users.Include(u=>u.Reservations).FirstOrDefaultAsync(u=>u.Id==id);return u==null?null:D(u);}
  public async Task<bool>ToggleAsync(int id){var u=await db.Users.FindAsync(id);if(u==null)return false;u.Status=u.Status=="active"?"blocked":"active";await db.SaveChangesAsync();return true;}
  public async Task<UserResponse?>UpdateProfileAsync(int id,UpdateProfileRequest r){var u=await db.Users.Include(u=>u.Reservations).FirstOrDefaultAsync(u=>u.Id==id);if(u==null)return null;u.Name=r.Name;u.Phone=r.Phone;if(!string.IsNullOrWhiteSpace(r.NewPassword))u.PasswordHash=BCrypt.Net.BCrypt.HashPassword(r.NewPassword);await db.SaveChangesAsync();return D(u);}
  static UserResponse D(Models.User u)=>new(u.Id,u.Name,u.Email,u.Phone,u.Role,u.Status,u.JoinDate,u.Reservations.Count(r=>r.Status=="confirmed"),u.Reservations.Where(r=>r.Status=="confirmed").Sum(r=>r.TotalPrice));}