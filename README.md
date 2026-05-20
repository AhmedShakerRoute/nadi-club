Aircraft Factory Club — Court Booking System
Backend: ASP.NET Core 8 + EF Core + SQL Server + SignalR
Mobile: Flutter 3.x Android + iOS — RTL Support
Running the Backend
cd backend/NadiApp.API
dotnet restore

# Update appsettings.json → ConnectionStrings

dotnet ef migrations add Init
dotnet ef database update
dotnet run

# API: http://localhost:5000
# Swagger: http://localhost:5000/swagger

Test Accounts:

Admin: admin@nadi.com / admin123
Member: ahmed@nadi.com / user123
Running the Flutter App
cd mobile/nadi_masna
flutter pub get

# Predefined IP: 192.168.22.2
# File location: lib/utils/constants.dart

flutter run

Publishing to Google Play:

flutter build appbundle --release

# Output file:
# build/app/outputs/bundle/release/app-release.aab
System Features
Login and user registration
Display available courts
Court booking in simple steps: select court → choose date → choose time → confirm
Pay 25% in advance using Visa or Vodafone Cash
Instant notification sent to the admin after successful payment using SignalR
Full admin dashboard: courts, bookings, members, and notifications
Switchable dark mode and light mode
Fully Arabic RTL user interface
The “AFC” logo/text is displayed in English at the top of the application
