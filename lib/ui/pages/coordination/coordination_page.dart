import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/Coordinacion_Reports_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/Coordinacion_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer_admin_area.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_text_field.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer_coord.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer_psico.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';

class CoordinacionPage extends StatefulWidget {
  const CoordinacionPage({super.key});

  @override
  State<CoordinacionPage> createState() => _CoordinacionPageState();
}

class _CoordinacionPageState extends State<CoordinacionPage> {
  CordinacionRemoteDatasourceImpl CoordinacionRemoteDatasourceImpl =
      CordinacionRemoteDatasourceImpl();
  List<CoordinacionModel> Coordinacions = [], filterList = [];
  final PersonaDataSourceImpl personaDataSource = PersonaDataSourceImpl();
  PersonaModel? usuario;
  bool isLoading = false;
  bool isSelected = true;
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
        status = 'pendiente';

        if (userRol != 'Administrador de Area') {
          CoordinacionRemoteDatasourceImpl.getReportCord().then((value) {
            setState(() {
              isLoading = true;
              Coordinacions = value;
              // Filtrar los reportes según el nivel del usuario
              filterList = FilterReportsList(
                  status, level, grade, searchController.text.trim(), userRol);
              isLoading = false;
            });
          });
        } else {
          CoordinacionRemoteDatasourceImpl.getCoordStatus().then((value) {
            setState(() {
              isLoading = true;
              Coordinacions = value;
              // Filtrar los reportes según el nivel del usuario
              filterList = FilterReportsList(
                  status, level, grade, searchController.text.trim(), userRol);
              isLoading = false;
            });
          });
        }
      });
    });
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

  List<CoordinacionModel> FilterReportsList(
    String status,
    String? level,
    String? grade,
    String? searchValue,
    String userRol,
  ) {
    return Coordinacions.where((Coordinacion) {
      bool matchesLevel = level == null ||
          level.isEmpty ||
          Coordinacion.level == level ||
          level == 'Cualquiera';
      bool matchesGrade = grade == null ||
          grade.isEmpty ||
          Coordinacion.course == grade ||
          grade == 'Cualquiera';
      bool matchesStudent = searchValue == null ||
          searchValue.isEmpty ||
          Coordinacion.studentFullName
              .toUpperCase()
              .contains(searchValue.toUpperCase());

      bool matchesUserRole = true;
      if (userRol == 'coordinacion_uno') {
        matchesUserRole = Coordinacion.level != 'Secundaria';
      } else if (userRol == 'coordinacion_dos') {
        matchesUserRole = Coordinacion.level == 'Secundaria';
      }

      bool matchesStatus = Coordinacion.estadoConfirmado == status;
      return matchesLevel &&
          matchesGrade &&
          matchesStudent &&
          matchesUserRole &&
          matchesStatus;
    }).toList();
  }

  Future<void> getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    personaId = prefs.getString('personId')!;
    usuario = await personaDataSource.getPersonFromId(personaId);
    userRol = usuario?.rol ?? '';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Administración de Informes - Coordinacion',
          style: GoogleFonts.barlow(
            textStyle: const TextStyle(
              color: Color(0xFF3D5269),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        toolbarHeight: 75,
        elevation: 0,
        leading: Center(
          child: Builder(
            builder: (context) => IconButton(
              iconSize: 50,
              icon: const Image(
                image: AssetImage('assets/ui/barra-de-menus.png'),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ),
        actions: [
          IconButton(
            iconSize: 50,
            icon: Image.asset(
              'assets/ui/home.png',
              width: 50,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/notice_main');
            },
          ),
        ],
      ),
      //Manejo de menus segun roles

      drawer: userRol == 'coordinacion_uno' || userRol == 'coordinacion_dos'
          ? CustomDrawerCoord()
          : userRol == 'Administrador de Area'
              ? CustomDrawerAdminArea()
              : CustomDrawerPsico(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (userRol != 'Administrador de Area')
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    iconSize: 50,
                                    icon: Image.asset(
                                      'assets/ui/reserva.png',
                                      width: 50,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/Coordination_Register');
                                    },
                                  ),
                                  const Text(
                                    'Registrar Informe',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            const SizedBox(width: 20),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Informes',
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
                                      filterList = FilterReportsList(
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
                                  value: levelList.contains(level)
                                      ? level
                                      : levelList.first,
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
                                        tempGradeList = [
                                          'Cualquiera',
                                          '1ra sección',
                                          '2da sección'
                                        ];
                                      } else if (level == 'Primaria' ||
                                          level == 'Secundaria') {
                                        tempGradeList = [
                                          'Cualquiera',
                                          '1er',
                                          '2do',
                                          '3er',
                                          '4to',
                                          '5to',
                                          '6to'
                                        ];
                                      } else {
                                        tempGradeList = ['Cualquiera'];
                                      }
                                      gradeList = tempGradeList;
                                      if (grade != 'Cualquiera' &&
                                          !gradeList.contains(grade)) {
                                        grade = 'Cualquiera';
                                      }
                                      // Filtrar los reportes según el nivel y grado seleccionados
                                      filterList = FilterReportsList(
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
                                  value: gradeList.contains(grade)
                                      ? grade
                                      : gradeList.first,
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
                                      filterList = FilterReportsList(
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
                        const SizedBox(
                          height: 10,
                        ),
                        //confirmado y pendiente
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: isSelected
                                    ? MaterialStateProperty.all(
                                        const Color(0xFF044086))
                                    : MaterialStateProperty.all(Colors.grey),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                if (!isSelected) {
                                  isSelected = !isSelected;
                                  status = 'pendiente';
                                  setState(() {});
                                  filterList = FilterReportsList(
                                    status,
                                    level,
                                    grade,
                                    searchController.text.trim(),
                                    userRol,
                                  );
                                }
                                setState(() {});
                              },
                              child: const Text('Pendientes',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: !isSelected
                                    ? MaterialStateProperty.all(
                                        const Color(0xFF044086))
                                    : MaterialStateProperty.all(Colors.grey),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                if (isSelected) {
                                  isSelected = !isSelected;
                                  status = 'Confirmado';
                                  setState(() {});
                                  filterList = FilterReportsList(
                                    status,
                                    level,
                                    grade,
                                    searchController.text.trim(),
                                    userRol,
                                  );
                                }
                                setState(() {});
                              },
                              child: const Text('Confirmadas',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),

                        //listado
                        Expanded(
                          child: Container(
                            width: constraints.maxWidth *
                                0.9, // Aumenta el ancho del contenedor
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth:
                                  800.0, // Aumenta el tamaño mínimo de la tabla
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: filterList.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No hay informes Coordinacion',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Color(0xFF044086),
                                            fontSize: 18),
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columnSpacing:
                                            40, // Ajusta el espaciado entre columnas
                                        columns: const [
                                          DataColumn(
                                            label: Text('Postulante',
                                                style: TextStyle(
                                                    color: Color(0xFF044086),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          DataColumn(
                                            label: Text('Nivel',
                                                style: TextStyle(
                                                    color: Color(0xFF044086),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          DataColumn(
                                            label: Text('Grado',
                                                style: TextStyle(
                                                    color: Color(0xFF044086),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          DataColumn(
                                            label: Text('Fecha de Coordinación',
                                                style: TextStyle(
                                                    color: Color(0xFF044086),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          DataColumn(
                                            label: Text('Estado del reporte',
                                                style: TextStyle(
                                                    color: Color(0xFF044086),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          DataColumn(
                                            label: Text('Estado',
                                                style: TextStyle(
                                                    color: Color(0xFF044086),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          DataColumn(label: Text('')),
                                        ],
                                        rows: filterList.map((Coordinacion) {
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(
                                                  '${Coordinacion.studentFullName}')),
                                              DataCell(
                                                  Text(Coordinacion.level)),
                                              DataCell(
                                                  Text(Coordinacion.course)),
                                              DataCell(Text(DateFormat(
                                                      'dd/MM/yyyy')
                                                  .format(Coordinacion
                                                      .interview_date_cord))),
                                              DataCell(Text(
                                                  Coordinacion.estadoRevisado)),
                                              DataCell(
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                                  color: Coordinacion
                                                              .estadoConfirmado ==
                                                          'Confirmado'
                                                      ? Colors.green
                                                      : Colors.yellow,
                                                  child: Text(
                                                    Coordinacion
                                                            .estadoConfirmado[0]
                                                            .toUpperCase() +
                                                        Coordinacion
                                                            .estadoConfirmado
                                                            .substring(
                                                                1), // Convierte la primera letra a mayúscula
                                                    style: TextStyle(
                                                      color: Colors
                                                          .white, // Texto blanco tanto para "Confirmado" como "Pendiente"
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    final recargar =
                                                        await Navigator.of(
                                                                context)
                                                            .pushNamed(
                                                      '/report_coordinacion_details',
                                                      arguments: {
                                                        'id': Coordinacion.id
                                                      },
                                                    );
                                                    if (recargar != null) {
                                                      setState(() {
                                                        isLoading = true;
                                                      });
                                                      CoordinacionRemoteDatasourceImpl
                                                              .getReportCord()
                                                          .then((value) => {
                                                                Coordinacions =
                                                                    value,
                                                                level = '',
                                                                grade = '',
                                                                searchController
                                                                    .text = '',
                                                                filterList = FilterReportsList(
                                                                    status,
                                                                    level,
                                                                    grade,
                                                                    searchController
                                                                        .text
                                                                        .trim(),
                                                                    userRol),
                                                                if (mounted)
                                                                  {
                                                                    setState(
                                                                        () {
                                                                      isLoading =
                                                                          false;
                                                                    })
                                                                  }
                                                              });
                                                    }
                                                  },
                                                  style: ButtonStyle(
                                                    padding: MaterialStateProperty
                                                        .all<EdgeInsets>(
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        10)),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.blue),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white),
                                                  ),
                                                  child: const Text('Ver',
                                                      style: TextStyle(
                                                          fontSize: 16)),
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
