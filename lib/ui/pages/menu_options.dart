import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OptionsMenuPage extends StatelessWidget {
  const OptionsMenuPage({super.key});

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
              title: 'Usuarios',
              imageUrl: 'usuarios',
              onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                Navigator.pushNamed(context, '/admin_dashboard');
              },
            ),
            CardOption(
              title: 'Estado económico',
              imageUrl: 'billetes-de-banco',
              onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                Navigator.pushNamed(context, '/estado_economico');
              },
            ),
            CardOption(
              title: 'Registro de Licencias',
              imageUrl: 'licencia',
              onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                Navigator.pushNamed(context, '/licences');
              },
            ),
            CardOption(
              title: 'Notificación estudiantil',
              imageUrl: 'advertencia',
              onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                Navigator.pushNamed(context, '/attention_calls');
              },
            ),
            CardOption(
              title: 'Administración de postulaciones',
              imageUrl: 'cuaderno-alternativo',
              onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                Navigator.pushNamed(context, '/interview_management');
              },
            ),
            CardOption(
              title: 'Calendario ',
              imageUrl: 'Calendar',
              onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                Navigator.pushNamed(context, '/CalendarPage');
              },
            ),
            CardOption(
              title: 'Credenciales de Usuario',
              imageUrl: 'cuaderno-alternativo',
              onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                Navigator.pushNamed(context, '/credential_view_home');
              },

            )
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
