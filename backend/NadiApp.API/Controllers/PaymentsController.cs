using NadiApp.API.DTOs;using NadiApp.API.Services;using Microsoft.AspNetCore.Authorization;using Microsoft.AspNetCore.Mvc;
namespace NadiApp.API.Controllers;
[ApiController][Route("api/[controller]")][Authorize]
public class PaymentsController(IPaymentService s):ControllerBase{
  [HttpPost] public async Task<IActionResult> Pay(PaymentRequest r){var x=await s.ProcessAsync(r);return x==null?BadRequest(new{message="فشلت عملية الدفع أو تم الدفع مسبقاً"}):Ok(x);}}