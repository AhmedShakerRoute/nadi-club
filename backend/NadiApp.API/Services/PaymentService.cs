using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using NadiApp.API.Data;
using NadiApp.API.DTOs;
using NadiApp.API.Hubs;
using NadiApp.API.Models;

namespace NadiApp.API.Services;

public interface IPaymentService
{
    Task<PaymentResponse?> ProcessAsync(PaymentRequest req);
}

public class PaymentService : IPaymentService
{
    private readonly AppDbContext db;
    private readonly IHubContext<NotifHub> hub;

    public PaymentService(AppDbContext db, IHubContext<NotifHub> hub)
    {
        this.db = db;
        this.hub = hub;
    }

    public async Task<PaymentResponse?> ProcessAsync(PaymentRequest req)
    {
        var res = await db.Reservations
            .Include(r => r.Court)
            .Include(r => r.User)
            .FirstOrDefaultAsync(r => r.Id == req.ReservationId);

        if (res == null || res.DepositPaid)
            return null;

        var pay = new Payment
        {
            ReservationId = req.ReservationId,
            Amount = res.DepositAmount,
            Method = req.Method,
            CardLastFour = req.CardLastFour,
            PhoneNumber = req.PhoneNumber
        };

        db.Payments.Add(pay);

        res.DepositPaid = true;
        res.Status = "confirmed";

        var method = req.Method == "visa" ? "بطاقة فيزا" : "فودافون كاش";

        var notif = new Notification
        {
            Title = "💳 دفعة مستلمة جديدة",
            Body =
                $"العضو: {res.User.Name}\n" +
                $"الملعب: {res.Court.Name}\n" +
                $"المبلغ: {res.DepositAmount} جنيه\n" +
                $"الطريقة: {method}\n" +
                $"رقم المعاملة: {pay.TransactionId}",
            Type = "payment",
            ReservationId = res.Id
        };

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

        return new PaymentResponse(
            pay.Id,
            pay.ReservationId,
            pay.Amount,
            pay.Method,
            pay.Status,
            pay.TransactionId,
            pay.CreatedAt
        );
    }
}