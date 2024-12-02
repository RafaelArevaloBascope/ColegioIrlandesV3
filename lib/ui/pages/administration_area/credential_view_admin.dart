import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/infraestructure/global/global_methods.dart';
import 'package:pr_h23_irlandes_web/ui/pages/administration_area/credential_view_details_admin.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/app_bar_custom.dart';
import 'package:data_table_2/data_table_2.dart';

class CredentialHomePage extends StatefulWidget {
  const CredentialHomePage({super.key});

  @override
  State<CredentialHomePage> createState() => _CredentialHomePageState();
}

const List<String> list = <String>[
  'Padre',
  'Administrador',
  'Docente',
  "Estudiante"
];

class _CredentialHomePageState extends State<CredentialHomePage> {
  void onSearchTextChanged(String text) {
    setState(() {
      filteredData = text.isEmpty
          ? orderedData
          : orderedData
              .where((item) =>
                  item.name.toLowerCase().contains(text.toLowerCase()) ||
                  item.surname.toLowerCase().contains(text.toLowerCase()) ||
                  item.lastname.toLowerCase().contains(text.toLowerCase()))
              .toList();
    });
  }

  String dropdownValue = list.first;
  PersonaDataSourceImpl personDataSource = PersonaDataSourceImpl();
  bool isForeign = false;
  List<PersonaModel> orderedData = [];
  List<PersonaModel> filteredData = [];

  final controllerName = TextEditingController();
  final controllerFirstSurname = TextEditingController();
  final controllerSecondSurname = TextEditingController();
  final controllerCI = TextEditingController();
  final controllerCellphone = TextEditingController();
  final controllerPhone = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerRole = TextEditingController();
  final controllerDirection = TextEditingController();
  final controllerFather = TextEditingController();
  final controllerMother = TextEditingController();
  final controllerGrade = TextEditingController();
  final searchController = TextEditingController();

  bool validationCheck() {
    if (controllerName.text != "" &&
        controllerFirstSurname.text != "" &&
        controllerSecondSurname.text != "" &&
        controllerCI.text != "" &&
        controllerCellphone.text != "" &&
        controllerCellphone.text.length == 8 &&
        isValidEmail(controllerEmail.text) &&
        controllerDirection.text != "") {
      return true;
    } else {
      return false;
    }
  }

  bool isValidEmail(String value) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(value);
  }

  String checkNationality() {
    if (isForeign) {
      return "E-${controllerCI.text}";
    } else {
      return controllerCI.text;
    }
  }

  Future<void> refreshUsers() async {
    orderedData = await personDataSource.readPeople();
    orderedData = orderedData
      ..sort((item1, item2) =>
          item1.lastname.toLowerCase().compareTo(item2.lastname.toLowerCase()));
    filteredData = orderedData;
  }

  late final Future userFuture = refreshUsers();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 227, 233, 244),
        appBar: const AppBarCustom(title: ""),
        body: FutureBuilder(
            future: userFuture,
            builder: (context, snapshot) {
              if (filteredData.isEmpty && searchController.text.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return Column(children: [
                  SizedBox(
                      width: 350,
                      child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              labelText:
                                  "Ingrese un nombre o apellido para filtrar",
                              hintText:
                                  "Ingrese un nombre o apellido para filtrar"),
                          onChanged: (value) {
                            onSearchTextChanged(value);
                          })),
                  Expanded(
                      child: Row(children: [
                    Expanded(
                        flex: 3,
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: DataTable2(
                                columns: const [
                                  DataColumn2(
                                    label: Text("Nombre",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  DataColumn(
                                      label: Text('Apellido\nPaterno',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Apellido\nMaterno',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Celular',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      numeric: true),
                                  DataColumn(
                                      label: Text('Teléfono',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      numeric: true),
                                  DataColumn(
                                      label: Text('Correo',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Editar',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  /*DataColumn(
                                      label: Text('Eliminar',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)))*/
                                ],
                                rows:
                                    List.generate(filteredData.length, (index) {
                                  final item = filteredData[index];

                                  return DataRow(cells: [
                                    DataCell(Text(item.name)),
                                    DataCell(Text(item.lastname)),
                                    DataCell(Text(item.surname)),
                                    DataCell(Text(item.cellphone)),
                                    DataCell(Text(item.telephone)),
                                    DataCell(Text(item.mail)),
                                    DataCell(IconButton(
                                        icon: const Icon(Icons.edit_document),
                                        color: Colors.blue[900],
                                        onPressed: () {
                                          searchController.text = "";
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditCredentialPage(
                                                          personModel: item)));
                                        })),

                                   /* DataCell(IconButton(
                                        icon: const Icon(Icons.delete),
                                        color: Colors.blue[900],
                                        onPressed: () {
                                          searchController.text = "";
                                          personDataSource
                                              .deletePerson(item.id);
                                          GlobalMethods.showSuccessSnackBar(
                                              context,
                                              "Usuario eliminado con éxito");
                                          Navigator.pushNamed(
                                              context, '/admin_dashboard');
                                        }))*/
                                  ]);
                                }))))
                  ]))
                ]);
              }
            }));
  }
}
