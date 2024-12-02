// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show window;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/report_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/interview_schedule_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/reports_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/pages/psychology/report_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_text_field.dart';

/*Pagina para registrar informe de psicologia

Contiene los campos necesarios correspondientes a la base de datos, cambio de horario de entrevista y demas
Falta incluir el estado de la entrevista o informe. Ejemplo: psicologia (si aun lo mantiene este rol), coordinacion si ya ha pasado a la siguiente fase y administracion


*/
class RegisterReport extends StatefulWidget {
  const RegisterReport({super.key});

  @override
  State<RegisterReport> createState() => _RegisterReport();
}

class _RegisterReport extends State<RegisterReport> {
  List<ReportModel> postulationsList = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  InterviewScheduleRemoteDatasourceImpl scheduleRemoteDatasourceImpl =
      InterviewScheduleRemoteDatasourceImpl();
  ReportRemoteDatasourceImpl reportRemoteDatasourceImpl =
      ReportRemoteDatasourceImpl();
  late TextEditingController _birthDayController;
  late TextEditingController _brothersInfoController;
  late TextEditingController _emotionCogInfoController;
  late TextEditingController _familiarDetailsController;
  late TextEditingController _fatherInfoController;
  late TextEditingController _finalTipController;
  late TextEditingController _fullnameController;
  late TextEditingController _gradeController;
  late TextEditingController _levelController;
  late TextEditingController _motherInfoController;
  late TextEditingController _observationsController;
  late TextEditingController _refCellphoneController;
  late TextEditingController _interviewHourController;
  late TextEditingController _interviewHourCoordController;
  late TextEditingController _ciController;
  late DateTime _selectedBirthDate = DateTime.now();
  late DateTime _selectedInterviewDate = DateTime.now();
  late String _cronologicalAge = '';
  late String _selectedInterviewHour = '';
  late String _defaultStatusReport;
  late TextEditingController _emailController;
  late DateTime _selectedCoordInterviewDate = DateTime.now();
  late String _selectedCoordInterviewHour = '';
  late String _ci = '';
  String? selectedLevel;
  String? selectedGrade;
  List<String> gradeOptions = [];


  @override
  void initState() {
    super.initState();
     _birthDayController = TextEditingController();
    _brothersInfoController = TextEditingController();
    _emotionCogInfoController = TextEditingController();
    _familiarDetailsController = TextEditingController();
    _fatherInfoController = TextEditingController();
    _finalTipController = TextEditingController();
    _fullnameController = TextEditingController();
    _gradeController = TextEditingController();
    _levelController = TextEditingController();
    _motherInfoController = TextEditingController();
    _observationsController = TextEditingController();
    _refCellphoneController = TextEditingController();
    _interviewHourController = TextEditingController();
    _selectedInterviewHour = '';
    _defaultStatusReport = 'Psicologia';
    _emailController = TextEditingController();
    _interviewHourCoordController = TextEditingController();
    _ciController = TextEditingController();
  }

  @override
  void dispose() {
     _birthDayController.dispose();
    _brothersInfoController.dispose();
    _emotionCogInfoController.dispose();
    _familiarDetailsController.dispose();
    _fatherInfoController.dispose();
    _finalTipController.dispose();
    _fullnameController.dispose();
    _gradeController.dispose();
    _levelController.dispose();
    _motherInfoController.dispose();
    _observationsController.dispose();
    _refCellphoneController.dispose();
    _interviewHourController.dispose();
    _emailController.dispose();
    _interviewHourCoordController.dispose();
    _ciController.dispose();
    super.dispose();

    super.dispose();
  }

  void _calculateChronologicalAge() {
  final currentDate = DateTime.now();
  final difference = currentDate.difference(_selectedBirthDate).inDays;
  final years = (difference / 365).floor();
  final months = ((difference % 365) / 30).floor();
  setState(() {
    _cronologicalAge = '$years años $months meses';
  });
}

