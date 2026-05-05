using NadiApp.API.DTOs;
using NadiApp.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace NadiApp.API.Controllers;

[ApiController][Route("api/[controller]")][Authorize]
public class ReservationsController(IReservationService svc) : ControllerBase {
    int UserId => int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
    string Role => User.FindFirst(ClaimTypes.Role)!.Value;

    [HttpGet] public async Task<IActionResult> Get() =>
        Ok(Role=="admin" ? await svc.GetAllAsync() : await svc.GetByUserAsync(UserId));

    [HttpGet("mine")] public async Task<IActionResult> Mine() => Ok(await svc.GetByUserAsync(UserId));

    [HttpPost] public async Task<IActionResult> Create(CreateReservationRequest req) {
        var r = await svc.CreateAsync(UserId, req);
        return r==null ? BadRequest(new{message="الموعد غير متاح"}) : Created("",r);
    }

    [HttpPost("screenshot")] public async Task<IActionResult> Screenshot(UploadScreenshotRequest req) {
        var ok = await svc.UploadScreenshotAsync(req.ReservationId, UserId, req.ScreenshotBase64);
        return ok ? Ok() : BadRequest(new{message="لا يمكن رفع الإيصال"});
    }

    [HttpPost("group-screenshot")] public async Task<IActionResult> GroupScreenshot(UploadGroupScreenshotRequest req) {
        var ok = await svc.UploadGroupScreenshotAsync(req.GroupId, UserId, req.ScreenshotBase64);
        return ok ? Ok() : BadRequest(new{message="لا يمكن رفع الإيصال"});
    }

    [HttpGet("{id}/screenshot")][Authorize(Roles="admin")]
    public async Task<IActionResult> GetScreenshot(int id) {
        using var scope = HttpContext.RequestServices.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<NadiApp.API.Data.AppDbContext>();
        var r = await db.Reservations.FindAsync(id);
        if (r?.ScreenshotBase64==null) return NotFound();
        return Ok(new{screenshot=r.ScreenshotBase64});
    }

    [HttpPut("review")][Authorize(Roles="admin")]
    public async Task<IActionResult> Review(AdminReviewRequest req) =>
        await svc.AdminReviewAsync(req) ? Ok() : NotFound();

    [HttpPut("review-group")][Authorize(Roles="admin")]
    public async Task<IActionResult> ReviewGroup(AdminReviewGroupRequest req) =>
        await svc.AdminReviewGroupAsync(req) ? Ok() : NotFound();

    [HttpPut("{id}/cancel")] public async Task<IActionResult> Cancel(int id) =>
        await svc.CancelAsync(id, UserId, Role) ? Ok() : Forbid();

    [HttpPut("cancel-group")] public async Task<IActionResult> CancelGroup([FromQuery]string groupId) =>
        await svc.CancelGroupAsync(groupId, UserId, Role) ? Ok() : Forbid();

    [HttpGet("availability")]
    public async Task<IActionResult> Avail([FromQuery]int courtId, [FromQuery]string date) =>
        Ok(await svc.GetAvailabilityAsync(courtId, date));

    [HttpGet("payment-info")] public IActionResult PaymentInfo() =>
        Ok(new PaymentInfoResponse("نادي مصنع الطائرات","1234567890","بنك مصر",0,"حوّل المبلغ وأرفق الإيصال"));
}