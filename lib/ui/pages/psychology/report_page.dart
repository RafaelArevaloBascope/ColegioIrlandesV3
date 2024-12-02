import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/report_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/reports_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer_admin_area.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer_psico.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer_coord.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_text_field.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
    Pagina donde se listan los reportes psicologicos, de manera similar a las postulaciones.
    Falta un boton para editar y otro para el pdf.
    Tambien añadir boton de cambiar estado del reporte (si sigue en psicologia o ya pasa a siguiente fase)
*/


class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPage();
}

class _ReportPage extends State<ReportPage> {
  ReportRemoteDatasourceImpl reportRemoteDatasourceImpl =
      ReportRemoteDatasourceImpl();
  List<ReportModel> reports = [], filterList = [];
  final PersonaDataSourceImpl personaDataSource = PersonaDataSourceImpl();
  PersonaModel? usuario;
  bool isLoading = true;
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
      status = 'Pendiente';


      // reportRemoteDatasourceImpl.getReport().then((value) {
      //   setState(() {
      //     isLoading = true;
      //     reports = value;
      //     // Filtrar los reportes según el nivel del usuario
      //     filterList = FilterReportsList(status, level, grade, searchController.text.trim(), userRol);
      //     isLoading = false;
      //   });
      // });

     //cambio
      if (userRol != 'Administrador de Area') {
        reportRemoteDatasourceImpl.getReport().then((value) {
          setState(() {
            isLoading = true;
            reports = value;
            // Filtrar los reportes según el nivel del usuario
            filterList = FilterReportsList(status, level, grade, searchController.text.trim(), userRol);
            isLoading = false;
          });
        });
      } else {
        reportRemoteDatasourceImpl.getPsicoStatus().then((value) {
          setState(() {
            isLoading = true;
            reports = value;
            // Filtrar los reportes según el nivel del usuario
            filterList = FilterReportsList(status, level, grade, searchController.text.trim(), userRol);
            isLoading = false;
          });
        });
      }

    });
  });
}
void _configureListsAndDefaultValues() {
  if (userRol == 'psicologia_uno' || userRol == 'coordinacion_uno') {
    levelList = ['Cualquiera', 'Inicial', 'Primaria'];
    level = 'Inicial';
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
  List<ReportModel> FilterReportsList(
  String status,
  String? level,
  String? grade,
  String? searchValue,
  String userRol,
) {
  return reports.where((report) {
    bool matchesLevel = level == null || level.isEmpty || report.level == level || level == 'Cualquiera';
    bool matchesGrade = grade == null || grade.isEmpty || report.grade == grade || grade == 'Cualquiera';
    bool matchesStudent = searchValue == null || searchValue.isEmpty || report.fullname.toUpperCase().contains(searchValue.toUpperCase());

    bool matchesUserRole = true;
    if (userRol == 'psicologia_uno' || userRol == 'coordinacion_uno') {
      matchesUserRole = report.level != 'Secundaria';
    } else if (userRol == 'psicologia_dos' || userRol == 'coordinacion_dos') {
      matchesUserRole = report.level == 'Secundaria';
    }

    return matchesLevel && matchesGrade && matchesStudent && matchesUserRole;
  }).toList();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Administración de Informes - Psicología',
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
        ],
      ),
      drawer: userRol == 'psicologia_uno' || userRol == 'psicologia_dos' ? CustomDrawerPsico() : userRol == 'Administrador de Area'
          ? CustomDrawerAdminArea()
          : CustomDrawerCoord(),
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
                            if(userRol!='Administrador de Area')
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
                                          context, '/register_report');
                                    }),
                                const Text('Registrar Informe',
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
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
                                      'No hay informes',
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
                                      columns: const [
                                        DataColumn(
                                            label: Text('Postulante',
                                                style: TextStyle(
                                                    color: Color(0xFF044086),
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text('Nivel',
                                                style: TextStyle(
                                                    color: Color(0xFF044086),
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text('Grado',
                                                style: TextStyle(
                                                    color: Color(0xFF044086),
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text('Fecha de entrevista',
                                                style: TextStyle(
                                                    color: Color(0xFF044086),
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text('Estado del reporte',
                                                style: TextStyle(
                                                    color: Color(0xFF044086),
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(label: Text('')),
                                      ],
                                      rows: filterList.map((report) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(
                                                '${report.fullname}')),
                                            DataCell(Text(report.level)),
                                            DataCell(Text(report.grade)),
                                            DataCell(Text(
                                                DateFormat('dd/MM/yyyy')
                                                    .format(report
                                                        .interview_date))),
                                            DataCell(Text(report.status_report)),
                                            DataCell(
                                              ElevatedButton(
                                                onPressed: () async {
                                                  final recargar =
                                                      await Navigator.of(
                                                              context)
                                                          .pushNamed(
                                                              '/report_details',
                                                              arguments: {
                                                        'id': report.id
                                                      });
                                                  if (recargar != null) {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    reportRemoteDatasourceImpl
                                                        .getReport()
                                                        .then((value) => {
                                                              reports =
                                                                  value,
                                                              level = '',
                                                              grade = '',
                                                              searchController
                                                                  .text = '',
                                                              filterList = FilterReportsList(
                                                                  status,
                                                                  level,
                                                                  grade,
                                                                  searchController.text.trim(),userRol),
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
                                                child: const Text('Ver'),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                )                                  
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
