import 'package:cloud_firestore/cloud_firestore.dart';

/*
Modelo con las variables y mapeo necesario para llevarlo a firebase
*/
class ReportModel {
  String? id;
  String fullname;
  DateTime interview_date;
  String interview_hour;
  DateTime interview_date_coord;
  String interview_hour_coord;
  String ci;
  String email;
  DateTime birth_day;
  String cronological_age;
  String familiar_details;
  String mother_info;
  String father_info;
  String brothers_info;
  String emotion_cog_info;
  String final_tip;
  String observations;
  String ref_cellphone;
  String grade;
  String level;
  String status_report;
  final String estadoConfirmado;

  ReportModel({
    this.id,
    required this.fullname,
    required this.interview_date,
    required this.interview_hour,
    required this.interview_date_coord,
    required this.interview_hour_coord,
    required this.ci,
    required this.email,
    required this.birth_day,
    required this.cronological_age,
    required this.familiar_details,
    required this.mother_info,
    required this.father_info,
    required this.brothers_info,
    required this.emotion_cog_info,
    required this.final_tip,
    required this.observations,
    required this.ref_cellphone,
    required this.grade,
    required this.level,
    required this.status_report,
    this.estadoConfirmado = 'Pendiente'
  });

  factory ReportModel.fromJson(Map<String, dynamic> json, String id) {
    return ReportModel(
      id: id,
      fullname: json['fullname'] as String,
      interview_date: (json['interview_date'] as Timestamp).toDate(),
      interview_hour: json['interview_hour'] as String,
      interview_date_coord: (json['interview_date_coord'] as Timestamp).toDate(),
      interview_hour_coord: json['interview_hour_coord'] as String,
      ci: json['ci'] as String,
      email: json ['email'] as String,
      birth_day: (json['birth_day'] as Timestamp).toDate(),
      cronological_age: json['cronological_age'] as String,
      familiar_details: json['familiar_details'] as String,
      mother_info: json['mother_info'] as String,
      father_info: json['father_info'] as String,
      brothers_info: json['brothers_info'] as String,
      emotion_cog_info: json['emotion_cog_info'] as String,
      final_tip: json['final_tip'] as String,
      observations: json['observations'] as String,
      ref_cellphone: json['ref_cellphone'] as String,
      grade: json['grade'] as String,
      level: json['level'] as String,
      status_report: json['status_report'] as String,
       estadoConfirmado: json['estadoConfirmado'] ?? 'pendiente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fullname': fullname,
      'interview_date': Timestamp.fromDate(interview_date),
      'interview_hour': interview_hour,
      'interview_date_coord': Timestamp.fromDate(interview_date_coord),
      'interview_hour_coord': interview_hour_coord,
      'ci': ci,
      'email': email,
      'birth_day': Timestamp.fromDate(birth_day),
      'cronological_age': cronological_age,
      'familiar_details': familiar_details,
      'mother_info': mother_info,
      'father_info': father_info,     
      'brothers_info': brothers_info,
      'emotion_cog_info': emotion_cog_info,
      'final_tip': final_tip,
      'observations': observations,
      'ref_cellphone': ref_cellphone,
      'grade': grade,
      'level': level,
      'status_report': status_report,
       'estadoConfirmado': estadoConfirmado,
    };
  }
}
