import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_prov.dart';
import '../../providers/court_prov.dart';
import '../../providers/notif_prov.dart';
import '../../providers/res_prov.dart';
import '../../providers/theme_prov.dart';
import '../../utils/theme.dart';
import 'admin_overview.dart';
import 'admin_courts.dart';
import 'admin_reservations.dart';
import 'admin_members.dart';
import 'admin_notifs.dart';

class AdminShell extends StatefulWidget{const AdminShell({super.key});@override State<AdminShell> createState()=>_S();}
class _S extends State<AdminShell>{
  int _tab=0;
  @override void initState(){super.initState();WidgetsBinding.instance.addPostFrameCallback((_){context.read<CourtProv>().fetch();context.read<ResProv>().fetch(admin:true);context.read<NotifProv>().fetchCount();});}
  @override Widget build(BuildContext ctx){
    final dark=ctx.watch<ThemeProv>().isDark;
    final unread=ctx.watch<NotifProv>().unread;
    final screens=[const AdminOverview(),const AdminCourts(),const AdminReservations(),const AdminMembers(),const AdminNotifs()];
    final labels=['الرئيسية','الملاعب','الحجوزات','الأعضاء','الإشعارات'];
    final icons=[Icons.dashboard_outlined,Icons.sports_tennis_outlined,Icons.list_alt_outlined,Icons.people_outline,Icons.notifications_outlined];
    return Scaffold(
      appBar:AppBar(
        title:Row(children:[
          Container(width:34,height:34,decoration:BoxDecoration(gradient:const LinearGradient(colors:[C.gold,C.goldL]),borderRadius:BorderRadius.circular(8)),child:Center(child:Text('AFC',style:GoogleFonts.roboto(color:Colors.white,fontWeight:FontWeight.w900,fontSize:11,letterSpacing:1)))),
          const SizedBox(width:10),
          Text('لوحة الإدارة',style:GoogleFonts.tajawal(color:C.gold,fontWeight:FontWeight.w800)),
        ]),
        actions:[
          IconButton(icon:Icon(dark?Icons.light_mode_rounded:Icons.dark_mode_rounded,color:C.gold),onPressed:()=>ctx.read<ThemeProv>().toggle()),
          IconButton(icon:const Icon(Icons.logout_rounded),onPressed:()=>ctx.read<AuthProv>().logout()),
        ],
      ),
      body:IndexedStack(index:_tab,children:screens),
      bottomNavigationBar:BottomNavigationBar(
        currentIndex:_tab,
        onTap:(i)=>setState(()=>_tab=i),
        items:List.generate(5,(i)=>BottomNavigationBarItem(
          icon:Stack(children:[Icon(icons[i]),if(i==4&&unread>0)Positioned(right:0,top:0,child:Container(width:16,height:16,decoration:const BoxDecoration(color:C.err,shape:BoxShape.circle),child:Center(child:Text('$unread',style:const TextStyle(color:Colors.white,fontSize:9,fontWeight:FontWeight.w800)))))]),
          label:labels[i])),
      ),
    );
  }
}
