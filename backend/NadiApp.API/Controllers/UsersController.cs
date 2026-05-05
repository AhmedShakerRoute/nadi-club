using NadiApp.API.DTOs;using NadiApp.API.Services;using Microsoft.AspNetCore.Authorization;using Microsoft.AspNetCore.Mvc;using System.Security.Claims;
namespace NadiApp.API.Controllers;
[ApiController][Route("api/[controller]")][Authorize]
public class UsersController(IUserService s):ControllerBase{
  int Uid=>int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
  [HttpGet][Authorize(Roles="admin")] public async Task<IActionResult> All()=>Ok(await s.GetMembersAsync());
  [HttpGet("{id}")] public async Task<IActionResult> Get(int id){var u=await s.GetByIdAsync(id);return u==null?NotFound():Ok(u);}
  [HttpPut("{id}/profile")] public async Task<IActionResult> Update(int id,UpdateProfileRequest r){if(User.FindFirst(ClaimTypes.Role)!.Value!="admin"&&id!=Uid)return Forbid();var x=await s.UpdateProfileAsync(id,r);return x==null?NotFound():Ok(x);}
  [HttpPut("{id}/toggle")][Authorize(Roles="admin")] public async Task<IActionResult> Toggle(int id)=>await s.ToggleAsync(id)?Ok():NotFound();}