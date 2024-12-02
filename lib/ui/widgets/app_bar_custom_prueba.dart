import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pr_h23_irlandes_web/ui/pages/menu_options.dart';

class AppBarCustomPrueba extends StatelessWidget
    implements PreferredSizeWidget {
  const AppBarCustomPrueba({Key? key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: GoogleFonts.barlow(
          textStyle: const TextStyle(
            color: Color(0xFF3D5269),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      toolbarHeight: 75,
      elevation: 0,
      leading: Center(
        child: Builder(
          builder: (context) => IconButton(
            iconSize: 50,
            icon:
                const Image(image: AssetImage('assets/ui/barra-de-menus.png')),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(75);
}
