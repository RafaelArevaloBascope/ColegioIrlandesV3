import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/model/postulation_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/postulation_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer_psico.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_text_field.dart';

/*
    Pagina de inicio para el rol de coordinacion para que vea las postulaciones.
*/

class Coordinationhomepage extends StatefulWidget {
  const Coordinationhomepage({super.key});

  @override
  State<Coordinationhomepage> createState() => _Coordinationhomepage();
}

class _Coordinationhomepage extends State<Coordinationhomepage> {
  PostulationRemoteDatasourceImpl postulationRemoteDatasourceImpl =
  PostulationRemoteDatasourceImpl();
  List<PostulationModel> postulations = [], filterList = [];
  bool isLoading = true;
  bool isSelected = true;
  TextEditingController searchController = TextEditingController();
  String level = '', grade = '', status = '';
  List<String> gradeList = ['Cualquiera'];

  bool isPendingSelected = false;
  bool isConfirmedSelected = false;
  bool isApprovedSelected = false;
  PersonaModel? usuario;
  String userRol = '', personaId = '';
  List<String> levelList = ['Cualquiera'];

  @override
  void initState() {
    status = 'Pendiente';

    postulationRemoteDatasourceImpl.getPostulations().then((value) => {
      isLoading = true,
      postulations = value,
      filterList = FilterPostulationsList(
          status, level, grade, searchController.text.trim()),
      if (mounted)
        {
          setState(() {
            isLoading = false;
          })
        }
    });
    super.initState();
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

  void _configureListsAndDefaultValues() {
    if (userRol == 'coordinacion_uno') {
      levelList = ['Cualquiera', 'Inicial', 'Primaria'];
      level = 'Inicial';
    } else if (userRol == 'coordinacion_dos') {
      levelList = ['Cualquiera', 'Secundaria'];
      level = 'Secundaria';
    }
  }

  List<PostulationModel> FilterPostulationsList(
      String status,
      String? level,
      String? grade,
      String? searchValue,
      ) {
    return postulations.where((postulation) {
      bool matchesStatus = false;

      // Condición para mostrar "Pendiente"
      if (status == 'Pendiente') {
        matchesStatus = postulation.vistoBuenoCoordinacion == 'Pendiente' &&
            postulation.estadoGeneral == 'Coordinacion';
      }
      // Condición para mostrar "Confirmado"
      if (status == 'Confirmado') {
        matchesStatus = postulation.estadoGeneral == 'Coordinacion' &&
            postulation.vistoBuenoCoordinacion == 'Confirmado';
      }
      // Condición para mostrar "Aprobado"
      if (status == 'Aprobado') {

        matchesStatus = postulation.estadoGeneral == 'admin' &&
            postulation.vistoBuenoCoordinacion == 'Confirmado';
      }



      // Si no es Pendiente, Aprobado ni Confirmado, se considera el estado por defecto
      if (status != 'Pendiente' && status != 'Aprobado' && status != 'Confirmado') {
        matchesStatus = postulation.status == status;
      }

      bool matchesLevel =
          level == null || level.isEmpty || postulation.level == level;
      bool matchesGrade =
          grade == null || grade.isEmpty || postulation.grade == grade;
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

      return matchesStatus && matchesLevel && matchesGrade && matchesStudent;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Administración de postulaciones-Coordinacion',
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
        /*
        actions: [
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

                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Postulaciones',
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
                            flex:
                            2, // Ajusta el flex para controlar el ancho
                            child: CustomTextField(
                              label: 'Buscar',
                              controller: searchController,
                              type: TextInputType.name,
                              onChanged: (value) => {
                                filterList = FilterPostulationsList(
                                    status,
                                    level,
                                    grade,
                                    searchController.text.trim()),
                                setState(() {})
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: customDecoration('Nivel'),
                              value: 'Cualquiera',
                              isDense: true,
                              items: [
                                'Cualquiera',
                                'Inicial',
                                'Primaria',
                                'Secundaria'
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                grade = '';
                                switch (value) {
                                  case 'Cualquiera':
                                    gradeList = ['Cualquiera'];
                                    level = '';
                                    break;
                                  case 'Inicial':
                                    gradeList = [ 'Cualquiera', '1ra sección','2da sección'];
                                    level = value!;
                                    break;
                                  default:
                                    gradeList = ['Cualquiera', '1er','2do','3er','4to','5to', '6to'];
                                    level = value!;
                                }
                                setState(() {});
                                filterList = FilterPostulationsList(
                                    status,
                                    level,
                                    grade,
                                    searchController.text.trim());
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: grade == '' ? 'Cualquiera': grade,
                              isDense: true,
                              decoration: customDecoration('Curso'),
                              items: gradeList.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value! == 'Cualquiera') {
                                  grade = '';
                                } else {
                                  grade = value;
                                }
                                setState(() {});
                                filterList = FilterPostulationsList(
                                    status,
                                    level,
                                    grade,
                                    searchController.text.trim());
                              },
                            ),
                          ),
                        ],
                      )
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            status == 'Pendiente' ? const Color(0xFF044086) : Colors.grey,
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (status != 'Pendiente') {
                            status = 'Pendiente';
                            filterList = FilterPostulationsList(
                              status,
                              level,
                              grade,
                              searchController.text.trim(),
                            );
                            setState(() {});
                          }
                        },
                        child: const Text(
                          'Pendientes',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            status == 'Confirmado' ? const Color(0xFF044086) : Colors.grey,
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (status != 'Confirmado') {
                            status = 'Confirmado';
                            filterList = FilterPostulationsList(
                              status,
                              level,
                              grade,
                              searchController.text.trim(),
                            );
                            setState(() {});
                          }
                        },
                        child: const Text(
                          'Confirmadas',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            status == 'Aprobado' ? const Color(0xFF044086) : Colors.grey,
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (status != 'Aprobado') {
                            status = 'Aprobado';
                            filterList = FilterPostulationsList(
                              status,
                              level,
                              grade,
                              searchController.text.trim(),
                            );
                            setState(() {});
                          }
                        },
                        child: const Text(
                          'Aprobados',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                Expanded(
  child: Container(
    width: constraints.maxWidth * 0.5,
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
                  fontSize: 18,
                ),
              ),
            )
          : Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Postulante',
                        style: TextStyle(
                          color: Color(0xFF044086),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Nivel',
                        style: TextStyle(
                          color: Color(0xFF044086),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Grado',
                        style: TextStyle(
                          color: Color(0xFF044086),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Fecha de entrevista',
                        style: TextStyle(
                          color: Color(0xFF044086),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Estado',
                        style: TextStyle(
                          color: Color(0xFF044086),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(label: Text('')),
                  ],
                  rows: filterList.map((postulation) {
                    return DataRow(
                      cells: [
                        DataCell(Text(
                            '${postulation.student_name} ${postulation.student_lastname}')),
                        DataCell(Text(postulation.level)),
                        DataCell(Text(postulation.grade)),
                        DataCell(Text(
                          DateFormat('dd/MM/yyyy')
                              .format(postulation.interview_date),
                        )),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            color: postulation.estadoGeneral == 'admin'
                                ? Colors.red
                                : postulation.vistoBuenoCoordinacion ==
                                        'Confirmado'
                                    ? Colors.green
                                    : postulation.vistoBuenoCoordinacion ==
                                            'Pendiente'
                                        ? Colors.yellow
                                        : Colors.yellow,
                            child: Text(
                              postulation.vistoBuenoCoordinacion,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                                Wrap(
                                  direction: Axis.vertical,
                                  spacing: 1,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        final recargar = await Navigator.of(context).pushNamed(
                                          '/postulation_details_Coordination',
                                          arguments: {'id': postulation.id},
                                        );
                                        if (recargar != null) {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          postulationRemoteDatasourceImpl.getPostulations().then((value) {
                                            postulations = value;
                                            level = '';
                                            grade = '';
                                            searchController.text = '';
                                            filterList = FilterPostulationsList(
                                                status, level, grade, searchController.text.trim());
                                            if (mounted) {
                                              setState(() {
                                                isLoading = false;
                                              });
                                            }
                                          });
                                        }
                                      },
                                      child: const Text('Ver'),
                                    ),
                                    if (postulation.vistoBuenoCoordinacion == 'Confirmado' &&
                                        postulation.estadoGeneral == 'Coordinacion')
                                      ElevatedButton(
                                        onPressed: () async {
                                          // Mostrar el modal de confirmación
                                          final bool? confirm = await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Confirmar cancelación'),
                                                content: const Text(
                                                    '¿Estás seguro de que deseas cancelar esta postulación? Esta acción no se puede deshacer.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop(false); // Cancelar
                                                    },
                                                    child: const Text('No'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop(true); // Confirmar
                                                    },
                                                    child: const Text('Sí'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          // Si el usuario confirma, ejecutar la acción
                                          if (confirm == true) {
                                            await actualizarCampos(postulation.id!);
                                            await Navigator.of(context).pushNamed(
                                              '/Coordinationhomepage',
                                              arguments: {
                                                'id': postulation.id,
                                              },
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text('Cancelar'),
                                      ),
                                  ],
                                ),
                              ),

                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    ),
  ),
),
const SizedBox(height: 4),

                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> actualizarCampos(String postulationID) async {
    // Crear el mapa con los campos a actualizar
    Map<String, dynamic> camposAActualizar = {
      'vistoBuenoCoordinacion': 'Pendiente',
    };

    try {
      // Llamar al método updatePostulation para actualizar los campos
      await postulationRemoteDatasourceImpl.updatePostulation(postulationID, camposAActualizar);
      print('Campos de la postulación actualizados correctamente.');
      // Aquí podrías mostrar un mensaje en la interfaz si es necesario
    } catch (e) {
      print('Error al actualizar la postulación: $e');
    }
  }

}
