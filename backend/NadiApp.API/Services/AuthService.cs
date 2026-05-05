using NadiApp.API.Data;using NadiApp.API.DTOs;using NadiApp.API.Models;
using Microsoft.EntityFrameworkCore;using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;using System.Security.Claims;using System.Text;
namespace NadiApp.API.Services;
public interface IAuthService{Task<AuthResponse?>LoginAsync(LoginRequest r);Task<AuthResponse?>RegisterAsync(RegisterRequest r);}
public class AuthService(AppDbContext db,IConfiguration cfg):IAuthService{
  public async Task<AuthResponse?>LoginAsync(LoginRequest req){
    var u=await db.Users.FirstOrDefaultAsync(u=>u.Email.ToLower()==req.Email.ToLower());
    if(u==null||!BCrypt.Net.BCrypt.Verify(req.Password,u.PasswordHash)||u.Status=="blocked")return null;
    return Build(u);}
  public async Task<AuthResponse?>RegisterAsync(RegisterRequest req){
    if(await db.Users.AnyAsync(u=>u.Email.ToLower()==req.Email.ToLower()))return null;
    var u=new User{Name=req.Name,Email=req.Email,PasswordHash=BCrypt.Net.BCrypt.HashPassword(req.Password),Phone=req.Phone};
    db.Users.Add(u);await db.SaveChangesAsync();return Build(u);}
  private AuthResponse Build(User u){
    var key=new SymmetricSecurityKey(Encoding.UTF8.GetBytes(cfg["Jwt:Key"]!));
    var claims=new[]{new Claim(ClaimTypes.NameIdentifier,u.Id.ToString()),new Claim(ClaimTypes.Email,u.Email),new Claim(ClaimTypes.Role,u.Role),new Claim("name",u.Name)};
    var tok=new JwtSecurityToken(cfg["Jwt:Issuer"],cfg["Jwt:Audience"],claims,expires:DateTime.UtcNow.AddHours(72),signingCredentials:new SigningCredentials(key,SecurityAlgorithms.HmacSha256));
    return new AuthResponse(u.Id,u.Name,u.Email,u.Phone,u.Role,u.Status,new JwtSecurityTokenHandler().WriteToken(tok));}}