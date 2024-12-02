import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/postulation_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/postulation_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer_psico.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/model/person_model.dart';
import '../../../data/remote/user_remote_datasource.dart';

/*
    Pagina de inicio para el rol de psicologia para que vea las postulaciones. Es igual a la que ya se creó previamente, se hizo esta copia para posibles modificaciones
    y no alterar la principal
*/

class PsychologistHomePage extends StatefulWidget {
  const PsychologistHomePage({super.key});

  @override
  State<PsychologistHomePage> createState() => _PsychologistHomePage();
}

class _PsychologistHomePage extends State<PsychologistHomePage> {
  PostulationRemoteDatasourceImpl postulationRemoteDatasourceImpl =
  PostulationRemoteDatasourceImpl();
  List<PostulationModel> postulations = [], filterList = [];
  final PersonaDataSourceImpl personaDataSource = PersonaDataSourceImpl();
  PersonaModel? usuario;
  bool isLoading = true;
  //bool isSelected = true;
  bool isPendienteSelected = true;
  bool isConfirmadaSelected = false;
  bool isAprobadaSelected = false;

  TextEditingController searchController = TextEditingController();
  String level = '', grade = '', status = '', userRol = '', personaId = '';
  List<String> gradeList = ['Cualquiera'];
  List<String> levelList = ['Cualquiera'];

  @override
  void initState() {
    super.initState();
    getId().then((_) {
      // Configurar levelList basado en el rol del usuario
      _configureListsAndDefaultValues();
      setState(() {

        status = 'Pendiente';
        postulationRemoteDatasourceImpl.getPostulations().then((value) => {
          isLoading = true,
          postulations = value,
          filterList = FilterPostulationsList(
              status, level, grade, searchController.text.trim(),userRol),
          if (mounted)
            {
              setState(() {
                isLoading = false;
              })
            }
        });
        //super.initState();
      });
    });
  }
  void _configureListsAndDefaultValues() {
    if (userRol == 'psicologia_uno' || userRol == 'coordinacion_uno') {
      levelList = ['Cualquiera', 'Inicial', 'Primaria'];
      level = 'Cualquiera';
    } else if (userRol == 'psicologia_dos' || userRol == 'coordinacion_dos') {
      levelList = ['Cualquiera', 'Secundaria'];
      level = 'Secundaria';
    }
  }

