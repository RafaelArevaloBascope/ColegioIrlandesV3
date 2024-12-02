import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/license_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/app_bar_custom_history.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Licenses extends StatefulWidget {
  const Licenses({super.key});

  @override
  State<Licenses> createState() => _LicensesState();
}

class _LicensesState extends State<Licenses> {
  LicenseRemoteDatasourceImpl licenseRemoteDatasourceImpl =
      LicenseRemoteDatasourceImpl();
  final PersonaDataSourceImpl _personaDataSource  =  PersonaDataSourceImpl();
  String grade = '-', level = '-';
  bool isReady = false;
  String selectedReason = 'Enfermedad';
  TextEditingController dateController = TextEditingController();
  TextEditingController controllerOtros = TextEditingController();
  TextEditingController fullnameController = TextEditingController();
  bool mostrarSearch = false;
  String personaId = '';  
  bool isLoading  = true;

  Uint8List? image;
  String filename = '';
  ImageProvider? justifyImage;
  //------------
  String startTime = "07:30", endTime = "08:00";

  String dateMessage = '';

  List<String> startTimes = [], endTimes = [];

  List<String> reasonsList = [
    'Enfermedad',
    'Viaje',
    'Accidente',
    'EMERGENCIA',
    'Otros'
  ];
  List<PersonaModel> students = [];
  PersonaModel? selectStudent;
  late List<PersonaModel> filerStudents;

  List<PersonaModel> filterStudents(String name, List<PersonaModel> students) {
    return students.where((student) {
      final fullName = '${student.name.toLowerCase()} ${student.lastname.toLowerCase()} ${student.surname.toLowerCase()}';
      return fullName.contains(name.toLowerCase());
    }).toList();
  }

