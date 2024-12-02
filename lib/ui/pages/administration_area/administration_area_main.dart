import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/postulation_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/postulation_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer_admin_area.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';

class AdministrationHomePage extends StatefulWidget {
  const AdministrationHomePage({super.key});

  @override
  State<AdministrationHomePage> createState() => _AdministrationHomePageState();
}

class _AdministrationHomePageState extends State<AdministrationHomePage> {
  //
  //CordinacionRemoteDatasourceImpl CoordinacionRemoteDatasourceImpl = CordinacionRemoteDatasourceImpl();
  //List<CoordinacionModel> Coordinacions = [], filterList = [];
  //
  PostulationRemoteDatasourceImpl postulationRemoteDatasourceImpl =PostulationRemoteDatasourceImpl();
  List<PostulationModel> postulations = [], filterList = [];
  final PersonaDataSourceImpl personaDataSource = PersonaDataSourceImpl();
  PersonaModel? usuario;
  bool isLoading = false;
  bool isSelected = true;
  TextEditingController searchController = TextEditingController();
  String level = '', grade = '', status = '', userRol = '', personaId = '';
  List<String> gradeList = ['Cualquiera'];
  List<String> levelList = ['Cualquiera'];
  String selectedStatus = 'pendiente';


  final TextEditingController commentController = TextEditingController();
  @override
  void initState() {
    super.initState(); // Mueve esto al principio
    status = 'pendiente';

    // Carga las postulaciones
    postulationRemoteDatasourceImpl.getPostulationsStatusAA().then((value) {
      setState(() {
        isLoading = false;
        postulations = value;
        filterList = FilterReportsList(status, level, grade, searchController.text.trim());
      });
    });

    // Establece isLoading a true antes de iniciar la carga
    isLoading = true;
  }