  Future<void> getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    personaId = prefs.getString('personId')!;
    usuario = await personaDataSource.getPersonFromId(personaId);
    userRol = usuario?.rol ?? '';
    print("tu"+ userRol);
  }
  @override
  void dispose() {
    super.dispose();
  }

  InputDecoration customDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: label,
      counter: const SizedBox.shrink(),
      labelStyle: const TextStyle(color: Color(0xFF044086)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF044086)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.transparent,
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  List<PostulationModel> FilterPostulationsList(
      String status,
      String? level,
      String? grade,
      String? searchValue,
      String?  userRol,
      ) {
    return postulations.where((postulation) {
      bool matchesStatus = postulation.status == status;

      bool matchesEstadoGeneral = true;
      if (status == 'Pendiente' || status == 'Confirmado') {
        matchesEstadoGeneral = postulation.estadoGeneral == 'Psico';
      }
      bool matchesLevel =
          level == null || level.isEmpty || postulation.level == level|| level == 'Cualquiera';
      bool matchesGrade =
          grade == null || grade.isEmpty || postulation.grade == grade|| grade == 'Cualquiera';
      bool matchesStudent = true;

      if (searchValue != null && searchValue.isNotEmpty) {
        matchesStudent =
            ("${postulation.student_name} ${postulation.student_lastname}")
                .toUpperCase()
                .contains(searchValue.toUpperCase()) ||
                postulation.student_ci
                    .toUpperCase()
                    .contains(searchValue.toUpperCase());
      }
      bool matchesUserRole = true;
      if (userRol == 'psicologia_uno') {
        matchesUserRole = postulation.level != 'Secundaria';
      } else if (userRol == 'psicologia_dos') {
        matchesUserRole = postulation.level == 'Secundaria';
      }
      return matchesStatus && matchesLevel && matchesGrade && matchesStudent &&matchesUserRole&&matchesEstadoGeneral ;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Administración  de Psicologia ',
            style: GoogleFonts.barlow(
                textStyle: const TextStyle(
                    color: Color(0xFF3D5269),
                    fontSize: 24,
                    fontWeight: FontWeight.bold))),
        backgroundColor: Colors.white,
        toolbarHeight: 75,
        elevation: 0,
        leading: Center(
          child: Builder(
            builder: (context) => IconButton(
              iconSize: 50,
              icon: const Image(
                  image: AssetImage('assets/ui/barra-de-menus.png')),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ),
        /*actions: [
          IconButton(
              iconSize: 2,
              icon: Image.asset(
                'assets/ui/home.png',
                width: 50,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/notice_main');
              })
        ],*/
      ),
      drawer: CustomDrawerPsico(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth * 0.6,
              constraints: const BoxConstraints(
                minWidth: 700.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE3E9F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              iconSize: 2,
                              icon: Image.asset(
                                'assets/ui/reserva.png',
                                width: 50,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/register_postulation_psyco');
                              }),
                          const Text('Registrar postulación',
                              style: TextStyle(fontSize: 16))

                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              iconSize: 2,
                              icon: Image.asset(
                                'assets/ui/calendar.png',
                                width: 50,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/interview_schedule');
                              }),
                          const Text('Cronograma de entrevistas',
                              style: TextStyle(fontSize: 16)),
                        ],
                      )


                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Psicologia',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF044086),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: CustomTextField(
                            label: 'Buscar',
                            controller: searchController,
                            type: TextInputType.name,
                            onChanged: (value) {
                              setState(() {
                                filterList = FilterPostulationsList(
                                  status,
                                  level,
                                  grade,
                                  searchController.text.trim(),
                                  userRol,
                                );
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        // DropdownButtonFormField para el nivel
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: customDecoration('Nivel'),
                            value: levelList.contains(level) ? level : levelList.first,
                            isDense: true,
                            items: levelList.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                level = value ?? '';
                                List<String> tempGradeList = [];
                                if (level == 'Inicial') {
                                  tempGradeList = ['Cualquiera', '1ra sección', '2da sección'];
                                } else if (level == 'Primaria' || level == 'Secundaria') {
                                  tempGradeList = ['Cualquiera', '1er', '2do', '3er', '4to', '5to', '6to'];
                                } else {
                                  tempGradeList = ['Cualquiera'];
                                }
                                gradeList = tempGradeList;
                                if (grade != 'Cualquiera' && !gradeList.contains(grade)) {
                                  grade = 'Cualquiera';
                                }
                                // Filtrar los reportes según el nivel y grado seleccionados
                                filterList = FilterPostulationsList(
                                  status,
                                  level,
                                  grade,
                                  searchController.text.trim(),
                                  userRol,
                                );
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: gradeList.contains(grade) ? grade : gradeList.first,
                            isDense: true,
                            decoration: customDecoration('Curso'),
                            items: gradeList.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                grade = value ?? '';
                                // Filtrar los reportes según el nivel y grado seleccionados
                                filterList = FilterPostulationsList(
                                  status,
                                  level,
                                  grade,
                                  searchController.text.trim(),
                                  userRol,
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: isPendienteSelected
                              ? MaterialStateProperty.all(Colors.grey)
                              : MaterialStateProperty.all(const Color(0xFF044086)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (!isPendienteSelected) {
                            setState(() {
                              isPendienteSelected = true;
                              isConfirmadaSelected = false;
                              isAprobadaSelected = false;
                              status = 'Pendiente';
                              filterList = FilterPostulationsList(
                                  status,
                                  level,
                                  grade,
                                  searchController.text.trim(),
                                  userRol);
                            });
                          }
                        },
                        child: const Text('Pendientes', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: isConfirmadaSelected
                              ? MaterialStateProperty.all(Colors.grey)
                              : MaterialStateProperty.all(const Color(0xFF044086)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (!isConfirmadaSelected) {
                            setState(() {
                              isPendienteSelected = false;
                              isConfirmadaSelected = true;
                              isAprobadaSelected = false;
                              status = 'Confirmado';
                              filterList = FilterPostulationsList(
                                  status,
                                  level,
                                  grade,
                                  searchController.text.trim(),
                                  userRol);
                            });
                          }
                        },
                        child: const Text('Confirmadas', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: isAprobadaSelected
                              ? MaterialStateProperty.all(Colors.grey)
                              : MaterialStateProperty.all(const Color(0xFF044086)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (!isAprobadaSelected) {
                            setState(() {
                              isPendienteSelected = false;
                              isConfirmadaSelected = false;
                              isAprobadaSelected = true;
                              status = 'Aprobado';
                              filterList = FilterPostulationsList(
                                  status,
                                  level,
                                  grade,
                                  searchController.text.trim(),
                                  userRol);
                            });
                          }
                        },
                        child: const Text('Aprobadas', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Container(
                      width: constraints.maxWidth *
                          0.55, // Ajusta según el diseño que necesitas
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 600.0,
                      ),
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: filterList.isEmpty
                              ? const Center(
                            child: Text(
                              'No hay postulaciones',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF044086),
                                  fontSize: 18),
                            ),
                          )
                              : Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing:
                                38, // Ajusta este valor según el diseño que necesites
                                columns: const [
                                  DataColumn(
                                      label: Text('Postulante',
                                          style: TextStyle(
                                              color:
                                              Color(0xFF044086),
                                              fontWeight: FontWeight
                                                  .bold))),
                                  DataColumn(
                                      label: Text('Nivel',
                                          style: TextStyle(
                                              color:
                                              Color(0xFF044086),
                                              fontWeight: FontWeight
                                                  .bold))),
                                  DataColumn(
                                      label: Text('Grado',
                                          style: TextStyle(
                                              color:
                                              Color(0xFF044086),
                                              fontWeight: FontWeight
                                                  .bold))),
                                  DataColumn(
                                      label: Text(
                                          'Fecha de entrevista',
                                          style: TextStyle(
                                              color:
                                              Color(0xFF044086),
                                              fontWeight: FontWeight
                                                  .bold))),
                                  DataColumn(
                                      label: Text('Estado',
                                          style: TextStyle(
                                              color:
                                              Color(0xFF044086),
                                              fontWeight: FontWeight
                                                  .bold))),
                                  DataColumn(label: Text('')),
                                ],
                                rows: filterList.map((postulation) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(
                                          '${postulation.student_name} ${postulation.student_lastname}')),
                                      DataCell(
                                          Text(postulation.level)),
                                      DataCell(
                                          Text(postulation.grade)),
                                      DataCell(Text(DateFormat(
                                          'dd/MM/yyyy')
                                          .format(postulation
                                          .interview_date))),
                                      DataCell(
                                        Container(
                                          padding:
                                          EdgeInsets.symmetric(
                                              vertical: 5,
                                              horizontal: 10),
                                          color: postulation.status == 'Confirmado'
                                              ? Colors.green
                                              : postulation.status == 'Aprobado'
                                              ? Colors.red // Rojo para "Aprobado"
                                              : Colors.yellow, //
                                          child: Text(
                                            postulation.status,
                                            style: TextStyle(
                                              color: Colors
                                                  .white, // Para "Confirmado"
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                            MaterialStateProperty
                                                .all<Color>(Colors
                                                .blue), // Color de fondo
                                            foregroundColor:
                                            MaterialStateProperty
                                                .all<Color>(Colors
                                                .white), // Color del texto
                                            padding: MaterialStateProperty.all<
                                                EdgeInsets>(
                                                EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical:
                                                    5)), // Espacio interno
                                          ),
                                          onPressed: () async {
                                            final recargar =
                                            await Navigator.of(
                                                context)
                                                .pushNamed(
                                              '/postulation_details_psychology',
                                              arguments: {
                                                'id': postulation.id
                                              },
                                            );
                                            if (recargar != null) {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              postulationRemoteDatasourceImpl
                                                  .getPostulations()
                                                  .then((value) {
                                                postulations =
                                                    value;
                                                level = '';
                                                grade = '';
                                                searchController
                                                    .text = '';
                                                filterList =
                                                    FilterPostulationsList(
                                                        status,
                                                        level,
                                                        grade,
                                                        searchController
                                                            .text
                                                            .trim(),userRol);
                                                if (mounted) {
                                                  setState(() {
                                                    isLoading =
                                                    false;
                                                  });
                                                }
                                              });
                                            }
                                          },
                                          child: Text('Ver',
                                              style: TextStyle(
                                                  fontSize: 14)),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
