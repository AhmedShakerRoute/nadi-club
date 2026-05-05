import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/notif_prov.dart';
import '../../utils/theme.dart';
import '../../widgets/w.dart';

class AdminNotifs extends StatefulWidget {
  const AdminNotifs({super.key});
  @override State<AdminNotifs> createState() => _S();
}

class _S extends State<AdminNotifs> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      context.read<NotifProv>().fetch());
  }

  @override
  Widget build(BuildContext ctx) {
    final np   = ctx.watch<NotifProv>();
    final dark = Theme.of(ctx).brightness == Brightness.dark;

    return Column(children: [
      if (np.unread > 0)
        Container(
          color: dark ? C.dSurf : C.lSurf,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.done_all, size: 16),
              label: Text('تحديد الكل كمقروء', style: GoogleFonts.tajawal()),
              onPressed: () => ctx.read<NotifProv>().markAll(),
              style: OutlinedButton.styleFrom(
                foregroundColor: C.gold,
                side: const BorderSide(color: C.gold))),
          )),
      Expanded(child: np.loading
        ? const Center(child: CircularProgressIndicator(color: C.gold))
        : np.items.isEmpty
          ? const EmptyV(icon: Icons.notifications_none, msg: 'لا توجد إشعارات بعد')
          : RefreshIndicator(
              color: C.gold,
              onRefresh: () => ctx.read<NotifProv>().fetch(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: np.items.length,
                itemBuilder: (_, i) => NotifTile(
                  np.items[i],
                  onTap: !np.items[i].isRead
                    ? () => ctx.read<NotifProv>().markRead(np.items[i].id)
                    : null)))),
    ]);
  }
}