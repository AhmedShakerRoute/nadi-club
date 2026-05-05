namespace NadiApp.API.Models;
public class Notification{
  public int Id{get;set;}
  public string Title{get;set;}=string.Empty;
  public string Body{get;set;}=string.Empty;
  public string Type{get;set;}="payment";
  public bool IsRead{get;set;}=false;
  public int? ReservationId{get;set;}
  public DateTime CreatedAt{get;set;}=DateTime.UtcNow;
}