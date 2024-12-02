import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pr_h23_irlandes_web/data/model/postulation_model.dart';


abstract class PostulationRemoteDatasource {
  Future<List<PostulationModel>> getPostulations();
  Future<String> createPostulations(PostulationModel postulation);
  Future<PostulationModel> getPostulationByID(String postulatioID);
  Future<List<PostulationModel>> getPostulationsAfterDate(DateTime date);
  Future<void> updatePostulationStatus(String postulatioID, String status);
  Future<void> deletePostulation(String postulatioID);
  Future<bool> buscarStudentCi(String studentCi);
  //de cris su metodo
  Future<void> updatePostulation(
      String postulationID, Map<String, dynamic> updatedFields);

  // Métodos de Coordinación de rafo
  Future<void> coordinacionUpdateInterviewDate(
      String postulationID, DateTime newDateTime);
  Future<void> coordinacionUpdateStatus(String postulationID);
  //Metodos de Coordinacion de erick
  Future<List<PostulationModel>> getPostulationsStatusAA();
  Future<void> confirmPostulation(String postulationID, String status);
}

class PostulationRemoteDatasourceImpl extends PostulationRemoteDatasource {
  final CollectionReference<PostulationModel> postulationFirestoreRef =
      FirebaseFirestore.instance
          .collection('Postulations')
          .withConverter<PostulationModel>(
              fromFirestore: (snapshot, options) =>
                  PostulationModel.fromJson(snapshot.data()!, snapshot.id),
              toFirestore: (postulation, options) => postulation.toJson());

  @override
  Future<String> createPostulations(PostulationModel postulation) async {
    DocumentReference docRef = await postulationFirestoreRef.add(postulation);
    return docRef.id;
  }

  @override
  Future<PostulationModel> getPostulationByID(String postulatioID) async {
    final postulationDoc =
        await postulationFirestoreRef.doc(postulatioID).get();
    final postulation = postulationDoc.data();

    await Future.delayed(const Duration(seconds: 4));
    return postulation!;
  }

  @override
  Future<List<PostulationModel>> getPostulations() async {
    final psotulationDocs = await postulationFirestoreRef.get();

    final potulations = psotulationDocs.docs.map((e) {
      return e.data();
    });

    final listPostulations = potulations.toList();

    listPostulations.sort((a, b) {
      DateTime dateA = a.interview_date;
      DateTime dateB = b.interview_date;
      return dateA.compareTo(dateB);
    });

    await Future.delayed(const Duration(seconds: 4));
    return listPostulations;
  }

  @override
  Future<List<PostulationModel>> getPostulationsAfterDate(DateTime date) async {
    final psotulationDocs = await postulationFirestoreRef.get();

    final potulations = psotulationDocs.docs.map((e) {
      return e.data();
    });

    final listPostulations = potulations.toList();

    final pendingPostulations = listPostulations.where((postulation) {
      return postulation.interview_date.isAfter(date);
    }).toList();

    await Future.delayed(const Duration(seconds: 4));
    return pendingPostulations.reversed.toList();
  }

  @override
  Future<void> updatePostulationStatus(
      String postulatioID, String status) async {
    final postulationDoc = postulationFirestoreRef.doc(postulatioID);
    await postulationDoc.update({'status': status});
  }

  @override
  Future<void> deletePostulation(String postulatioID) async {
    final postulationDoc = postulationFirestoreRef.doc(postulatioID);
    await postulationDoc.delete();
  }

