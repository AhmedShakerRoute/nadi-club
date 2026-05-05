using NadiApp.API.DTOs;using NadiApp.API.Services;using Microsoft.AspNetCore.Authorization;using Microsoft.AspNetCore.Mvc;
namespace NadiApp.API.Controllers;
[ApiController][Route("api/[controller]")]
public class CourtsController(ICourtService s):ControllerBase{
  [HttpGet] public async Task<IActionResult> All()=>Ok(await s.GetAllAsync());
  [HttpGet("{id}")] public async Task<IActionResult> Get(int id){var c=await s.GetByIdAsync(id);return c==null?NotFound():Ok(c);}
  [HttpGet("{id}/availability")][Authorize] public async Task<IActionResult> Avail(int id,[FromQuery]string date)=>Ok(await s.AvailAsync(id,date));
  [HttpPost][Authorize(Roles="admin")] public async Task<IActionResult> Create(CourtUpsertRequest r)=>Created("",await s.CreateAsync(r));
  [HttpPut("{id}")][Authorize(Roles="admin")] public async Task<IActionResult> Update(int id,CourtUpsertRequest r){var x=await s.UpdateAsync(id,r);return x==null?NotFound():Ok(x);}
  [HttpDelete("{id}")][Authorize(Roles="admin")] public async Task<IActionResult> Delete(int id)=>await s.DeleteAsync(id)?NoContent():NotFound();}