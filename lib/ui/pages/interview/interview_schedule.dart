import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/interview_schedule_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/interview_schedule_remote_datasource.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

class InterviewSchedule extends StatefulWidget {
  const InterviewSchedule({super.key});

  @override
  State<InterviewSchedule> createState() => _InterviewSchedule();
}

class _InterviewSchedule extends State<InterviewSchedule> {
  List<bool> isSelectedDays = [false, false, false, false, false];
  String startTime = "08:30", endTime = "09:30";
  List<String> startTimes = [], endTimes = [];
  TextEditingController dateController = TextEditingController();
  InterviewScheduleRemoteDatasourceImpl datasource =
      InterviewScheduleRemoteDatasourceImpl();
  bool isLoading = true, isScheduleActive = false;
  late InterviewScheduleModel activeSchedule;

  @override
  void initState() {
    super.initState();
    startTimes = generateTimeSlots("08:30", "15:30", 1);
    datasource.getActiveInterviewSchedule().then((value) => {
          if (value != null)
            {
              startTime = value.start_time,
              endTime = value.end_time,
              dateController.text = value.limit_date,
              isSelectedDays = loadIsSelectedDays(value.days),
              isScheduleActive = true,
              activeSchedule = value
            },
          if (mounted)
            {
              setState(() {
                isLoading = false;
              })
            }
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  String getNextHour(String time) {
    List<String> parts = time.split(':');

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    hour = (hour + 1) % 24; // Increase the hour and wrap around if necessary.

    return "${hour.toString().padLeft(2, '0')}:$minute";
  }

  List<String> selectedDays(List<bool> isSelectedDays) {
    const List<String> weekDays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes'
    ];

    return isSelectedDays
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => weekDays[entry.key])
        .toList();
  }

  List<bool> loadIsSelectedDays(List<String> days) {
    const List<String> weekDays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes'
    ];

    return List.generate(weekDays.length, (i) => days.contains(weekDays[i]));
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

  @override
  Widget build(BuildContext context) {
    endTimes = generateTimeSlots(getNextHour(startTime), "16:30", 1);
    if (!endTimes.contains(endTime)) endTime = endTimes[0];

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Cronograma de entrevistas',
              style: GoogleFonts.barlow(
                  textStyle: const TextStyle(
                      color: Color(0xFF3D5269),
                      fontSize: 24,
                      fontWeight: FontWeight.bold))),
          backgroundColor: Colors.white,
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
            : SingleChildScrollView(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWide = constraints.maxWidth > 600;
                      return Container(
                        width: constraints.maxWidth * 0.6,
                        padding: EdgeInsets.only(
                            left: constraints.maxWidth * 0.07,
                            right: constraints.maxWidth * 0.07,
                            top: 16),
                        constraints: const BoxConstraints(
                          minWidth: 700.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3E9F4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            if (isScheduleActive)
                              const Text(
                                'Un cronograma ya ha sido establecido, puede actualizarlo si lo desea',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color(0xFF044086), fontSize: 20),
                              ),
                            const SizedBox(height: 25),
                            const Text(
                              'Horario de atención',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color(0xFF044086),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: customDecoration('Inicio'),
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
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: customDecoration('Fin'),
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
                              ],
                            ),
                            const SizedBox(height: 25),
                            const Text(
                              'Fecha límite',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color(0xFF044086),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: dateController,
                              decoration: customDecoration('Fecha'),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now()
                                      .add(const Duration(days: 1)),
                                  currentDate: DateTime.now()
                                      .add(const Duration(days: 1)),
                                  initialDate: DateTime.now()
                                      .add(const Duration(days: 1)),
                                  lastDate: DateTime(DateTime.now().year + 1,
                                      DateTime.now().month, DateTime.now().day),
                                );
                                if (pickedDate != null) {
                                  DateTime currentDate = DateTime.now();
                                  DateTime justDate = DateTime(currentDate.year,
                                      currentDate.month, currentDate.day);

                                  if (pickedDate.isAtSameMomentAs(justDate)) {
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
                            const SizedBox(height: 25),
                            const Text(
                              'Días de atención',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color(0xFF044086),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 300,
                              child: GridView.count(
                                crossAxisCount: isWide ? 5 : 2,
                                childAspectRatio: 1.0,
                                mainAxisSpacing: 20.0,
                                crossAxisSpacing: 20.0,
                                children: List.generate(5, (index) {
                                  return DayButton(
                                    day: [
                                      'Lunes',
                                      'Martes',
                                      'Miércoles',
                                      'Jueves',
                                      'Viernes'
                                    ][index],
                                    isSelected: isSelectedDays[index],
                                    onTap: () {
                                      setState(() {
                                        isSelectedDays[index] =
                                            !isSelectedDays[index];
                                      });
                                    },
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 20),
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
                                    if (dateController.text != '' &&
                                        isSelectedDays.contains(true)) {
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
                                                        child: ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              List<String>
                                                                  days =
                                                                  selectedDays(
                                                                      isSelectedDays);
                                                              try {
                                                                if (!isScheduleActive) {
                                                                  await datasource.addInterviewSchedule(
                                                                      days,
                                                                      startTime,
                                                                      endTime,
                                                                      dateController
                                                                          .text,
                                                                      'ACTIVE',
                                                                      DateTime
                                                                          .now(),
                                                                      DateTime
                                                                          .now());
                                                                } else {
                                                                  activeSchedule
                                                                          .days =
                                                                      days;
                                                                  activeSchedule
                                                                          .start_time =
                                                                      startTime;
                                                                  activeSchedule
                                                                          .end_time =
                                                                      endTime;
                                                                  activeSchedule
                                                                          .limit_date =
                                                                      dateController
                                                                          .text;
                                                                  activeSchedule
                                                                          .last_update =
                                                                      DateTime
                                                                          .now();
                                                                  await datasource
                                                                      .updateInterviewSchedule(
                                                                          activeSchedule);
                                                                }
                                                                // ignore: use_build_context_synchronously
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                // ignore: use_build_context_synchronously
                                                                showMessageDialog(
                                                                    context,
                                                                    'assets/ui/marque-el-circulo.png',
                                                                    'Correcto',
                                                                    'Accion realizada con éxito');
                                                              } catch (e) {
                                                                // ignore: use_build_context_synchronously
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
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
                                                            const EdgeInsets
                                                                .only(
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
                                    } else {
                                      showMessageDialog(
                                          context,
                                          'assets/ui/circulo-cruzado.png',
                                          'Error',
                                          'No olvide marcar la fecha límite y los días');
                                    }
                                  },
                                  child: const Text('Registrar',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                if (isScheduleActive)
                                  const SizedBox(
                                    width: 10,
                                  ),
                                if (isScheduleActive)
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
                                      if (dateController.text != '' &&
                                          isSelectedDays.contains(true)) {
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
                                                        '¿Estás seguro de que quieres eliminar el cronograma?',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF3D5269),
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                          child: ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                activeSchedule
                                                                        .status =
                                                                    'ELIMINATE';
                                                                activeSchedule
                                                                        .last_update =
                                                                    DateTime
                                                                        .now();
                                                                try {
                                                                  await datasource
                                                                      .updateInterviewSchedule(
                                                                          activeSchedule);
                                                                  // ignore: use_build_context_synchronously
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  // ignore: use_build_context_synchronously
                                                                  showMessageDialog(
                                                                      context,
                                                                      'assets/ui/marque-el-circulo.png',
                                                                      'Correcto',
                                                                      'Se ha eliminado el cronograma');
                                                                  setState(
                                                                      () {});
                                                                } catch (e) {
                                                                  // ignore: use_build_context_synchronously
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
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
                                                              const EdgeInsets
                                                                  .only(
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
                                      } else {
                                        showMessageDialog(
                                            context,
                                            'assets/ui/circulo-cruzado.png',
                                            'Error',
                                            'No olvide marcar la fecha límite y los días');
                                      }
                                    },
                                    child: const Text('Eliminar',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ));
  }
}

class DayButton extends StatelessWidget {
  final String day;
  final bool isSelected;
  final void Function()? onTap;

  const DayButton({
    super.key,
    required this.day,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF198754) : Colors.grey,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
