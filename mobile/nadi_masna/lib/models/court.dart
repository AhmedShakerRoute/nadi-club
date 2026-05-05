class Court {
  final int id; final String name,type,status,description; final int capacity; final double hourlyRate,totalRevenue; final int totalBookings; final DateTime createdAt;
  const Court({required this.id,required this.name,required this.type,required this.capacity,required this.hourlyRate,required this.status,required this.description,required this.totalBookings,required this.totalRevenue,required this.createdAt});
  bool get isActive => status=='active';
  String get icon => const{'Tennis':'🎾','Padel':'🏓','Squash':'🟡','Basketball':'🏀','Volleyball':'🏐','Badminton':'🏸'}[type]??'🏟️';
  String get typeAr => const{'Tennis':'تنس','Padel':'بادل','Squash':'إسكواش','Basketball':'كرة سلة','Volleyball':'كرة طائرة','Badminton':'ريشة'}[type]??type;
  String get statusAr => const{'active':'نشط','maintenance':'صيانة','closed':'مغلق'}[status]??status;
  factory Court.fromJson(Map<String,dynamic> j)=>Court(id:j['id'],name:j['name'],type:j['type'],capacity:j['capacity'],hourlyRate:(j['hourlyRate']as num).toDouble(),status:j['status'],description:j['description']??'',totalBookings:j['totalBookings']??0,totalRevenue:(j['totalRevenue']as num?)?.toDouble()??0,createdAt:DateTime.tryParse(j['createdAt']??'')??DateTime.now());
}