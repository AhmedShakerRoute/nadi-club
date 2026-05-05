using Microsoft.AspNetCore.Authorization;using Microsoft.AspNetCore.SignalR;
namespace NadiApp.API.Hubs;
[Authorize]
public class NotifHub:Hub{
  public override async Task OnConnectedAsync(){
    var role=Context.User?.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
    if(role=="admin")await Groups.AddToGroupAsync(Context.ConnectionId,"admins");
    await base.OnConnectedAsync();}}