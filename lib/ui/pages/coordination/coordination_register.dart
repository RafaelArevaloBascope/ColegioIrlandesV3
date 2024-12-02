import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/Coordinacion_Reports_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/Coordinacion_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/pages/coordination/Coordination_Page.dart';

class RegisterCoordinacionReport extends StatefulWidget {
  const RegisterCoordinacionReport({super.key});

  @override
  _RegisterCoordinacionReportState createState() => _RegisterCoordinacionReportState();
}

class _RegisterCoordinacionReportState extends State<RegisterCoordinacionReport> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();             
  final CordinacionRemoteDatasourceImpl coordinacionRemoteDatasourceImpl = CordinacionRemoteDatasourceImpl();

  late TextEditingController _emailController;

  late TextEditingController _previousSchoolController;
  late TextEditingController _hasSiblingsController;
  late TextEditingController _siblingDetailsController;
  late TextEditingController _studentFullNameController;
  late TextEditingController _ciController;
  late DateTime _birthDate = DateTime.now();
  late TextEditingController _fatherFullNameController;
  late TextEditingController _fatherPhoneNumberController;
  late TextEditingController _motherFullNameController;
  late TextEditingController _motherPhoneNumberController;
  late TextEditingController _familyPhoneNumberController;

  // Psicología
  late DateTime _interviewDatePsicologia = DateTime.now();
  late TextEditingController _interviewHourPsicologiaController;
  late TextEditingController _obsPsychologyController;

  // Coordinación
  late DateTime _interviewDateCord = DateTime.now();
  late TextEditingController _interviewHourCordController;
  late TextEditingController _obsCordController;

  // Administración
  late DateTime _interviewDateAdmin = DateTime.now();
  late TextEditingController _interviewHourAdminController;
  late TextEditingController _obsAdminController;

  // Default values
  final String estadoRevisado = 'coordinacion';
  final String estadoConfirmado = 'pendiente';
  final String approvedAdm = 'no revisado';
  final DateTime registrationDate = DateTime.now();


 late String _cronologicalAge = '';
  String? selectedLevel;
  String? selectedGrade;
  List<String> gradeOptions = [];
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _previousSchoolController = TextEditingController();
    _hasSiblingsController = TextEditingController();
    _siblingDetailsController = TextEditingController();
    _studentFullNameController = TextEditingController();
    _ciController = TextEditingController();
    _fatherFullNameController = TextEditingController();
    _fatherPhoneNumberController = TextEditingController();
    _motherFullNameController = TextEditingController();
    _motherPhoneNumberController = TextEditingController();
    _familyPhoneNumberController = TextEditingController();
    _interviewHourPsicologiaController = TextEditingController();
    _obsPsychologyController = TextEditingController();
    _interviewHourCordController = TextEditingController();
    _obsCordController = TextEditingController();
    _interviewHourAdminController = TextEditingController();
    _obsAdminController = TextEditingController();
  }