  InputDecoration customDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: label,
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

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Aceptar"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
List<String> generateTimeSlots(
    String startTime, String endTime, int intervalInMinutes) {
  final start = TimeOfDay(
      hour: int.parse(startTime.split(':')[0]),
      minute: int.parse(startTime.split(':')[1]));
  final end = TimeOfDay(
      hour: int.parse(endTime.split(':')[0]),
      minute: int.parse(endTime.split(':')[1]));

  final List<String> times = [];

  var currentHour = start.hour;
  var currentMinute = start.minute;

  while (currentHour < end.hour ||
      (currentHour == end.hour && currentMinute <= end.minute)) {
    times.add(
        '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}');

    currentMinute += intervalInMinutes;
    if (currentMinute >= 60) {
      currentHour++;
      currentMinute -= 60;
    }

    if (currentHour >= 24) {
      currentHour -= 24;
    }
  }

  return times;
}
/*
  List<String> generateTimeSlots(
      String startTime, String endTime, int intervalInHours) {
    final start = TimeOfDay(
        hour: int.parse(startTime.split(':')[0]),
        minute: int.parse(startTime.split(':')[1]));
    final end = TimeOfDay(
        hour: int.parse(endTime.split(':')[0]),
        minute: int.parse(endTime.split(':')[1]));

    final List<String> times = [];

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
*/
/*
  String getNextHour(String time) {
    List<String> parts = time.split(':');

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    hour = (hour + 1) % 24; 

    return "${hour.toString().padLeft(2, '0')}:$minute";
  }*/
  String getNextHour(String time) {
  List<String> parts = time.split(':');

  int hour = int.parse(parts[0]);
  int minute = int.parse(parts[1]);

  hour = (hour + (minute >= 30 ? 1 : 0)) % 24;
  minute = (minute + 30) % 60;

  return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
}

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) => {
      personaId = value.getString('personId')!,
      _personaDataSource.getStudents().then((value) => {      
        isLoading = true,
        students = value,    
        if (mounted)
          {
            setState(() {
              isLoading = false;
            })
          }
      }),
    }); 
    filerStudents = filterStudents('', students);
    super.initState();
    startTimes = generateTimeSlots("07:30", "16:00", 30);

    filerStudents = filterStudents('', students);

    controllerOtros.addListener(() {
      setState(() {});
    });
  }

    void clearForm() {
      selectStudent = null;
      fullnameController.text = '';
      startTimes = generateTimeSlots("07:30", "16:00", 30);
      endTimes = generateTimeSlots(getNextHour(startTime), "16:30", 30);
      image = null;
      filename = '';
      justifyImage = null;
      selectedReason = 'Enfermedad';
      dateController.text == '';
      controllerOtros.text == '';
      dateMessage = '';
      setState(() {});
    }

  @override
  void dispose() {
    controllerOtros.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    endTimes = generateTimeSlots(getNextHour(startTime), "16:30", 30);
    if (!endTimes.contains(endTime)) endTime = endTimes[0];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppBarCustomHistory(
        title: 'Registro de licencias',
      ),
      drawer: CustomDrawer(),
      body: isLoading ? const Center(child: CircularProgressIndicator(),)
      :Center(
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
                        const SizedBox(
                          height: 20,
                        ),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Buscar estudiante',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Color(0xFF044086),
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 5, bottom: 2, left: 8, right: 8),
                          child: CustomTextField(
                            label: 'Nombre Completo',
                            controller: fullnameController,
                            onChanged: (value) => {
                              if (fullnameController.text.trim() != '')
                                {
                                  mostrarSearch = true,
                                  filerStudents = filterStudents(fullnameController.text.trim(), students)
                                }
                              else
                                {
                                  mostrarSearch = false,
                                },
                              setState(() {})
                            },
                          ),
                        ),
                        if (filerStudents.isNotEmpty && mostrarSearch)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 60.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            height: 150,
                            child: ListView.builder(
                              itemCount: filerStudents.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  elevation: 2.0,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 8.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(10.0),
                                    title: filerStudents[index].grade.trim() != ''? Text('${filerStudents[index].name} ${filerStudents[index].lastname} ${filerStudents[index].surname}, ${filerStudents[index].grade}')
                                      : Text('${filerStudents[index].name} ${filerStudents[index].lastname} ${filerStudents[index].surname}'),                                
                                    onTap: () async {
                                      selectStudent = filerStudents[index];
                                      mostrarSearch = false;
                                      setState(() {});
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 10,),
                        if(selectStudent != null)
                        Text('${selectStudent!.name} ${selectStudent!.lastname} ${selectStudent!.surname}  ${selectStudent!.grade.trim() != '' ? ', ${selectStudent!.grade}':''}'),
                        const SizedBox(
                          height: 30,
                        ),
                        Padding(
                            padding: const EdgeInsets.only(
                                top: 5, bottom: 2, left: 8, right: 8),
                            child: Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  decoration: customDecoration('Motivo'),
                                  isDense: true,
                                  value: selectedReason,
                                  onChanged: (String? newValue) {
                                    selectedReason = newValue!;
                                    controllerOtros.clear();
                                    dateMessage = '';

                                    if (dateController.text != '') {
                                      DateTime currentDate = DateTime.now();
                                      DateTime justDate = DateTime(
                                          currentDate.year,
                                          currentDate.month,
                                          currentDate.day);
                                      DateFormat format =
                                          DateFormat("MMM d, yyyy");
                                      DateTime date =
                                          format.parse(dateController.text);

                                      if (date.isAtSameMomentAs(justDate)) {
                                        dateController.text = '';
                                      }
                                    }
                                    if (newValue == 'EMERGENCIA') {
                                      String formatedDate = DateFormat('yMMMd')
                                          .format(DateTime.now());
                                      dateController.text =
                                          formatedDate.toString();
                                      dateMessage =
                                          'Fecha establecida automaticamente';
                                    }
                                    setState(() {});
                                  },
                                  items: reasonsList
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                                if (selectedReason == 'Otros')
                                  TextField(
                                    maxLength: 15,
                                    controller: controllerOtros,
                                    decoration: InputDecoration(
                                      hintText: 'Escribe tu razón',
                                      counterText:
                                          '${controllerOtros.text.length}/15',
                                    ),
                                  ),
                                if (selectedReason == 'EMERGENCIA')
                                  const Text('Motivo de EMERGENCIA',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Color(0xFFC00707),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                              ],
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Justificativo:',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color(0xFF3D5269),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        IconButton(
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['png', 'jpg', 'jpeg'],
                            );

                            if (result != null) {
                              final pickedFile = result.files.single;
                              const maxSize = 2 * 1024 * 1024;
                              if (pickedFile.size > maxSize) {
                                // ignore: use_build_context_synchronously
                                showErrorDialog(context,
                                    "El archivo seleccionado es demasiado grande.");
                              } else {
                                image = pickedFile.bytes;
                                filename = pickedFile.name;
                                justifyImage = MemoryImage(Uint8List.fromList(image!));
                                
                                setState(() {});
                              }
                            } else {
                              // ignore: use_build_context_synchronously
                              showErrorDialog(context,
                                  "No olvide subir el justificativo.");
                            }
                          },
                          iconSize: 2,
                          icon: Image.asset(
                            'assets/ui/carga-de-carpeta.png',
                            width: 50,
                          )
                        ),
                        if(justifyImage != null)
                        Image(
                          image: justifyImage!,
                          width: 500.0,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            controller: dateController,
                            decoration: customDecoration('Fecha'),
                            readOnly: true,
                            onTap: () async {
                              if (selectedReason != 'EMERGENCIA') {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(DateTime.now().year + 20),
                                );
                                if (pickedDate != null) {
                                  // Obtener la fecha actual sin la parte de la hora (sólo año, mes y día).
                                  DateTime currentDate = DateTime.now();
                                  DateTime justDate = DateTime(currentDate.year,
                                      currentDate.month, currentDate.day);

                                  dateMessage = '';
                                  if (pickedDate.isAtSameMomentAs(justDate)) {
                                    dateController.text = '';
                                    // ignore: use_build_context_synchronously
                                    showErrorDialog(context,
                                        "Debe solicitar la licencia minimamente con un día de anticipación.\nEn caso quiera solicitar una licencia para el dia de hoy debe marcar como motivo de EMERGENCIA.");
                                  } else {
                                    String formattedDate =
                                        DateFormat('yMMMd').format(pickedDate);
                                    dateController.text =
                                        formattedDate.toString();
                                  }
                                } else {
                                  if (dateController.text == '') {
                                    dateMessage = 'DEBE MARCAR UNA FECHA';
                                  }
                                }
                                setState(() {});
                              }
                            },
                          ),
                        ),
                        if (selectedReason == 'EMERGENCIA' || dateMessage != '')
                          Text(dateMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Color(0xFFC00707),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),

                        const SizedBox(
                          height: 20,
                        ),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Hora:',
                              style: TextStyle(
                                  color: Color(0xFF3D5269),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: DropdownButtonFormField<String>(
                                      decoration: customDecoration('Desde'),
                                      value: startTime,
                                      onChanged: (String? newValue) {
                                        startTime = newValue.toString();
                                        setState(() {});
                                      },
                                      items: startTimes
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: DropdownButtonFormField<String>(
                                      decoration: customDecoration('Hasta'),
                                      value: endTime,
                                      onChanged: (String? newValue) {
                                        endTime = newValue.toString();
                                        setState(() {});
                                      },
                                      items: endTimes
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(
                          height: 40,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if ((filename.trim() != '' || selectedReason == 'EMERGENCIA') && dateController.text != '') {
                              if ((controllerOtros.text.trim() != '' || selectedReason != 'Otros') && selectStudent != null) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      alignment: Alignment.center,
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            '¿Estás seguro de que quieres enviar el formulario?',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFF3D5269),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18
                                            )
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        left: 5, right: 5),
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    String reason = (selectedReason =='Otros')? controllerOtros.text.trim(): selectedReason;

                                                    String result = await licenseRemoteDatasourceImpl.addLicense(
                                                      selectStudent!,
                                                      reason,
                                                      image,
                                                      filename,
                                                      dateController.text,
                                                      startTime,
                                                      endTime,
                                                      'ACTIVE',
                                                      'GPR0028293',
                                                      DateTime.now()
                                                    );
                                                    clearForm();
                                                    // ignore: use_build_context_synchronously
                                                    Navigator.of(context).pop();                                                    
                                                    // ignore: use_build_context_synchronously
                                                    Navigator.of(context).pushNamed(
                                                      '/license_verification',
                                                      arguments: {
                                                        'id': result
                                                      },
                                                    );
                                                  },
                                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all( const Color(0xFF044086))),
                                                  child: const Text(
                                                    'Si',
                                                    style: TextStyle(color: Colors.white)
                                                  )
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        left: 5, right: 5),
                                                child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty.all(
                                                                const Color(
                                                                    0xFF044086))),
                                                    child: const Text('No',
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
                              } else {
                                showErrorDialog(context, 'No olvide señalar el motivo y seleccionar un estudiante');
                              }
                            } else {
                              showErrorDialog(context, 'No olvide subir el justificativo y marcar la fecha');
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xFF044086))),
                          child: const Text('Enviar',
                              style: TextStyle(color: Colors.white))),
                        const SizedBox(
                          height: 40,
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/notice_main');
                            },
                            iconSize: 2,
                            icon: Image.asset(
                              'assets/ui/home.png',
                              width: 50,
                            )),
                        const Text(
                          'Inicio',
                          style: TextStyle(
                              color: Color(0xFF3D5269),
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        )
                      ],
                    ),
                  ),
                ));
          },
        ),
      ),
    );
  }
}
