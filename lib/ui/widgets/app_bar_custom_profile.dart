import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBarCustomProfile extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCustomProfile({Key? key, required this.title, required this.userRol});

  final String title;
  final String userRol;

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
      backgroundColor: const Color(0xFFE3E9F4),
      toolbarHeight: 75,
      elevation: 0,
      leading: Center(
        child: IconButton(
          iconSize: 50,
          icon: const Image(
            image: AssetImage('assets/ui/barra-de-menus.png'),
          ),
          onPressed: () {
            //Navigator.pushNamed(context, '/optionmenu');
            // Navegar según el rol del usuario recibido
            if (userRol == "coordinacion_dos" || userRol == "coordinacion_uno") {
              Navigator.pushNamed(context, '/optionmenuCoord');
            } else if (userRol == "psicologia_uno" || userRol == "psicologia_dos") {
              Navigator.pushNamed(context, '/optionmenuPsico');
            } else if (userRol == "Administrador de Area") {
              Navigator.pushNamed(context, '/optionmenuArea');
            } else {
              Navigator.pushNamed(context, '/optionmenu');
            }
          },
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        ),
      ),
      actions: [
        IconButton(
          iconSize: 50,
          icon: const Image(image: AssetImage('assets/ui/home.png')),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
        IconButton(iconSize:25, icon: const Image(image: AssetImage('assets/ui/cerrarsesion.png') ), 
          onPressed: () async {
            // Pregunta al usuario si desea cerrar sesión
            bool confirmLogout = await _confirmLogoutDialog(context);
            if (confirmLogout) {
              // Cierra sesión y redirige a la pantalla de inicio de sesión
              await FirebaseAuth.instance.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacementNamed(context, '/');
            }
          },
          //icon: const Icon(Icons.exit_to_app),
          tooltip: 'Cerrar Sesión',
        ),
      ],
    );
  }

  Future<bool> _confirmLogoutDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Sí
              },
              child: const Text('Sí'),
            ),
          ],
        );
      },
    ) ?? false; // Por defecto, no cerrar sesión si se cierra el diálogo
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}