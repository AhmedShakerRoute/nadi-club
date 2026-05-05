namespace NadiApp.API.Models;
public class Court{
  public int Id{get;set;}
  public string Name{get;set;}=string.Empty;
  public string Type{get;set;}=string.Empty;
  public int Capacity{get;set;}
  public decimal HourlyRate{get;set;}
  public string Status{get;set;}="active";
  public string Description{get;set;}=string.Empty;
  public DateTime CreatedAt{get;set;}=DateTime.UtcNow;
  public ICollection<Reservation> Reservations{get;set;}=new List<Reservation>();
}