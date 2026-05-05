class K {
  // ── Server (update before build) ─────────────────────────────────────────
  static const String serverIp   = '10.0.2.2';   // ← your LAN IP
  // static const String serverIp   = '192.168.22.2';   // ← your LAN 
  static const String serverPort = '5000';
//  static const String baseUrl    = 'http://$serverIp:$serverPort';
    static const String baseUrl    = 'https://escapist-unscathed-escalate.ngrok-free.dev';
  static const String hubUrl     = 'http://$serverIp:$serverPort/hubs/notifications';
  // Production: 'https://api.nadimasna.com'

  // ── Storage keys ─────────────────────────────────────────────────────────
  static const tokenKey = 'auth_token';
  static const userKey  = 'auth_user';
  static const themeKey = 'is_dark';

  // ── App ───────────────────────────────────────────────────────────────────
  static const appName     = 'نادي مصنع الطائرات';
  static const appEn       = 'Aircraft Factory Club';
  static const appShort    = 'AFC';
  static const depositRate = 0.25; // 25%

  // ── Court types ────────────────────────────────────────────────────────────
  static const courtTypes = ['Tennis','Padel','Squash','Basketball','Volleyball','Badminton'];
  static const courtIcons = {'Tennis':'🎾','Padel':'🏓','Squash':'🟡','Basketball':'🏀','Volleyball':'🏐','Badminton':'🏸'};
  static const courtTypesAr = {'Tennis':'تنس','Padel':'بادل','Squash':'إسكواش','Basketball':'كرة سلة','Volleyball':'كرة طائرة','Badminton':'ريشة'};

  // ── Time slots ─────────────────────────────────────────────────────────────
  static const hours = ['06:00','07:00','08:00','09:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00'];
}
