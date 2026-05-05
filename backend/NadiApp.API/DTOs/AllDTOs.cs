namespace NadiApp.API.DTOs;

// ── Auth ──────────────────────────────────────────────────────────────────────
public record LoginRequest(string Email, string Password);
public record RegisterRequest(string Name, string Email, string Password, string Phone);
public record AuthResponse(int Id, string Name, string Email, string Phone, string Role, string Status, string Token);

// ── Courts ────────────────────────────────────────────────────────────────────
public record CourtResponse(int Id, string Name, string Type, int Capacity, decimal HourlyRate, string Status, string Description, int TotalBookings, decimal TotalRevenue, DateTime CreatedAt);
public record CourtUpsertRequest(string Name, string Type, int Capacity, decimal HourlyRate, string Status, string Description);

// ── Reservations ──────────────────────────────────────────────────────────────
public record ReservationResponse(
    int Id, int UserId, string UserName, string UserEmail, string UserPhone,
    int CourtId, string CourtName, string CourtType,
    string Date, string StartTime, string EndTime,
    string Status, decimal TotalPrice, decimal DepositAmount,
    bool HasScreenshot, DateTime BookedAt, string? AdminNote, string? GroupId);

public record CreateReservationRequest(int CourtId, string Date, string StartTime, string? GroupId);
public record UploadScreenshotRequest(int ReservationId, string ScreenshotBase64);
public record AdminReviewRequest(int ReservationId, string Action, string? Note);

// ── For uploading screenshot to entire group ──────────────────────────────────
public record UploadGroupScreenshotRequest(string GroupId, string ScreenshotBase64);

// ── For admin reviewing entire group ─────────────────────────────────────────
public record AdminReviewGroupRequest(string GroupId, string Action, string? Note);

public record AvailabilityResponse(string Hour, bool IsAvailable);
public record PaymentInfoResponse(string AccountName, string AccountNumber, string BankName, decimal DepositAmount, string Instructions);

// ── Notifications ─────────────────────────────────────────────────────────────
public record NotificationResponse(int Id, string Title, string Body, string Type, bool IsRead, int? ReservationId, DateTime CreatedAt);

// ── Users ─────────────────────────────────────────────────────────────────────
public record UserResponse(int Id, string Name, string Email, string Phone, string Role, string Status, DateTime JoinDate, int TotalBookings, decimal TotalRevenue);
public record UpdateProfileRequest(string Name, string Phone, string? NewPassword);