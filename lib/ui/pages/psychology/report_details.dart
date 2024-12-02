import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/notification_model.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/model/report_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/notifications_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/reports_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:fluttertoast/fluttertoast.dart';

/*
    Pagina para ver detalles del reporte psicologico
*/

class ReportDetails extends StatefulWidget {
  final String id;
  const ReportDetails({super.key, required this.id});

  @override
  State<ReportDetails> createState() => _ReportDetails();
}

class _ReportDetails extends State<ReportDetails> {
  ReportRemoteDatasourceImpl reportRemoteDatasourceImpl =
      ReportRemoteDatasourceImpl();
  PersonaDataSource _personaDataSource = PersonaDataSourceImpl();
  final NotificationRemoteDataSource notificationRemoteDataSource =
      NotificationRemoteDataSourceImpl();
  late ReportModel report;
  bool isLoading = true;
  String fatherUserName = '';
  String fatherPassword = '';
  String motherUserName = '';
  String motherPassword = '';
  late String _cronologicalAge = report.cronological_age;
  DateTime? _newInterviewDateTime;
  TextEditingController? birthDateController;
  final reportRemoteDataSource = ReportRemoteDatasourceImpl();

  Future<void> generatePdf(BuildContext context, ReportModel report) async {
    final pdf = pw.Document();

    pw.Widget _buildDataRow(String data) {
      List<String> parts = data.split(':');
      if (parts.length != 2) {
        return pw.Container(); // O manejar el error de alguna otra manera
      }

      String label = parts[0].trim();
      String value = parts[1].trim();

      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Container(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(label, style: pw.TextStyle(fontSize: 14)),
            ),
          ),
          pw.Expanded(
            child: pw.Container(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(value, style: pw.TextStyle(fontSize: 14)),
            ),
          ),
        ],
      );
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('Detalles de reporte - Psicología',
                    style: pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 10),
                pw.Text(
                    'Fecha de entrevista: ${DateFormat('dd/MM/yyyy').format(report.interview_date)} ${report.interview_hour}',
                    style: pw.TextStyle(fontSize: 14)),
                _buildDataRow('Nombre completo: ${report.fullname}'),
                _buildDataRow('Edad cronologica: ${report.cronological_age}'),
                _buildDataRow('Fecha de nacimiento: ${report.birth_day}'),
                _buildDataRow('Nivel: ${report.level}'),
                _buildDataRow('Grado: ${report.grade}'),
                _buildDataRow(
                    'Aspecto socioemocional y cognitivo: ${report.emotion_cog_info}'),
                _buildDataRow('Aspecto familiar: ${report.familiar_details}'),
                _buildDataRow('Datos de la madre: ${report.mother_info}'),
                _buildDataRow('Datos del padre: ${report.father_info}'),
                _buildDataRow('Datos de los hermanos: ${report.brothers_info}'),
                _buildDataRow('Sugerencia: ${report.final_tip}'),
                _buildDataRow('Observaciones: ${report.observations}'),
                _buildDataRow('Datos de contacto: ${report.ref_cellphone}'),
              ],
            ),
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
      ..setAttribute("download", "report_details_" + report.fullname + ".pdf")
      ..click();

    // Limpiar la URL creada
    html.Url.revokeObjectUrl(url);

    // Mostrar un mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('PDF generado exitosamente'),
    ));
  }

  void _showEditDialog(BuildContext context) {
    TextEditingController emotionCogInfoController =
        TextEditingController(text: report.emotion_cog_info);
    TextEditingController familiarDetailsController =
        TextEditingController(text: report.familiar_details);
    TextEditingController motherInfoController =
        TextEditingController(text: report.mother_info);
    TextEditingController fatherInfoController =
        TextEditingController(text: report.father_info);
    TextEditingController brothersInfoController =
        TextEditingController(text: report.brothers_info);
    TextEditingController finalTipController =
        TextEditingController(text: report.final_tip);
    TextEditingController observationsController =
        TextEditingController(text: report.observations);
    TextEditingController refCellphoneController =
        TextEditingController(text: report.ref_cellphone);
    TextEditingController statusReportController =
        TextEditingController(text: report.status_report);
    TextEditingController birthDateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(report.birth_day));
    TextEditingController emailController =
        TextEditingController(text: report.email);
    TextEditingController ciController = TextEditingController(text: report.ci);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar reporte'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emotionCogInfoController,
                  decoration: const InputDecoration(
                      labelText: 'Aspecto socioemocional y cognitivo'),
                ),
                TextFormField(
                  controller: birthDateController,
                  readOnly: true,
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: report.birth_day,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        report.birth_day = selectedDate;
                        birthDateController.text =
                            DateFormat('dd/MM/yyyy').format(selectedDate);
                        _cronologicalAge =
                            _calculateChronologicalAge(selectedDate);
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Fecha de nacimiento',
                  ),
                ),
                TextFormField(
                  controller: familiarDetailsController,
                  decoration:
                      const InputDecoration(labelText: 'Aspecto familiar'),
                ),
                TextFormField(
                  controller: motherInfoController,
                  decoration:
                      const InputDecoration(labelText: 'Datos de la madre'),
                ),
                TextFormField(
                  controller: fatherInfoController,
                  decoration:
                      const InputDecoration(labelText: 'Datos del padre'),
                ),
                TextFormField(
                  controller: brothersInfoController,
                  decoration:
                      const InputDecoration(labelText: 'Datos de los hermanos'),
                ),
                TextFormField(
                  controller: finalTipController,
                  decoration: const InputDecoration(labelText: 'Sugerencia'),
                ),
                TextFormField(
                  controller: observationsController,
                  decoration: const InputDecoration(labelText: 'Observaciones'),
                ),
                TextFormField(
                  controller: refCellphoneController,
                  decoration: const InputDecoration(
                      labelText: 'Número(s) de referencia'),
                ),
                TextFormField(
                  controller: emailController,
                  decoration:
                      const InputDecoration(labelText: 'Email de referencia'),
                ),
                TextFormField(
                  controller: ciController,
                  decoration:
                      const InputDecoration(labelText: 'Carnet de identidad'),
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
                  ReportModel updatedReport = ReportModel(
                    id: report.id,
                    fullname: report.fullname,
                    interview_date: report.interview_date,
                    interview_hour: report.interview_hour,
                    birth_day: report.birth_day,
                    cronological_age: _cronologicalAge,
                    grade: report.grade,
                    level: report.level,
                    familiar_details: familiarDetailsController.text!,
                    mother_info: motherInfoController.text!,
                    father_info: fatherInfoController.text!,
                    brothers_info: brothersInfoController.text!,
                    emotion_cog_info: emotionCogInfoController.text!,
                    final_tip: finalTipController.text!,
                    observations: observationsController.text!,
                    ref_cellphone: refCellphoneController.text!,
                    status_report: statusReportController.text!,
                    //cambiar despues solo es prueba!!
                    interview_date_coord: report.interview_date_coord,
                    interview_hour_coord: report.interview_hour_coord,
                    ci: ciController.text!,
                    email: emailController.text!,
                  );

                  // Llamar a updateReport con el objeto ReportModel actualizado
                  await reportRemoteDatasourceImpl.updateReport(updatedReport);

                  setState(() {
                    report = updatedReport;
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
    reportRemoteDatasourceImpl.getReportByID(widget.id).then((value) => {
          isLoading = true,
          report = value,
          if (mounted)
            {
              setState(() {
                isLoading = false;
                birthDateController = TextEditingController(
                    text: DateFormat('dd/MM/yyyy').format(report.birth_day));
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
        title: Text('Detalles de reporte - Psicología',
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
                                    initialDate: report.interview_date
                                            .isBefore(firstAllowedDate)
                                        ? DateTime.now()
                                        : report.interview_date,
                                    firstDate: firstAllowedDate,
                                    lastDate: DateTime(2100),
                                  );

                                  if (selectedDate != null) {
                                    final selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          report.interview_date),
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
                              '${DateFormat('dd/MM/yyyy').format(report.interview_date)} ${report.interview_hour}',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                            ElevatedButton(
                              onPressed: _newInterviewDateTime != null
                                  ? () async {
                                      try {
                                        // Actualizar la fecha y hora de la entrevista en Firebase
                                        await reportRemoteDatasourceImpl
                                            .updateInterviewDateTime(
                                          widget.id,
                                          _newInterviewDateTime!,
                                          TimeOfDay.fromDateTime(
                                                  _newInterviewDateTime!)
                                              .format(context),
                                        );

                                        // Actualizar el estado del widget con la nueva fecha y hora
                                        setState(() {
                                          report.interview_date =
                                              _newInterviewDateTime!;
                                          report.interview_hour =
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
                                  report.level,
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
                                  report.grade,
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
                                  '${report.fullname} ',
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
                                  '${report.ci} ',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 35,
                                ),
                                const Text(
                                  'Edad Cronológica: ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color(0xFF044086), fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${report.cronological_age} ',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 18),
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
                                      .format(report.birth_day),
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
                                            'Aspecto socioemocional y cognitivo: ',
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
                                              report.emotion_cog_info,
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
                                            'Aspecto familiar: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              report.familiar_details,
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
                                            'Datos de la madre: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              report.mother_info,
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
                                            'Datos del padre: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              report.father_info,
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
                                            'Datos de los hermanos: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              report.brothers_info,
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
                            const Text(
                              'Sugerencia: ',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color(0xFF044086), fontSize: 18),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              report.final_tip,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                            const Text(
                              'Observaciones: ',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color(0xFF044086), fontSize: 18),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              report.observations,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
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
                                          'Numero(s) de referencia: ',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Color(0xFF044086),
                                              fontSize: 18),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          report.ref_cellphone,
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
                                          report.email,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
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
                                          'Estado del reporte: ',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Color(0xFF044086),
                                              fontSize: 18),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          report.status_report,
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
                                        await reportRemoteDatasourceImpl
                                            .updateReportStatus(
                                          widget.id,
                                          'Coordinación',
                                        );

                                        setState(() {
                                          report.status_report = 'Coordinación';
                                        });

                                        showMessageDialog(
                                          context,
                                          'assets/ui/marque-el-circulo.png',
                                          'Correcto',
                                          'Se ha actualizado el estado a "Coordinación"',
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
                                      'Actualizar a Coordinación',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: ElevatedButton(
                                    onPressed:
                                        report.status_report != 'Administración'
                                            ? () => _showEditDialog(context)
                                            : null,
                                    // Si el status del informe es "Administración", onPressed es null y el botón se deshabilita
                                    child: const Text(
                                      'Editar',
                                      style: TextStyle(color: Colors.white),
                                    ),
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
                                          return Color.fromARGB(255, 74, 121,
                                              190); // Color del botón cuando está habilitado
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
                                                            await reportRemoteDatasourceImpl
                                                                .deleteReport(
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
          await generatePdf(context, report);
        },
        child: Icon(Icons.download),
      ),
    );
  }
}
