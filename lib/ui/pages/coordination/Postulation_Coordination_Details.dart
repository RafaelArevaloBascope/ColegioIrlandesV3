import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/notification_model.dart';
import 'package:pr_h23_irlandes_web/data/model/postulation_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/access_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/notifications_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/postulation_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter, rootBundle;

import '../../widgets/custom_text_field.dart';

class PostulationDetailsCoordination extends StatefulWidget {
  final String id;
  const PostulationDetailsCoordination({super.key, required this.id});

  @override
  State<PostulationDetailsCoordination> createState() =>
      _PostulationDetailsCoordination();
}

class _PostulationDetailsCoordination
    extends State<PostulationDetailsCoordination> {
  //cosas para editar son de rafo respuestaAPpffController y fechaEntrevistaCoordinacionController
  DateTime? fechaEntrevistaCoordinacionController;
  TextEditingController vistoBuenoCoordinacionController =
      TextEditingController(); //como confirmado
  TextEditingController respuestaAPpffController =
      TextEditingController(); //mensaje de coordinacion creo
  //cosas para editar son de rafo respuestaAPpffController y fechaEntrevistaAdministracionController tentativa para admin
  DateTime? fechaEntrevistaAdministracionController;
  //Dato nuevo añadido 
  TextEditingController mensajeCoordinacionController  =TextEditingController();

  //controladores nuevos campos arriba
  AccessRemoteDataSourceImpl accessDataSource = AccessRemoteDataSourceImpl();
  PostulationRemoteDatasourceImpl postulationRemoteDatasourceImpl =
      PostulationRemoteDatasourceImpl();
  PersonaDataSource _personaDataSource = PersonaDataSourceImpl();
  final NotificationRemoteDataSource notificationRemoteDataSource =
      NotificationRemoteDataSourceImpl();
  late PostulationModel postulation;
  bool isLoading = true;
  String fatherUserName = '';
  String fatherPassword = '';
  String motherUserName = '';
  String motherPassword = '';
  DateTime? _newInterviewDateTime;

  Future<void> sendEmail(String toEmail, String subject, String message) async {
    final url = Uri.parse(
        'http://localhost:3000/send-email'); // URL del servidor Node.js

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'toEmail': toEmail,
        'subject': subject,
        'message': message,
      }),
    );

    if (response.statusCode == 202 || response.statusCode == 200) {
      print('Correo enviado exitosamente');
    } else {
      print('Fallo al enviar el correo: ${response.body}');
    }
  }

  @override
  void initState() {
    postulationRemoteDatasourceImpl
        .getPostulationByID(widget.id)
        .then((value) => {
              isLoading = true,
              postulation = value,
              if (mounted)
                {
                  setState(() {
                    _markers.add(
                      Marker(
                        markerId: MarkerId(postulation.toString() +
                            postulation.longitude.toString()),
                        position:
                            LatLng(postulation.latitude, postulation.longitude),
                      ),
                    );
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

  final controllerLatitud = TextEditingController();
  final controllerLongitud = TextEditingController();
  //MARKERW BEGIN
  //METODO MAPAGOGOLE
  final controllerLatitude = TextEditingController();
  final controllerLongitude = TextEditingController();
  final LatLng _initialPosition = LatLng(-17.3833, -66.1667);

  final LatLngBounds _cochabambaBounds = LatLngBounds(
    southwest: LatLng(-22.8726, -69.6447), // Límite suroeste de Bolivia
    northeast: LatLng(-9.6697, -57.4966),
  );

  late GoogleMapController _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(postulation.latitude, postulation.longitude),
        14, // Zoom level
      ),
    );
  }

  void _onCameraMove(CameraPosition position) {
    // Verificar si la nueva posición de la cámara está fuera de los límites de Cochabamba
    if (!_cochabambaBounds.contains(position.target)) {
      // Si está fuera de los límites, mover la cámara de vuelta a Cochabamba
      _mapController
          .animateCamera(CameraUpdate.newLatLngBounds(_cochabambaBounds, 0));
    }
  }

  final Set<Marker> _markers = {};
  //ssssssss
  double _markerInfoLati = 0;
  double _markerInfoLong = 0;

  double _markLATI = 0;
  double _markLONG = 0;
  void _onMapTapped(LatLng position) {
    setState(() {
      // Limpia el conjunto de marcadores antes de agregar uno nuevo
      _markers.clear();
      _markers.add(Marker(
        markerId:
            MarkerId(position.toString()), // Usar la posición como ID único
        position: position,
        infoWindow: InfoWindow(
          title: 'New Marker',
          snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
        ),
      ));
      setState(() {
        _markerInfoLati = position.latitude;
        print('Latitude: $_markerInfoLati');
        _markLATI = _markerInfoLati;
        _markerInfoLong = position.longitude;
        print('Latitude: $_markerInfoLong');
        _markLONG = _markerInfoLong;
      });
    });

    cambiar();
    //_writeToDirectionField();
  }

  String mostrarMarcador() {
    String latu = '';
    String longu = '';

    if (_markers.isNotEmpty) {
      latu = _markers.first.position.latitude.toString();
    }
    if (_markers.isNotEmpty) {
      longu = _markers.first.position.longitude.toString();
    }
    String eje = latu + '||' + longu;
    ;
    return eje;
  }

  void cambiar() {
    controllerLatitud.text = _markerInfoLati.toString();
    controllerLongitud.text = _markerInfoLong.toString();
  }

  String _varlo = "";

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

  Future<void> generatePdf(
      BuildContext context, PostulationModel postulation) async {
    final pdf = pw.Document();
    // Cargar la imagen de los assets
    final ByteData bytes = await rootBundle.load('assets/ui/logo.png');
    final Uint8List imageData = bytes.buffer.asUint8List();
    final image = pw.MemoryImage(imageData);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Container(), // Contenedor vacío para empujar la imagen a la derecha
                  pw.Image(image,
                      width: 100,
                      height: 100), // Imagen en la parte superior derecha
                ],
              ),
              pw.SizedBox(height: 20), // Espacio entre la imagen y el texto
              pw.Center(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Detalles de postulación',
                        style: pw.TextStyle(fontSize: 20)),
                    pw.Text(
                        'Fecha de entrevista: ${DateFormat('dd/MM/yyyy').format(postulation.interview_date)} ${postulation.interview_hour}',
                        style: pw.TextStyle(fontSize: 14)),
                    pw.Text(
                        'Nombre completo postulante: ${postulation.student_name} ${postulation.student_lastname}',
                        style: pw.TextStyle(fontSize: 14)),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('Nivel: ${postulation.level}',
                            style: pw.TextStyle(fontSize: 14)),
                        pw.SizedBox(width: 35),
                        pw.Text('Grado: ${postulation.grade}',
                            style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                            'Unidad educativa de procedencia: ${postulation.institutional_unit}',
                            style: pw.TextStyle(fontSize: 14)),
                        pw.SizedBox(width: 35),
                        pw.Text('Ciudad: ${postulation.city}',
                            style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.SizedBox(height: 20), // Espacio adicional
                    pw.Text(
                        'Fecha de Entrevista de Coordinación: ${DateFormat('dd/MM/yyyy').format(postulation.fechaEntrevistaCoordinacion)}',
                        style: pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 10), // Espacio entre los textos
                    pw.Text(
                        'Mensaje de Coordinación: ${postulation.respuestaAPpff}',
                        style: pw.TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Guardar el PDF como blob en memoria
    final Uint8List pdfBytes = await pdf.save();
    final blob = html.Blob([pdfBytes]);

    // Crear un URL del blob y abrir una ventana para descargar el archivo
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download",
          "postulation_details_${postulation.student_name} ${postulation.student_lastname}.pdf")
      ..click();

    // Limpiar la URL creada
    html.Url.revokeObjectUrl(url);

    // Mostrar un mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('PDF generado exitosamente'),
    ));
  }

  final List<String> nombresHermanos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Detalles de postulación-Coordinación',
            style: GoogleFonts.barlow(
                textStyle: const TextStyle(
                    color: Color(0xFF3D5269),
                    fontSize: 24,
                    fontWeight: FontWeight.bold))),
        toolbarHeight: 75,
        elevation: 0,
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  //este no usare antes
                  bool editable =
                      postulation.estadoEntrevistaPsicologia == 'Aprobado' &&
                          postulation.estadoGeneral == 'Coordinacion';
                  //solo tendra acceso a la fecha de coordinacion
                  bool editablePendiente =
                      postulation.vistoBuenoCoordinacion == 'Pendiente' &&
                          postulation.estadoGeneral == 'Coordinacion';
                  //este es el estado que tiene que estar para que te muestren los datos en la pestaña puede usar todo excepto ala fecha de coordinacion
                  bool editableConfirmado =
                      postulation.vistoBuenoCoordinacion == 'Confirmado' &&
                          postulation.estadoGeneral == 'Coordinacion';
                  //estado de confirmacion solo le mostrara no podra editar nada  cuando lo madne a administrador
                  bool editableAprobado =
                      postulation.vistoBuenoCoordinacion == 'Confirmado' &&
                          postulation.estadoGeneral == 'admin';
                  return Container(
                    width: constraints.maxWidth * 0.6,
                    constraints: const BoxConstraints(
                      minWidth: 700.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E9F4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Fecha de entrevista:',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color(0xFF044086), fontSize: 18),
                            ),
                            InkWell(
                              onTap: () async {
                                try {
                                  // Definir una fecha inicial que sea un punto de referencia en el pasado
                                  DateTime firstAllowedDate = DateTime(2000);

                                  final selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: postulation.interview_date
                                            .isBefore(firstAllowedDate)
                                        ? DateTime.now()
                                        : postulation.interview_date,
                                    firstDate: firstAllowedDate,
                                    lastDate: DateTime(2100),
                                  );

                                  if (selectedDate != null) {
                                    final selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          postulation.interview_date),
                                    );

                                    if (selectedTime != null) {
                                      setState(() {
                                        _newInterviewDateTime = DateTime(
                                          selectedDate.year,
                                          selectedDate.month,
                                          selectedDate.day,
                                          selectedTime.hour,
                                          selectedTime.minute,
                                        );
                                      });
                                    }
                                  }
                                } catch (e) {
                                  print('Error selecting date/time: $e');
                                  // Optionally, show a dialog to inform the user about the error
                                }
                              },
                              child: _newInterviewDateTime != null
                                  ? Text('${_newInterviewDateTime.toString()}')
                                  : const Text(
                                      'Seleccionar nueva fecha y hora'),
                            ),
                            Text(
                              ('${DateFormat('dd/MM/yyyy').format(postulation.interview_date)} ${postulation.interview_hour}'),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                            ElevatedButton(
                              onPressed: _newInterviewDateTime != null
                                  ? () async {
                                      try {
                                        // Actualizar la fecha y hora de la entrevista en Firebase
                                        await postulationRemoteDatasourceImpl
                                            .updateInterviewDateTime(
                                          widget.id,
                                          _newInterviewDateTime!,
                                          TimeOfDay.fromDateTime(
                                                  _newInterviewDateTime!)
                                              .format(context),
                                        );

                                        // Actualizar el estado del widget con la nueva fecha y hora
                                        setState(() {
                                          postulation.interview_date =
                                              _newInterviewDateTime!;
                                          postulation.interview_hour =
                                              TimeOfDay.fromDateTime(
                                                      _newInterviewDateTime!)
                                                  .format(context);
                                          _newInterviewDateTime = null;
                                        });
                                        Fluttertoast.showToast(
                                          msg:
                                              'La fecha de la entrevista se ha actualizado correctamente',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      } catch (e) {
                                        print(
                                            'Error updating interview date/time: $e');
                                        // Optionally, show a dialog to inform the user about the error
                                      }
                                    }
                                  : null,
                              child: const Text('Guardar cambios'),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Nivel:',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color(0xFF044086), fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  postulation.level,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 35,
                                ),
                                const Text(
                                  'Grado:',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color(0xFF044086), fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  postulation.grade,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Unidad educativa de procedencia: ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color(0xFF044086), fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  postulation.institutional_unit,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 35,
                                ),
                                const Text(
                                  'Ciudad: ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color(0xFF044086), fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  postulation.city,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Postulante',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color(0xFF044086),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            width: 35,
                                          ),
                                          const Text(
                                            'Nombre: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '${postulation.student_name} ${postulation.student_lastname}',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            width: 35,
                                          ),
                                          const Text(
                                            'CI: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            postulation.student_ci,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                          const SizedBox(
                                            width: 35,
                                          ),
                                          const Text(
                                            'Género: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            postulation.gender,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                          const SizedBox(
                                            width: 35,
                                          ),
                                          const Text(
                                            'Fecha de nacimiento: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            DateFormat('dd/MM/yyyy')
                                                .format(postulation.birth_day),
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            if (postulation.father_name.trim() != '')
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Padre',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color(0xFF044086),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            if (postulation.father_name.trim() != '')
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 35,
                                      ),
                                      const Text(
                                        'Nombre: ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xFF044086),
                                            fontSize: 18),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '${postulation.father_name} ${postulation.father_lastname}',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 18),
                                      ),
                                      const SizedBox(
                                        width: 35,
                                      ),
                                      const Text(
                                        'Número de celular : ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xFF044086),
                                            fontSize: 18),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        postulation.father_cellphone,
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(
                              height: 25,
                            ),
                            if (postulation.mother_name.trim() != '')
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Madre',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color(0xFF044086),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            if (postulation.mother_name.trim() != '')
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 35,
                                      ),
                                      const Text(
                                        'Nombre: ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xFF044086),
                                            fontSize: 18),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '${postulation.mother_name} ${postulation.mother_lastname}',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 18),
                                      ),
                                      const SizedBox(
                                        width: 35,
                                      ),
                                      const Text(
                                        'Número de celular: ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xFF044086),
                                            fontSize: 18),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        postulation.mother_cellphone,
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(
                              height: 25,
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Datos de contacto',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color(0xFF044086),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 35,
                                    ),
                                    const Text(
                                      'Teléfono: ',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Color(0xFF044086),
                                          fontSize: 18),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      postulation.telephone,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 18),
                                    ),
                                    const SizedBox(
                                      width: 35,
                                    ),
                                    const Text(
                                      'Correo electrónico: ',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Color(0xFF044086),
                                          fontSize: 18),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      postulation.email,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Direccion del postulante',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color(0xFF044086),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 600,
                                        height: 600,
                                        child: Container(
                                          color: Colors.blue,
                                          child: GoogleMap(
                                            initialCameraPosition:
                                                CameraPosition(
                                              target: _initialPosition,
                                              zoom: 12,
                                            ),
                                            //onTap: _onMapTapped,
                                            markers: _markers,
                                            mapType: MapType.none,
                                            onMapCreated: _onMapCreated,
                                            onCameraMove: _onCameraMove,
                                            minMaxZoomPreference:
                                                MinMaxZoomPreference(12, 18),
                                          ),
                                        ),
                                      ),
                                    ])),
                            const SizedBox(
                              height: 25,
                            ),

                            //psico-hermano
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Datos De hermano',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color(0xFF044086),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 35,
                                    ),
                                    const Text(
                                      'Nombre Completo Del Hermano: ',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Color(0xFF044086),
                                          fontSize: 18),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      postulation.nombreHermano.join(', '),
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 18),
                                    ),
                                    const SizedBox(
                                      width: 35,
                                    ),
                                    const Text(
                                      'Unidad Educativa De hermano/s:',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Color(0xFF044086),
                                          fontSize: 18),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      postulation.hermanosUEE.join(', '),
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 25,
                            ),
                            //observaciones
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Observaciones De Psicologia',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color(0xFF044086),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 35,
                                    ),
                                    const Text(
                                      'Observacion',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Color(0xFF044086),
                                          fontSize: 18),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      postulation.obs,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 18),
                                    ),
                                    const SizedBox(
                                      width: 35,
                                    ),
                                    const Text(
                                      'Psicologo Encargado',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Color(0xFF044086),
                                          fontSize: 18),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      postulation.psicologoEncargado,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 25,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 35,
                                    ),
                                    const Text(
                                      'Informacion De Entrevista',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Color(0xFF044086),
                                          fontSize: 18),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      postulation.informeBreveEntrevista,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 18),
                                    ),
                                    const SizedBox(
                                      width: 35,
                                    ),
                                    const Text(
                                      'Recomendacion De Psicologia',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Color(0xFF044086),
                                          fontSize: 18),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      postulation.recomendacionPsicologia,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //
                              
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 35,
                                    ),
                                    const Text(
                                      'Respuesta de PPFF',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Color(0xFF044086),
                                          fontSize: 18),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      postulation.respuestaPPFF,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 18),
                                    ),
                                    const SizedBox(
                                      width: 35,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                       

                            const SizedBox(
                              height: 25,
                            ),
                            // Solo mostrar el Container si editableAprobado es true
editableAprobado
    ? Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de Coordinación
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Coordinación',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(0xFF044086),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10), // Espaciado

              // Información de Coordinación
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Respuesta del respuestaAPpff
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Respuesta Del respuestaAPpff:',
                          style: TextStyle(
                            color: Color(0xFF044086),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          postulation.respuestaAPpff ?? "",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20), // Espaciado entre los elementos

                  // Mensaje de Coordinación
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mensaje de Coordinación:',
                          style: TextStyle(
                            color: Color(0xFF044086),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          postulation.MensajeCoordinacion ?? " ",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    : SizedBox.shrink(), // Si no es editable, no muestra nada
// Si editableAprobado es false, no mostrar nada



                            //-------------------------------------------------------------------------Registro coordinacion
                            //mostrar Coordiancion
                          
                     if (editableConfirmado )
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Coordinación',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Color(0xFF044086),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                         
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),

                                      // Campo de texto para la respuesta de coordinación
                                      if (editableConfirmado)
                                        CustomTextField(
                                          label: 'Respuesta Del respuestaAPpff',
                                          controller: respuestaAPpffController,
                                          maxLength: 40,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.deny(
                                                RegExp(
                                                    r'[^A-Za-záéíóúÁÉÍÓÚñÑüÜ\s]')),
                                            FilteringTextInputFormatter.deny(
                                                RegExp(r'\s\s+')),
                                          ],
                                          enabled: editableConfirmado,
                                        ),
                                        if (editableConfirmado)
                                          CustomTextField(
                                            label: 'Mensaje de Coordinación',
                                            controller: mensajeCoordinacionController,
                                            maxLength: 100,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.deny(RegExp(r'[^A-Za-záéíóúÁÉÍÓÚñÑüÜ\s]')),
                                              FilteringTextInputFormatter.deny(RegExp(r'\s\s+')),
                                            ],
                                            enabled: editableConfirmado,
                                          ),
                                      if (editablePendiente) ...[
                                        const Text(
                                          'Fecha de Coordinacion desea mantenerla o cambiarla?',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Color(0xFF044086),
                                              fontSize: 18),
                                        ),

                                        // Selector de fecha y hora para coordinación
                                        InkWell(
                                          onTap: editablePendiente
                                              ? () async {
                                                  DateTime firstAllowedDate =
                                                      DateTime(2000);
                                                  final selectedDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: postulation
                                                        .fechaEntrevistaCoordinacion,
                                                    firstDate: firstAllowedDate,
                                                    lastDate: DateTime(2100),
                                                  );

                                                  if (selectedDate != null) {
                                                    final selectedTime =
                                                        await showTimePicker(
                                                      context: context,
                                                      initialTime: TimeOfDay
                                                          .fromDateTime(postulation
                                                              .fechaEntrevistaCoordinacion),
                                                    );

                                                    if (selectedTime != null) {
                                                      setState(() {
                                                        fechaEntrevistaCoordinacionController =
                                                            DateTime(
                                                          selectedDate.year,
                                                          selectedDate.month,
                                                          selectedDate.day,
                                                          selectedTime.hour,
                                                          selectedTime.minute,
                                                        );
                                                      });
                                                    }
                                                  }
                                                }
                                              : null,
                                          child: fechaEntrevistaCoordinacionController !=
                                                  null
                                              ? Text(DateFormat(
                                                      'dd/MM/yyyy HH:mm')
                                                  .format(
                                                      fechaEntrevistaCoordinacionController!))
                                              : const Text(
                                                  'Fecha de Coordinacion'),
                                        ),

                                        // Mostrar la fecha actual de coordinación en el modelo
                                        Text(
                                          '${DateFormat('dd/MM/yyyy').format(postulation.fechaEntrevistaCoordinacion)} ${postulation.fechaEntrevistaCoordinacion.hour}:${postulation.fechaEntrevistaCoordinacion.minute}',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        ),
                                      ],

                                      const SizedBox(height: 10),

                                      // Solo visible para usuarios con permisos confirmados
                                      if (editableConfirmado) ...[
                                        const Text(
                                          'Fecha tentativa Para Administrador',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Color(0xFF044086),
                                              fontSize: 18),
                                        ),
                                        InkWell(
                                          onTap: editableConfirmado
                                              ? () async {
                                                  DateTime firstAllowedDate =
                                                      DateTime(2000);
                                                  final selectedDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: postulation
                                                        .fechaEntrevistaAdministracion,
                                                    firstDate: firstAllowedDate,
                                                    lastDate: DateTime(2100),
                                                  );

                                                  if (selectedDate != null) {
                                                    final selectedTime =
                                                        await showTimePicker(
                                                      context: context,
                                                      initialTime: TimeOfDay
                                                          .fromDateTime(postulation
                                                              .fechaEntrevistaAdministracion),
                                                    );

                                                    if (selectedTime != null) {
                                                      setState(() {
                                                        fechaEntrevistaAdministracionController =
                                                            DateTime(
                                                          selectedDate.year,
                                                          selectedDate.month,
                                                          selectedDate.day,
                                                          selectedTime.hour,
                                                          selectedTime.minute,
                                                        );
                                                      });
                                                    }
                                                  }
                                                }
                                              : null,
                                          child: fechaEntrevistaAdministracionController !=
                                                  null
                                              ? Text(DateFormat(
                                                      'dd/MM/yyyy HH:mm')
                                                  .format(
                                                      fechaEntrevistaAdministracionController!))
                                              : const Text(
                                                  'Seleccionar fecha tentativa para el administrador'),
                                        ),
                                        Text(
                                          '${DateFormat('dd/MM/yyyy').format(postulation.fechaEntrevistaAdministracion)} ${postulation.fechaEntrevistaAdministracion.hour}:${postulation.fechaEntrevistaAdministracion.minute}',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        ),
                                      ],

                                      const SizedBox(height: 10),

                                      // Botón para guardar cambios
                                      if (editablePendiente)
                                        ElevatedButton(
                                          onPressed: () async {
                                            guardarCambios(); // Llamamos a la función guardarCambios
                                            actualizarCamposPostulacionAprobadoLafecha(
                                                widget.id);
                                          },
                                          child: const Text('Guardar'),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 25),
                                const SizedBox(width: 25),
                              ],
                            ),

                            //Coordianciom
                            /*
                      if (postulation.userID == '0')
                        const Text(
                          'No se tiene acceso a la aplicación',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colors.black, fontSize: 18),
                        ),
                      if (postulation.userID != '0')
                        const Text(
                          'Se tiene acceso a la aplicación',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colors.black, fontSize: 18),
                        ),*/
                            if (postulation.vistoBuenoCoordinacion ==
                                    'Confirmado' &&
                                postulation.estadoGeneral == 'Coordinacion')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              const Color(0xFF044086)),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            alignment: Alignment.center,
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5),
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return const Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              );
                                                            },
                                                          );

                                                          try {
                                                            await actualizarCamposPostulacionConfirmado(
                                                                widget.id);

                                                            // Call enviarNotificacionConfirmado without .then()
                                                            enviarNotificacionConfirmado(
                                                                postulation);

                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Close loading dialog
                                                            showMessageDialog(
                                                              context,
                                                              'assets/ui/marque-el-circulo.png',
                                                              'Correcto',
                                                              'Se ha confirmado la entrevista por coordinación',
                                                            );
                                                            Navigator.of(
                                                                    context)
                                                                .pushReplacementNamed(
                                                                    '/Coordinationhomepage');
                                                            setState(() {});
                                                          } catch (e) {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Close loading dialog
                                                            showMessageDialog(
                                                              context,
                                                              'assets/ui/circulo-cruzado.png',
                                                              'Error',
                                                              'Ha ocurrido un error inesperado',
                                                            );
                                                          }
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(const Color(
                                                                      0xFF044086)),
                                                        ),
                                                        child: postulation
                                                                    .status ==
                                                                'Pendiente'
                                                            ? const Text(
                                                                'Confirmar',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white))
                                                            : const Text(
                                                                'Aprobar',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5),
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(const Color(
                                                                      0xFF044086)),
                                                        ),
                                                        child: const Text('No',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: postulation.status == 'Pendiente'
                                        ? const Text('Confirmar',
                                            style:
                                                TextStyle(color: Colors.white))
                                        : const Text('Aprobar',
                                            style:
                                                TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 10),
                                  if (editableConfirmado)
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Confirmación'),
                                              content: const Text(
                                                  '¿Está seguro de que desea devolver esta postulación a Psicología?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    // Cierra el modal sin realizar ninguna acción
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(context).pop(); // Cierra el modal
                                                    await MandarAPsicologia(postulation.userID); // Llama la función
                                                    // Aquí puedes agregar una acción posterior si es necesario
                                                  },
                                                  child: const Text('Aceptar'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red, // Cambia el color si es necesario
                                      ),
                                      child: const Text('Devolver a Psicología'),
                                    ),


                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              const Color(0xFFd9534f)),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            alignment: Alignment.center,
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  '¿Estás seguro de que quieres eliminar la postulación?',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Color(0xFF3D5269),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5),
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          try {
                                                            await postulationRemoteDatasourceImpl
                                                                .deletePostulation(
                                                                    widget.id);
                                                            Navigator.of(
                                                                    context)
                                                                .pushReplacementNamed(
                                                                    '/Coordinationhomepage');
                                                            showMessageDialog(
                                                              context,
                                                              'assets/ui/marque-el-circulo.png',
                                                              'Correcto',
                                                              'Se ha eliminado la postulación',
                                                            );
                                                            setState(() {});
                                                          } catch (e) {
                                                            showMessageDialog(
                                                              context,
                                                              'assets/ui/circulo-cruzado.png',
                                                              'Error',
                                                              'Ha ocurrido un error inesperado',
                                                            );
                                                          }
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(const Color(
                                                                      0xFF044086)),
                                                        ),
                                                        child: const Text('Si',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5),
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(const Color(
                                                                      0xFF044086)),
                                                        ),
                                                        child: const Text('No',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: const Text('Eliminar',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await generatePdf(context, postulation);
        },
        child: Icon(Icons.download),
      ),
    );
  }

  void enviarNotificacionConfirmado(PostulationModel postulation) async {
    try {
      String userToken = await _personaDataSource.getToken(postulation.userID);
      NotificationModel notification = NotificationModel(
        title: 'Entrevista confirmada',
        deviceToken: userToken,
        content:
            'En fecha: ${postulation.interview_date.day} del ${postulation.interview_date.month} de ${postulation.interview_date.year}, se confirma la entrevista para el estudiante: ${postulation.student_name} ${postulation.student_lastname}',
        userId: postulation.userID,
        registerDate: DateTime.now(),
      );

      Map<String, dynamic> notificationBody = {
        'to': userToken,
        'notification': {
          'title': notification.title,
          'body': notification.content,
        }
      };

      String jsonNotificationBody = jsonEncode(notificationBody);
      var response = await http.post(
        Uri.parse(notification.url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=${notification.serverkey}'
        },
        body: jsonNotificationBody,
      );

      if (response.statusCode == 200) {
        notificationRemoteDataSource.addNotification(notification);
      } else {
        throw Exception('Error al enviar la notificación');
      }
    } catch (e) {
      print('Error en enviarNotificacionConfirmado: $e');
    }
  }

  void enviarNotificacionAprobado(PostulationModel postulation) async {
    // Recuperar el token del usuario
    String userToken = await _personaDataSource.getToken(postulation.userID);

    NotificationModel notification = NotificationModel(
        title: 'Proceso de registro al sistema finalizado',
        deviceToken: userToken,
        content:
            'El estudiante ${postulation.student_name} ${postulation.student_lastname} fue registrado en el sistema',
        userId: postulation.userID,
        registerDate: DateTime.now());

    Map<String, dynamic> notificationBody = {
      'to': userToken,
      'notification': {
        'title': notification.title,
        'body': notification.content,
      }
    };

    String jsonNotificationBody = jsonEncode(notificationBody);
    var response = await http.post(Uri.parse(notification.url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=${notification.serverkey}'
        },
        body: jsonNotificationBody);

    if (response.statusCode == 200) {
      notificationRemoteDataSource.addNotification(notification);
    }
  }

  Future<void> actualizarCamposPostulacionConfirmado(
      String postulationID) async {
    // Crear el mapa con los campos a actualizar
    Map<String, dynamic> camposAActualizar = {
      // Los campos que sí deseas permitir la actualización:
      'respuestaAPpff': respuestaAPpffController.text.isEmpty
          ? 'Se realizó la revisión correctamente'
          : respuestaAPpffController.text,
      'fechaEntrevistaCoordinacion':
          fechaEntrevistaCoordinacionController ?? DateTime.now(),
      'fechaEntrevistaAdministracion':
          fechaEntrevistaAdministracionController ?? DateTime.now(),
      'MensajeCoordinacion': mensajeCoordinacionController.text.isEmpty
        ? 'Fue confirmado '
          : mensajeCoordinacionController.text,
      // Los demás campos que no quieres modificar solo los dejas igual
      'vistoBuenoCoordinacion': 'Confirmado',
      'administracion': '',
      'recepcionDocumentos': '',
      'estadoEntrevistaPsicologia': 'Aprobado',
      'estadoGeneral': 'admin',
      'estadoConfirmacion': 'Confirmado',
      'estadoConfirmacionAdmin': 'pendiente',
    };

    try {
      // Llamar al método updatePostulation para actualizar los campos
      await postulationRemoteDatasourceImpl.updatePostulation(
          postulationID, camposAActualizar);
      print('Campos de la postulación actualizados correctamente.');
      // Aquí podrías mostrar un mensaje en la interfaz si es necesario
    } catch (e) {
      print('Error al actualizar la postulación: $e');
      // Aquí también podrías mostrar un mensaje de error en la interfaz
    }
  }

  Future<void> actualizarCamposPostulacionAprobadoLafecha(
      String postulationID) async {
    // Crear el mapa con los campos a actualizar
    Map<String, dynamic> camposAActualizar = {
      //Modificar la fecha
      'fechaEntrevistaCoordinacion':
          fechaEntrevistaCoordinacionController ?? DateTime.now(),
      //texto
      'respuestaAPpff': respuestaAPpffController.text.isEmpty
          ? 'Se realizó la revisión correctamente'
          : respuestaAPpffController.text,
      //modificar el estado
      'MensajeCoordinacion': mensajeCoordinacionController.text.isEmpty
        ? 'Fue confirmado '
          : mensajeCoordinacionController.text,
      'vistoBuenoCoordinacion': 'Confirmado',
    };

    try {
      // Llamar al método updatePostulation para actualizar los campos
      await postulationRemoteDatasourceImpl.updatePostulation(
          postulationID, camposAActualizar);
      print('Campos de la postulación actualizados correctamente.');
      // Aquí podrías mostrar un mensaje en la interfaz si es necesario
    } catch (e) {
      print('Error al actualizar la postulación: $e');
      // Aquí también podrías mostrar un mensaje de error en la interfaz
    }
  }
