import 'dart:convert';
import 'dart:html' show window;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/notification_model.dart';
import 'package:pr_h23_irlandes_web/data/model/postulation_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/interview_schedule_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/notifications_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/postulation_remote_datasource.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
//
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';

import 'package:crypto/crypto.dart';

import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;


class RegisterPostulationHardCoded extends StatefulWidget {
  const RegisterPostulationHardCoded({super.key});

  @override
  State<RegisterPostulationHardCoded> createState() => _RegisterPostulationHardCoded();
}

class _RegisterPostulationHardCoded extends State<RegisterPostulationHardCoded> {

  Future<bool> _confirmLogoutDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Sí
              },
              child: const Text('Sí'),
            ),
          ],
        );
      },
    ) ?? false; // Por defecto, no cerrar sesión si se cierra el diálogo
  }
  //hardcoded

  PersonaDataSourceImpl _personaDataSource = PersonaDataSourceImpl();
  final NotificationRemoteDataSourceImpl notificationRemoteDataSource =
  NotificationRemoteDataSourceImpl();
  late PostulationModel postulation;
  // bool isLoading = true;
  String fatherUserName = '';
  String fatherPassword = '';
  String motherUserName = '';
  String motherPassword = '';
  //hardcoded
  List<PostulationModel> postulationsList = [];

  InterviewScheduleRemoteDatasourceImpl scheduleRemoteDatasourceImpl =
  InterviewScheduleRemoteDatasourceImpl();
  PostulationRemoteDatasourceImpl postulationRemoteDatasourceImpl =
  PostulationRemoteDatasourceImpl();
  TextEditingController dateController = TextEditingController();
  TextEditingController schoolController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController studentNameController = TextEditingController();
  TextEditingController studentLastnameController = TextEditingController();
  TextEditingController studentCIController = TextEditingController();
  TextEditingController complementController = TextEditingController();
  TextEditingController fatherNameController = TextEditingController();
  TextEditingController fatherLastnameController = TextEditingController();
  TextEditingController fatherCellphoneController = TextEditingController();
  TextEditingController motherNameController = TextEditingController();
  TextEditingController motherLastnameController = TextEditingController();
  TextEditingController motherCellphoneController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
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
  }

  void _onCameraMove(CameraPosition position) {
    // Verificar si la nueva posición de la cámara está fuera de los límites de Cochabamba
    if (!_cochabambaBounds.contains(position.target)) {
      // Si está fuera de los límites, mover la cámara de vuelta a Cochabamba
      _mapController
          .animateCamera(CameraUpdate.newLatLngBounds(_cochabambaBounds, 0));
      _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            _initialPosition,
            12, // Zoom level
          ));

    }
  }

  final Set<Marker> _markers = {};
  //ssssssss
  double _markerInfoLati =0;
  double _markerInfoLong =0;
  void _onMapTapped(LatLng position) {
    setState(() {
      // Limpia el conjunto de marcadores antes de agregar uno nuevo
      _markers.clear();
      _markers.add(Marker(
        markerId:
        MarkerId(position.toString()), // Usar la posición como ID único
        position: position,
        //infoWindow: InfoWindow(
        //title: 'Sus coordenadas son',
        //snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
        //),
      ));
    });

    _writeToDirectionField();

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

  String _varlo = "";

  //MAPACONFIG
  bool _isExpanded = false;
  bool _expanded = false;
  void toggleMapSize() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
  void _centerMapOnCochabamba() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          _initialPosition,
          12, // Zoom level
        ),
      );
    }
  }
  void _writeToDirectionField() {
    setState(() {
      if (_markers.isNotEmpty) {
        _markerInfoLati = _markers.first.position.latitude;
      }
      if (_markers.isNotEmpty) {
        _markerInfoLong = _markers.first.position.longitude;
      }
      // controllerDirection.text = 'avenida zabala';
      print('Latitude: $_markerInfoLati, Longitude: $_markerInfoLong');
    });
  }

  //METODO MAPAGOOGLE-FIN
  String level = '', grade = '', gender = '', foreign = '';
  List<String> gradeList = [];

  DateFormat format = DateFormat("dd/MM/yyyy");
  DateTime startDate = DateTime.now().add(const Duration(days: 1)),
      endDate = DateTime(2023, 11, 1),
      selectedDay = DateTime(1999, 11, 1);
  late List<String> days, times;
  final CarouselController _carouselController = CarouselController();
  String startTime = '08:30', endTime = '16:30', selectedHour = '';
  bool isLoading = true, isScheduleActive = false, needColorHelp = false;

  @override
  void initState() {
    scheduleRemoteDatasourceImpl.getActiveInterviewSchedule().then((value) => {
      isLoading = true,
      if (value != null)
        {
          endDate = format.parse(value.limit_date),
          if (endDate.isAfter(startDate))
            {
              startTime = value.start_time,
              endTime = value.end_time,
              times =
                  generateTimeSlots(value.start_time, value.end_time, 1),
              days = value.days,
              isScheduleActive = true,
            }
        },
      if (mounted)
        {
          setState(() {
            isLoading = false;
          })
        }
    });
    postulationRemoteDatasourceImpl
        .getPostulationsAfterDate(startDate)
        .then((value) => {
      isLoading = true,
      postulationsList = value,
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
              if (title == 'Correcto') {
                window.location.reload();
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  DateTime resetTime(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  List<List<DateTime>> getWeeks(DateTime startDate, DateTime endDate) {
    List<List<DateTime>> weeks = [];

    startDate = resetTime(startDate);
    endDate = resetTime(endDate);

    // Si startDate es sábado (6) o domingo (7), ajusta al próximo lunes
    if (startDate.weekday == 6) {
      startDate = startDate.add(const Duration(days: 2));
    } else if (startDate.weekday == 7) {
      startDate = startDate.add(const Duration(days: 1));
    }

    DateTime currentMonday =
    resetTime(startDate.subtract(Duration(days: startDate.weekday - 1)));

    while (currentMonday.isBefore(endDate)) {
      List<DateTime> week = [];
      for (int i = 0; i < 5; i++) {
        week.add(currentMonday.add(Duration(days: i)));
      }
      weeks.add(week);
      currentMonday = currentMonday.add(const Duration(days: 7));
    }

    return weeks;
  }

  List<String> generateTimeSlots(
      String startTime, String endTime, int intervalInHours) {
    final start = TimeOfDay(
        hour: int.parse(startTime.split(':')[0]),
        minute: int.parse(startTime.split(':')[1]));
    final end = TimeOfDay(
        hour: int.parse(endTime.split(':')[0]),
        minute: int.parse(endTime.split(':')[1]));

    final List<String> times = [''];

    var currentHour = start.hour;
    var currentMinute = start.minute;

    while (currentHour < end.hour ||
        (currentHour == end.hour && currentMinute <= end.minute)) {
      times.add(
          '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}');

      currentHour += intervalInHours;
      if (currentHour >= 24) {
        currentHour -= 24;
        currentMinute += (intervalInHours - (currentHour / 24).floor()) * 60;
        currentMinute %= 60;
      }
    }
    return times;
  }

  bool areTextControllersNotEmpty(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      if (controller.text.isEmpty) {
        return false;
      }
    }
    if (level == '' || grade == '' || gender == '') {
      return false;
    }
    return true;
  }

  bool areAllFieldsFilled() {
    List<TextEditingController> allControllers = [
      dateController,
      schoolController,
      cityController,
      studentNameController,
      studentLastnameController,
      studentCIController,
      phoneController,
      emailController,
    ];
    return areTextControllersNotEmpty(allControllers);
  }

  @override
  Widget build(BuildContext context) {
    List<List<DateTime>> weeks = getWeeks(startDate, endDate);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Registrar postulación Directa',
            style: GoogleFonts.barlow(
                textStyle: const TextStyle(
                    color: Color(0xFF3D5269),
                    fontSize: 24,
                    fontWeight: FontWeight.bold))),
        toolbarHeight: 75,
        elevation: 0,
        actions: [
          IconButton(iconSize:25, icon: const Image(image: AssetImage('assets/ui/cerrarsesion.png') ),
            onPressed: () async {
              // Pregunta al usuario si desea cerrar sesión
              bool confirmLogout = await _confirmLogoutDialog(context);
              if (confirmLogout) {
                // Cierra sesión y redirige a la pantalla de inicio de sesión
                await FirebaseAuth.instance.signOut();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            //icon: const Icon(Icons.exit_to_app),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : !isScheduleActive
          ? const Center(
        child: Text(
          'Las postulaciones no estan activas',
          style: TextStyle(
              color: Color(0xFF044086),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      )
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
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: customDecoration('Nivel'),
                              isDense: true,
                              items: ['Inicial', 'Primaria', 'Secundaria']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                level = value!;
                                switch (value) {
                                  case 'Inicial':
                                    gradeList = ['1ra sección','2da sección'];
                                    grade = gradeList[0];
                                    break;
                                  default:
                                    gradeList = ['1er','2do','3er','4to','5to', '6to'];
                                    grade = gradeList[0];
                                }
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isDense: true,
                              decoration:customDecoration('Curso'),
                              value: gradeList.isNotEmpty ? grade:'',
                              items: gradeList.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                grade = value!;
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        label: 'Unidad educativa de procedencia',
                        controller: schoolController,
                        maxLength: 40,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(
                              r"[a-zA-Z0-9áéíóúÁÉÍÓÚñÑüÜ'.\s-]")),
                          FilteringTextInputFormatter.deny(
                              RegExp(r'\s\s+')),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        label: 'Ciudad',
                        controller: cityController,
                        maxLength: 20,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.deny(
                              RegExp(r'[^A-Za-záéíóúÁÉÍÓÚñÑüÜ\s]')),
                          FilteringTextInputFormatter.deny(
                              RegExp(r'\s\s+')),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                CustomTextField(
                                  label: 'Nombres',
                                  controller: studentNameController,
                                  maxLength: 40,
                                  type: TextInputType.name,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.deny(
                                        RegExp(
                                            r'[^A-Za-záéíóúÁÉÍÓÚñÑüÜ\s]')),
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'\s\s+')),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Container(
                                          margin: const EdgeInsets.only(bottom: 25),
                                          child: GestureDetector(
                                            onTap:() {
                                              foreign ==''? foreign = 'E-' : foreign = '';
                                              setState(() {});
                                            },
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: Container(
                                                height: 30,
                                                width: 30,
                                                decoration: BoxDecoration(
                                                  color: foreign !='' ? const Color(0xFF044086) : Colors.grey,
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    'E',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 25),
                                      child: const Text('-', style: TextStyle(color: Colors.black, fontSize: 24)),
                                    ),

                                    const SizedBox(width: 5),
                                    Flexible(
                                      flex: 10,
                                      child: CustomTextField(
                                        label: 'CI',
                                        controller: studentCIController,
                                        maxLength: 10,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]')
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      flex: 3,
                                      child: CustomTextField(
                                        label: 'Complemento',
                                        controller: complementController,
                                        maxLength: 3,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[a-z]')
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                DropdownButtonFormField<String>(
                                  isDense: true,
                                  decoration:
                                  customDecoration('Género'),
                                  items: ['Masculino', 'Femenino']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    gender = value!;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                CustomTextField(
                                  label: 'Apellidos',
                                  controller:
                                  studentLastnameController,
                                  maxLength: 40,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.deny(
                                        RegExp(
                                            r'[^A-Za-záéíóúÁÉÍÓÚñÑüÜ\s]')),
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'\s\s+')),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: dateController,
                                  decoration: customDecoration(
                                      'Fecha de nacimiento'),
                                  readOnly: true,
                                  onTap: () async {
                                    DateTime? pickedDate =
                                    await showDatePicker(
                                      context: context,
                                      initialDate: DateTime(
                                          DateTime.now().year - 5),
                                      firstDate: DateTime(
                                          DateTime.now().year - 25),
                                      lastDate: DateTime.now(),
                                    );
                                    if (pickedDate != null) {
                                      DateTime currentDate =
                                      DateTime.now();
                                      DateTime justDate = DateTime(
                                          currentDate.year,
                                          currentDate.month,
                                          currentDate.day);

                                      if (pickedDate.isAtSameMomentAs(
                                          justDate)) {
                                        dateController.text = '';
                                      } else {
                                        String formattedDate =
                                        DateFormat('dd/MM/yyyy')
                                            .format(pickedDate);
                                        dateController.text =
                                            formattedDate.toString();
                                      }
                                    } else {
                                      if (dateController.text == '') {
                                        // ignore: use_build_context_synchronously
                                        showMessageDialog(
                                            context,
                                            'assets/ui/circulo-cruzado.png',
                                            'Error',
                                            'Debe marcar una fecha');
                                      }
                                    }
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                CustomTextField(
                                  label: 'Nombres',
                                  controller: fatherNameController,
                                  maxLength: 40,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.deny(
                                        RegExp(
                                            r'[^A-Za-záéíóúÁÉÍÓÚñÑüÜ\s]')),
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'\s\s+')),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomTextField(
                                  label: 'Número de celular',
                                  controller:
                                  fatherCellphoneController,
                                  maxLength: 12,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          Expanded(
                            child: CustomTextField(
                              label: 'Apellidos',
                              controller: fatherLastnameController,
                              maxLength: 40,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.deny(
                                    RegExp(
                                        r'[^A-Za-záéíóúÁÉÍÓÚñÑüÜ\s]')),
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'\s\s+')),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                CustomTextField(
                                  label: 'Nombres',
                                  controller: motherNameController,
                                  maxLength: 40,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.deny(
                                        RegExp(
                                            r'[^A-Za-záéíóúÁÉÍÓÚñÑüÜ\s]')),
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'\s\s+')),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomTextField(
                                  label: 'Número de celular',
                                  controller:
                                  motherCellphoneController,
                                  maxLength: 12,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          Expanded(
                            child: CustomTextField(
                              label: 'Apellidos',
                              controller: motherLastnameController,
                              maxLength: 40,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.deny(
                                    RegExp(
                                        r'[^A-Za-záéíóúÁÉÍÓÚñÑüÜ\s]')),
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'\s\s+')),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Teléfono',
                              controller: phoneController,
                              maxLength: 10,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          Expanded(
                            child: CustomTextField(
                              label: 'Correo electrónico',
                              controller: emailController,
                              maxLength: 30,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.deny(
                                    RegExp(r"[&=_\s\'\-+,<>]")),
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'\.\.+')),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Direccion geografica del estudiante',
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Ubicacion : *", style: TextStyle(fontSize: 15, color: Colors.blue[900])),
                                SizedBox(
                                  width:  300  ,
                                  height:  500  ,
                                  child: Container(
                                    color: Colors.blue,
                                    child: GoogleMap(

                                      initialCameraPosition: CameraPosition(
                                        target: _initialPosition,
                                        zoom: 12,
                                      ),
                                      onTap: _onMapTapped,
                                      markers: _markers,
                                      mapType: MapType.none,
                                      onMapCreated: _onMapCreated,
                                      onCameraMove: _onCameraMove,
                                      minMaxZoomPreference: MinMaxZoomPreference(12, 18),

                                    ),
                                  ),
                                ),
                                // ElevatedButton(
                                //   onPressed: () {
                                //     setState(() {
                                //       _expanded = !_expanded;
                                //     });
                                //   },
                                //   child: Text(_expanded ? 'Restaurar' : 'Expandir'),
                                // ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _centerMapOnCochabamba();
                                    });
                                  },
                                  child: Text('Centrar en Cbba'),
                                ),



                              ]
                          )
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Fecha de entrevista',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color(0xFF044086),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          IconButton(
                              icon: Image.asset(
                                'assets/ui/interrogatorio.png',
                                width: 20,
                              ),
                              onPressed: () {
                                needColorHelp = !needColorHelp;
                                setState(() {});
                              }
                          ),
                        ],
                      ),
                      if(needColorHelp)
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 60.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment:CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Significado de los colores',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color(0xFF044086), fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5,),
                                ColorHelp(color: Color(0x5F9E9E9E), text: 'No disponible'),
                                SizedBox(height: 5,),
                                ColorHelp(color: Color(0xFF9E9E9E), text: 'Disponible'),
                                SizedBox(height: 5,),
                                ColorHelp(color: Color(0xFFd9534f), text: 'Ocupado'),
                                SizedBox(height: 5,),
                                ColorHelp(color: Color(0xFF198754), text: 'Seleccionado'),
                                SizedBox(height: 5,),
                              ],
                            )
                        ),
                      const SizedBox(height: 10,),
                      if (selectedHour.isNotEmpty)
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            ('${DateFormat('dd/MM/yyyy').format(selectedDay)} $selectedHour'),
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                color: Color(0xFF044086),
                                fontSize: 18),
                          ),
                        ),
                      SizedBox(
                        child: CarouselSlider.builder(
                          carouselController: _carouselController,
                          itemCount: weeks.length,
                          itemBuilder:
                              (context, carouselIndex, realIndex) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.builder(
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 6,
                                    childAspectRatio: 1.5,
                                    mainAxisSpacing: 10.0,
                                    crossAxisSpacing: 10.0,
                                  ),
                                  itemBuilder: (context, gridIndex) {
                                    int rowIndex = gridIndex ~/ 6;
                                    int columnIndex = gridIndex % 6;

                                    if (columnIndex == 0) {
                                      return Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Text(times[rowIndex],
                                              style: const TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: Color(
                                                      0xFF044086))),
                                          if (rowIndex != 0)
                                            const VerticalDivider(),
                                        ],
                                      );
                                    } else {
                                      if (rowIndex == 0) {
                                        DateTime day =
                                        weeks[carouselIndex]
                                        [columnIndex - 1];
                                        return Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .center,
                                          children: [
                                            Text(
                                                DateFormat(
                                                    'E', 'ES_es')
                                                    .format(day),
                                                style: const TextStyle(
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color: Color(
                                                        0xFF044086))),
                                            Text(
                                                DateFormat('d MMM',
                                                    'ES_es')
                                                    .format(day),
                                                style: const TextStyle(
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color: Color(
                                                        0xFF044086))),
                                            const Divider(
                                              height: 2,
                                            ),
                                          ],
                                        );
                                      } else {
                                        DateTime day =
                                        weeks[carouselIndex]
                                        [columnIndex - 1];
                                        String formattedDay =
                                        DateFormat(
                                            'EEEE', 'ES_es')
                                            .format(day)
                                            .toLowerCase();
                                        bool isSelected =
                                            selectedDay == day &&
                                                selectedHour ==
                                                    times[rowIndex];

                                        int status = postulationsList.any((d) =>
                                        DateTime(
                                            d.interview_date
                                                .year,
                                            d.interview_date
                                                .month,
                                            d.interview_date
                                                .day) ==
                                            day &&
                                            d.interview_hour ==
                                                times[rowIndex])
                                            ? 1
                                            : 2;

                                        if (endDate.isBefore(day) ||
                                            startDate.isAfter(day) ||
                                            !days.any((d) =>
                                            d.toLowerCase() ==
                                                formattedDay)) {
                                          status = 0;
                                        }

                                        return HourButton(
                                          isSelected: isSelected,
                                          status: status,
                                          onTap: () {
                                            if (status == 2) {
                                              selectedDay = day;
                                              selectedHour =
                                              times[rowIndex];
                                              setState(() {});
                                            }
                                          },
                                        );
                                      }
                                    }
                                  },
                                  itemCount: times.length * 6,
                                ),
                              ),
                            );
                          },
                          options: CarouselOptions(
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            viewportFraction: 0.8,
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              _carouselController.previousPage();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              _carouselController.nextPage();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                        onPressed: () async {
                          final bool emailValid = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                              .hasMatch(emailController.text);
                          if (areAllFieldsFilled()) {
                            if ((fatherCellphoneController.text != '' && fatherLastnameController.text != '' && fatherNameController.text != '') || (motherCellphoneController.text != '' && motherLastnameController.text != '' && motherNameController.text != '')) {
                              if (emailValid) {
                                if (selectedHour.trim().isNotEmpty) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          alignment: Alignment.center,
                                          content: Column(
                                            mainAxisSize:
                                            MainAxisSize.min,
                                            children: [
                                              const Text(
                                                  '¿Estás seguro de que quieres enviar el formulario?',
                                                  textAlign:
                                                  TextAlign.center,
                                                  style: TextStyle(
                                                      color: Color(
                                                          0xFF3D5269),
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      fontSize: 18)),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .only(
                                                        left: 5,
                                                        right: 5),
                                                    child:
                                                    ElevatedButton(
                                                        onPressed:
                                                            () async {
                                                          DateFormat
                                                          format =
                                                          DateFormat(
                                                              "dd/MM/yyyy");
                                                          DateTime
                                                          birth_day =
                                                          format
                                                              .parse(dateController.text);
                                                          try {
                                                            if(fatherCellphoneController.text == '' || fatherLastnameController.text == '' || fatherNameController.text == ''){
                                                              fatherCellphoneController.text = '';
                                                              fatherLastnameController.text = '';
                                                              fatherNameController.text = '';
                                                            }
                                                            if(motherCellphoneController.text == '' || motherLastnameController.text == '' || motherNameController.text == ''){
                                                              motherCellphoneController.text = '';
                                                              motherLastnameController.text = '';
                                                              motherNameController.text = '';
                                                            }
                                                            PostulationModel postulation = PostulationModel(
                                                                level:
                                                                level,
                                                                grade:
                                                                grade,
                                                                institutional_unit: schoolController.text
                                                                    .trim(),
                                                                city: cityController.text
                                                                    .trim(),
                                                                amount_brothers:
                                                                0,
                                                                student_name: studentNameController.text
                                                                    .trim(),
                                                                student_lastname: studentLastnameController.text
                                                                    .trim(),
                                                                student_ci: '$foreign${studentCIController.text.trim()} ${complementController.text.trim()}'.trim(),
                                                                birth_day:
                                                                birth_day,
                                                                gender:
                                                                gender,
                                                                father_name: fatherNameController.text
                                                                    .trim(),
                                                                father_lastname: fatherLastnameController.text
                                                                    .trim(),
                                                                father_cellphone: fatherCellphoneController.text
                                                                    .trim(),
                                                                mother_name: motherNameController.text
                                                                    .trim(),
                                                                mother_lastname: motherLastnameController.text
                                                                    .trim(),
                                                                mother_cellphone: motherCellphoneController.text
                                                                    .trim(),
                                                                telephone: phoneController.text
                                                                    .trim(),
                                                                email: emailController.text
                                                                    .trim(),
                                                                interview_date:
                                                                selectedDay,
                                                                interview_hour:
                                                                selectedHour,
                                                                userID:
                                                                "0",
                                                                status: 'Aprobado',
                                                                latitude: _markerInfoLati,
                                                                longitude: _markerInfoLong,
                                                                register_date: DateTime.now(),

                                                                hermanosUEE: [
                                                                  'Carlos',
                                                                  'Ana',
                                                                ],
                                                                nombreHermano: [
                                                                  'Carlos',
                                                                  'Ana',
                                                                ],
                                                                obs: 'ver',
                                                                fechaEntrevista: DateTime.timestamp(),
                                                                psicologoEncargado: 'ver',
                                                                informeBreveEntrevista: 'ver',
                                                                recomendacionPsicologia: 'ver',
                                                                respuestaPPFF: 'ver',
                                                                fechaEntrevistaCoordinacion: DateTime.timestamp(),
                                                                vistoBuenoCoordinacion: 'ver',
                                                                respuestaAPpff: 'ver',
                                                                administracion: 'ver',
                                                                recepcionDocumentos: 'ver',
                                                                estadoEntrevistaPsicologia: 'ver',
                                                                estadoGeneral: 'ver',
                                                                estadoConfirmacion: 'ver',
                                                                reasonRescheduleAppointment: '',
                                                                reasonMissAppointment: '',
                                                                estadoConfirmacionAdmin: 'Aprobado',
                                                                approvedAdm: '',
                                                                fechaEntrevistaAdministracion: DateTime.now(),
                                                                horaEntrevistaAdministracion: '',
                                                                );


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

                                                            setState(() {});

                                                          } catch (e) {
                                                            // ignore: use_build_context_synchronously
                                                            showMessageDialog(
                                                                context,
                                                                'assets/ui/circulo-cruzado.png',
                                                                'Error',
                                                                'Ha ocurrido un error inesperado');
                                                          }
                                                          setState(
                                                                  () {});
                                                        },
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                            MaterialStateProperty.all(const Color(
                                                                0xFF044086))),
                                                        child: const Text(
                                                            'Si',
                                                            style: TextStyle(
                                                                color:
                                                                Colors.white))),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .only(
                                                        left: 5,
                                                        right: 5),
                                                    child:
                                                    ElevatedButton(
                                                        onPressed:
                                                            () {
                                                          Navigator.of(
                                                              context)
                                                              .pop();
                                                        },
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                            MaterialStateProperty.all(const Color(
                                                                0xFF044086))),
                                                        child: const Text(
                                                            'No',
                                                            style: TextStyle(
                                                                color:
                                                                Colors.white))),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      });
                                } else {
                                  showMessageDialog(
                                      context,
                                      'assets/ui/circulo-cruzado.png',
                                      'Error',
                                      'No olvide seleccionar una fecha para la entrevista');
                                }
                              } else {
                                showMessageDialog(
                                    context,
                                    'assets/ui/circulo-cruzado.png',
                                    'Error',
                                    'El correo no tiene un formato valido');
                              }
                            }
                            else{
                              showMessageDialog(
                                  context,
                                  'assets/ui/circulo-cruzado.png',
                                  'Error',
                                  'Debe llenar todos los campos de padre o madre');
                            }
                          } else {
                            showMessageDialog(
                                context,
                                'assets/ui/circulo-cruzado.png',
                                'Error',
                                'No debe dejar campos vacios');
                          }
                        },
                        child: const Text('Enviar',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
      if(fatherId=='None'){
        fatherId  =await refId.getFatherReference(motherId);
      }
      if(motherId=='None'){
        motherId  =await refId.getMotherReference(fatherId);
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
          latitude: -17.3935,
          longitude: -66.1570,
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
        latitude: -17.3935,
        longitude: -66.1570,
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
        latitude: -17.3935,
        longitude: -66.1570,
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
        latitude: -17.3935,
        longitude: -66.1570,
        motherReference: 'None',
        fatherReference: fatherId,
        updatedate: DateTime.now(),
      );
      try {
        _personaDataSource.registrarUsuario(estudiante);
        _personaDataSource.registrarUsuario(madre);
        _personaDataSource.registrarUsuario(padre);
      } catch (e) {}
    }
  }

  String hashPassword(String password) {
    // Encriptar la contraseña con SHA-256
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }


}

class HourButton extends StatelessWidget {
  final bool isSelected;
  final int status;
  final void Function()? onTap;

  const HourButton({
    super.key,
    required this.isSelected,
    this.onTap,
    required this.status,
  });

  Color getColor() {
    return status == 0
        ? const Color.fromARGB(95, 158, 158, 158)
        : status == 1
        ? const Color(0xFFd9534f)
        : isSelected
        ? const Color(0xFF198754)
        : const Color(0xFF9E9E9E);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor:
        status < 2 ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: getColor(),
              borderRadius: BorderRadius.circular(5),
            )),
      ),
    );
  }

}

class ColorHelp extends StatelessWidget {
  final String text;
  final Color color;

  const ColorHelp({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            )
        ),
        Text(text)
      ],
    );


  }


}