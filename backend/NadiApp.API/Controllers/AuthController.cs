using NadiApp.API.DTOs;using NadiApp.API.Services;using Microsoft.AspNetCore.Mvc;
namespace NadiApp.API.Controllers;
[ApiController][Route("api/[controller]")]
public class AuthController(IAuthService a):ControllerBase{
  [HttpPost("login")] public async Task<IActionResult> Login(LoginRequest r){var x=await a.LoginAsync(r);return x==null?Unauthorized(new{message="بيانات غير صحيحة أو الحساب محظور"}):Ok(x);}
  [HttpPost("register")] public async Task<IActionResult> Register(RegisterRequest r){if(string.IsNullOrWhiteSpace(r.Name)||r.Password.Length<6)return BadRequest(new{message="تحقق من البيانات"});var x=await a.RegisterAsync(r);return x==null?Conflict(new{message="البريد مسجل مسبقاً"}):Created("",x);}}