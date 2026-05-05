namespace NadiApp.API.Models;
public class Payment{
  public int Id{get;set;}
  public int ReservationId{get;set;}
  public Reservation Reservation{get;set;}=null!;
  public decimal Amount{get;set;}
  public string Method{get;set;}=string.Empty;
  public string Status{get;set;}="completed";
  public string? CardLastFour{get;set;}
  public string? PhoneNumber{get;set;}
  public string TransactionId{get;set;}=Guid.NewGuid().ToString("N")[..12].ToUpper();
  public DateTime CreatedAt{get;set;}=DateTime.UtcNow;
}