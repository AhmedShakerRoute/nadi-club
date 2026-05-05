import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user.dart';
import '../../services/api.dart';
import '../../utils/theme.dart';
import '../../widgets/w.dart';

class AdminMembers extends StatefulWidget {
  const AdminMembers({super.key});
  @override State<AdminMembers> createState() => _S();
}

class _S extends State<AdminMembers> {
  List<AppUser> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _users = (await api.users()).map((j) => AppUser.fromJson(j)).toList();
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _toggle(AppUser u) async {
    try {
      await api.toggleUser(u.id);
      await _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext ctx) => _loading
    ? const Center(child: CircularProgressIndicator(color: C.gold))
    : RefreshIndicator(
        color: C.gold,
        onRefresh: _load,
        child: _users.isEmpty
          ? const EmptyV(icon: Icons.people_outline, msg: 'لا يوجد اعضاء')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (_, i) => _Tile(_users[i], () => _toggle(_users[i]))),
      );
}

class _Tile extends StatelessWidget {
  final AppUser u;
  final VoidCallback onToggle;
  const _Tile(this.u, this.onToggle);

  @override
  Widget build(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Row(children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: C.gold.withOpacity(0.15),
              child: Text(
                u.name.substring(0, 1),
                style: GoogleFonts.tajawal(
                  color: C.gold, fontWeight: FontWeight.w800, fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.name, style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w700, fontSize: 14,
                  color: dark ? C.dTx : C.lTx)),
                Text(u.email, style: GoogleFonts.tajawal(
                  color: dark ? C.dMu : C.lMu, fontSize: 12)),
                Text(u.phone.isEmpty ? 'بدون هاتف' : u.phone,
                  style: GoogleFonts.tajawal(
                    color: dark ? C.dMu : C.lMu, fontSize: 12)),
              ])),
            StatusBadge(u.status),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('عضو منذ: ${u.joinDate.year}',
              style: GoogleFonts.tajawal(
                color: dark ? C.dMu : C.lMu, fontSize: 12)),
            OutlinedButton(
              onPressed: onToggle,
              style: OutlinedButton.styleFrom(
                foregroundColor: u.isActive ? C.err : C.ok,
                side: BorderSide(color: u.isActive ? C.err : C.ok),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              child: Text(
                u.isActive ? 'حظر' : 'رفع الحظر',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w700))),
          ]),
        ]),
      ),
    );
  }
}