void _clearTextControllers() {
  _emailController.clear();
  _previousSchoolController.clear();
  _hasSiblingsController.clear();
  _siblingDetailsController.clear();
  _studentFullNameController.clear();
  _ciController.clear();
  _fatherFullNameController.clear();
  _fatherPhoneNumberController.clear();
  _motherFullNameController.clear();
  _motherPhoneNumberController.clear();
  _familyPhoneNumberController.clear();
  _interviewHourPsicologiaController.clear();
  _obsPsychologyController.clear();
  _interviewHourCordController.clear();
  _obsCordController.clear();
  _interviewHourAdminController.clear();
  _obsAdminController.clear();
}
  @override
  void dispose() {
    _emailController.dispose();
    _previousSchoolController.dispose();
    _hasSiblingsController.dispose();
    _siblingDetailsController.dispose();
    _studentFullNameController.dispose();
    _ciController.dispose();
    _fatherFullNameController.dispose();
    _fatherPhoneNumberController.dispose();
    _motherFullNameController.dispose();
    _motherPhoneNumberController.dispose();
    _familyPhoneNumberController.dispose();
    _interviewHourPsicologiaController.dispose();
    _obsPsychologyController.dispose();
    _interviewHourCordController.dispose();
    _obsCordController.dispose();
    _interviewHourAdminController.dispose();
    _obsAdminController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      CoordinacionModel newReport = CoordinacionModel(
        email: _emailController.text,
        level: selectedLevel ?? '',
        course: selectedGrade ?? '',
        previousSchool: _previousSchoolController.text,
        hasSiblings: _hasSiblingsController.text,
        siblingDetails: _siblingDetailsController.text,
        studentFullName: _studentFullNameController.text,
        ci: _ciController.text,
        birthDate: _birthDate,
        fatherFullName: _fatherFullNameController.text,
        fatherPhoneNumber: _fatherPhoneNumberController.text,
        motherFullName: _motherFullNameController.text,
        motherPhoneNumber: _motherPhoneNumberController.text,
        familyPhoneNumber: _familyPhoneNumberController.text,
        interview_date_psicologia: _interviewDatePsicologia,
        interview_hour_psicologia: _interviewHourPsicologiaController.text,
        obs_Psychology: _obsPsychologyController.text,
        interview_date_cord: _interviewDateCord,
        interview_hour_cord: _interviewHourCordController.text,
        obs_Cord: _obsCordController.text,
        interview_date_admin: _interviewDateAdmin,
        interview_hour_admin: _interviewHourAdminController.text,
        obs_Admin: _obsAdminController.text,
        estadoRevisado: estadoRevisado,
        estadoConfirmado: estadoConfirmado,
        approvedAdm: approvedAdm,
        registrationDate: registrationDate,
          reasonMissAppointment: '',
          reasonRescheduleAppointment:''
      );

      try {
        await coordinacionRemoteDatasourceImpl.createReportCord(newReport);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report successfully created')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create report: $e')),
        );
      }
    }
  }
      void _calculateChronologicalAge() {
      final currentDate = DateTime.now();
      final difference = currentDate.difference(_birthDate).inDays;
      final years = (difference / 365).floor();
      final months = ((difference % 365) / 30).floor();
      setState(() {
        _cronologicalAge = '$years años $months meses';
      });
    }

    Future<void> _selectDateTime(BuildContext context, DateTime initialDate, Function(DateTime) onDateTimeSelected) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime.now(), // Restringe las fechas anteriores al día de hoy
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != initialDate) {
        onDateTimeSelected(picked);
      }
}

  Widget _buildTextFormField(TextEditingController controller, String labelText, String validatorText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        return null;
      },
    );
  }


 @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Registro Reporte de Coordinación'),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600), // Establece un ancho máximo para el formulario
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
            _buildTextFormField(_emailController, 'Email', 'Por favor, ingrese el email'),
            DropdownButtonFormField<String>(
              value: selectedLevel,
              hint: Text('Nivel'),
              onChanged: (value) {
                setState(() {
                  selectedLevel = value;
                  if (value == 'Inicial') {
                    gradeOptions = ['1ra seccion', '2da seccion'];
                    selectedGrade = '1ra seccion'; // Asigna el primer grado cuando cambia el nivel
                  } else if (value == 'Primaria' || value == 'Secundaria') {
                    gradeOptions = ['1er', '2do', '3er', '4to', '5to', '6to'];
                    selectedGrade = '1er'; // Asigna el primer grado cuando cambia el nivel
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
              _buildTextFormField(_previousSchoolController, 'Escuela anterior', 'Por favor, ingrese la escuela anterior'),
              _buildTextFormField(_hasSiblingsController, '¿Tiene hermanos?si/no', 'Por favor, ingrese si tiene hermanos'),
              _buildTextFormField(_siblingDetailsController, 'si/Detalles de hermanos/no/(no tiene)', 'Por favor, ingrese los detalles de hermanos'),
              _buildTextFormField(_studentFullNameController, 'Nombre completo del estudiante', 'Por favor, ingrese el nombre completo del estudiante'),
              _buildTextFormField(_ciController, 'CI', 'Por favor, ingrese el CI'),
              GestureDetector(
                  onTap: () => _selectDateTime(context, _birthDate, (date) {
                    setState(() {
                      _birthDate = date;
                      _calculateChronologicalAge(); // Calcular la edad cronológica cuando se selecciona la fecha de nacimiento
                    });
                  }),
                  child: AbsorbPointer(
                    child: _buildTextFormField(
                      TextEditingController(text: DateFormat('dd/MM/yyyy').format(_birthDate)),
                      'Fecha de nacimiento',
                      'Por favor, seleccione la fecha de nacimiento',
                    ),
                  ),
                ),
              _buildTextFormField(_fatherFullNameController, 'Nombre completo del padre', 'Por favor, ingrese el nombre completo del padre'),
              _buildTextFormField(_fatherPhoneNumberController, 'Número de teléfono del padre', 'Por favor, ingrese el número de teléfono del padre'),
              _buildTextFormField(_motherFullNameController, 'Nombre completo de la madre', 'Por favor, ingrese el nombre completo de la madre'),
              _buildTextFormField(_motherPhoneNumberController, 'Número de teléfono de la madre', 'Por favor, ingrese el número de teléfono de la madre'),
              _buildTextFormField(_familyPhoneNumberController, 'Número de teléfono de la familia', 'Por favor, ingrese el número de teléfono de la familia'),
              GestureDetector(
                onTap: () => _selectDateTime(context, _interviewDatePsicologia, (date) {
                  setState(() {
                    _interviewDatePsicologia = date;
                  });
                }),
                child: AbsorbPointer(
                  child: _buildTextFormField(
                    TextEditingController(text: DateFormat('dd/MM/yyyy').format(_interviewDatePsicologia)),
                    'Fecha de entrevista psicología',
                    'Por favor, seleccione la fecha de entrevista de psicología',
                  ),
                ),
              ),
              _buildTextFormField(_interviewHourPsicologiaController, 'Hora de entrevista psicología', 'Por favor, ingrese la hora de entrevista de psicología'),
              _buildTextFormField(_obsPsychologyController, 'Observaciones psicología', 'Por favor, ingrese las observaciones de psicología'),
              GestureDetector(
                onTap: () => _selectDateTime(context, _interviewDateCord, (date) {
                  setState(() {
                    _interviewDateCord = date;
                  });
                }),
                child: AbsorbPointer(
                  child: _buildTextFormField(
                    TextEditingController(text: DateFormat('dd/MM/yyyy').format(_interviewDateCord)),
                    'Fecha de entrevista coordinación',
                    'Por favor, seleccione la fecha de entrevista de coordinación',
                  ),
                ),
              ),
              _buildTextFormField(_interviewHourCordController, 'Hora de entrevista coordinación', 'Por favor, ingrese la hora de entrevista de coordinación'),
              _buildTextFormField(_obsCordController, 'Observaciones coordinación', 'Por favor, ingrese las observaciones de coordinación'),
              GestureDetector(
                    onTap: () => _selectDateTime(
                      context,
                      _interviewDateAdmin,
                      (date) {
                        setState(() {
                          _interviewDateAdmin = date;
                        });
                      },
                    ),
                    child: AbsorbPointer(
                      child: _buildTextFormField(
                        TextEditingController(text: DateFormat('dd/MM/yyyy').format(_interviewDateAdmin)),
                        'Fecha de entrevista administración',
                        'Por favor, seleccione la fecha de entrevista de administración',
                      ),
                    ),
                  ),

              _buildTextFormField(_interviewHourAdminController, 'Hora de entrevista administración', 'Por favor, ingrese la hora de entrevista de administración'),
              _buildTextFormField(_obsAdminController, 'Observaciones administración', 'Por favor, ingrese las observaciones de administración'),
                     SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Regitrar formulario
                    _submitForm();
                    // Limpieza de los controladores 
                    _clearTextControllers();
                  },
                  child: Text(
                      'Guardar Reporte',
                      style: TextStyle(
                        color: Colors.white, // Color del texto blanco
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF044086)),
                    ),
                    
                ),
                 ElevatedButton(
                     onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
                Navigator.pushNamed(context, '/Coordination_Page');
                  },
                  child: Text(
                      'Cancelar Reporte',
                      style: TextStyle(
                        color: Colors.white, // Color del texto blanco
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 202, 10, 10)),
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

void main() {
  runApp(MaterialApp(
    title: 'Formulario',
    home: CoordinacionPage(),
  ));
}