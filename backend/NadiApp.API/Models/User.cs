namespace NadiApp.API.Models;
public class User{
  public int Id{get;set;}
  public string Name{get;set;}=string.Empty;
  public string Email{get;set;}=string.Empty;
  public string PasswordHash{get;set;}=string.Empty;
  public string Phone{get;set;}=string.Empty;
  public string Role{get;set;}="user";
  public string Status{get;set;}="active";
  public DateTime JoinDate{get;set;}=DateTime.UtcNow;
  public ICollection<Reservation> Reservations{get;set;}=new List<Reservation>();
}