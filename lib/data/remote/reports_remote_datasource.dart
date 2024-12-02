import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pr_h23_irlandes_web/data/model/report_model.dart';


/*
    Metodos necesarios para manejar los reportes de psicologia: crear, recuperar, etc.
    Falta el metodo de editar o actualizar.
*/
abstract class ReportsRemoteDatasource{
  Future<List<ReportModel>> getReport();
  Future<String> createReport(ReportModel report);
  Future<ReportModel> getReportByID(String reportID);
  Future<List<ReportModel>> getReportAfterDate(DateTime date);
  Future<void> updateReportStatus(String postulatioID, String status);
  Future<void> deleteReport(String postulatioID);

  Future<List<ReportModel>> getPsicoStatus();
}

class ReportRemoteDatasourceImpl extends ReportsRemoteDatasource {
  final CollectionReference<ReportModel> reportFirestoreRef =FirebaseFirestore.instance.collection('Psychology_Reports').withConverter<ReportModel>(fromFirestore: (snapshot, options) =>ReportModel.fromJson(snapshot.data()!,snapshot.id),toFirestore: (report, options) => report.toJson());
  
  @override
  Future<String> createReport(ReportModel report) async {
    DocumentReference docRef = await reportFirestoreRef.add(report);
    return docRef.id;
  }

  @override
  Future<void> updateReport(ReportModel report) async {
    // Utilizamos el método `set` para actualizar un documento existente en Firestore
    await reportFirestoreRef.doc(report.id).update(report.toJson());
  }
  
  @override
  Future<ReportModel> getReportByID(String reportID) async {
    final reportDoc = await reportFirestoreRef.doc(reportID).get();
    final report = reportDoc.data();
    
    await Future.delayed(const Duration(seconds: 4));
    return report!;
  }
  
  @override
  Future<List<ReportModel>> getReport() async {
    final reportDocs = await reportFirestoreRef.get();
    final reports = reportDocs.docs.map((e) {
      return e.data();
    });

    final listReports = reports.toList();

    listReports.sort((a, b) {
      DateTime dateA = a.interview_date;
      DateTime dateB = b.interview_date;
      return dateA.compareTo(dateB);
    });

    await Future.delayed(const Duration(seconds: 4));
    return listReports;
  }
  
  @override
  Future<List<ReportModel>> getReportAfterDate(DateTime date) async {
    final reportDocs = await reportFirestoreRef.get();

    final reports = reportDocs.docs.map((e) {
      return e.data();
    });

    final listReports = reports.toList();

    final pendingReports = listReports.where((report) {
      return report.interview_date.isAfter(date);
    }).toList();

    

    await Future.delayed(const Duration(seconds: 4));
    return pendingReports.reversed.toList();    
  }
  
  @override
  Future<void> updateReportStatus(String reportID, String status) async {
    final reportDoc = reportFirestoreRef.doc(reportID);
    await reportDoc.update({'status_report': status});
  }
  
  @override
  Future<void> deleteReport(String reportID) async {
    final reportDoc = reportFirestoreRef.doc(reportID);
    await reportDoc.delete();
  }

  Future<void> updateInterviewDateTime(String postulationId, DateTime newDateTime, String newTime) async {
    try {
      await FirebaseFirestore.instance
          .collection('Psychology_Reports')
          .doc(postulationId)
          .update({
            'interview_date': Timestamp.fromDate(newDateTime),
            'interview_hour': newTime,
          });
    } catch (e) {
      //throw Exception('Error al actualizar la fecha y hora de la entrevista');
      throw Exception(e);
    }
  }
//un cambio
  @override
  Future<List<ReportModel>> getPsicoStatus() async {
    final querySnapshot = await reportFirestoreRef
        .where('status_report', isEqualTo: 'Administración')
        .where('estadoConfirmado', whereIn: ['Confirmado', 'Pendiente'])
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }





  
}