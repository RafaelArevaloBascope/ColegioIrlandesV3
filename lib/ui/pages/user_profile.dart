import 'package:flutter/material.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/infraestructure/global/global_methods.dart';
import 'package:pr_h23_irlandes_web/ui/pages/edit_profile.dart';
import 'package:pr_h23_irlandes_web/ui/pages/menu_options.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/app_bar_custom.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/app_bar_custom_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'menu_options_admin_area.dart';
import 'menu_options_coord.dart';
import 'menu_options_psico.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key});

  @override
  _UserProfilePage createState() => _UserProfilePage();
}

class _UserProfilePage extends State<UserProfilePage>{
  PersonaModel? persona;
  String personaId = '';
  final PersonaDataSourceImpl _usuarioDataSource = PersonaDataSourceImpl();
  //
  final PersonaDataSourceImpl personaDataSource = PersonaDataSourceImpl();
  PersonaModel? usuario;
  String userRol = '';
  @override
  void initState() {
    super.initState();
    getPe().then((_) {
    //super.initState();
    getId();
  });
  }


  Future<void> getPe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    personaId = prefs.getString('personId')!;
    usuario = await personaDataSource.getPersonFromId(personaId);
    userRol = usuario?.rol ?? '';
    print("tu"+ userRol);
  }
  void getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      personaId = prefs.getString('personId')!;
    });

    // Luego, puedes llamar a la función para obtener los datos del usuario
    loadUserData();
  }

  void loadUserData() async {
    try {
      PersonaModel? loadedPersona =
          await _usuarioDataSource.getPersonFromId(personaId);

      // Verifica que loadedPersona no sea nulo antes de asignar a persona
      if (loadedPersona != null) {
        setState(() {
          persona = loadedPersona;
        });
      } else {
        // Manejar el caso donde loadedPersona es nulo
        print('Error: loadedPersona es nulo');
        setState(() {
          persona = PersonaModel.AdminHarcoded;
        });
      }
    } catch (error) {

      // Manejar el error si ocurre durante la carga de datos del usuario
      print('Error al cargar datos del usuario: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (persona == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    getId();
    Future.delayed(const Duration(seconds: 2), () async {
     persona =await _usuarioDataSource.getPersonFromId(personaId) as PersonaModel;
    });
    return Scaffold(
        backgroundColor: GlobalMethods.secondaryColor,
        appBar:  AppBarCustomProfile(
          title: 'Perfil de Usuario',
          userRol: userRol,
        ),
        //drawer: const OptionsMenuPage(),

        drawer: userRol == "coordinacion_dos" || userRol == "coordinacion_uno"
            ? const OptionsMenuPageCoord()
            : userRol == "psicologia_uno" || userRol == "psicologia_dos"
            ? const OptionsMenuPagePsico()
            : userRol == "Administrador de Area"
            ? const OptionsMenuPageAdminArea()
            : const OptionsMenuPage(),
        body: Align(
            alignment: Alignment.topCenter,
            child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Column(children: [
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(45),
                      ),
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, '/edit_profile_picture');
                          },
                          child: const CircleAvatar(
                            radius: 45,
                            backgroundImage: AssetImage("ui/usuario.png"),
                          ))),
                  const SizedBox(height: 20),
                  Text(
                    persona!.username,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        child: SizedBox(
                            child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.abc),
                                      const Text('Nombre: ',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      Text(
                                          '${persona!.name} ${persona!.lastname} ${persona!.surname}',
                                          style: const TextStyle(fontSize: 20))
                                    ],
                                  ),
                                  const SizedBox(height: 9),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.phone),
                                      const Text('Teléfono: ',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      Text(persona!.telephone,
                                          style: const TextStyle(fontSize: 20))
                                    ],
                                  ),
                                  const SizedBox(height: 9),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.phone_android),
                                      const Text('Celular: ',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      Text(persona!.cellphone,
                                          style: const TextStyle(fontSize: 20))
                                    ],
                                  ),
                                  const SizedBox(height: 9),
                                  Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.email),
                                        const Text('Correo: ',
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                        Text(persona!.mail,
                                            style:
                                                const TextStyle(fontSize: 20))
                                      ]),
                                  const SizedBox(height: 9),
                                  Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.home),
                                        const Text('Dirección: ',
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                        Text(persona!.direction,
                                            style:
                                                const TextStyle(fontSize: 20))
                                      ]),
                                  const SizedBox(height: 20),
                                  Column(
                                    children: [

                                      userRol != "coordinacion_dos" && userRol != "psicologia_uno" && userRol != "Administrador de Area"&& userRol != "psicologia_dos"&& userRol != "coordinacion_uno"
                                          ?ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.greenAccent,
                                            elevation: 3,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(32.0)),
                                            minimumSize: const Size(200, 40)),
                                        onPressed: () {
                                          Navigator.push(
                                    context,
                                          MaterialPageRoute(
                                      builder: (context) => EditProfilePage(currentUser: persona!)
                                    ));
                                        },
                                        child: const Text(
                                            "Editar")
                                      )//,
                                    : SizedBox.shrink(),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.greenAccent,
                                            elevation: 3,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(32.0)),
                                            minimumSize: const Size(200, 40)),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/edit_password');
                                        },
                                        child: const Text(
                                            "Cambiar contraseña")
                                      )
                                    ]
                                  )
                                    
                                ])))),
                  )),
                  const SizedBox(height: 50),
                ]))));
  }
}