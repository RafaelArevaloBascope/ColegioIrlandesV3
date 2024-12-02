import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/postulation_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/postulation_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_text_field.dart';

class InterviewManagement extends StatefulWidget {
  const InterviewManagement({super.key});

  @override
  State<InterviewManagement> createState() => _InterviewManagement();
}

class _InterviewManagement extends State<InterviewManagement> {
  PostulationRemoteDatasourceImpl postulationRemoteDatasourceImpl =
      PostulationRemoteDatasourceImpl();
  List<PostulationModel> postulations = [], filterList = [];
  bool isLoading = true;
  bool isSelected = true;
  TextEditingController searchController = TextEditingController();
  String level = '', grade = '', status = '';
  List<String> gradeList = ['Cualquiera'];

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

  List<PostulationModel> FilterPostulationsList(
    String status,
    String? level,
    String? grade,
    String? searchValue,
  ) {
    return postulations.where((postulation) {
      bool matchesStatus = postulation.status == status;
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
        title: Text('Administración de postulaciones',
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
      drawer: CustomDrawer(),
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
                                          context, '/register_postulation');
                                    }),
                                const Text('Registrar postulación',
                                    style: TextStyle(fontSize: 16)),
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
                                          gradeList = [
                                            'Cualquiera',
                                            '1ra sección',
                                            '2da sección'
                                          ];
                                          level = value!;
                                          break;
                                        default:
                                          gradeList = [
                                            'Cualquiera',
                                            '1er',
                                            '2do',
                                            '3er',
                                            '4to',
                                            '5to',
                                            '6to'
                                          ];
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
                                    value: grade == '' ? 'Cualquiera' : grade,
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
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: !isSelected
                                    ? WidgetStateProperty.all(
                                        const Color(0xFF044086))
                                    : WidgetStateProperty.all(Colors.grey),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                if (!isSelected) {
                                  isSelected = !isSelected;
                                  status = 'Pendiente';
                                  setState(() {});
                                  filterList = FilterPostulationsList(
                                      status,
                                      level,
                                      grade,
                                      searchController.text.trim());
                                }
                                setState(() {});
                              },
                              child: const Text('Pendientes',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: isSelected
                                    ? WidgetStateProperty.all(
                                        const Color(0xFF044086))
                                    : WidgetStateProperty.all(Colors.grey),
                                shape: WidgetStateProperty.all(
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
                                  filterList = FilterPostulationsList(
                                      status,
                                      level,
                                      grade,
                                      searchController.text.trim());
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
                        Expanded(
                          child: Container(
                            width: constraints.maxWidth * 0.55,
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
                                                38, // Espacio entre columnas
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
                                                      color:
                                                          postulation.status ==
                                                                  'Confirmado'
                                                              ? Colors.green
                                                              : Colors.yellow,
                                                      child: Text(
                                                        postulation.status,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
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
                                                                    '/postulation_details',
                                                                    arguments: {
                                                              'id':
                                                                  postulation.id
                                                            });
                                                        if (recargar != null) {
                                                          setState(() {
                                                            isLoading = true;
                                                          });
                                                          postulationRemoteDatasourceImpl
                                                              .getPostulations()
                                                              .then((value) => {
                                                                    postulations =
                                                                        value,
                                                                    level = '',
                                                                    grade = '',
                                                                    searchController
                                                                        .text = '',
                                                                    filterList = FilterPostulationsList(
                                                                        status,
                                                                        level,
                                                                        grade,
                                                                        searchController
                                                                            .text
                                                                            .trim()),
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
                                                      child: Text(
                                                        'Ver',
                                                        style: TextStyle(
                                                            fontSize:
                                                                14), // Tamaño de texto
                                                      ),
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
