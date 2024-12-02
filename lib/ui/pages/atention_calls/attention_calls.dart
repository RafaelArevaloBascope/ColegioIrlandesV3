import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pr_h23_irlandes_web/data/model/calls_model.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/calls_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttentionCallsPage extends StatefulWidget {
  const AttentionCallsPage({Key? key}) : super(key: key);

  @override
  AttentionCallsPageState createState() => AttentionCallsPageState();
}

class AttentionCallsPageState extends State<AttentionCallsPage> {
  final AttentionCallsRemoteDataSource _attentionCallsDataSource = AttentionCallsRemoteDataSource();
  List<AttentionCallsModel> Calls = [];
  List<AttentionCallsModel> filterList = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  final PersonaDataSourceImpl personaDataSource = PersonaDataSourceImpl();
  String level = '', grade = '', userRol = '', personaId = '';
  List<String> gradeList = ['Cualquiera'];
  PersonaModel? usuario;

  @override
  void initState() {
    super.initState();
    gradeList = ['Cualquiera'];
    _attentionCallsDataSource.getAttentionCalls().then((value) {
      setState(() {
        Calls = value;
        filterList = FilterReportsList(level, grade, searchController.text.trim());
        isLoading = false;
      });
    });
  }

  Future<void> getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    personaId = prefs.getString('personId')!;
    usuario = await personaDataSource.getPersonFromId(personaId);
    userRol = usuario?.rol ?? '';
  }

  List<AttentionCallsModel> FilterReportsList(String? level, String? grade, String? searchValue) {
    return Calls.where((Callsatencion) {
      bool matchesLevel = level == null || level.isEmpty || Callsatencion.level == level;
      bool matchesGrade = grade == null || grade.isEmpty || Callsatencion.course == grade;
      bool matchesStudent = true;

      if (searchValue != null && searchValue.isNotEmpty) {
        matchesStudent = Callsatencion.student.toUpperCase().contains(searchValue.toUpperCase());
      }

      return matchesLevel && matchesGrade && matchesStudent;
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Administración de Llamadas de Atención',
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
              icon: const Image(image: AssetImage('assets/ui/barra-de-menus.png')),
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
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/create_call');
                              },
                              child: const Text(
                                "Añadir notificación",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/calls_history');
                              },
                              child: const Text(
                                "Ver historial",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/notice_main');
                              },
                              child: const Text(
                                "Volver al menú principal",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
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
                                      level,
                                      grade,
                                      searchController.text.trim(),
                                    );
                                  });
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
                                  'Secundaria',
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
                                      gradeList = ['Cualquiera', '1ra sección', '2da sección'];
                                      level = value!;
                                      break;
                                    default:
                                      gradeList = ['Cualquiera', '1er', '2do', '3er', '4to', '5to', '6to'];
                                      level = value!;
                                  }
                                  setState(() {});
                                  filterList = FilterReportsList(
                                    level,
                                    grade,
                                    searchController.text.trim(),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: grade.isEmpty ? 'Cualquiera' : grade,
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
                                  filterList = FilterReportsList(
                                    level,
                                    grade,
                                    searchController.text.trim(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: filterList.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No hay llamadas de atención',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF044086),
                                      fontSize: 18,
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          'Estudiante',
                                          style: TextStyle(
                                            color: Color(0xFF044086),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Nombre del Profesor',
                                          style: TextStyle(
                                            color: Color(0xFF044086),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Motivo',
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
                                          'Curso',
                                          style: TextStyle(
                                            color: Color(0xFF044086),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                    ],
                                    rows: filterList.map((report) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              '${report.student}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              report.teacher,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              report.motive,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          DataCell(Text(report.level)),
                                          DataCell(Text(report.course)),
                                          DataCell(
                                            ElevatedButton(
                                              onPressed: () async {
                                                final recargar =
                                                    await Navigator.of(context).pushNamed(
                                                  '/edit_call',
                                                  arguments: {'id': report.id},
                                                );
                                                if (recargar != null) {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  _attentionCallsDataSource
                                                      .getAttentionCalls()
                                                      .then((value) {
                                                    setState(() {
                                                      Calls = value;
                                                      level = '';
                                                      grade = '';
                                                      searchController.text =
                                                          report.student;
                                                      filterList = FilterReportsList(
                                                        level,
                                                        grade,
                                                        searchController.text.trim(),
                                                      );
                                                      isLoading = false;
                                                    });
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
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
