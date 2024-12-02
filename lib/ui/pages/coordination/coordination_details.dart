import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/notification_model.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/model/report_model.dart';
import 'package:pr_h23_irlandes_web/data/model/Coordinacion_Reports_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/notifications_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/reports_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/model/postulation_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/Coordinacion_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

/*
    Pagina para ver detalles del reporte psicologico
*/

class ReportCoordDetails extends StatefulWidget {
  final String id;
  const ReportCoordDetails({super.key, required this.id});

  @override
  State<ReportCoordDetails> createState() => _ReportCoordDetails();
}

class _ReportCoordDetails extends State<ReportCoordDetails> {
  CordinacionRemoteDatasourceImpl reportCoordRemoteDatasourceImpl =
      CordinacionRemoteDatasourceImpl();
  PersonaDataSource _personaDataSource = PersonaDataSourceImpl();
  final NotificationRemoteDataSource notificationRemoteDataSource =
      NotificationRemoteDataSourceImpl();
  late CoordinacionModel reportCoord;
  late PostulationModel reportPostulacion;
  bool isLoading = true;
  String fatherUserName = '';
  String fatherPassword = '';
  String motherUserName = '';
  String motherPassword = '';
  DateTime? _newInterviewDateTime;
  TextEditingController? birthDateController;
  final reportCoordRemoteDataSource = CordinacionRemoteDatasourceImpl();

  //funcion para enviar correos - prueba
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

