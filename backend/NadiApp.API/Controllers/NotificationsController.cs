using NadiApp.API.Services;using Microsoft.AspNetCore.Authorization;using Microsoft.AspNetCore.Mvc;
namespace NadiApp.API.Controllers;
[ApiController][Route("api/[controller]")][Authorize(Roles="admin")]
public class NotificationsController(INotificationService s):ControllerBase{
  [HttpGet] public async Task<IActionResult> All()=>Ok(await s.GetAllAsync());
  [HttpGet("unread")] public async Task<IActionResult> Unread()=>Ok(new{count=await s.UnreadCountAsync()});
  [HttpPut("{id}/read")] public async Task<IActionResult> Read(int id){await s.MarkReadAsync(id);return Ok();}
  [HttpPut("read-all")] public async Task<IActionResult> ReadAll(){await s.MarkAllReadAsync();return Ok();}}