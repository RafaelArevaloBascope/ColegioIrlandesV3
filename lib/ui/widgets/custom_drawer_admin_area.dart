import 'package:flutter/material.dart';
import 'package:pr_h23_irlandes_web/ui/pages/menu_options_psico.dart';
import 'package:pr_h23_irlandes_web/ui/pages/menu_options_admin_area.dart';
/*
    Redireccionamiento para usar el menu personalizado para psicologia
*/

class CustomDrawerAdminArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double drawerWidth = screenWidth * 0.4;
    double maxDrawerWidth = 800.0;
    double finalDrawerWidth = (screenWidth > maxDrawerWidth) ? drawerWidth : screenWidth;

    return SizedBox(
      width: finalDrawerWidth,
      child: Drawer(
        child: OptionsMenuPageAdminArea(),
      ),
    );
  }
}