  void showMessageDialog(
      BuildContext context, String iconSource, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Image.asset(
              iconSource,
              width: 30,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF044086),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text(
              "Aceptar",
              style: TextStyle(
                color: Color(0xFF044086),
                fontSize: 15,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (title == 'Correcto') {
                //Navigator.of(context).pop();
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
    );
  }
// ojo creo que no lo necesito
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

  List<PostulationModel> FilterReportsList(String status, String? level, String? grade, String? searchValue) {
    return postulations.where((postulation) {
      bool matchesStatus = postulation.estadoConfirmacionAdmin == status;
      bool matchesLevel = level == null || level.isEmpty || postulation.level == level;
      bool matchesGrade = grade == null || grade.isEmpty || postulation.grade == grade;
      bool matchesStudent = true;

      if (searchValue != null && searchValue.isNotEmpty) {
        matchesStudent = ("${postulation.student_name} ${postulation.student_ci}")
            .toUpperCase()
            .contains(searchValue.toUpperCase());
      }

      return matchesStatus && matchesLevel && matchesGrade && matchesStudent;
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
          'Administración de Informes - Administrador de area',
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
        /*
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
        ],*/
      ),
      //Manejo de menus segun roles
      drawer:  CustomDrawerAdminArea(),

      // drawer: userRol == 'coordinacion_uno' || userRol == 'coordinacion_dos' ? CustomDrawerCoord() : CustomDrawerPsico(),
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // IconButton(
                          // iconSize: 50,
                          //icon: Image.asset(
                          //'assets/ui/reserva.png',
                          // width: 50,
                          // ),
                          //onPressed: () {
                          // Navigator.pushNamed(
                          //   context, '/Coordination_Register');
                          //},
                          //),
                          // const Text(
                          // 'Registrar Informe',
                          //style: TextStyle(fontSize: 16),
                          //),
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
                            flex:
                            2, // Ajusta el flex para controlar el ancho
                            child: CustomTextField(
                              label: 'Buscar',
                              controller: searchController,
                              type: TextInputType.name,
                              onChanged: (value) => {
                                filterList = FilterReportsList(
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
                                filterList = FilterReportsList(
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
                                filterList = FilterReportsList(
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
                  const SizedBox(
                    height: 10,
                  ),
                  //confirmado y pendiente pro12

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            selectedStatus == 'pendiente' ? const Color(0xFF044086) : Colors.grey,
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (selectedStatus != 'pendiente') {
                            selectedStatus = 'pendiente';
                            status = 'pendiente';
                            setState(() {});
                            filterList = FilterReportsList(
                              status,
                              level,
                              grade,
                              searchController.text.trim(),
                            );
                          }
                        },
                        child: const Text('Pendientes', style: TextStyle(color: Colors.white)),
                      ),

                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            selectedStatus == 'confirmado' ? const Color(0xFF044086) : Colors.grey,
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (selectedStatus != 'confirmado') {
                            selectedStatus = 'confirmado';
                            status = 'Confirmado';
                            setState(() {});
                            filterList = FilterReportsList(
                              status,
                              level,
                              grade,
                              searchController.text.trim(),
                            );
                          }
                        },
                        child: const Text('Confirmadas', style: TextStyle(color: Colors.white)),
                      ),

                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            selectedStatus == 'aprobado' ? const Color(0xFF044086) : Colors.grey,
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (selectedStatus != 'aprobado') {
                            selectedStatus = 'aprobado';
                            status = 'Aprobado';
                            setState(() {});
                            filterList = FilterReportsList(
                              status,
                              level,
                              grade,
                              searchController.text.trim(),
                            );
                          }
                        },
                        child: const Text('Aprobado', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),


                  //listado
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
                              'No hay informes Coordinacion',
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
                                dataRowMaxHeight: 70, //altura
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
                                      label: Text('Fecha de Cordinacion',
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
                                rows: filterList.map((postulation) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(
                                          '${postulation.student_name}')),
                                      DataCell(Text(postulation.level)),
                                      DataCell(Text(postulation.grade)),
                                      DataCell(Text(
                                          DateFormat('dd/MM/yyyy')
                                              .format(postulation
                                              .register_date))), //// modificar ha la fecha de entrevista de coordinacion
                                      //DataCell(Text(postulation.estadoGeneral)),
                                      DataCell(
                                        Container(
                                          padding:
                                          EdgeInsets.symmetric(
                                              vertical: 5,
                                              horizontal: 10),
                                          color: postulation.estadoConfirmacionAdmin == 'Confirmado'
                                              ? Colors.green
                                              : postulation.estadoConfirmacionAdmin == 'Aprobado'
                                              ? Colors.red // Rojo para "Aprobado"
                                              : Colors.yellow, //
                                          child: Text(
                                            postulation.estadoGeneral,
                                            style: TextStyle(
                                              color: Colors
                                                  .white, // Para "Confirmado"
                                            ),
                                          ),
                                        ),
                                      ),// estado general admin
                                      DataCell(
                                        Column(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                final recargar =
                                                await Navigator.of(
                                                    context)
                                                    .pushNamed(
                                                    '/report_details_admin_area',
                                                    arguments: {
                                                      'id': postulation.id,



                                                    });

                                                if (recargar != null) {
                                                  setState(() {
                                                    isLoading = true;
                                                  });

                                                  postulationRemoteDatasourceImpl.getPostulations()  // modificar para que recargue una lista ordenada de reportes por fechas

                                                      .then((value) => {
                                                    postulations  =
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
                                              child: const Text('Ver'),
                                            ),
                                            if(status=='Confirmado' && postulation.reasonRescheduleAppointment=='')
                                              ElevatedButton(
                                                onPressed: () async {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: Text('Cancelar la postulacion',style:TextStyle(color: Color(0xFF044086),fontSize: 18),),
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          TextField(
                                                            controller: commentController,
                                                            decoration: InputDecoration(
                                                              labelText: 'Justificativo',
                                                              border: OutlineInputBorder(),
                                                            ),
                                                            minLines: 3,
                                                            maxLines: 5,
                                                          ),
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop(); // Cerrar el AlertDialog
                                                          },
                                                          child: Text('Atras'),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () async{
                                                            try {


                                                              // Aquí se captura el comentario del TextField
                                                              String comment = commentController.text;
                                                              if (comment.isEmpty) {
                                                                // Si el comentario está vacío, muestra un diálogo de advertencia
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (context) => AlertDialog(
                                                                    title: Text('Aviso'),
                                                                    content: Text('Favor de dar la justificación.'),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () {
                                                                          Navigator.of(context).pop(); // Cierra el aviso
                                                                        },
                                                                        child: Text('OK'),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );

                                                              }
                                                              else{
                                                                if (postulation.id == null) {
                                                                  throw Exception('El ID de la postulación no puede ser nulo');
                                                                }
                                                                await postulationRemoteDatasourceImpl.insertReasonMissAppointment(postulation.id!, comment);
                                                                await postulationRemoteDatasourceImpl.confirmPostulation(postulation.id,'pendiente');

                                                                print('Justificativo insertado correctamente para el ID: ${postulation.id}, el coment ${comment}');

                                                                // Cerrar el AlertDialog
                                                                Navigator.of(context).pop();}

                                                              Navigator.pushNamed(context, '/admin_area_main');

                                                              // Llamar al método para insertar el comentario

                                                            } catch (e) {
                                                              // Manejar cualquier excepción que ocurra al insertar el comentario
                                                              print('Error al insertar el comentario: $e');
                                                              // Otra opción sería mostrar un mensaje de error al usuario
                                                            }
                                                          },
                                                          child: Text('Enviar'),

                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
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
