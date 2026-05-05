import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_prov.dart';
import '../../providers/theme_prov.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/w.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget{const LoginScreen({super.key});@override State<LoginScreen> createState()=>_S();}
class _S extends State<LoginScreen>{
  final _e=TextEditingController();final _p=TextEditingController();bool _obs=true;
  @override void dispose(){_e.dispose();_p.dispose();super.dispose();}
  void _snack(String m)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(m,style:GoogleFonts.tajawal()),backgroundColor:C.err,behavior:SnackBarBehavior.floating,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10))));
  Future<void> _go()async{if(_e.text.isEmpty||_p.text.isEmpty){_snack('أدخل البيانات المطلوبة');return;}final ok=await context.read<AuthProv>().login(_e.text.trim(),_p.text);if(!ok&&mounted)_snack(context.read<AuthProv>().err??'فشل الدخول');}
  @override Widget build(BuildContext ctx){
    final auth=ctx.watch<AuthProv>();final theme=ctx.watch<ThemeProv>();final dark=theme.isDark;
    return Scaffold(body:SafeArea(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Column(children:[
      const SizedBox(height:20),
      // Theme toggle
      Align(alignment:Alignment.centerLeft,child:Row(mainAxisSize:MainAxisSize.min,children:[Icon(dark?Icons.dark_mode:Icons.light_mode,color:C.gold,size:20),const SizedBox(width:6),Switch(value:dark,onChanged:(_)=>ctx.read<ThemeProv>().toggle())])),
      const SizedBox(height:16),
      const AppLogo(size:80),
      const SizedBox(height:16),
      Text(K.appName,style:GoogleFonts.tajawal(fontSize:22,fontWeight:FontWeight.w800,color:C.gold),textAlign:TextAlign.center),
      Text(K.appEn,style:GoogleFonts.roboto(fontSize:13,color:dark?C.dMu:C.lMu,letterSpacing:1.5)),
      const SizedBox(height:36),
      Container(decoration:BoxDecoration(color:dark?C.dCard:C.lCard,borderRadius:BorderRadius.circular(20),border:Border.all(color:dark?C.dBdr:C.lBdr)),padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('تسجيل الدخول',style:GoogleFonts.tajawal(fontSize:22,fontWeight:FontWeight.w800,color:dark?C.dTx:C.lTx)),
        const SizedBox(height:20),
        TextField(controller:_e,keyboardType:TextInputType.emailAddress,textDirection:TextDirection.ltr,decoration:InputDecoration(labelText:'البريد الإلكتروني',prefixIcon:const Icon(Icons.email_outlined,color:C.gold))),
        const SizedBox(height:14),
        TextField(controller:_p,obscureText:_obs,decoration:InputDecoration(labelText:'كلمة المرور',prefixIcon:const Icon(Icons.lock_outline,color:C.gold),suffixIcon:IconButton(icon:Icon(_obs?Icons.visibility_off_outlined:Icons.visibility_outlined,color:dark?C.dMu:C.lMu),onPressed:()=>setState(()=>_obs=!_obs))),onSubmitted:(_)=>_go()),
        const SizedBox(height:24),
        GoldBtn(text:'دخول',onTap:_go,loading:auth.loading,icon:Icons.login_rounded),
        const SizedBox(height:16),
        Center(child:GestureDetector(onTap:()=>Navigator.push(ctx,MaterialPageRoute(builder:(_)=>const RegisterScreen())),child:RichText(text:TextSpan(children:[TextSpan(text:'ليس لديك حساب؟ ',style:GoogleFonts.tajawal(color:dark?C.dMu:C.lMu,fontSize:14)),TextSpan(text:'سجّل الآن',style:GoogleFonts.tajawal(color:C.gold,fontWeight:FontWeight.w800,fontSize:14))])))),
      ])),
      const SizedBox(height:20),
      Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:C.gold.withOpacity(.08),borderRadius:BorderRadius.circular(12),border:Border.all(color:C.gold.withOpacity(.3))),child:Column(children:[
        Text('بيانات الدخول التجريبية',style:GoogleFonts.tajawal(color:C.gold,fontWeight:FontWeight.w800,fontSize:13)),
        const SizedBox(height:6),
        Text('مدير: admin@nadi.com / admin123',style:GoogleFonts.tajawal(color:dark?C.dMu:C.lMu,fontSize:12)),
        Text('عضو: ahmed@nadi.com / user123',style:GoogleFonts.tajawal(color:dark?C.dMu:C.lMu,fontSize:12)),
      ])),
    ]))));
  }
}