Future<void> MandarAPsicologia(
      String postulationID) async {
    // Crear el mapa con los campos a actualizar
    Map<String, dynamic> camposAActualizar = {
      'status': 'Pendiente',
      'estadoGeneral': 'Psico',
    };

    try {
      // Llamar al método updatePostulation para actualizar los campos
      await postulationRemoteDatasourceImpl.updatePostulation(
          postulationID, camposAActualizar);
      print('Campos de la postulación actualizados correctamente.');
      // Aquí podrías mostrar un mensaje en la interfaz si es necesario
    } catch (e) {
      print('Error al actualizar la postulación: $e');
      // Aquí también podrías mostrar un mensaje de error en la interfaz
    }
  }

  void guardarCambios() async {
    try {
      // Actualiza los datos en el modelo antes de guardarlos en Firebase.
      if (respuestaAPpffController.text.isNotEmpty) {
        postulation.respuestaAPpff = respuestaAPpffController.text;
      }

      if (fechaEntrevistaCoordinacionController != null) {
        postulation.fechaEntrevistaCoordinacion =
            fechaEntrevistaCoordinacionController!;
      }

      // Construir el mapa de campos a actualizar para Firebase

      // Convierte los datos a un Map<String, dynamic> para enviar a Firebase
      await guardarEnFirebase(postulation.toJson());

      // Restablece los controladores después de la actualización
      setState(() {
        fechaEntrevistaCoordinacionController = null;
        respuestaAPpffController.clear();
      });

      // Mostrar mensaje de éxito
      Fluttertoast.showToast(
        msg: 'Los cambios se han guardado correctamente',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Redirigir a la página principal de coordinación
      Navigator.of(context).pushReplacementNamed('/Coordinationhomepage');
    } catch (e) {
      print('Error guardando los cambios: $e');

      // Mostrar mensaje de error
      Fluttertoast.showToast(
        msg: 'Error al guardar los cambios',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

// Función para guardar en Firebase
  Future<void> guardarEnFirebase(Map<String, dynamic> postulationData) async {
    try {
      await FirebaseFirestore.instance
          .collection('Postulations')
          .doc(postulation.id)
          .update(postulationData);
    } catch (e) {
      print('Error actualizando en Firebase: $e');
      throw Exception('Error al guardar en Firebase');
    }
  }
}
