import 'dart:convert';
class AppUser {
  final int id; final String name,email,phone,role,status,token; final DateTime joinDate;
  const AppUser({required this.id,required this.name,required this.email,required this.phone,required this.role,required this.status,required this.joinDate,this.token=''});
  bool get isAdmin => role=="admin";
  bool get isActive => status=="active";
  factory AppUser.fromJson(Map<String,dynamic> j,{String token=''}) => AppUser(id:j['id'],name:j['name'],email:j['email'],phone:j['phone']??'',role:j['role'],status:j['status'],joinDate:DateTime.tryParse(j['joinDate']??'')??DateTime.now(),token:token.isNotEmpty?token:(j['token']??''));
  Map<String,dynamic> toJson()=>{'id':id,'name':name,'email':email,'phone':phone,'role':role,'status':status,'joinDate':joinDate.toIso8601String(),'token':token};
}