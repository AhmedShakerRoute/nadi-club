namespace NadiApp.API.Models;
public class Reservation {
    public int Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public int CourtId { get; set; }
    public Court Court { get; set; } = null!;
    public DateOnly Date { get; set; }
    public TimeOnly StartTime { get; set; }
    public TimeOnly EndTime { get; set; }
    public string Status { get; set; } = "pending_screenshot";
    public decimal TotalPrice { get; set; }
    public decimal DepositAmount { get; set; }
    public string? ScreenshotBase64 { get; set; }
    public string? GroupId { get; set; }        // groups multi-hour bookings
    public DateTime BookedAt { get; set; } = DateTime.UtcNow;
    public DateTime? ConfirmedAt { get; set; }
    public string? AdminNote { get; set; }
}