  Future<void> updateInterviewDateTime(
      String postulationId, DateTime newDateTime, String newTime) async {
    try {
      await FirebaseFirestore.instance
          .collection('Postulations')
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

  @override
  Future<bool> buscarStudentCi(String studentCi) async {
    try {
      QuerySnapshot<Map<String, dynamic>> docs = await FirebaseFirestore
          .instance
          .collection('Person')
          .where('ci', isEqualTo: studentCi)
          .get();
      return docs.docs.isNotEmpty;
    } catch (e) {
      print("Error al buscar student_ci: $e");
      return false;
    }
  }

  //psico
  Future<void> updatePostulation(
      String postulationID, Map<String, dynamic> updatedFields) async {
    try {
      final postulationDoc = postulationFirestoreRef.doc(postulationID);
      await postulationDoc.update(updatedFields);
    } catch (e) {
      throw Exception('Error updating postulation: $e');
    }
  }

// Método para actualizar solo la fecha de la entrevista en Coordinación
  @override
  Future<void> coordinacionUpdateInterviewDate(
      String postulationID, DateTime newDateTime) async {
    try {
      final postulationDoc = postulationFirestoreRef.doc(postulationID);
      await postulationDoc.update(
          {'fechaEntrevistaCoordinacion': Timestamp.fromDate(newDateTime)});
    } catch (e) {
      throw Exception(
          'Error al actualizar la fecha de entrevista en Coordinación: $e');
    }
  }

  // Método para actualizar el estado general y visto bueno en Coordinación
  @override
  Future<void> coordinacionUpdateStatus(String postulationID) async {
    try {
      final postulationDoc = postulationFirestoreRef.doc(postulationID);
      await postulationDoc.update({
        'estadoGeneral': 'Administracion',
        'vistoBuenoCoordinacion': 'Confirmado'
      });
    } catch (e) {
      throw Exception('Error al actualizar los estados en Coordinación: $e');
    }
  }

  // Metodos
  @override
  Future<List<PostulationModel>> getPostulationsStatusAA() async {
    final querySnapshot = await postulationFirestoreRef
        .where('estadoGeneral', isEqualTo: 'admin')
        .where('estadoConfirmacionAdmin',
            whereIn: ['Confirmado', 'pendiente', 'Aprobado']).get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<void> confirmPostulation(String? postulationID, String status) async {
    final postulationDoc = postulationFirestoreRef.doc(postulationID);
    await postulationDoc.update({'estadoConfirmacionAdmin': status});
  }

  Future<void> insertReasonMissAppointment(
      String postulationID, String reason) async {
    try {
      await postulationFirestoreRef
          .doc(postulationID)
          .update({'reasonMissAppointment': reason});
    } catch (e) {
      // Manejo de errores aquí
      throw Exception('Error al insertar la razón de la cita perdida: $e');
    }
  }

  Future<void> updateFechaHoraEntrevistaAdmin(
      String postulationID, DateTime nuevaFecha, String nuevaHora) async {
    try {
      final postulationDoc = postulationFirestoreRef.doc(postulationID);
      await postulationDoc.update({
        'fechaEntrevistaAdministracion': Timestamp.fromDate(nuevaFecha),
        'horaEntrevistaAdministracion': nuevaHora,
      });
    } catch (e) {
      throw Exception(
          'Error al actualizar la fecha y hora de la entrevista de administración: $e');
    }
  }

//confirmar
  Future<void> updateEstadoConfirmacionAdmin(
      String postulationID, String nuevoEstado) async {
    try {
      final postulationDoc = postulationFirestoreRef.doc(postulationID);
      await postulationDoc.update({'estadoConfirmacionAdmin': nuevoEstado});
    } catch (e) {
      throw Exception(
          'Error al actualizar el estado de confirmación admin: $e');
    }
  }
  Future<void> updatePostulationAdminFields(
    String postulationID, String nuevoEstado, String nuevaAdministracion, String nuevaRecepcionDocumentos) async {
  try {
    final postulationDoc = postulationFirestoreRef.doc(postulationID);
    await postulationDoc.update({
      'estadoConfirmacionAdmin': nuevoEstado,
      'administracion': nuevaAdministracion,
      'recepcionDocumentos': nuevaRecepcionDocumentos,
    });
  } catch (e) {
    throw Exception(
        'Error al actualizar los campos de postulación admin: $e');
  }
}


// update co
  Future<void> insertReasonReschedule(
      String postulationID, String reason) async {
    try {
      await postulationFirestoreRef
          .doc(postulationID)
          .update({'reasonRescheduleAppointment': reason});
    } catch (e) {
      // Manejo de errores aquí
      throw Exception(
          'Error al insertar la razón de reprogramación de la cita: $e');
    }
  }

  Future<void> updateVolverCoord(String postulationID) async {
    try {
      final postulationDoc = postulationFirestoreRef.doc(postulationID);
      await postulationDoc.update({
        'estadoGeneral': 'Coordinacion',
        'vistoBuenoCoordinacion': 'Pendiente',
        'estadoConfirmacionAdmin': 'pendiente',
      });
    } catch (e) {
      throw Exception('Error al actualizar los estados en la postulación: $e');
    }
  }
}
