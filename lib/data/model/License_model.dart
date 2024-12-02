import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';

class LicenseModel {
  String? id;
  PersonaModel? user;
  String reason;
  String justification;
  String license_date;
  String departure_time;
  String return_time;
  String status;
  String user_id;
  DateTime register_date;

  LicenseModel({this.id, this.user, required this.reason, required this.justification, required this.license_date,
              required this.departure_time, required this.return_time, required this.status, required this.user_id, required this.register_date});
  

  factory LicenseModel.fromJson(Map<String, dynamic> json, String id) {
    return LicenseModel(
      id: id,
      user: PersonaModel.fromJson(json['user'] ?? {}),
      reason: json['reason'] ?? '',
      justification: json['justification'] ?? '',
      license_date: json['license_date'] ?? '',
      departure_time: json['departure_time'] ?? '',
      return_time: json['return_time'] ?? '',
      status: json['status'] ?? '',
      user_id: json['user_id'] ?? '',
      register_date: (json['register_date'] as Timestamp? ?? Timestamp.fromDate(DateTime.now())).toDate()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'user': user!.toJson(),
      'reason': reason,
      'justification': justification,
      'license_date': license_date,
      'departure_time': departure_time,
      'return_time': return_time,
      'status': status,
      'user_id': user_id,
      'register_date': register_date,
    };
  }
}
