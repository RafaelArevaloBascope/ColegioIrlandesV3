import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/License_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/license_remote_datasource.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

class LicenseVerification extends StatefulWidget {
  final String id;
  final String? action;
  const LicenseVerification({super.key, required this.id, this.action});

  @override
  State<LicenseVerification> createState() => _LicenseVerification();
}

class _LicenseVerification extends State<LicenseVerification> {
  LicenseRemoteDatasourceImpl licenseRemoteDatasourceImpl =
      LicenseRemoteDatasourceImpl();
  final _screenshotController = ScreenshotController();

  Future<LicenseModel> refreshLicenses(String id) async {
    return licenseRemoteDatasourceImpl.getLicenseByID(id);
  }

  String formatDate(String date) {
    DateFormat inputFormat = DateFormat("MMM d, yyyy", "en_US");
    DateTime inputDate = inputFormat.parse(date);

    // Formateando la fecha al formato deseado
    String formattedDate =
        DateFormat("dd 'de' MMMM 'de' yyyy", 'es_ES').format(inputDate);
    return formattedDate;
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(label,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(width: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 14)),
      ],
    );
  }

  Future<void> _generatePdf(BuildContext context, LicenseModel license) async {
    final pdf = pw.Document();

    // Carga el logo desde los assets
    final logoData = await rootBundle.load('assets/ui/logo.png');
    final logo = logoData.buffer.asUint8List();

    // Captura la imagen de la justificación, si existe
    Uint8List? screenshot;
    if (license.justification.isNotEmpty) {
      try {
        screenshot = await _screenshotController.capture();
      } catch (e) {
        // Maneja el error de captura si es necesario
        print('Error capturando la justificación: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Contenido principal centrado
              pw.Center(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Título centrado
                    pw.Center(
                      child: pw.Text(
                        'Detalles de la Licencia',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.SizedBox(height: 16),

                    // Línea separadora
                    pw.Divider(thickness: 1),

                    // Información del estudiante
                    pw.SizedBox(height: 8),
                    _buildInfoRow('Estudiante:',
                        '${license.user!.name} ${license.user!.lastname} ${license.user!.surname}'),
                    _buildInfoRow('Curso:', license.user!.grade),
                    _buildInfoRow('Fecha:', formatDate(license.license_date)),
                    _buildInfoRow('De:', license.departure_time),
                    _buildInfoRow('Hasta:', license.return_time),
                    _buildInfoRow('Motivo:', license.reason),
                    pw.SizedBox(height: 16),

                    // Justificación
                    if (license.justification.isNotEmpty && screenshot != null)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Justificación:',
                            style: pw.TextStyle(
                                fontSize: 16, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Image(pw.MemoryImage(screenshot),
                              width: 200, height: 150),
                        ],
                      ),
                    if (license.justification.isEmpty)
                      pw.Text(
                        'El usuario no subió un justificativo',
                        style: pw.TextStyle(
                            fontSize: 14, fontStyle: pw.FontStyle.italic),
                      ),
                  ],
                ),
              ),

              // Logo en la esquina superior derecha
              pw.Positioned(
                top: 0,
                right: 0,
                child: pw.Image(
                  pw.MemoryImage(logo),
                  width: 50, // Ajusta el tamaño del logo según tus necesidades
                ),
              ),
            ],
          );
        },
      ),
    );

    // Guarda el PDF como blob en memoria
    final Uint8List pdfBytes = await pdf.save();
    final blob = html.Blob([pdfBytes]);

    // Crea un URL del blob y abre una ventana para descargar el archivo
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "license.pdf")
      ..click();

    // Limpia la URL creada
    html.Url.revokeObjectUrl(url);

    // Muestra un mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('PDF generado exitosamente'),
    ));
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
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final leftPadding = screenWidth * 0.075;
    final rightPadding = screenWidth * 0.075;

    String formatDate(String date) {
      DateFormat inputFormat = DateFormat("MMM d, yyyy", "en_US");
      DateTime inputDate = inputFormat.parse(date);

      // Formateando la fecha al formato deseado
      String formattedDate =
          DateFormat("dd 'de' MMMM 'de' yyyy", 'es_ES').format(inputDate);
      return formattedDate;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE3E9F4),
      appBar: AppBar(
          toolbarHeight: 75,
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true),
      body: Center(
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
              child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: FutureBuilder<LicenseModel>(
                    future: refreshLicenses(widget.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error al cargar la licencia.'));
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(
                            child: Text('No se encontró la licencia.'));
                      } else {
                        LicenseModel? license = snapshot.data;
                        return Screenshot(
                          controller: _screenshotController,
                          child: ListView.builder(
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.all(10),
                                margin: EdgeInsets.only(
                                    top: 20,
                                    bottom: 10,
                                    left: leftPadding,
                                    right: rightPadding),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    const Center(
                                      child: Image(
                                          image:
                                              AssetImage('assets/ui/logo.png'),
                                          width: 100),
                                    ),
                                    const Text('Detalles de la licencia',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Color(0xFF044086),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25)),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      children: [
                                        CustomRow('Estudiante: ',
                                            '${license!.user!.name} ${license.user!.lastname} ${license.user!.surname}'),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        CustomRow(
                                            'Curso: ', license.user!.grade),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        CustomRow('Fecha: ',
                                            formatDate(license.license_date)),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        CustomRow(
                                            'De: ', license.departure_time),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        CustomRow(
                                            'Hasta: ', license.return_time),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        CustomRow('Motivo: ', license.reason),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Align(
                                          alignment: Alignment.center,
                                          child: Text('Justificativo:',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Color(0xFF044086),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        if (license.justification != '')
                                          Center(
                                            child: Image.network(
                                              license.justification,
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                return const Text(
                                                    'Error al cargar la imagen');
                                              },
                                            ),
                                          ),
                                        if (license.justification == '')
                                          const Text(
                                              'El usuario no subio un justificativo')
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  )),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Obtener la licencia del futuro
          LicenseModel license = await refreshLicenses(widget.id);
          // Generar y descargar el PDF
          await _generatePdf(context, license);
        },
        child: Icon(Icons.download),
      ),
    );
  }
}

class CustomRow extends StatelessWidget {
  const CustomRow(this.label, this.text, {super.key});
  final String label;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF044086),
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        Text(text, style: const TextStyle(color: Colors.black87, fontSize: 16)),
      ],
    );
  }
}
