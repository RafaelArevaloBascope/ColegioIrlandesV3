import 'package:flutter/material.dart';
import 'package:pr_h23_irlandes_web/data/model/calls_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/calls_remote_datasource.dart';

class EditAttentionCallPage extends StatefulWidget {
  final String callId;

  const EditAttentionCallPage({Key? key, required this.callId}) : super(key: key);

  @override
  _EditAttentionCallPageState createState() => _EditAttentionCallPageState();
}

class _EditAttentionCallPageState extends State<EditAttentionCallPage> {
  final AttentionCallsRemoteDataSource _attentionCallsDataSource = AttentionCallsRemoteDataSource();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController studentController;
  late TextEditingController teacherController;
  late TextEditingController motiveController;
  String level = 'Cualquiera';
  String course = 'Cualquiera';
  List<String> gradeList = ['Cualquiera'];
  bool isLoading = true;
  AttentionCallsModel? currentCall;

  @override
  void initState() {
    super.initState();
    _loadCallDetails();
  }

  Future<void> _loadCallDetails() async {
    List<AttentionCallsModel> allCalls = await _attentionCallsDataSource.getAttentionCalls();
    currentCall = allCalls.firstWhere((call) => call.id == widget.callId);

    setState(() {
      studentController = TextEditingController(text: currentCall?.student);
      teacherController = TextEditingController(text: currentCall?.teacher);
      motiveController = TextEditingController(text: currentCall?.motive);
      level = currentCall?.level ?? 'Cualquiera';
      course = currentCall?.course ?? 'Cualquiera';
      isLoading = false;

      // Actualizar la lista de cursos según el nivel
      _updateGradeList(level);
    });
  }

  void _updateGradeList(String level) {
    switch (level) {
      case 'Inicial':
        gradeList = ['Cualquiera', '1ra sección', '2da sección'];
        break;
      case 'Primaria':
      case 'Secundaria':
        gradeList = ['Cualquiera', '1er', '2do', '3er', '4to', '5to', '6to'];
        break;
      default:
        gradeList = ['Cualquiera'];
    }
  }

  void _updateCall() async {
    if (_formKey.currentState!.validate()) {
      AttentionCallsModel updatedCall = AttentionCallsModel(
        id: widget.callId,
        student: studentController.text,
        teacher: teacherController.text,
        motive: motiveController.text,
        level: level,
        course: course,
        studentId: currentCall!.studentId,
        registrationDate: currentCall!.registrationDate,
      );

      await _attentionCallsDataSource.updateCall(widget.callId, updatedCall);
      Navigator.pop(context, true); // Volver a la página anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: const Text('Editar Llamada de Atención'),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ),
  body: isLoading
      ? const Center(child: CircularProgressIndicator())
      : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Center( // Added Center widget to center everything
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust horizontal padding
                child: ListView(
                  shrinkWrap: true,  // Ensures the ListView takes only necessary space
                  children: [
                    TextFormField(
                      controller: studentController,
                      decoration: const InputDecoration(
                        labelText: 'Estudiante',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 50,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre del estudiante';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: teacherController,
                      decoration: const InputDecoration(
                        labelText: 'Profesor',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 50,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre del profesor';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: motiveController,
                      decoration: const InputDecoration(
                        labelText: 'Motivo',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      maxLength: 150,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el motivo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: level,
                      decoration: const InputDecoration(
                        labelText: 'Nivel',
                        border: OutlineInputBorder(),
                      ),
                      isDense: true, // Makes the field more compact
                      items: ['Cualquiera', 'Inicial', 'Primaria', 'Secundaria']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Center(child: Text(value)), // Centers the dropdown text
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          level = value!;
                          _updateGradeList(level);
                          course = 'Cualquiera'; // Reset course
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: course,
                      decoration: const InputDecoration(
                        labelText: 'Curso',
                        border: OutlineInputBorder(),
                      ),
                      isDense: true, // Makes the field more compact
                      items: gradeList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Center(child: Text(value)), // Centers the dropdown text
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          course = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _updateCall,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Actualizar'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Cancelar'),
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
