import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/*
    Menu personalizado para el rol de coordinacion
*/

class OptionsMenuPageCoord extends StatelessWidget {
  const OptionsMenuPageCoord({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFE3E9F4),
        appBar: AppBar(
          toolbarHeight: 60,
          backgroundColor: const Color(0xFFE3E9F4),
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/notice_main');
                },
                icon: const Image(
                    image: AssetImage('assets/ui/barra-de-menus.png')),
                iconSize: 50)
          ],
        ),
        body: Center(
            child: ListView(
          children: [
            const SizedBox(
              height: 20,
            ),
            CardOption(
              title: 'Ver Perfil',
              imageUrl: 'usuario',
              onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                Navigator.pushNamed(context, '/user_profile');
              },
            ),
            CardOption(
              title: 'Administración de postulaciones coordinacion',
              imageUrl: 'cuaderno-alternativo',
              onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                Navigator.pushNamed(context, '/Coordinationhomepage');
              },
            ),
            /*CardOption(
              title: 'Administración de informes - Psicología',
              imageUrl: 'cuaderno-alternativo',
              onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                Navigator.pushNamed(context, '/report_management');
              },
            ),
            CardOption(
              title: 'Administración de informes - Coordinación',
              imageUrl: 'cuaderno-alternativo',
              onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                Navigator.pushNamed(context, '/Coordinationhomepage');
              },
            )*/
          ],
        )));
  }
}

class CardOption extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback? onPressed;
  const CardOption(
      {super.key, required this.title, required this.imageUrl, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 33, right: 33, top: 10),
      child: Container(
        height: 94,
        decoration: BoxDecoration(
            color: const Color(0xFFffffff),
            borderRadius: BorderRadius.circular(6)),
        child: Center(
          child: InkWell(
            //efecto boton
            onTap: onPressed,
            child: ListTile(
              leading: Image(image: AssetImage('assets/ui/${imageUrl}.png')),
              title: Text(title,
                  style: GoogleFonts.lato(
                      color: const Color(0xFF3D5269), fontSize: 20)),
            ),
          ),
        ),
      ),
    );
  }
}
