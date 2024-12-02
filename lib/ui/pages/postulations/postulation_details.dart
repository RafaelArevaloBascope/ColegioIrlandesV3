import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/access_model.dart';
import 'package:pr_h23_irlandes_web/data/model/notification_model.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/model/postulation_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/access_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/notifications_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/postulation_remote_datasource.dart';
import 'package:crypto/crypto.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'dart:convert';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart' show rootBundle;

class PostulationDetails extends StatefulWidget {
  final String id;
  const PostulationDetails({super.key, required this.id});

  @override
  State<PostulationDetails> createState() => _PostulationDetails();
}

class _PostulationDetails extends State<PostulationDetails> {
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
                        // infoWindow: InfoWindow(
                        //   title: 'New Marker',
                        //   snippet: 'Lat: ${widget.personModel.latitude}, Lng: ${widget.personModel.longitude}',
                        // ),
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
    //southwest: LatLng(-17.4725, -66.4512), // Límite suroeste de Cochabamba
    //northeast: LatLng(-17.3055, -65.9995), // Límite noreste de Cochabamba
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
  // Campo de clase para almacenar la información del marcador

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
  //METODO CARGAR

  //METODO MAPAGOOGLE-FIN

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

  //PDF
  Future<void> generatePdf(
      BuildContext context, PostulationModel postulation) async {
    final pdf = pw.Document();

    // Cargar la imagen de los assets
    final ByteData bytes = await rootBundle.load('assets/ui/logo.png');
    final Uint8List imageData = bytes.buffer.asUint8List();
    final image = pw.MemoryImage(imageData);

    // Añadir la página al PDF
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
              pw.SizedBox(height: 20), // Espacio entre la imagen y el contenido
              pw.Center(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Detalles de postulación',
                        style: pw.TextStyle(fontSize: 20)),
                    pw.SizedBox(
                        height: 10), // Espacio entre el título y los detalles
                    pw.Text(
                        'Fecha de entrevista: ${DateFormat('dd/MM/yyyy').format(postulation.interview_date)} ${postulation.interview_hour}',
                        style: pw.TextStyle(fontSize: 14)),
                    pw.Text(
                        'Nombre completo postulante: ${postulation.student_name} ${postulation.student_lastname}',
                        style: pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(
                        height: 10), // Espacio entre cada bloque de texto
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('Nivel: ${postulation.level}',
                            style: pw.TextStyle(fontSize: 14)),
                        pw.SizedBox(
                            width:
                                35), // Espacio entre los textos en la misma fila
                        pw.Text('Grado: ${postulation.grade}',
                            style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.SizedBox(
                        height: 10), // Espacio entre filas de información
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                            'Unidad educativa: ${postulation.institutional_unit}',
                            style: pw.TextStyle(fontSize: 14)),
                        pw.SizedBox(
                            width:
                                35), // Espacio entre los textos en la misma fila
                        pw.Text('Ciudad: ${postulation.city}',
                            style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
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
          "postulation_details_${postulation.student_name}_${postulation.student_lastname}.pdf")
      ..click();

    // Limpiar la URL creada
    html.Url.revokeObjectUrl(url);

    // Mostrar un mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('PDF generado exitosamente'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Detalles de postulación',
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
                                        const Color(0xFF044086)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
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
                                                if (postulation.status ==
                                                    'Pendiente')
                                                  const Text(
                                                      '¿Estás seguro de que quieres confirmar la entevista?',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF3D5269),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18)),
                                                if (postulation.status ==
                                                    'Confirmado')
                                                  const Text(
                                                      '¿Estás seguro de que quieres Aprobar esta postulación?',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF3D5269),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18)),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5),
                                                      child: ElevatedButton(
                                                          onPressed: () async {
                                                            try {
                                                              if (postulation
                                                                      .status ==
                                                                  'Pendiente') {
                                                                await postulationRemoteDatasourceImpl
                                                                    .updatePostulationStatus(
                                                                        widget
                                                                            .id,
                                                                        'Confirmado');
                                                                enviarNotificacionConfirmado(
                                                                    postulation);

                                                                // Enviar el correo electrÃ³nico notificando la actualizaciÃ³n
                                                                String
                                                                    formattedDate =
                                                                    DateFormat(
                                                                            'yyyy-MM-dd')
                                                                        .format(
                                                                            postulation.interview_date);
                                                                String
                                                                    messagetosend =
                                                                    'Estimado/a Padre/Madre/Tutor,\n\n'
                                                                    'Nos complace informarle que la fecha de la entrevista ha sido confirmada para el día $formattedDate a las ${postulation.interview_hour} en el Departamento de Psicologia.\n\n'
                                                                    'Le agradecemos su puntualidad y quedamos a su disposición para cualquier consulta.\n\n'
                                                                    'Atentamente,\n'
                                                                    'Colegio Esclavas del Sagrado Corazón de Jesús';
                                                                await sendEmail(
                                                                  postulation
                                                                      .email, // Reemplaza con el correo del destinatario
                                                                  'ConfirmaciÃ³n de entrevista',
                                                                  messagetosend,
                                                                );
                                                                // ignore: use_build_context_synchronously
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                // ignore: use_build_context_synchronously
                                                                showMessageDialog(
                                                                    context,
                                                                    'assets/ui/marque-el-circulo.png',
                                                                    'Correcto',
                                                                    'Se ha confirmado la entrevista');
                                                              } else {
                                                                await postulationRemoteDatasourceImpl
                                                                    .updatePostulationStatus(
                                                                        widget
                                                                            .id,
                                                                        'Aprobado');
                                                                //crear usuario
                                                                crearUsuario(
                                                                    postulation);
                                                                enviarNotificacionAprovado(
                                                                    postulation);
                                                                // ignore: use_build_context_synchronously
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                // ignore: use_build_context_synchronously
                                                                showMessageDialog(
                                                                    context,
                                                                    'assets/ui/marque-el-circulo.png',
                                                                    'Correcto',
                                                                    'Postulación aprobada');
                                                                if (postulation
                                                                        .userID ==
                                                                    '0') {
                                                                  // ignore: use_build_context_synchronously
                                                                  showMessageDialog(
                                                                      context,
                                                                      'assets/ui/marque-el-circulo.png',
                                                                      'Datos de usuarios',
                                                                      (fatherUserName != ''
                                                                              ? 'Usuario del padre: $fatherUserName \nContraseña del padre: $fatherPassword\n'
                                                                              : '') +
                                                                          (motherUserName != ''
                                                                              ? 'Usuario de la madre: $motherUserName \nContraseña de la madre: $motherPassword'
                                                                              : ''));
                                                                }
                                                              }
                                                              setState(() {});
                                                            } catch (e) {
                                                              // ignore: use_build_context_synchronously
                                                              showMessageDialog(
                                                                  context,
                                                                  'assets/ui/circulo-cruzado.png',
                                                                  'Error',
                                                                  'Ha ocurrido un error inesperado');
                                                            }
                                                          },
                                                          style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all(
                                                                      const Color(
                                                                          0xFF044086))),
                                                          child: const Text(
                                                              'Si',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white))),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5),
                                                      child: ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all(
                                                                      const Color(
                                                                          0xFF044086))),
                                                          child: const Text(
                                                              'No',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white))),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                  child: postulation.status == 'Pendiente'
                                      ? const Text('Confirmar',
                                          style: TextStyle(color: Colors.white))
                                      : const Text('Aprobar',
                                          style:
                                              TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color(0xFFd9534f)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
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
                                                        color:
                                                            Color(0xFF3D5269),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18)),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
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
                                                                      widget
                                                                          .id);
                                                              // ignore: use_build_context_synchronously
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              // ignore: use_build_context_synchronously
                                                              showMessageDialog(
                                                                  context,
                                                                  'assets/ui/marque-el-circulo.png',
                                                                  'Correcto',
                                                                  'Se ha eliminado la postulación');
                                                              setState(() {});
                                                            } catch (e) {
                                                              // ignore: use_build_context_synchronously
                                                              showMessageDialog(
                                                                  context,
                                                                  'assets/ui/circulo-cruzado.png',
                                                                  'Error',
                                                                  'Ha ocurrido un error inesperado');
                                                            }
                                                          },
                                                          style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all(
                                                                      const Color(
                                                                          0xFF044086))),
                                                          child: const Text(
                                                              'Si',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white))),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5),
                                                      child: ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all(
                                                                      const Color(
                                                                          0xFF044086))),
                                                          child: const Text(
                                                              'No',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white))),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          );
                                        });
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
    //recuperar id persona
    String userToken = await _personaDataSource
        .getToken(postulation.userID); //cambiar por id recuperado
    //Navigator.pushNamed(context, '/register_notice');
    NotificationModel notification = NotificationModel(
        title: 'Entrevista confirmada',
        deviceToken: userToken,
        content:
            'En fecha: ${postulation.interview_date.day} del ${postulation.interview_date.month} de ${postulation.interview_date.year}, se se confima la entrevista para el estudiante: ${postulation.student_name} ${postulation.student_lastname}',
        userId: postulation.userID,
        registerDate: DateTime.now());
    print(notification.content.toString());
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
    print(response.statusCode);
    if (response.statusCode == 200) {
      notificationRemoteDataSource.addNotification(notification);
    }
  }

  void enviarNotificacionAprovado(PostulationModel postulation) async {
    //recuperar id persona
    String userToken = await _personaDataSource
        .getToken(postulation.userID); //cambiar por id recuperado
    //Navigator.pushNamed(context, '/register_notice');
    NotificationModel notification = NotificationModel(
        title: 'Proceso de registro al sistema finalizado',
        deviceToken: userToken,
        content:
            'El estudiante ${postulation.student_name} ${postulation.student_lastname} fue registrado en el sistema',
        userId: postulation.userID,
        registerDate: DateTime.now());
    print(notification.content.toString());
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
    print(response.statusCode);
    if (response.statusCode == 200) {
      notificationRemoteDataSource.addNotification(notification);
    }
  }

  void crearUsuario(PostulationModel postulation) async {
    // Crear una instancia de la clase Uuid
    var uuid = Uuid();
    PersonaDataSourceImpl refId;
    // Generar un ID único
    String fatherId = 'None';
    String motherId = 'None';
    if (postulation.father_name != '') {
      fatherId = postulation.userID;
    } else if (postulation.mother_name != '') {
      motherId = postulation.userID;
    }
    List<String> estudianteApellidos = postulation.student_lastname.split(' ');
    if (postulation.userID != '0') {
      //TRABJAR AQUI
      //opcion1
      //agrega adtributo referencemotherid en padre y lo mismoen madre
      //Crea consulta que devuelva el iddepadre que esta en la madre
      //if(fatherId=none)
      //padreid= consultaridpadreconSegunmadreID(motherId)
      //caso1 madreid exisite entonces se busca padreid mediante llave compartida,sacamos id de padre y lo inswertamos en en fatherid
      refId = new PersonaDataSourceImpl();
      if (fatherId == 'None') {
        fatherId = await refId.getFatherReference(motherId);
      }
      if (motherId == 'None') {
        motherId = await refId.getMotherReference(fatherId);
      }
      Future.delayed(Duration(seconds: 2), () async {
        PersonaModel estudiante = PersonaModel(
          username: 'None',
          password: 'None',
          rol: 'estudiante',
          cellphone: postulation.father_cellphone,
          ci: postulation.student_ci,
          direction: postulation.city,
          id: uuid.v4(),
          grade: postulation.grade,
          fatherId: fatherId,
          motherId: motherId,
          lastname: estudianteApellidos[0],
          mail: postulation.email,
          name: postulation.student_name,
          resgisterdate: DateTime.now(),
          status: 1,
          surname: estudianteApellidos[1],
          telephone: postulation.telephone,
          latitude: postulation.latitude,
          longitude: postulation.longitude,
          motherReference: 'None',
          fatherReference: 'None',
          updatedate: DateTime.now(),
        );
        _personaDataSource.registrarUsuario(estudiante);
      });
    } else {
      String fatherId = uuid.v4();
      String motherId = uuid.v4();
      PersonaModel estudiante = PersonaModel(
        username: 'None',
        password: 'None',
        rol: 'estudiante',
        cellphone: postulation.father_cellphone,
        ci: postulation.student_ci,
        direction: postulation.city,
        id: uuid.v4(),
        fatherId: fatherId,
        grade: postulation.grade,
        motherId: motherId,
        lastname: estudianteApellidos[0],
        mail: postulation.email,
        name: postulation.student_name,
        resgisterdate: DateTime.now(),
        status: 1,
        surname: estudianteApellidos[1],
        telephone: postulation.telephone,
        latitude: postulation.latitude,
        longitude: postulation.longitude,
        motherReference: 'None',
        fatherReference: 'None',
        updatedate: DateTime.now(),
      );
      // Generar nombre de usuario y contraseña
      // List<String> fatherApellidos = postulation.father_lastname.split(' ');
      // fatherUserName = "${postulation.father_name.substring(0, 3)}${fatherApellidos[0].substring(0, 2)}${fatherApellidos[1].substring(0, 2)}${Random().nextInt(9)}${Random().nextInt(9)}${Random().nextInt(9)}";
      // fatherPassword = "${postulation.father_lastname.substring(0, 3)}${Random().nextInt(9)}${Random().nextInt(9)}${Random().nextInt(9)}${Random().nextInt(9)}";

      List<String> fatherApellidos = postulation.father_lastname.split(' ');

// Validar si hay al menos dos apellidos
      String secondApellido =
          fatherApellidos.length > 1 ? fatherApellidos[1] : '';

// Validar si el segundo apellido está vacío
      if (secondApellido.isEmpty) {
        // Generar dos letras aleatorias en caso de que esté vacío
        secondApellido = String.fromCharCodes(
            List.generate(2, (_) => Random().nextInt(26) + 65));
      }

// Crear el nombre de usuario y contraseña
      fatherUserName =
          "${postulation.father_name.substring(0, 3)}${fatherApellidos[0].substring(0, 2)}${secondApellido.substring(0, 2)}${Random().nextInt(9)}${Random().nextInt(9)}${Random().nextInt(9)}";
      fatherPassword =
          "${postulation.father_lastname.substring(0, 3)}${Random().nextInt(9)}${Random().nextInt(9)}${Random().nextInt(9)}${Random().nextInt(9)}";

      // if (!secondApellido.isEmpty) {
      // Encriptar la contraseña con SHA-256
      String encryptedFatherPassword = hashPassword(fatherPassword);
      PersonaModel padre = PersonaModel(
        username: fatherUserName,
        password: encryptedFatherPassword,
        rol: 'padre',
        cellphone: postulation.father_cellphone,
        ci: 'None',
        direction: postulation.city,
        id: fatherId,
        fatherId: 'None',
        motherId: 'None',
        grade: 'None',
        lastname: fatherApellidos[0],
        mail: postulation.email,
        name: postulation.father_name,
        resgisterdate: DateTime.now(),
        status: 2,
        surname: secondApellido[1],
        //surname: secondApellido,
        telephone: postulation.telephone,
        latitude: postulation.latitude,
        longitude: postulation.longitude,
        motherReference: motherId,
        fatherReference: 'None',
        updatedate: DateTime.now(),
      );

      // Generar nombre de usuario y contraseña

      //List<String> motherApellidos = postulation.mother_lastname.split(' ');
      // motherUserName =
      //     "${postulation.mother_name.substring(0, 3)}${motherApellidos[0].substring(0, 2)}${motherApellidos[1].substring(0, 2)}${Random().nextInt(9)}${Random().nextInt(9)}${Random().nextInt(9)}";
      // motherPassword =
      //     "${postulation.mother_lastname.substring(0, 3)}${Random().nextInt(9)}${Random().nextInt(9)}${Random().nextInt(9)}${Random().nextInt(9)}";

      List<String> motherApellidos = postulation.mother_lastname.split(' ');

// Validar si hay al menos dos apellidos
      String secondApellidomother =
          motherApellidos.length > 1 ? motherApellidos[1] : '';

// Validar si el segundo apellido está vacío
      if (secondApellidomother.isEmpty) {
        // Generar dos letras aleatorias en caso de que esté vacío
        secondApellidomother = String.fromCharCodes(
            List.generate(2, (_) => Random().nextInt(26) + 65));
      }

// Crear el nombre de usuario y contraseña
      motherUserName =
          "${postulation.mother_name.substring(0, 3)}${motherApellidos[0].substring(0, 2)}${secondApellidomother.substring(0, 2)}${Random().nextInt(9)}${Random().nextInt(9)}${Random().nextInt(9)}";
      motherPassword =
          "${postulation.mother_lastname.substring(0, 3)}${Random().nextInt(9)}${Random().nextInt(9)}${Random().nextInt(9)}${Random().nextInt(9)}";

      // Encriptar la contraseña con SHA-256
      String encryptedMotherPassword = hashPassword(motherPassword);
      PersonaModel madre = PersonaModel(
        username: motherUserName,
        password: encryptedMotherPassword,
        rol: 'madre',
        cellphone: postulation.mother_cellphone,
        ci: 'None',
        direction: postulation.city,
        id: motherId,
        fatherId: 'None',
        motherId: 'None',
        grade: 'None',
        lastname: motherApellidos[0],
        mail: postulation.email,
        name: postulation.mother_name,
        resgisterdate: DateTime.now(),
        status: 2,
        //surname: motherApellidos[1],
        surname: secondApellidomother[1],
        telephone: postulation.telephone,
        latitude: postulation.latitude,
        longitude: postulation.longitude,
        motherReference: 'None',
        fatherReference: fatherId,
        updatedate: DateTime.now(),
      );
      try {
        _personaDataSource.registrarUsuario(estudiante);
        _personaDataSource.registrarUsuario(madre);
        _personaDataSource.registrarUsuario(padre);
        addNewAccess(fatherPassword, padre.id);
        print('accesos añadietno 12345678');
        addNewAccess(motherPassword, madre.id);
      } catch (e) {}
    }
  }

  String hashPassword(String password) {
    // Encriptar la contraseña con SHA-256
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  String encryptToBinary(String text) {
    StringBuffer binaryString = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      // Convertir cada carácter a su código ASCII y luego a binario
      String binaryChar = text.codeUnitAt(i).toRadixString(2).padLeft(8, '0');
      binaryString.write(binaryChar);
    }

    return binaryString.toString();
  }

  void addNewAccess(String access, String refe) async {
    try {
      AccessRemoteDataSourceImpl accessDataSource =
          AccessRemoteDataSourceImpl();

      // Crea un nuevo AccessModel como ejemplo
      AccessModel newAccess = AccessModel(
        acess: encryptToBinary(access),
        reference: refe,
      );

      // Usa el método createAccess para agregarlo a Firestore
      await accessDataSource.createAccess(newAccess);

      print('Nuevo acceso agregado exitosamente');
    } catch (e) {
      print('Error al agregar nuevo acceso: $e');
    }
  }
}
