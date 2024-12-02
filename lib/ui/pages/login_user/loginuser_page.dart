import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/infraestructure/global/global_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fluro/fluro.dart'; // Importa fluro

class LoginUserPage extends StatefulWidget {
  const LoginUserPage({super.key});

  @override
  State<LoginUserPage> createState() => _LoginUserPageState();
}

class _LoginUserPageState extends State<LoginUserPage> {
  final PersonaDataSource _usuarioDataSource = PersonaDataSourceImpl();
  bool obscurePassword = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Container(
          color: const Color(0xFFE3E9F4),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 350,
                  height: 350,
                  child: Card(
                    color: const Color(0xFF044086),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Image.asset('assets/ui/logo.png',
                              width: 100,
                              height: 100),
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(25),
                              child: Text(
                                'COLEGIO ESCLAVAS DEL SAGRADO CORAZÓN DE JESÚS-IRLANDÉS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 350,
                  height: 350,
                  child: Card(
                    color: const Color(0xFFF1F1F1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const Text(
                              'Inicio de Sesión',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color(0xff3D5269)),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: usernameController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: AppLocalizations.of(context)!.user_prompt,
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: AppLocalizations.of(context)!
                                    .passwd_prompt,
                                prefixIcon:
                                const Icon(Icons.password_outlined),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                  icon: obscurePassword
                                      ? const Icon(Icons.visibility_outlined)
                                      : const Icon(
                                    Icons.visibility_off_outlined),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xff044086),
                                    minimumSize: const Size.fromHeight(50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final username = usernameController.text;
                                    final password = passwordController.text;
                                    try {

                                      PersonaModel? persona;
                                      PersonaModel usuario = PersonaModel.AdminHarcoded;
                                      if(username==usuario.username && password==usuario.password){
                                        persona = PersonaModel.AdminHarcoded;
                                      }
                                      else  {
                                        persona =
                                        await _authenticate(
                                            username, password);
                                      }
                                     // PersonaModel? persona =
                                      //await _authenticate(
                                        //  username, password);
                                      if (persona != null) {
                                        // Verificar el rol del usuario
                                        if (persona.rol == 'administrador') {
                                          // Usuario con rol de administrador
                                          SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                          await prefs.setString('personId', persona.id);
                                          Navigator.pushNamed(
                                              context, '/notice_main');
                                        } else if (persona.rol == 'psicologia_uno' || persona.rol == 'psicologia_dos') {
                                          // Usuario no tiene permisos de administrador
                                          SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                          await prefs.setString('personId', persona.id);
                                          Navigator.pushNamed(
                                              context, '/psicologia_page');                                        
                                        }
                                        else if (persona.rol == 'coordinacion_uno' || persona.rol == 'coordinacion_dos') {
                                          // Usuario no tiene permisos de administrador
                                          SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                          await prefs.setString('personId', persona.id);
                                          Navigator.pushNamed(
                                              context, '/Coordinationhomepage');
                                        }
                                        else if (persona.rol == 'Administrador de Area') {
                                          // Usuario no tiene permisos de administrador
                                          SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                          await prefs.setString('personId', persona.id);
                                          Navigator.pushNamed(
                                              context, '/admin_area_main');
                                        }
                                          else if (persona.rol == 'HardcodedAdmin') {
                                            // Usuario no tiene permisos de administrador
                                            SharedPreferences prefs =
                                            await SharedPreferences.getInstance();
                                            await prefs.setString('personId', persona.id);
                                            Navigator.pushNamed(
                                                context, '/register_postulation_hardcoded');
                                          }

                                         else {
                                          GlobalMethods.showToast(
                                              "Usuario no tiene permiso de acceso");
                                        }
                                      } else {
                                        // Error al iniciar sesión
                                        GlobalMethods.showToast(
                                            "Error al iniciar sesión");
                                      }
                                    } catch (e) {
                                      // Error al iniciar sesión
                                      GlobalMethods.showToast(
                                          "Error al iniciar sesión: $e");
                                    }
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.login_btn,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Divider(
                                  color: Color(0x00767676),
                                  height: 20,
                                  thickness: 2,
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'O continuar con',
                                  style: TextStyle(
                                    color: Color(0x00767676),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<PersonaModel?> _authenticate(String username, String password) async {
    try {
      var bytes = utf8.encode(password);
      var digest = sha256.convert(bytes);
      return await _usuarioDataSource.iniciarSesion(
          username, digest.toString());
    } catch (e) {
      print("Error al iniciar sesión: $e");
      return null;
    }
  }
}