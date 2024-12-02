import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/notification_model.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/notifications_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/postulation_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/model/postulation_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

import 'dart:math';
import 'package:uuid/uuid.dart';

import '../../../data/remote/access_remote_datasource.dart';

/*
    Pagina para ver detalles del reporte psicologico
*/

class ReportCoordDetails_AdminArea extends StatefulWidget {
  final String id;

  const ReportCoordDetails_AdminArea({super.key, required this.id});

  @override
  State<ReportCoordDetails_AdminArea> createState() => _ReportCoordDetails();
}

class _ReportCoordDetails extends State<ReportCoordDetails_AdminArea> {
  //CordinacionRemoteDatasourceImpl reportCoordRemoteDatasourceImpl =CordinacionRemoteDatasourceImpl();
  AccessRemoteDataSourceImpl accessDataSource = AccessRemoteDataSourceImpl();
  PostulationRemoteDatasourceImpl postulationRemoteDatasourceImpl =
      PostulationRemoteDatasourceImpl();

  PersonaDataSource _personaDataSource = PersonaDataSourceImpl();
  final NotificationRemoteDataSource notificationRemoteDataSource =
      NotificationRemoteDataSourceImpl();

  late PostulationModel postulationModel;
  //late CoordinacionModel reportCoord;

  bool isLoading = true;
  String fatherUserName = '';
  String fatherPassword = '';
  String motherUserName = '';
  String motherPassword = '';

  String capturedFatherUserName = ''; // Para almacenar el usuario del padre
  String capturedFatherPassword = ''; // Para almacenar la contraseña del padre

  DateTime? _newInterviewDateTime;
  TextEditingController? birthDateController;
  //final reportCoordRemoteDataSource = CordinacionRemoteDatasourceImpl();//comentar
  final postulationRemoteDatasource = PostulationRemoteDatasourceImpl();

  final TextEditingController commentController = TextEditingController();

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
      BuildContext context, PostulationModel postulationModel) async {
    final pdf = pw.Document();

    try {
      // Cargar la imagen de manera asíncrona
      final logoBytes = await rootBundle.load('assets/logo.png');
      final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

      // Método para crear una fila de datos
      pw.Widget _buildDataRow(String label, String value) {
        return pw.Padding(
          padding: pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  label,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey,
                  ),
                ),
              ),
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  value,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Agregar una página al documento PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Padding(
              padding: pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Cabecera con el logo y el título
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Image(
                        logoImage,
                        width: 50,
                        height: 50,
                      ),
                      pw.Text(
                        'Detalles de Reporte - Coordinación',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),

                  // Datos del Estudiante
                  pw.Divider(color: PdfColors.blueGrey),
                  _buildDataRow(
                    'Nombre Completo:',
                    '${postulationModel.student_name} ${postulationModel.student_lastname}',
                  ),
                  _buildDataRow(
                    'Carnet de Identidad:',
                    postulationModel.student_ci,
                  ),
                  _buildDataRow(
                    'Colegio Anterior:',
                    postulationModel.institutional_unit,
                  ),
                  _buildDataRow(
                    'Correo Electrónico:',
                    postulationModel.email,
                  ),
                  _buildDataRow(
                    'Nivel:',
                    postulationModel.level,
                  ),
                  _buildDataRow(
                    'Grado:',
                    postulationModel.grade,
                  ),
                  pw.SizedBox(height: 10),

                  // Datos Familiares
                  pw.Divider(color: PdfColors.blueGrey),
                  _buildDataRow(
                    'Nombre de la Madre:',
                    '${postulationModel.mother_name} ${postulationModel.mother_lastname}',
                  ),
                  _buildDataRow(
                    'Teléfono de la Madre:',
                    postulationModel.mother_cellphone,
                  ),
                  _buildDataRow(
                    'Nombre del Padre:',
                    '${postulationModel.father_name} ${postulationModel.father_lastname}',
                  ),
                  _buildDataRow(
                    'Teléfono del Padre:',
                    postulationModel.father_cellphone,
                  ),
                  _buildDataRow(
                    'Datos de los Hermanos:',
                    postulationModel.hermanosUEE != null
                        ? postulationModel.hermanosUEE.join('\n')
                        : 'No disponible',
                  ),
                  _buildDataRow(
                    'Teléfono Familiar:',
                    postulationModel.telephone,
                  ),
                  pw.SizedBox(height: 10),

                  // Observaciones
                  pw.Divider(color: PdfColors.blueGrey),
                  _buildDataRow(
                    'Observación de Coordinación:',
                    postulationModel.obs,
                  ),
                  _buildDataRow(
                    'Observación de Psicología:',
                    postulationModel.obs,
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Guardar el PDF como blob en memoria
      final Uint8List pdfBytes = await pdf.save();
      final blob = html.Blob([pdfBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute(
          "download",
          "Informe_Coordinacion_${postulationModel.student_name}_${postulationModel.student_lastname}.pdf",
        )
        ..click();
      html.Url.revokeObjectUrl(url);

      // Notificar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF generado exitosamente')),
      );
    } catch (e) {
      // Notificar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar PDF: $e')),
      );
    }
  }

  // Función auxiliar para crear una fila de detalle
  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFF044086), fontSize: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

