using NadiApp.API.Data;
using NadiApp.API.DTOs;
using NadiApp.API.Models;
using NadiApp.API.Hubs;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace NadiApp.API.Services;

public interface IReservationService
{
    Task<List<ReservationResponse>> GetAllAsync();
    Task<List<ReservationResponse>> GetByUserAsync(int userId);
    Task<ReservationResponse?> CreateAsync(int userId, CreateReservationRequest req);
    Task<bool> UploadScreenshotAsync(int reservationId, int userId, string base64);
    Task<bool> UploadGroupScreenshotAsync(string groupId, int userId, string base64);
    Task<bool> AdminReviewAsync(AdminReviewRequest req);
    Task<bool> AdminReviewGroupAsync(AdminReviewGroupRequest req);
    Task<bool> CancelAsync(int id, int userId, string role);
    Task<bool> CancelGroupAsync(string groupId, int userId, string role);
    Task<List<AvailabilityResponse>> GetAvailabilityAsync(int courtId, string date);
}

public class ReservationService(AppDbContext db, IHubContext<NotifHub> hub) : IReservationService
{

    static readonly string[] Hours = [
        "06:00","07:00","08:00","09:00","10:00","11:00","12:00",
        "13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00"
    ];

    public async Task<List<ReservationResponse>> GetAllAsync() =>
        (await db.Reservations.Include(r => r.User).Include(r => r.Court)
            .OrderByDescending(r => r.BookedAt).ToListAsync()).Select(ToDto).ToList();

    public async Task<List<ReservationResponse>> GetByUserAsync(int userId) =>
        (await db.Reservations.Include(r => r.User).Include(r => r.Court)
            .Where(r => r.UserId == userId).OrderByDescending(r => r.BookedAt)
            .ToListAsync()).Select(ToDto).ToList();

    public async Task<List<AvailabilityResponse>> GetAvailabilityAsync(int courtId, string date)
    {
        var d = DateOnly.Parse(date);
        var booked = await db.Reservations
            .Where(r => r.CourtId == courtId && r.Date == d && r.Status == "confirmed")
            .Select(r => r.StartTime.ToString("HH:mm")).ToListAsync();
        return Hours.Select(h => new AvailabilityResponse(h, !booked.Contains(h))).ToList();
    }

    public async Task<ReservationResponse?> CreateAsync(int userId, CreateReservationRequest req)
    {
        var court = await db.Courts.FindAsync(req.CourtId);
        if (court == null || court.Status != "active") return null;

        var date = DateOnly.Parse(req.Date);
        var start = TimeOnly.Parse(req.StartTime);

        var conflict = await db.Reservations.AnyAsync(r =>
            r.CourtId == req.CourtId && r.Date == date &&
            r.StartTime == start && r.Status == "confirmed");
        if (conflict) return null;

        var deposit = Math.Round(court.HourlyRate * 0.25m, 2);
        var res = new Reservation
        {
            UserId = userId,
            CourtId = req.CourtId,
            Date = date,
            StartTime = start,
            EndTime = start.AddHours(1),
            TotalPrice = court.HourlyRate,
            DepositAmount = deposit,
            Status = "pending_screenshot",
            GroupId = req.GroupId
        };
        db.Reservations.Add(res);
        await db.SaveChangesAsync();
        await db.Entry(res).Reference(r => r.User).LoadAsync();
        await db.Entry(res).Reference(r => r.Court).LoadAsync();

        // Only notify admin for single bookings (multi-hour notifies once via group)
        if (req.GroupId == null)
        {
            await NotifyAdmin("طلب حجز جديد",
                string.Join("\n", new[] {
                    "العضو: " + res.User.Name,
                    "الملعب: " + res.Court.Name,
                    "التاريخ: " + date.ToString("yyyy-MM-dd") + " - " + start.ToString("HH:mm"),
                    "بانتظار إرسال إيصال الدفع"
                }), "new_booking", res.Id);
        }
        return ToDto(res);
    }

    public async Task<bool> UploadScreenshotAsync(int reservationId, int userId, string base64)
    {
        var res = await db.Reservations.Include(r => r.User).Include(r => r.Court)
            .FirstOrDefaultAsync(r => r.Id == reservationId);
        if (res == null || res.UserId != userId) return false;
        if (res.Status != "pending_screenshot") return false;

        res.ScreenshotBase64 = base64;
        res.Status = "pending_review";
        await db.SaveChangesAsync();

        await NotifyAdmin("ايصال دفع مرسل - بانتظار مراجعتك",
            string.Join("\n", new[] {
                "العضو: " + res.User.Name,
                "الملعب: " + res.Court.Name,
                "التاريخ: " + res.Date.ToString("yyyy-MM-dd") + " - " + res.StartTime.ToString("HH:mm"),
                "المبلغ: " + res.DepositAmount + " جنيه"
            }), "screenshot_uploaded", res.Id);
        return true;
    }

