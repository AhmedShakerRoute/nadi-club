# نادي مصنع الطائرات — نظام حجز الملاعب

## المكونات
- **Backend**: ASP.NET Core 8 + EF Core + SQL Server + SignalR
- **Mobile**: Flutter 3.x (Android + iOS) — واجهة عربية RTL

---

## IP الجهاز: 192.168.22.2

---

## تشغيل الـ Backend

```bash
cd backend/NadiApp.API
dotnet restore
# عدّل appsettings.json → ConnectionStrings
dotnet ef migrations add Init
dotnet ef database update
dotnet run
# API: http://192.168.22.2:5000
# Swagger: http://localhost:5000/swagger
```

**بيانات تجريبية:**
- مدير: admin@nadi.com / admin123
- عضو: ahmed@nadi.com / user123

---

## تشغيل تطبيق Flutter

```bash
cd mobile/nadi_masna
flutter pub get
# IP مُعيَّن مسبقاً: 192.168.22.2 (lib/utils/constants.dart)
flutter run
```

**نشر على Google Play:**
```bash
flutter build appbundle --release
# الملف: build/app/outputs/bundle/release/app-release.aab
```

---

## مميزات النظام
1. تسجيل دخول وتسجيل حساب جديد
2. عرض الملاعب المتاحة
3. حجز ملعب بخطوات (اختر → تاريخ → وقت → تأكيد)
4. دفع 25% مقدماً (فيزا أو فودافون كاش)
5. إشعار فوري للمدير عند نجاح الدفع (SignalR)
6. لوحة إدارة كاملة: ملاعب + حجوزات + أعضاء + إشعارات
7. وضع ليلي / نهاري قابل للتبديل
8. واجهة عربية RTL بالكامل
9. الرمز "AFC" بالإنجليزية في أعلى التطبيق
