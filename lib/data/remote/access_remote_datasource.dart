import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pr_h23_irlandes_web/data/model/access_model.dart';

abstract class AccessRemoteDataSource {
  Future<AccessModel?> getAccessByReference(String reference);
  Future<void> updateAccess(String reference, String acess);

  Future<void> createAccess(AccessModel accessModel);
}

class AccessRemoteDataSourceImpl extends AccessRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference<AccessModel> accessFirestoreRef = FirebaseFirestore
      .instance
      .collection('AdminViewAccess')
      .withConverter<AccessModel>(
      fromFirestore: (snapshot, options) =>
          AccessModel.fromJson(snapshot.data()!, snapshot.id),
      toFirestore: (access, options) => access.toJson());

  @override
  Future<AccessModel?> getAccessByReference(String reference) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('AdminViewAccess')
          .where('reference', isEqualTo: reference)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        return AccessModel.fromJson(doc.data(), doc.id);
      } else {
        print("No se encontró ningún acceso con esa referencia.");
        return null;
      }
    } catch (e) {
      print("Error al obtener acceso por referencia: $e");
      return null;
    }
  }
 /*
  @override
  Future<void> updateAccess(String reference, String acess) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('AdminViewAccess')
          .where('reference', isEqualTo: reference)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;

        // Actualiza solo el campo 'acess'
        await accessFirestoreRef.doc(doc.id).update({'access': acess});
        print("Acceso actualizado con éxito.");
      } else {
        print("No se encontró ningún acceso con la referencia proporcionada.");
      }
    } catch (e) {
      print("Error al actualizar acceso: $e");
    }
  }
*/
  @override
  Future<void> createAccess(AccessModel accessModel) async {
    try {
      await _firestore.collection('AdminViewAccess').add(accessModel.toJson());
    } catch (e) {
      print("Error al crear acceso: $e");
    }
  }

  @override
  Future<void> updateAccess(String reference, String acess) async {
    try {
      // Buscar documento con el campo 'reference' que coincida con la referencia dada
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('AdminViewAccess')
          .where('reference', isEqualTo: reference)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Si se encuentra el documento, se actualiza el campo 'access'
        var doc = querySnapshot.docs.first;
        await accessFirestoreRef.doc(doc.id).update({'access': acess});
        print("Acceso actualizado con éxito.");
      } else {
        // Si no se encuentra, se crea un nuevo registro
        print("No se encontró ningún acceso con la referencia proporcionada. Creando nuevo acceso...");

        // Crear un nuevo modelo de acceso con la referencia y el valor de 'access'
        AccessModel newAccess = AccessModel(
          acess: acess,
          reference: reference,
          // Asegúrate de incluir otros campos si tu modelo tiene más atributos
        );

        // Agregar el nuevo acceso a la colección
        await createAccess(newAccess);
        print("Nuevo acceso creado con éxito.");
      }
    } catch (e) {
      print("Error al actualizar o crear acceso: $e");
    }
  }

}