    public async Task<bool> UploadGroupScreenshotAsync(string groupId, int userId, string base64)
    {
        var group = await db.Reservations.Include(r => r.User).Include(r => r.Court)
            .Where(r => r.GroupId == groupId && r.UserId == userId && r.Status == "pending_screenshot")
            .OrderBy(r => r.StartTime).ToListAsync();
        if (!group.Any()) return false;

        var first = group.First();
        var last = group.Last();
        foreach (var r in group)
        {
            r.ScreenshotBase64 = base64;
            r.Status = "pending_review";
        }
        await db.SaveChangesAsync();

        await NotifyAdmin("ايصال دفع مرسل - حجز متعدد الساعات",
            string.Join("\n", new[] {
                "العضو: " + first.User.Name,
                "الملعب: " + first.Court.Name,
                "التاريخ: " + first.Date.ToString("yyyy-MM-dd"),
                "الوقت: " + first.StartTime.ToString("HH:mm") + " – " + last.EndTime.ToString("HH:mm"),
                "المدة: " + group.Count + " ساعات",
                "المبلغ: " + group.Sum(r => r.DepositAmount) + " جنيه"
            }), "screenshot_uploaded", first.Id);
        return true;
    }

    public async Task<bool> AdminReviewAsync(AdminReviewRequest req)
    {
        var res = await db.Reservations.FirstOrDefaultAsync(r => r.Id == req.ReservationId);
        if (res == null) return false;
        if (req.Action == "confirm")
        {
            res.Status = "confirmed";
            res.ConfirmedAt = DateTime.UtcNow;
            res.AdminNote = req.Note;
        }
        else
        {
            res.Status = "cancelled";
            res.AdminNote = req.Note;
        }
        await db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> AdminReviewGroupAsync(AdminReviewGroupRequest req)
    {
        var group = await db.Reservations
            .Where(r => r.GroupId == req.GroupId && r.Status == "pending_review")
            .ToListAsync();
        if (!group.Any()) return false;
        foreach (var r in group)
        {
            if (req.Action == "confirm")
            {
                r.Status = "confirmed";
                r.ConfirmedAt = DateTime.UtcNow;
                r.AdminNote = req.Note;
            }
            else
            {
                r.Status = "cancelled";
                r.AdminNote = req.Note;
            }
        }
        await db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> CancelAsync(int id, int userId, string role)
    {
        var res = await db.Reservations.FindAsync(id);
        if (res == null || res.Status == "cancelled") return false;
        if (role != "admin" && res.UserId != userId) return false;
        if (role != "admin" && res.Status == "pending_review") return false;
        res.Status = "cancelled";
        await db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> CancelGroupAsync(string groupId, int userId, string role)
    {
        var group = await db.Reservations.Where(r => r.GroupId == groupId).ToListAsync();
        if (!group.Any()) return false;
        if (role != "admin" && group.Any(r => r.UserId != userId)) return false;
        if (role != "admin" && group.Any(r => r.Status == "pending_review")) return false;
        foreach (var r in group) r.Status = "cancelled";
        await db.SaveChangesAsync();
        return true;
    }

    private async Task NotifyAdmin(string title, string body, string type, int resId)
    {
        var notif = new Notification { Title = title, Body = body, Type = type, ReservationId = resId };
        db.Notifications.Add(notif);
        await db.SaveChangesAsync();
        await hub.Clients.Group("admins").SendAsync("NewNotification", new
        {
            notif.Id,
            notif.Title,
            notif.Body,
            notif.Type,
            notif.ReservationId,
            notif.CreatedAt
        });
    }

    private static ReservationResponse ToDto(Reservation r) => new(
      r.Id, r.UserId, r.User.Name, r.User.Email, r.User.Phone,
      r.CourtId, r.Court.Name, r.Court.Type,
      r.Date.ToString("yyyy-MM-dd"),
      r.StartTime.ToString("HH:mm"),
      r.EndTime.ToString("HH:mm"),
      r.Status, r.TotalPrice, r.DepositAmount,
      r.ScreenshotBase64 != null,
      r.BookedAt, r.AdminNote,
      r.GroupId);
}