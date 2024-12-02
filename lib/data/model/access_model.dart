import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';

class AccessModel {
  String? id;

  String acess;
  String reference;

  AccessModel({this.id, required this.acess, required this.reference});

  factory AccessModel.fromJson(Map<String, dynamic> json, String id) {
    return AccessModel(
      id: id,
      acess: json['access'] ?? '',
      reference: json['reference'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'access': acess,
      'reference': reference,
    };
  }
}
