import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pr_h23_irlandes_web/data/model/Coordinacion_Reports_model.dart';

abstract class CordinacionRemoteDatasource {
  //metodos anteriores  
  Future<List<CoordinacionModel>> getReportCord();
  Future<String> createReportCord(CoordinacionModel reportCord);
  Future<CoordinacionModel> getReportCordByID(String reportCordID);
  Future<List<CoordinacionModel>> getReportCordAfterDate(DateTime date);
  Future<void> updateReportCordStatus(String reportCordID, String status);
  Future<void> deleteReportCord(String reportCordID);
  Future<List<CoordinacionModel>> getCoordStatus();
  Future<void> confirmReportCord(String reportCordID,String status);
  //metodos actuales en coordinacion
  
}

class CordinacionRemoteDatasourceImpl extends CordinacionRemoteDatasource {
  final CollectionReference<CoordinacionModel> reportCordFirestoreRef =
      FirebaseFirestore.instance.collection('Coordinacion_Reports').withConverter<CoordinacionModel>(
            fromFirestore: (snapshot, options) => CoordinacionModel.fromJson(snapshot.data()!, snapshot.id),
            toFirestore: (reportCord, options) => reportCord.toJson(),
          );


  @override
  Future<String> createReportCord(CoordinacionModel reportCord) async {
    DocumentReference docRef = await reportCordFirestoreRef.add(reportCord);
    return docRef.id;
  }

  
  Future<void> updateReportCoord(CoordinacionModel reportCoord) async {
    // Utilizamos el método `set` para actualizar un documento existente en Firestore
    await reportCordFirestoreRef.doc(reportCoord.id).update(reportCoord.toJson());
  }

  @override
  Future<void> deleteReportCord(String reportCordID) async {
    final reportCordDoc = reportCordFirestoreRef.doc(reportCordID);
    await reportCordDoc.delete();
  }

  @override
  Future<List<CoordinacionModel>> getReportCord() async {
    final reportCordDocs = await reportCordFirestoreRef.get();
    final reportsCord = reportCordDocs.docs.map((e) {
      return e.data();
    });

    final listReports = reportsCord.toList();

    listReports.sort((a, b) {
      DateTime dateA = a.interview_date_cord;
      DateTime dateB = b.interview_date_cord;
      return dateA.compareTo(dateB);
    });

    await Future.delayed(const Duration(seconds: 4));
    return listReports;
  }

  @override
  Future<List<CoordinacionModel>> getReportCordAfterDate(DateTime date) async {
    final reportCordDocs = await reportCordFirestoreRef.get();
    final reportsCord = reportCordDocs.docs.map((e) => e.data()).toList();

    final pendingReportsCord = reportsCord.where((reportCord) => reportCord.interview_date_cord.isAfter(date)).toList();

    await Future.delayed(const Duration(seconds: 4));
    return pendingReportsCord.reversed.toList();
  }

  @override
  Future<CoordinacionModel> getReportCordByID(String reportCordID) async {
    final reportCordDoc = await reportCordFirestoreRef.doc(reportCordID).get();
    final reportCord = reportCordDoc.data();

    await Future.delayed(const Duration(seconds: 4));
    return reportCord!;
  }

  @override
  Future<void> updateReportCordStatus(String reportCordID, String status) async {
    final reportCordDoc = reportCordFirestoreRef.doc(reportCordID);
    await reportCordDoc.update({'estadoRevisado': status});
  }

  Future<void> updateReportCordInterviewStatus(String reportCordID, String status) async {
    try {
      final reportCordDoc = reportCordFirestoreRef.doc(reportCordID);
      await reportCordDoc.update({'estadoConfirmado': status});
    } catch (e) {
      throw Exception('Failed to update interview status: $e');
    }
  }
  Future<void> updateInterviewCordDateTime(String postulationId, DateTime newDateTime, String newTime) async {
    try {
      await FirebaseFirestore.instance
          .collection('Coordinacion_Reports')
          .doc(postulationId)
          .update({
            'interview_date_cord': Timestamp.fromDate(newDateTime),
            'interview_hour_cord': newTime,
          });
    } catch (e) {
      //throw Exception('Error al actualizar la fecha y hora de la entrevista');
      throw Exception(e);
    }
  }

  @override
  Future<List<CoordinacionModel>> getCoordStatus() async {
    final querySnapshot = await reportCordFirestoreRef
        .where('estadoRevisado', isEqualTo: 'Administración')
        .where('estadoConfirmado', whereIn: ['Confirmado', 'pendiente'])
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
  // Nuevo método para actualizar estadoConfirmado a "Confirmado"
  @override
  Future<void> confirmReportCord(String? reportCordID, String status) async {
    final reportCordDoc = reportCordFirestoreRef.doc(reportCordID);
    await reportCordDoc.update({'estadoConfirmado': status});
  }

  Future<void> insertReasonMissAppointment(String? reportCordID, String reason) async {
    try {
      await reportCordFirestoreRef.doc(reportCordID).update({'reasonMissAppointment': reason});
    } catch (e) {
      // Manejo de errores aquí
      throw Exception('Error al insertar la razón de la cita perdida: $e');
    }
  }

  Future<void> insertReasonReschedule(String? reportCordID, String reason) async {
    try {
      await reportCordFirestoreRef.doc(reportCordID).update({'reasonRescheduleAppointment': reason});
    } catch (e) {
      // Manejo de errores aquí
      throw Exception('Error al insertar la razón de la cita perdida: $e');
    }
  }
  //sss
  Future<void> updateInterviewAdminDateTime(String postulationId, DateTime newDateTime, String newTime) async {
    try {
      await FirebaseFirestore.instance
          .collection('Coordinacion_Reports')
          .doc(postulationId)
          .update({
        'interview_date_admin': Timestamp.fromDate(newDateTime),
        'interview_hour_admin': newTime,
      });
    } catch (e) {
      //throw Exception('Error al actualizar la fecha y hora de la entrevista');
      throw Exception(e);
    }
  }
}