// Definición del método _buildListSection
  Widget _buildListSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF044086),
          ),
        ),
        const SizedBox(height: 8),
        for (var item in items)
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 4.0),
            child: Text(
              '- $item',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  void initState() {
    postulationRemoteDatasourceImpl
        .getPostulationByID(widget.id)
        .then((value) => {
              isLoading = true,
              postulationModel = value,
              if (mounted)
                {
                  setState(() {
                    isLoading = false;
                    birthDateController = TextEditingController(
                        text: DateFormat('dd/MM/yyyy')
                            .format(postulationModel.birth_day));
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

  void showMessageDialogpri(
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

              Navigator.pushNamed(context, '/admin_area_main');
              //Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }

  Future<void> generatePdfLetter(
      BuildContext context, PostulationModel postulation) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Center(
                        child: pw.Text(
                          'ACUERDO DE INTENCIONES VINCULANTE',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'En la ciudad de Cochabamba, al día ${DateTime.now().day} del ${DateTime.now().month} del ${DateTime.now().year}, se reúnen:', // añadir dia mes en este sector  ojo clave1  ?
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                //-----------------------------
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'De una parte LA UNIDAD EDUCATIVA  "ESCLAVAS DEL SAGRADO CORAZÓN DE JESUS", representada por la Hna. MAGDALENA CONDORI CALCINA, en su calidad de Directora General y representante legal quien es mayor de edad, vecina de esta, hábil por derecho, quien a efectos del presente acuerdo se denominara simplemente como la UNIDAD EDUCATIVA.',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                //---------------
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Y de la otra, la Sr/Sra ${postulation.father_name} ${postulation.father_lastname} , mayor de edad, hábil por ley, vecina de esta ciudad, en lo sucesivo LA CONTRATANTE.',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'En conjunto se denominaran LAS PARTES, reconociéndose mutuamente capacidad legal suficiente para contratar y obligarse, siendo responsables de honrar sus compromisos.',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Center(
                        child: pw.Text(
                          'EXPONEN',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        '1.	Que la UNIDAD EDUCATIVA, es una Institución caracterizada por su alto nivel académico y sólida formación en valores, siendo una de sus múltiples fortalezas el brindar una educación de calidad con una atención personalizada.',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        '2. Que LA CONTRATANTE, es madre/padre del menor de nombre  ${postulation.student_name}  ${postulation.student_lastname} , quien la próxima gestión académica 2022, habrá de cursar el 3 grado del Nivel Primario. Misma que se encuentra muy interesada en formar parte del estamento estudiantil de la Unidad Educativa, durante la gestión 2022 ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        '3. Que LAS PARTES, están interesadas y comprometidas en formalizar un contrato de prestación de servicios educativos por la gestión 2022, y en virtud a ello de manera libre y espontánea formalizan el presente acuerdo de intenciones, el cual se regirá por las siguientes clausulas: ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'PRIMERA -  OBJETO DEL ACUERDO. ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'El presente acuerdo tiene por objeto garantizar la incorporación del menor a la Unidad Educativa, debido a que el proceso de entrevistas ha concluido y existe voluntad de ambas partes, de suscribir un contrato de prestación de servicio educativo por la Gestión 2022.  ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'SEGUNDA - DURACION DEL ACUERDO. ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'LAS PARTES. En completa igualdad jurídica, determinan que el presente acuerdo estará vigente hasta el último día de Inscripción Educativa para la Gestión 2022, fecha que será determinada por el Ministerio del Área, mediante Resolución Ministerial o Instructivo específico, pasada la fecha señalada, se aplicara lo dispuesto en la cláusula sexta. ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'TERCERA - CONFIDENCIALIDAD. ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Debido al carácter reservado de este acuerdo, LAS PARTES acuerdan no divulgarla y mantener la más estricta confidencialidad en cuanto a su contenido y sus alcances. ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'CUARTA - DEPOSITO DE GARANTIA. ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Con la finalidad de garantizar el cumplimiento estricto del presente acuerdo, a la suscripción del mismo, LA CONTRATANTE entrega la suma de Bs. 500.00 ( QUINIENTOS 00/100 Bolivianos). Monto que se restará de la primera pensión a cancelarse la próxima gestión, cuya cuantía aún se desconoce. ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'QUINTA - TERMINACION ANTICIPADA DEL ACUERDO. ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'El presente acuerdo podrá ser resuelto por decisión mutua de LAS PARTES, con los efectos que ellos determinen, siempre y cuando así lo decidieran de manera consensuada, caso contrario la parte que lo diera por terminado a pesar de la oposición de la otra deberá abonar un monto sancionatorio igual al 30 %, del depósito entregado en garantía. ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'SEXTA - INCUMPLIMIENTO DEL ACUERDO RESPECTO A LA INSCRIPCIÓN. ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'En caso de concluir la etapa de inscripciones escolares gestión 2022 y el menor no se hubiera matriculado, la UNIDAD EDUCATIVA, solo reintegrara el 70 % del monto de la garantía, por el perjuicio sufrido al negar otras inscripciones precautelando la plaza comprometida. ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'SEPTIMA - NOTIFICACIONES Y ACLARACIÓN. ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Para realizar cualquier notificación entre partes, la UNIDAD EDUCATIVA, señala como domicilio legal la Secretaria de sus Instalaciones y los números habilitados, LA CONTRATANTE señala el correo electrónico ${postulation.email}  y N° de Whatsapp ${postulation.father_cellphone}. De modo similar dejan expresa constancia que el presente acuerdo no vulnera lo dispuesto en el Articulo 99 de la R.M. 001/2021 en actual vigencia, por no existir relación contractual vigente entre ellas. ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'OCTAVA - ACEPTACION. ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'En prueba de conformidad y aceptación, de todo lo establecido en el clausulado anterior, ambas partes firman el presente acuerdo, en un solo ejemplar y a un solo efecto, en el lugar y fecha al comienzo indicados.',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 150),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        '${postulation.father_name}   ${postulation.father_lastname}                                    Hna. Magdalena Condori Calcina ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        // correcion de obtener el Carnet del padre de familia
                        'C.I.: ${postulation.student_ci}                                                  C.I.:5264196 CB ',
                        style: pw.TextStyle(fontSize: 12),
                        textAlign: pw.TextAlign.justify,
                      ),
                    ),
                  ],
                ),
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
      ..setAttribute("download",
          "Acuerdo_${postulation.student_name}_${postulation.student_lastname}_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.pdf")
      ..click();

    // Limpiar la URL creada
    html.Url.revokeObjectUrl(url);

    // Mostrar un mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF generado exitosamente'),
      ),
    );
  }

//----------------------------------------------------------------------------------------------------------------
  Future<void> generatePdfCredentials(
      BuildContext context, PostulationModel postulation) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'ACTA DE ENTREGA DE USUARIO Y CLAVE PARA LA PAGINA WEB',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                    'Estimado(a): ${postulation.father_name} ${postulation.father_lastname}',
                    style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Se ha generado una nuevo usuario y contraseña de Acceso a la Página Web',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Usuario:        $capturedFatherUserName',
                    style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 10),
                pw.Text('Contraseña:      $capturedFatherPassword',
                    style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 10),
                pw.Text('Dirección de acceso:  ${postulation.email}',
                    style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),
                pw.Text(
                  'El funcionario se compromete a guardar absoluta confidencialidad como también a asegurar el uso exclusivo e intransferible del usuario y la contraseña que le ha sido asignado. Le recordamos que las contraseñas son de uso personal y no deben ser compartidas con ninguna persona.',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'CONSEJOS DE SEGURIDAD',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  '- Se recomienda el cambio inmediato de la contraseña.\n'
                  '- La clave debe tener como mínimo 6 caracteres, sin espacios, ni símbolos, debe contener números, letras mayúsculas, minúsculas.\n'
                  '- La clave se debe cambiar de forma periódica. Se sugiere el cambio cada 60 días.\n'
                  '- La clave es personal e intransferible.\n'
                  '- Resguardar y proteger la información es responsabilidad de TODOS.\n'
                  '- Acostumbrarse a cerrar la sesión al terminar las actividades.\n'
                  '- No utilizar la opción de recordar clave del navegador para el ingreso.\n'
                  '- Reiteramos que es responsabilidad de todos los funcionarios crear Contraseñas Seguras para los sistemas de información, salvaguardar las mismas y no compartirlas. De igual manera, ante cualquier consulta o duda favor tomar contacto con Encargado de Soporte del Colegio.',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 40),
                pw.Text('______________________',
                    style: pw.TextStyle(fontSize: 12)),
                pw.Text('Firma Funcionario', style: pw.TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );

    // Save the PDF as a blob in memory
    final Uint8List pdfBytes = await pdf.save();
    final blob = html.Blob([pdfBytes]);
    // Create a URL for the blob and open a window to download the file
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download",
          "contrato_${postulation.student_name}_${postulation.student_lastname}_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.pdf")
      ..click();
    // Revoke the created URL
    html.Url.revokeObjectUrl(url);
    // Show a success message
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
        title: Text('Detalles de reporte - Admistracion ',
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
                            if (postulationModel.reasonMissAppointment != '' &&
                                postulationModel.estadoConfirmacionAdmin ==
                                    'pendiente')
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Esta postulacion fue previamente cancelada!',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            if (postulationModel.reasonMissAppointment != '' &&
                                postulationModel.estadoConfirmacionAdmin ==
                                    'pendiente')
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            width: 35,
                                          ),
                                          const Text(
                                            'Justificativo: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            postulationModel
                                                .reasonMissAppointment,
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
                            if (postulationModel.reasonMissAppointment != '' &&
                                postulationModel.estadoConfirmacionAdmin ==
                                    'Confirmado')
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Esta postulacion fue reprogramada!',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            if (postulationModel.reasonMissAppointment != '' &&
                                postulationModel.estadoConfirmacionAdmin ==
                                    'Confirmado')
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            width: 35,
                                          ),
                                          const Text(
                                            'Justificativo: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF044086),
                                                fontSize: 18),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            postulationModel
                                                .reasonRescheduleAppointment,
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
                                    initialDate: postulationModel
                                            .fechaEntrevistaAdministracion
                                            .isBefore(firstAllowedDate)
                                        ? DateTime.now()
                                        : postulationModel
                                            .fechaEntrevistaAdministracion,
                                    firstDate: firstAllowedDate,
                                    lastDate: DateTime(2100),
                                  );

                                  if (selectedDate != null) {
                                    final selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          postulationModel
                                              .fechaEntrevistaAdministracion),
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
                              '${DateFormat('dd/MM/yyyy').format(postulationModel.fechaEntrevistaAdministracion)} ${postulationModel.horaEntrevistaAdministracion}',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                            ElevatedButton(
                              // boton de guardar fecha
                              onPressed: _newInterviewDateTime != null
                                  ? () async {
                                      try {
                                        // Actualizar la fecha y hora de la entrevista en Firebase
                                        await postulationRemoteDatasourceImpl
                                            .updateFechaHoraEntrevistaAdmin(
                                          widget.id,
                                          _newInterviewDateTime!,
                                          TimeOfDay.fromDateTime(
                                                  _newInterviewDateTime!)
                                              .format(context),
                                        );

                                        // Actualizar el estado del widget con la nueva fecha y hora
                                        setState(() {
                                          postulationModel
                                                  .fechaEntrevistaAdministracion =
                                              _newInterviewDateTime!;
                                          postulationModel
                                                  .horaEntrevistaAdministracion =
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
                                  postulationModel.level,
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
                                  postulationModel.grade,
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
                                  '${postulationModel.student_name} ${postulationModel.student_lastname} ',
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
                                  '${postulationModel.student_ci} ',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 35,
                                ),
                                const Text(
                                  'Fecha nacimiento: ', //cregir año cronologico
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color(0xFF044086), fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(postulationModel.birth_day),
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Sección Psicología
                                  const Text(
                                    'Detalles Psicología',
                                    style: TextStyle(
                                        color: Color(0xFF044086),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailRow(
                                              'Observación psicología:',
                                              postulationModel.obs),
                                          _buildDetailRow(
                                              'Fecha entrevista:',
                                              postulationModel.fechaEntrevista
                                                  .toString()),
                                          _buildDetailRow(
                                              'Psicólogo encargado:',
                                              postulationModel
                                                  .psicologoEncargado),
                                          _buildDetailRow(
                                              'Informe breve entrevista:',
                                              postulationModel
                                                  .informeBreveEntrevista),
                                          _buildDetailRow(
                                              'Recomendación psicología:',
                                              postulationModel
                                                  .recomendacionPsicologia),
                                          _buildDetailRow('Respuesta PPFF:',
                                              postulationModel.respuestaPPFF),
                                          if (postulationModel
                                              .hermanosUEE.isNotEmpty)
                                            _buildListSection(
                                                'Hermanos en UEE:',
                                                postulationModel.hermanosUEE),
                                          if (postulationModel
                                              .nombreHermano.isNotEmpty)
                                            _buildListSection(
                                                'Nombres de hermanos:',
                                                postulationModel.nombreHermano),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Sección Coordinación
                                  const Text(
                                    'Detalles Coordinación',
                                    style: TextStyle(
                                        color: Color(0xFF044086),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailRow(
                                              'Fecha entrevista coordinación:',
                                              postulationModel
                                                  .fechaEntrevistaCoordinacion
                                                  .toString()),
                                          _buildDetailRow(
                                              'Visto bueno coordinación:',
                                              postulationModel
                                                  .vistoBuenoCoordinacion),
                                          _buildDetailRow('Respuesta a PPFF:',
                                              postulationModel.respuestaAPpff),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Sección Administración
                                  const Text(
                                    'Detalles Administración',
                                    style: TextStyle(
                                      color: Color(0xFF044086),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: postulationModel.estadoConfirmacionAdmin == 'Confirmado'
                                            ? [
                                                // Mostrar campos de texto para ingresar nueva información
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Ingrese observación administración:',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    TextField(
                                                      onChanged: (value) {
                                                        // Capturar el texto ingresado
                                                        postulationModel.administracion = value;
                                                      },
                                                      decoration: const InputDecoration(
                                                        hintText: 'Escriba aquí...',
                                                        border: OutlineInputBorder(),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    const Text(
                                                      'Ingrese recepción documentos:',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    TextField(
                                                      onChanged: (value) {
                                                        // Capturar el texto ingresado
                                                        postulationModel.recepcionDocumentos = value;
                                                      },
                                                      decoration: const InputDecoration(
                                                        hintText: 'Escriba aquí...',
                                                        border: OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ]
                                            : [
                                                // Mantener la visualización actual si el estado no es "Confirmado"
                                                _buildDetailRow(
                                                    'Observación administración:', postulationModel.administracion),
                                                _buildDetailRow(
                                                    'Recepción documentos:', postulationModel.recepcionDocumentos),
                                              ],
                                      ),
                                    ),
                                  ),


                              // Función auxiliar para mostrar listas
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Detalles Tutores',
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
                                              '${postulationModel.father_name} ${postulationModel.father_lastname} ',
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
                                              '${postulationModel.mother_name} ${postulationModel.mother_lastname} ',
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
                                          postulationModel.email,
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
                                            postulationModel.father_cellphone,
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
                                            postulationModel.mother_cellphone,
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
                                          postulationModel.telephone,
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
                                if (postulationModel.estadoConfirmacionAdmin ==
                                    'Confirmado')
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          //
                                          //metodo de postulacion
                                          //carta
                                          //email
                                          PostulationModel postulation =
                                              PostulationModel(
                                            level: postulationModel.level,
                                            grade: postulationModel.grade,
                                            institutional_unit: postulationModel
                                                .institutional_unit,
                                            city: 'cbba',
                                            amount_brothers: 0,
                                            student_name:
                                                postulationModel.student_name,
                                            student_lastname: postulationModel
                                                .student_lastname,
                                            student_ci:
                                                postulationModel.student_ci,
                                            birth_day:
                                                postulationModel.birth_day,
                                            gender: 'M',
                                            father_name:
                                                postulationModel.father_name,
                                            father_lastname: postulationModel
                                                .father_lastname,
                                            father_cellphone: postulationModel
                                                .father_cellphone,
                                            mother_name: postulationModel
                                                .mother_cellphone,
                                            mother_lastname: postulationModel
                                                .mother_lastname,
                                            mother_cellphone: postulationModel
                                                .mother_cellphone,
                                            telephone:
                                                postulationModel.telephone,
                                            email: postulationModel.email,
                                            interview_date: postulationModel
                                                .fechaEntrevistaCoordinacion,
                                            interview_hour: postulationModel
                                                .horaEntrevistaAdministracion,
                                            userID: "0",
                                            status: 'Pendiente',
                                            latitude: 0,
                                            longitude: 0,
                                            register_date: DateTime.now(),
                                            // Nuevos campos inicializados a vacío o nulo
                                            hermanosUEE: [], // Inicializado como vacío
                                            nombreHermano: [], // Inicializado como lista vacía
                                            obs: '', // Inicializado como vacío
                                            fechaEntrevista: DateTime
                                                .now(), // Fecha actual por defecto
                                            psicologoEncargado:
                                                '', // Inicializado como vacío
                                            informeBreveEntrevista:
                                                '', // Inicializado como vacío
                                            recomendacionPsicologia:
                                                '', // Inicializado como vacío
                                            respuestaPPFF:
                                                '', // Inicializado como vacío
                                            fechaEntrevistaCoordinacion: DateTime
                                                .now(), // Fecha actual por defecto
                                            vistoBuenoCoordinacion:
                                                '', // Inicializado como vacío
                                            respuestaAPpff:
                                                '', // Inicializado como vacío
                                            administracion:
                                                '', // Inicializado como vacío
                                            recepcionDocumentos:
                                                '', // Inicializado como vacío
                                            estadoEntrevistaPsicologia:
                                                '', // Inicializado como vacío
                                            estadoGeneral:
                                                '', // Inicializado como vacío
                                            estadoConfirmacion:
                                                '', // Inicializado como vacío
                                            reasonRescheduleAppointment: '',
                                            reasonMissAppointment: '',
                                            estadoConfirmacionAdmin: '',
                                            approvedAdm: '',
                                            fechaEntrevistaAdministracion:
                                                DateTime.now(),
                                            horaEntrevistaAdministracion: '',
                                          );

                                          //crear usuarios
                                          crearUsuario(postulation);
                                          enviarNotificacionAprovado(postulation);
                                          generatePdfCredentials(context, postulation);
                                          generatePdfLetter(context, postulation);
                                          // ignore: use_build_context_synchronously
                                          Navigator.of(context).pop();
                                          // ignore: use_build_context_synchronously
                                          showMessageDialogpri(
                                              context,
                                              'assets/ui/marque-el-circulo.png',
                                              'Correcto',
                                              'Postulación aprobada');
                                          if (postulation.userID == '0') {
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
                                          //estado para que ya no apresca mas
                                          await postulationRemoteDatasourceImpl
                                              .updatePostulationAdminFields(
                                            widget.id,
                                            'Aprobado',postulation.administracion,postulation.recepcionDocumentos
                                          );
                                          //??? ojo2

                                          setState(() {
                                            postulationModel.estadoGeneral =
                                                'Administración';
                                          });
                                        } catch (e) {
                                          showMessageDialog(
                                            context,
                                            'assets/ui/circulo-cruzado.png',
                                            'Error',
                                            'Ha ocurrido un error inesperado',
                                          );
                                        }
                                      },
                                      child: Text(
                                          'Terminar proceso de Postulacion'),
                                    ),
                                  ),
                                if (postulationModel.estadoConfirmacionAdmin ==
                                    'pendiente') //solo para pendiente
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          if (postulationModel
                                                      .reasonMissAppointment !=
                                                  '' &&
                                              postulationModel
                                                      .estadoConfirmacionAdmin ==
                                                  'pendiente') {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                String comment =
                                                    ''; // Variable para almacenar el comentario

                                                return AlertDialog(
                                                  title: Text(
                                                    'Reprogramar cita',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF044086),
                                                        fontSize: 18),
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      TextField(
                                                        onChanged: (value) {
                                                          // Actualiza el valor del comentario conforme el usuario escribe
                                                          comment = value;
                                                        },
                                                        controller:
                                                            commentController,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              'Justificativo',
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                        minLines: 3,
                                                        maxLines: 5,
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Cierra el AlertDialog sin hacer nada
                                                      },
                                                      child: Text('Cancelar'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        // Si se presiona "Enviar", actualiza el comentario
                                                        //setState(() {
                                                        //reportCoord.reasonRescheduleAppointment = comment;
                                                        //});

                                                        String comment =
                                                            commentController
                                                                .text;

                                                        if (comment.isEmpty) {
                                                          // Si el comentario está vacío, muestra un diálogo de advertencia
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                              title:
                                                                  Text('Aviso'),
                                                              content: Text(
                                                                  'Favor de dar la justificación.'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(); // Cierra el aviso
                                                                  },
                                                                  child: Text(
                                                                      'OK'),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        } else {
                                                          await postulationRemoteDatasourceImpl
                                                              .insertReasonReschedule(
                                                                  postulationModel
                                                                      .id!,
                                                                  comment);
                                                          await postulationRemoteDatasourceImpl
                                                              .updateEstadoConfirmacionAdmin(
                                                                  postulationModel
                                                                      .id!,
                                                                  'Confirmado');
                                                          // Enviar el correo electrÃ³nico notificando la actualizaciÃ³n
                                                          String formattedDate =
                                                              DateFormat(
                                                                      'yyyy-MM-dd')
                                                                  .format(postulationModel
                                                                      .fechaEntrevistaAdministracion);
                                                          String messagetosend =
                                                              'Estimado/a Padre/Madre/Tutor,\n\n'
                                                              'Nos complace informarle que la fecha de la entrevista ha sido confirmada para el día $formattedDate a las ${postulationModel.horaEntrevistaAdministracion} en el Departamento de Administración.\n\n'
                                                              'Le agradecemos su puntualidad y quedamos a su disposición para cualquier consulta.\n\n'
                                                              'Atentamente,\n'
                                                              'Colegio Esclavas del Sagrado Corazón de Jesús';
                                                          await sendEmail(
                                                            postulationModel
                                                                .email, // Reemplaza con el correo del destinatario
                                                            'Confirmacion de entrevista',
                                                            messagetosend,
                                                          );

                                                          Navigator.of(context)
                                                              .pop();

                                                          showMessageDialogpri(
                                                            context,
                                                            'assets/ui/marque-el-circulo.png',
                                                            'Exito',
                                                            'Se ha realizado la reprogramacion',
                                                          );
                                                        }
                                                      },
                                                      child: Text('Enviar'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            // Si la condición no se cumple, simplemente confirma el reporte
                                            await postulationRemoteDatasourceImpl
                                                .updateEstadoConfirmacionAdmin(
                                              postulationModel.id!,
                                              'Confirmado',
                                            );

                                            // Actualiza el estado en el widget
                                            setState(() {
                                              postulationModel.estadoGeneral =
                                                  'admin'; // ojo estadogeneral12
                                            });

                                            showMessageDialog(
                                              context,
                                              'assets/ui/marque-el-circulo.png',
                                              'Correcto',
                                              'Se ha actualizado el estado a "Administración"',
                                            );
                                          }
                                        } catch (e) {
                                          // Muestra un mensaje de error si hay un problema al confirmar el reporte
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
                                if (postulationModel.estadoConfirmacionAdmin ==
                                    'Confirmado')
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
                                                    '¿Estás seguro de que quieres devolver la postulación a Coordinación?',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color(0xFF3D5269),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      // Botón Aceptar
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 5,
                                                                right: 5),
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            try {
                                                              await postulationRemoteDatasourceImpl
                                                                  .updateVolverCoord(
                                                                      postulationModel
                                                                          .id!);
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Cierra el diálogo
                                                              showMessageDialogpri(
                                                                context,
                                                                'assets/ui/marque-el-circulo.png',
                                                                'Correcto',
                                                                'Postulación devuelta a Coordinación',
                                                              );
                                                            } catch (e) {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Cierra el diálogo
                                                              print(
                                                                  'Error al devolver a Coordinación: $e');
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
                                                            'Aceptar',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                      // Botón Cancelar
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
                                                                .pop(); // Cierra el diálogo sin hacer nada
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
                                                            'Cancelar',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
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
                                      child:
                                          const Text('Devolver a Coordinación'),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            return Colors.blue;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),

                                // estadogeral=coord ; visbueno coordinacion Pendiente ,estadoconfirmacionadministracion= pendiente

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
                                                //ojo3
                                                
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5, right: 5),
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    try {
                                                      await postulationRemoteDatasourceImpl
                                                          .deletePostulation(widget.id);
                                                      Navigator.of(context).pop();
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
                                                    backgroundColor: MaterialStateProperty.all(
                                                      const Color(0xFF044086),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Si',
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5, right: 5),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor: MaterialStateProperty.all(
                                                      const Color(0xFF044086),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'No',
                                                    style: TextStyle(color: Colors.white),
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
                   ],),
                  ),)
              );},
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await generatePdf(context, postulationModel);
        },
        child: Icon(Icons.download),
      ),
    );
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

  String encryptToBinary(String text) {
    StringBuffer binaryString = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      // Convertir cada carácter a su código ASCII y luego a binario
      String binaryChar = text.codeUnitAt(i).toRadixString(2).padLeft(8, '0');
      binaryString.write(binaryChar);
    }

    return binaryString.toString();
  }

  void crearUsuario(PostulationModel postulation) async {
    // Crear una instancia de la clase Uuid
    var uuid = Uuid();
    // Generar un ID único
    String fatherId = 'None';
    String motherId = 'None';
    if (postulation.father_name != 'None') {
      fatherId = postulation.userID;
    } else if (postulation.mother_name != 'None') {
      motherId = postulation.userID;
    }
    List<String> estudianteApellidos = postulation.student_lastname.split(' ');
    if (postulation.userID != '0') {
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
      capturedFatherUserName = fatherUserName;
      capturedFatherPassword = fatherPassword;
      //respaldo en binario
      accessDataSource.updateAccess(fatherId, encryptToBinary(fatherPassword));
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

      //respaldo en binario
      accessDataSource.updateAccess(motherId, encryptToBinary(motherPassword));
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
