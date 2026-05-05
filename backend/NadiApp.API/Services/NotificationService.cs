using NadiApp.API.Data;using NadiApp.API.DTOs;using Microsoft.EntityFrameworkCore;
namespace NadiApp.API.Services;
public interface INotificationService{Task<List<NotificationResponse>>GetAllAsync();Task<int>UnreadCountAsync();Task MarkReadAsync(int id);Task MarkAllReadAsync();}
public class NotificationService(AppDbContext db):INotificationService{
  public async Task<List<NotificationResponse>>GetAllAsync()=>(await db.Notifications.OrderByDescending(n=>n.CreatedAt).Take(50).ToListAsync()).Select(n=>new NotificationResponse(n.Id,n.Title,n.Body,n.Type,n.IsRead,n.ReservationId,n.CreatedAt)).ToList();
  public async Task<int>UnreadCountAsync()=>await db.Notifications.CountAsync(n=>!n.IsRead);
  public async Task MarkReadAsync(int id){var n=await db.Notifications.FindAsync(id);if(n!=null){n.IsRead=true;await db.SaveChangesAsync();}}
  public async Task MarkAllReadAsync()=>await db.Notifications.Where(n=>!n.IsRead).ExecuteUpdateAsync(s=>s.SetProperty(n=>n.IsRead,true));}