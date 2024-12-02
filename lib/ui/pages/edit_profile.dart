import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/infraestructure/global/global_methods.dart';
import 'package:pr_h23_irlandes_web/ui/pages/admin/edit_user.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/app_bar_custom.dart';
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key, required this.currentUser});
  final PersonaModel currentUser;

  @override
  Widget build(BuildContext context) {
    final controllerPhone = TextEditingController();
    final controllerCellphone = TextEditingController();
    final controllerName = TextEditingController();
    final controllerEmail = TextEditingController();

    controllerPhone.text = currentUser.telephone;
    controllerCellphone.text = currentUser.cellphone;
    controllerName.text ="${currentUser.name} ${currentUser.surname} ${currentUser.lastname}";
    controllerEmail.text=currentUser.mail;

    return Scaffold(
      backgroundColor:const Color(0xFFE3E9F4),
      appBar: const AppBarCustom(
        title: ""
      ),
      body: Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50)
            ),
            child: GestureDetector(
              onTap: (){
                Navigator.pushNamed(context, '/edit_profile_picture');
              },
              child: const CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage("ui/default_user.png"),
              )
            )
          ),
          const SizedBox(height: 20),
          Text(
            controllerName.text,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          Center(
            child: Card(
              child: SizedBox(
                width: 400,
                height: 250,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                    child: Column(
                    children: [
                      Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Teléfono:", style: TextStyle(fontSize: 15, color: Colors.blue[900])),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 250,
                          height: 50,
                          child: TextField(
                            maxLength: 7,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(
                                  "[0-9]",
                                ),
                              ),
                            ],
                            controller: controllerPhone,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            )
                          )
                        )
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Celular:", style: TextStyle(fontSize: 15, color: Colors.blue[900])),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 250,
                          height: 50,
                          child: TextField(
                            maxLength: 8,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(
                                  "[0-9]",
                                ),
                              ),
                            ],
                            controller: controllerCellphone,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            )
                          )
                        )
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Correo:", style: TextStyle(fontSize: 15, color: Colors.blue[900])),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 250,
                          height: 30,
                          child: TextField(
                            controller: controllerEmail,
                            readOnly: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            )
                          )
                        )
                      ]
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.greenAccent,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0)),
                        minimumSize: const Size(200, 40)
                      ),
                      onPressed: () {
                        final person = PersonaModel(
                          username: currentUser.username, 
                          password: currentUser.password, 
                          rol: currentUser.rol, 
                          cellphone: controllerCellphone.text, 
                          ci: currentUser.ci,
                          direction: currentUser.direction, 
                          id: currentUser.id,
                          token: currentUser.token, 
                          fatherId: currentUser.fatherId, 
                          motherId: currentUser.motherId, 
                          lastname: currentUser.lastname, 
                          grade: currentUser.grade, 
                          mail: controllerEmail.text, 
                          name: currentUser.name, 
                          resgisterdate: currentUser.resgisterdate, 
                          status: currentUser.status, 
                          surname: currentUser.surname, 
                          telephone: controllerPhone.text,
                          latitude: -17.3935,
                          longitude: -66.1570,
                          motherReference: "",
                          fatherReference: "",
                          updatedate: DateTime.now());
                        personDataSource.updatePerson(currentUser.id, person);
                        GlobalMethods.showSuccessSnackBar(context, "Datos actualizados con éxito");
                        Navigator.pushNamed(context, "/user_profile");
                      },
                      child: const Text("Guardar"),
                    )]
                  )
                )
              )
            )
          ),
          const SizedBox(height: 50),
        ]
      )
    ));
  }
}