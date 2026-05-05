class PaymentResult {
  final int id,reservationId; final double amount; final String method,status,transactionId; final DateTime createdAt;
  const PaymentResult({required this.id,required this.reservationId,required this.amount,required this.method,required this.status,required this.transactionId,required this.createdAt});
  factory PaymentResult.fromJson(Map<String,dynamic> j)=>PaymentResult(id:j['id'],reservationId:j['reservationId'],amount:(j['amount']as num).toDouble(),method:j['method'],status:j['status'],transactionId:j['transactionId'],createdAt:DateTime.tryParse(j['createdAt']??'')??DateTime.now());
}