  void submitForm() async {
  if (_formKey.currentState!.validate()) {
    // Construir el modelo de informe
    DateTime interviewDateTimestamp = _selectedInterviewDate;
    DateTime interviewDateCoordTimestamp = _selectedCoordInterviewDate;


      ReportModel report = ReportModel(
        fullname: _fullnameController.text,
        interview_date: interviewDateTimestamp,
        interview_hour: _selectedInterviewHour,
        interview_date_coord: interviewDateCoordTimestamp,
        interview_hour_coord: _selectedCoordInterviewHour,
        ci: _ciController.text,
        email: _emailController.text,
        birth_day: _selectedBirthDate,
        cronological_age: _cronologicalAge,
        familiar_details: _familiarDetailsController.text,
        mother_info: _motherInfoController.text,
        father_info: _fatherInfoController.text,
        brothers_info: _brothersInfoController.text,
        emotion_cog_info: _emotionCogInfoController.text,
        final_tip: _finalTipController.text,
        observations: _observationsController.text,
        ref_cellphone: _refCellphoneController.text,
        grade: selectedGrade ?? '',
        level: selectedLevel ?? '',
        status_report: _defaultStatusReport,
      );

    // Llamar al método para crear el informe en la base de datos
    String reportId = await reportRemoteDatasourceImpl.createReport(report);
    if (reportId.isNotEmpty) {
      // Mostrar un mensaje de éxito o navegar a otra pantalla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informe creado correctamente')),
      );
      // Reiniciar el formulario
      _formKey.currentState!.reset();
      setState(() {
        _selectedBirthDate = DateTime.now();
        _selectedInterviewDate = DateTime.now();
        _selectedCoordInterviewDate = DateTime.now();
        _cronologicalAge = '';
        selectedLevel = null;
        selectedGrade = null;
        gradeOptions = [];
      });
    } else {
      // Mostrar un mensaje de error si falla la creación del informe
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear el informe')),
      );
    }
  }
}



    
    @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulario'),
      ),
      body: Center(
        child:SizedBox(width: 1000,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
            child: Form(key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Registro',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _birthDayController,
                        decoration: InputDecoration(
                          labelText: 'Fecha de nacimiento',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedBirthDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null && pickedDate != _selectedBirthDate) {
                            setState(() {
                              _selectedBirthDate = pickedDate;
                              _birthDayController.text =
                                  DateFormat('dd/MM/yyyy').format(pickedDate);
                              _calculateChronologicalAge();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20.0),
                    const Text(
                      'Entrevista de Psicología',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        final selectedDateTime = await showDatePicker(
                          context: context,
                          initialDate: _selectedInterviewDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        if (selectedDateTime != null) {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                                _selectedInterviewDate ?? DateTime.now()),
                          );

                          if (selectedTime != null) {
                            setState(() {
                              _selectedInterviewDate = DateTime(
                                selectedDateTime.year,
                                selectedDateTime.month,
                                selectedDateTime.day,
                                selectedTime.hour,
                                selectedTime.minute,
                              );
                              _selectedInterviewHour =
                                  '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 8.0),
                            Text(
                              _selectedInterviewDate != null
                                  ? DateFormat('dd/MM/yyyy HH:mm').format(_selectedInterviewDate!)
                                  : 'Seleccionar fecha y hora',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Entrevista de Coordinación',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        final selectedDateTime = await showDatePicker(
                          context: context,
                          initialDate: _selectedCoordInterviewDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        if (selectedDateTime != null) {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                                _selectedCoordInterviewDate ?? DateTime.now()),
                          );

                          if (selectedTime != null) {
                            setState(() {
                              _selectedCoordInterviewDate = DateTime(
                                selectedDateTime.year,
                                selectedDateTime.month,
                                selectedDateTime.day,
                                selectedTime.hour,
                                selectedTime.minute,
                              );
                              _selectedCoordInterviewHour =
                                  '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 8.0),
                            Text(
                              _selectedCoordInterviewDate != null
                                  ? DateFormat('dd/MM/yyyy HH:mm').format(_selectedCoordInterviewDate!)
                                  : 'Seleccionar fecha y hora',
                            ),
                          ],
                        ),
                      ),
                    ),
                      SizedBox(height: 10.0),
                      Text('Edad cronológica: $_cronologicalAge'),
                      SizedBox(height: 10.0),
                      TextField(
                        controller: _brothersInfoController,
                        decoration: InputDecoration(
                          labelText: 'Información de hermanos',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        controller: _emotionCogInfoController,
                        decoration: InputDecoration(
                          labelText: 'Información emocional y cognitiva',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        controller: _familiarDetailsController,
                        decoration: InputDecoration(
                          labelText: 'Detalles familiares',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        controller: _fatherInfoController,
                        decoration: InputDecoration(
                          labelText: 'Información del padre',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        controller: _finalTipController,
                        decoration: InputDecoration(
                          labelText: 'Consejo final del entrevistador',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        controller: _fullnameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre completo',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        controller: _ciController,
                        decoration: InputDecoration(
                          labelText: 'Carnet de Identidad',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                      SizedBox(height: 10.0),
                       DropdownButtonFormField<String>(
                        value: selectedLevel,
                        hint: Text('Nivel'),
                        onChanged: (value) {
                          setState(() {
                            selectedLevel = value;
                            if (value == 'Inicial') {
                              gradeOptions = ['1ra seccion', '2da seccion'];
                              selectedGrade = null;
                            } else if (value == 'Primaria') {
                              gradeOptions = ['1er', '2do', '3er', '4to', '5to', '6to'];
                              selectedGrade = null;
                            } else if (value == 'Secundaria') {
                              gradeOptions = ['1er', '2do', '3er', '4to', '5to', '6to'];
                              selectedGrade = null;
                            }
                          });
                        },
                        items: ['Inicial', 'Primaria', 'Secundaria']
                            .map((label) => DropdownMenuItem(
                                  child: Text(label),
                                  value: label,
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 10.0),
                      DropdownButtonFormField<String>(
                        value: selectedGrade,
                        hint: Text('Grado'),
                        onChanged: (value) {
                          setState(() {
                            selectedGrade = value!;
                          });
                        },
                        items: gradeOptions
                            .map((label) => DropdownMenuItem(
                                  child: Text(label),
                                  value: label,
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        controller: _motherInfoController,
                        decoration: InputDecoration(
                          labelText: 'Información de la madre',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        controller: _observationsController,
                        decoration: InputDecoration(
                          labelText: 'Observaciones',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        controller: _refCellphoneController,
                        decoration: InputDecoration(
                          labelText: 'Número de celular de referencia',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                      SizedBox(height: 20.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            submitForm();
                          },
                          child: Text('Guardar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      )
      )
    );
  }
}
void main() {
  runApp(MaterialApp(
    title: 'Formulario',
    home: ReportPage(),
  ));
}