  Future<void> generatePdf(
      BuildContext context, PostulationModel reportPostulacion) async {
    final pdf = pw.Document();

    // Cargar el logo desde los assets
    final ByteData logoData = await rootBundle.load('assets/images/logo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();

    // Función para construir una fila de datos en el PDF
    pw.Widget _buildDataRow(String label, String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            pw.Text(label,
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 8),
            pw.Flexible(
              child: pw.Text(value,
                  style: pw.TextStyle(fontSize: 14),
                  overflow: pw.TextOverflow.clip),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Logo
                pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(logoBytes), // Inserta el logo cargado
                    height: 80,
                  ),
                ),
                pw.SizedBox(height: 10),

                // Título principal
                pw.Center(
                  child: pw.Text(
                    'Detalles de Reporte - Postulación',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Información del postulante
                pw.Text(
                  'Información del Postulante',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                _buildDataRow('Nombre completo:',
                    '${reportPostulacion.student_name} ${reportPostulacion.student_lastname}'),
                _buildDataRow('Fecha de nacimiento:',
                    '${reportPostulacion.birth_day.toLocal()}'),
                _buildDataRow(
                    'Carnet de identidad:', reportPostulacion.student_ci),
                _buildDataRow('Correo electrónico de referencia:',
                    reportPostulacion.email),
                _buildDataRow('Nivel:', reportPostulacion.level),
                _buildDataRow('Grado:', reportPostulacion.grade),
                pw.SizedBox(height: 10),

                // Información familiar
                pw.Text(
                  'Información Familiar',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                _buildDataRow('Nombre de la madre:',
                    '${reportPostulacion.mother_name} ${reportPostulacion.mother_lastname}'),
                _buildDataRow('Teléfono de la madre:',
                    reportPostulacion.mother_cellphone),
                _buildDataRow('Nombre del padre:',
                    '${reportPostulacion.father_name} ${reportPostulacion.father_lastname}'),
                _buildDataRow(
                    'Teléfono del padre:', reportPostulacion.father_cellphone),
                _buildDataRow('Número de hermanos:',
                    reportPostulacion.amount_brothers.toString()),
                _buildDataRow(
                    'Teléfono familiar:', reportPostulacion.telephone),
                pw.SizedBox(height: 10),

                // Observaciones
                pw.Text(
                  'Observaciones',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                _buildDataRow(
                    'Observación de la postulación:', reportPostulacion.obs),
                pw.SizedBox(height: 10),

                // Visto Bueno y Respuesta
                pw.Divider(),
                _buildDataRow('Visto Bueno de Postulación:',
                    reportPostulacion.vistoBuenoCoordinacion),
                _buildDataRow(
                    'Respuesta a Ppff:', reportPostulacion.respuestaAPpff),
              ],
            ),
          );
        },
      ),
    );

    // Guardar el PDF como blob en memoria
    try {
      final Uint8List pdfBytes = await pdf.save();
      final blob = html.Blob([pdfBytes]);

      // Crear un URL del blob y abrir una ventana para descargar el archivo
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download",
            "Informe Postulación - ${reportPostulacion.student_name} ${reportPostulacion.student_lastname}.pdf")
        ..click();

      // Limpiar la URL creada
      html.Url.revokeObjectUrl(url);

      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF generado exitosamente'),
        ),
      );
    } catch (e) {
      // Mostrar un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar PDF: $e'),
        ),
      );
    }
  }

  void _showEditDialog(BuildContext context) {
    TextEditingController studentFullNameController =
        TextEditingController(text: reportCoord.studentFullName);
    TextEditingController ciController =
        TextEditingController(text: reportCoord.ci);
    TextEditingController previousSchoolController =
        TextEditingController(text: reportCoord.previousSchool);
    TextEditingController emailController =
        TextEditingController(text: reportCoord.email);
    TextEditingController motherNameController =
        TextEditingController(text: reportCoord.motherFullName);
    TextEditingController motherPhoneController =
        TextEditingController(text: reportCoord.motherPhoneNumber);
    TextEditingController fatherNameController =
        TextEditingController(text: reportCoord.fatherFullName);
    TextEditingController fatherPhoneController =
        TextEditingController(text: reportCoord.fatherPhoneNumber);
    TextEditingController siblingInfoController =
        TextEditingController(text: reportCoord.siblingDetails);
    TextEditingController familyPhoneController =
        TextEditingController(text: reportCoord.familyPhoneNumber);
    TextEditingController hasSiblingsController =
        TextEditingController(text: reportCoord.hasSiblings);
    TextEditingController obsCoordController =
        TextEditingController(text: reportCoord.obs_Cord);
    TextEditingController birthDateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(reportCoord.birthDate));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar reporte - Coordinación'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: studentFullNameController,
                  decoration: const InputDecoration(
                      labelText: 'Nombre completo del estudiante'),
                ),
                TextFormField(
                  controller: birthDateController,
                  readOnly: true,
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: reportCoord.birthDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        reportCoord.birthDate = selectedDate;
                        birthDateController.text =
                            DateFormat('dd/MM/yyyy').format(selectedDate);
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Fecha de nacimiento',
                  ),
                ),
                TextFormField(
                  controller: ciController,
                  decoration:
                      const InputDecoration(labelText: 'Carnet de identidad'),
                ),
                TextFormField(
                  controller: previousSchoolController,
                  decoration:
                      const InputDecoration(labelText: 'Colegio anterior'),
                ),
                TextFormField(
                  controller: emailController,
                  decoration:
                      const InputDecoration(labelText: 'Email de referencia'),
                ),
                TextFormField(
                  controller: motherNameController,
                  decoration: const InputDecoration(
                      labelText: 'Nombre completo de la madre'),
                ),
                TextFormField(
                  controller: motherPhoneController,
                  decoration: const InputDecoration(
                      labelText: 'Nro. teléfono de la madre'),
                ),
                TextFormField(
                  controller: fatherNameController,
                  decoration: const InputDecoration(
                      labelText: 'Nombre completo del padre'),
                ),
                TextFormField(
                  controller: fatherPhoneController,
                  decoration: const InputDecoration(
                      labelText: 'Nro. teléfono del padre'),
                ),
                TextFormField(
                  controller: siblingInfoController,
                  decoration: const InputDecoration(
                      labelText: 'Información de los hermanos'),
                ),
                TextFormField(
                  controller: familyPhoneController,
                  decoration: const InputDecoration(
                      labelText: 'Nro. teléfono familiar'),
                ),
                TextFormField(
                  controller: hasSiblingsController,
                  decoration:
                      const InputDecoration(labelText: '¿Tiene hermanos?'),
                ),
                TextFormField(
                  controller: obsCoordController,
                  decoration: const InputDecoration(
                      labelText: 'Observación de coordinación'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  CoordinacionModel updatedReport = CoordinacionModel(
                      id: reportCoord.id,
                      studentFullName: studentFullNameController.text,
                      interview_date_cord: reportCoord.interview_date_cord,
                      interview_hour_cord: reportCoord.interview_hour_cord,
                      birthDate: reportCoord.birthDate,
                      course: reportCoord.course,
                      level: reportCoord.level,
                      email: emailController.text!,
                      previousSchool: previousSchoolController.text!,
                      hasSiblings: hasSiblingsController.text!,
                      siblingDetails: siblingInfoController.text!,
                      fatherFullName: fatherNameController.text!,
                      fatherPhoneNumber: fatherPhoneController.text!,
                      motherFullName: motherNameController.text!,
                      motherPhoneNumber: motherPhoneController.text!,
                      familyPhoneNumber: familyPhoneController.text!,
                      ci: ciController.text!,
                      interview_date_psicologia:
                          reportCoord.interview_date_psicologia,
                      interview_hour_psicologia:
                          reportCoord.interview_hour_psicologia,
                      obs_Psychology: reportCoord.obs_Psychology,
                      obs_Cord: obsCoordController.text!,
                      interview_date_admin: reportCoord.interview_date_admin,
                      interview_hour_admin: reportCoord.interview_hour_admin,
                      obs_Admin: reportCoord.obs_Admin,
                      registrationDate: reportCoord.registrationDate,
                      reasonMissAppointment: '',
                      reasonRescheduleAppointment: '');

                  // Llamar a updateReport con el objeto ReportModel actualizado
                  await reportCoordRemoteDatasourceImpl
                      .updateReportCoord(updatedReport);

                  setState(() {
                    reportCoord = updatedReport;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Informe modificado correctamente')));
                  }); // Actualizar el estado después de editar
                  Navigator.of(context).pop();
                } catch (e) {
                  print(e);
                  showMessageDialog(
                    context,
                    'assets/ui/circulo-cruzado.png',
                    'Error',
                    'Ha ocurrido un error inesperado',
                  );
                }
              },
              child: const Text('Guardar cambios'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    reportCoordRemoteDatasourceImpl
        .getReportCordByID(widget.id)
        .then((value) => {
              isLoading = true,
              reportCoord = value,
              if (mounted)
                {
                  setState(() {
                    isLoading = false;
                    birthDateController = TextEditingController(
                        text: DateFormat('dd/MM/yyyy')
                            .format(reportCoord.birthDate));
                  })
                }
            });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _calculateChronologicalAge(DateTime birthDate) {
    final currentDate = DateTime.now();
    final difference = currentDate.difference(birthDate).inDays;
    final years = (difference / 365).floor();
    final months = ((difference % 365) / 30).floor();
    return '$years años $months meses';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Detalles de reporte - Coordinación',
            style: GoogleFonts.barlow(
                textStyle: const TextStyle(
                    color: Color(0xFF3D5269),
                    fontSize: 24,
                    fontWeight: FontWeight.bold))),
        toolbarHeight: 75,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth * 0.7,
                    constraints: const BoxConstraints(
                      minWidth: 1400.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E9F4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(100),
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
                                    initialDate: reportCoord.interview_date_cord
                                            .isBefore(firstAllowedDate)
                                        ? DateTime.now()
                                        : reportCoord.interview_date_cord,
                                    firstDate: firstAllowedDate,
                                    lastDate: DateTime(2100),
                                  );

                                  if (selectedDate != null) {
                                    final selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          reportCoord.interview_date_cord),
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
                              '${DateFormat('dd/MM/yyyy').format(reportCoord.interview_date_cord)} ${reportCoord.interview_hour_cord}',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                            ElevatedButton(
                              onPressed: _newInterviewDateTime != null
                                  ? () async {
                                      try {
                                        // Actualizar la fecha y hora de la entrevista en Firebase
                                        await reportCoordRemoteDatasourceImpl
                                            .updateInterviewCordDateTime(
                                          widget.id,
                                          _newInterviewDateTime!,
                                          TimeOfDay.fromDateTime(
                                                  _newInterviewDateTime!)
                                              .format(context),
                                        );

                                        // Actualizar el estado del widget con la nueva fecha y hora
                                        setState(() {
                                          reportCoord.interview_date_cord =
                                              _newInterviewDateTime!;
                                          reportCoord.interview_hour_cord =
                                              TimeOfDay.fromDateTime(
                                                      _newInterviewDateTime!)
                                                  .format(context);
                                          _newInterviewDateTime = null;
                                        });
                                        // Enviar el correo electrónico notificando la actualización
                                        await sendEmail(
                                          reportCoord
                                              .email, // Reemplaza con el correo del destinatario
                                          'Actualización de la Fecha de Entrevista',
                                          'La fecha de la entrevista se ha actualizado a ${reportCoord.interview_date_cord} a las ${reportCoord.interview_hour_cord} para el departamento de Coordinación.',
                                        );
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
                                        //print('Error updating interview date/time: $e');
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
                                  reportCoord.level,
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
                                  reportCoord.course,
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
                                  'Nombre Completo: ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color(0xFF044086), fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${reportCoord.studentFullName} ',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                                const Text(
                                  'Carnet de Identidad: ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color(0xFF044086), fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${reportCoord.ci} ',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 35,
                                ),
                                const Text(
                                  'Fecha nacimiento: ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color(0xFF044086), fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(reportCoord.birthDate),
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
                                'Detalles',
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
                                  padding: const EdgeInsets.all(20.0),
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
                                            'Observación psicología: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: Text(
                                              reportCoord.obs_Psychology,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 35),
                                          const Text(
                                            'Observación coordinación: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              reportCoord.obs_Cord,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 35),
                                          const Text(
                                            'Observación administración: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              reportCoord.obs_Admin,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 35),
                                          const Text(
                                            'Nombre del padre: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              reportCoord.fatherFullName,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 35),
                                          const Text(
                                            'Nombre de la madre: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              reportCoord.motherFullName,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 35),
                                          const Text(
                                            'Teléfono de la madre: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              reportCoord.motherPhoneNumber,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 35),
                                          const Text(
                                            'Tiene hermanos: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              reportCoord.hasSiblings,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 35),
                                          const Text(
                                            'Información de hermanos: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              reportCoord.siblingDetails,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          width: 35,
                                        ),
                                        const Text(
                                          'Email de referencia: ',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Color(0xFF044086),
                                              fontSize: 18),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          reportCoord.email,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: 35),
                                        const Text(
                                          'Telefono del padre: ',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Color(0xFF044086),
                                              fontSize: 18),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            reportCoord.fatherPhoneNumber,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: 35),
                                        const Text(
                                          'Telefono de la madre: ',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Color(0xFF044086),
                                              fontSize: 18),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            reportCoord.motherPhoneNumber,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                        height: 10), // Espacio entre las filas
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          width: 35,
                                        ),
                                        const Text(
                                          'Teléfono familiar: ',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Color(0xFF044086),
                                              fontSize: 18),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          reportCoord.familyPhoneNumber,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await reportCoordRemoteDatasourceImpl
                                            .updateReportCordStatus(
                                          widget.id,
                                          'Administración',
                                        );

                                        setState(() {
                                          reportCoord.estadoRevisado =
                                              'Administración';
                                        });

                                        showMessageDialog(
                                          context,
                                          'assets/ui/marque-el-circulo.png',
                                          'Correcto',
                                          'Se ha actualizado el estado a "Administración"',
                                        );
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
                                          MaterialStateProperty.all(
                                        const Color(0xFF28a745), // Verde
                                      ),
                                    ),
                                    child: const Text(
                                      'Actualizar a Administración',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await reportCoordRemoteDatasourceImpl
                                            .updateReportCordInterviewStatus(
                                          widget.id,
                                          'Confirmado',
                                        );
                                        // Enviar el correo electrÃ³nico notificando la actualizaciÃ³n
                                        String formattedDate =
                                            DateFormat('yyyy-MM-dd').format(
                                                reportCoord
                                                    .interview_date_cord);
                                        String messagetosend =
                                            'Estimado/a Padre/Madre/Tutor,\n\n'
                                            'Nos complace informarle que la fecha de la entrevista ha sido confirmada para el día $formattedDate a las ${reportCoord.interview_hour_cord} para el departamento de Coordinacion.\n\n'
                                            'Le agradecemos su puntualidad y quedamos a su disposición para cualquier consulta.\n\n'
                                            'Atentamente,\n'
                                            'Colegio Esclavas del Sagrado Corazón de Jesús';
                                        await sendEmail(
                                          reportCoord
                                              .email, // Reemplaza con el correo del destinatario
                                          'ConfirmaciÃ³n de entrevista',
                                          messagetosend,
                                        );

                                        setState(() {
                                          reportCoord.estadoConfirmado =
                                              'Confirmado';
                                        });

                                        showMessageDialog(
                                          context,
                                          'assets/ui/marque-el-circulo.png',
                                          'Correcto',
                                          'Se ha actualizado el estado de la entrevista a "Confirmado"',
                                        );
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
                                          MaterialStateProperty.all(
                                        Color.fromARGB(
                                            255, 40, 74, 167), // Verde
                                      ),
                                    ),
                                    child: const Text(
                                      'Confirmar entrevista',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: ElevatedButton(
                                    onPressed: reportCoord.estadoRevisado !=
                                            'Administración'
                                        ? () => _showEditDialog(context)
                                        : null,
                                    // Si el status del informe es "Administración", onPressed es null y el botón se deshabilita
                                    child: const Text('Editar'),
                                    // El botón se deshabilita si el status del informe es "Administración"
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                          if (states.contains(
                                              MaterialState.disabled)) {
                                            return Colors
                                                .grey; // Color del botón cuando está deshabilitado
                                          }
                                          return Colors
                                              .blue; // Color del botón cuando está habilitado
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: ElevatedButton(
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
                                                  '¿Estás seguro de que quieres eliminar el informe?',
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
                                                            await reportCoordRemoteDatasourceImpl
                                                                .deleteReportCord(
                                                                    widget.id);
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            showMessageDialog(
                                                              context,
                                                              'assets/ui/marque-el-circulo.png',
                                                              'Correcto',
                                                              'Se ha eliminado el reporte',
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
                                                                  .all(
                                                            const Color(
                                                                0xFF044086),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'Si',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
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
                                                                  .all(
                                                            const Color(
                                                                0xFF044086),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'No',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
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
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        const Color(0xFFd9534f), // Rojo
                                      ),
                                    ),
                                    child: const Text('Eliminar',
                                        style: TextStyle(color: Colors.white)),
                                  ),
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
          await generatePdf(context, reportPostulacion);
        },
        child: Icon(Icons.download),
      ),
    );
  }
}
