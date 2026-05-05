class AppNotif {
  final int id; final String title,body,type; final bool isRead; final int? reservationId; final DateTime createdAt;
  const AppNotif({required this.id,required this.title,required this.body,required this.type,required this.isRead,this.reservationId,required this.createdAt});
  factory AppNotif.fromJson(Map<String,dynamic> j)=>AppNotif(id:j['id'],title:j['title'],body:j['body'],type:j['type'],isRead:j['isRead'],reservationId:j['reservationId'],createdAt:DateTime.tryParse(j['createdAt']??'')??DateTime.now());
}