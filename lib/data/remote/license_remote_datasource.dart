
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/License_model.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/storage_remote_datasource.dart';

abstract class LicenseRemoteDatasource{
  Future <List<LicenseModel>> getLicenses();
  Future <String> addLicense(PersonaModel user, String reason,  Uint8List data, String fileName, String license_date, String departure_time, String return_time, String status, String user_id, DateTime register_date);
  Future <List<LicenseModel>> getLicensesByStudentID(String user_id);
  Future <LicenseModel> getLicenseByID(String id);
  Future <void> updateLicenseStatus(String id, String status);

}


class LicenseRemoteDatasourceImpl extends LicenseRemoteDatasource {
  final CollectionReference<LicenseModel> licenseFirestoreRef =FirebaseFirestore.instance.collection('Licenses').withConverter<LicenseModel>(fromFirestore: (snapshot, options) =>LicenseModel.fromJson(snapshot.data()!,snapshot.id),toFirestore: (license, options) => license.toJson());
  StorageRemoteDatasourceImpl storage = StorageRemoteDatasourceImpl();

  @override
  Future<String> addLicense(PersonaModel user, String reason, Uint8List? data, String fileName, String license_date, String departure_time, 
                          String return_time, String status, String user_id, DateTime register_date) async {
    String justification = ''; 
    //Subiendo la imagen de justificación a Firebase
    if (fileName != '') {
      justification = await storage.uploadFile(data!, fileName, 'Licenses');
    }   

    final license= LicenseModel(user: user, reason: reason,justification: justification, license_date: license_date, 
                              departure_time:departure_time, return_time:return_time, status:status, user_id:user_id, 
                              register_date:register_date);

    //Creando un nuevo documento
    DocumentReference docRef = await licenseFirestoreRef.add(license);

    // Retornando el ID del documento creado
    return docRef.id;
  }  

  @override
  Future<List<LicenseModel>> getLicenses() async {
    final licensesDocs = await licenseFirestoreRef.get();

    final licenses = licensesDocs.docs.map((e) {
      return e.data();
    });

    final listLicenses=licenses.toList();

    final activeLicenses = listLicenses.where((license) {
      return license.status == 'ACTIVE';
    }).toList();

    activeLicenses.sort((a, b) {
      DateFormat inputFormat = DateFormat("MMM d, yyyy", "en_US");
      DateTime dateA = inputFormat.parse(a.license_date);
      DateTime dateB = inputFormat.parse(b.license_date);
      return dateA.compareTo(dateB);
    });

    await Future.delayed(const Duration(seconds: 4));
    return activeLicenses;
  }
  
  @override
  Future<LicenseModel> getLicenseByID(String id) async {
    final licenseDoc = await licenseFirestoreRef.doc(id).get();
    final license = licenseDoc.data();
    
    await Future.delayed(const Duration(seconds: 4));
    return license!;
  }
  
  @override
  Future<List<LicenseModel>> getLicensesByStudentID(String user_id) async {
    final licensesDocs=await licenseFirestoreRef.where('user.id', isEqualTo: user_id).get();
    final licenses= licensesDocs.docs.map((e) {
      return e.data();
    });
    final listLicenses=licenses.toList();

    final activeLicenses = listLicenses.where((license) {
      return license.status == 'ACTIVE';
    }).toList();

    activeLicenses.sort((a, b) {
      DateFormat inputFormat = DateFormat("MMM d, yyyy", "en_US");
      DateTime dateA = inputFormat.parse(a.license_date);
      DateTime dateB = inputFormat.parse(b.license_date);
      return dateA.compareTo(dateB);
    });

    await Future.delayed(const Duration(seconds: 4));
    return activeLicenses.reversed.toList();
  }
  
  @override
  Future<void> updateLicenseStatus(String id, String status) async {
    final docRef = licenseFirestoreRef.doc(id);
      
      // Actualizando el documento
    await docRef.update({'status': status});
  }
}